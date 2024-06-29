//
//  ImageResData.swift
//  BBK
//
//  Created by Wttch on 2024/6/15.
//

import CoreGraphics
import Foundation

/// 图片集数据。
struct ImageResData: BaseResData {
    let data: Data
    
    // 单张图片宽度
    let width: Int
    // 单张图片高度
    let height: Int
    // 图片数量
    let number: Int
    // 是否透明
    let transparent: Bool
}

extension ImageResData {
    init(_ data: Data) {
        self.data = data
        // type 0
        // index 1
        self.width = Int(data[2])
        self.height = Int(data[3])
        self.number = Int(data[4])
        self.transparent = data[5] == 2
    }
    
    private var bytesPerPixel: Int { transparent ? 2 : 1 }
    
    var length: Int {
        return number * Int(ceil(Float(width) / 8 )) * height * bytesPerPixel
    }
}

class ResImage: ResBase {
    let type: Int
    let index: Int
    
    let width: Int
    let height: Int
    let number: Int
    let transparent: Bool
    
    var images: [CGImage] = []
    var image: CGImage? = nil
    
    let data: ResData
    
    required init(data: ResData) {
        self.data = data
        self.type = Int(data[0])
        self.index = Int(data[1])
        self.width = Int(data[2])
        self.height = Int(data[3])
        self.number = Int(data[4])
        self.transparent = data[5] == 2
        
        createImage()
        self.image = images.combine(imageWidth: width, imageHeight: height, columnCount: 10)
    }
    
    private func createImage() {
        var tmp = [UInt32](repeating: 0, count: width * height)
        
        let len = number * (width / 8 + (width % 8 != 0 ? 1 : 0)) * height * Int(data[5])
        let imageData = Data(data[6..<6 + len])
        
        // 数据索引
        var dataI = 0
        
        for _ in 0..<number {
            // 位数
            var cnt = 0
            // 像素索引
            var tmpI = 0
            for _ in 0..<height {
                for _ in 0..<width {
                    if transparent {
                        if (imageData[dataI] << cnt) & 0x80 != 0 {
                            tmp[tmpI] = 0x00000000
                        } else {
                            tmp[tmpI] = ((Int(imageData[dataI]) << (cnt + 1)) & 0x80) != 0 ? 0xff000000 : 0xffffffff
                        }
                    } else {
                        tmp[tmpI] = ((imageData[dataI] << cnt) & 0x80) != 0 ? 0xff000000 : 0xffffffff
                    }
                    
                    tmpI += 1
                    cnt += (transparent ? 2 : 1)
                    if cnt >= 8 {
                        //
                        cnt = 0
                        dataI += 1
                    }
                }
                if cnt != 0 {
                    cnt = 0
                    dataI += 1
                }
                if transparent {
                    // 对齐
                    print("对齐")
                    if dataI % 2 != 0 { dataI += 1 }
                }
            }
            
            if let image = imageFromARGB32Bitmap(pixels: tmp, width: width, height: height) {
                images.append(image)
            }
        }
    }
    
    private func imageFromARGB32Bitmap(pixels: [UInt32], width: Int, height: Int) -> CGImage? {
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        var data = pixels // Copy to mutable array
        
        let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count * MemoryLayout<UInt32>.size))
        let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * MemoryLayout<UInt32>.size,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        
        return cgim
    }
}
