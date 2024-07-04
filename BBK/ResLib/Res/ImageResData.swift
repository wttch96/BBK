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
    /// 单张图片宽度
    let width: Int
    /// 单张图片高度
    let height: Int
    /// 图片数量
    let number: Int
    /// 是否透明
    let transparent: Bool
    /// 图片集
    private(set) var images: [CGImage] = []
}

extension ImageResData {
    init(_ data: Data) {
        // type 0
        // index 1
        self.width = Int(data[2])
        self.height = Int(data[3])
        self.number = Int(data[4])
        self.transparent = data[5] == 2
        
        loadImages(imageData: Data(data[6..<6 + imageDataLength]))
    }
    
    /// 加载图片
    private mutating func loadImages(imageData: Data) {
        images = []
        for i in 0..<number {
            // 像素数组
            var pixels: [UInt32] = []
            let offset = i * height * lineBytes
            for h in 0..<height {
                // 处理每一行数据
                let start = offset + h * lineBytes
                let lineData = imageData.subdata(in: start..<start + lineBytes)
                // 像素
                let linePixel: [UInt32] = lineData.flatMap { byte in
                    if transparent {
                        // 透明 1byte 4个像素点
                        var linePixel: [UInt32] = []
                        for i in 0..<4 {
                            // 四个像素
                            if (byte << (i * 2) & 0x80) != 0 {
                                linePixel.append(0x00000000)
                            } else {
                                linePixel.append(((byte << (i * 2 + 1)) & 0x80) != 0 ? 0xFF000000 : 0xFFFFFFFF)
                            }
                        }
                        return linePixel
                    } else {
                        // 不透明 1byte 8个像素点// byte 处理
                        return (0..<8).map { ((byte << $0) & 0x80) != 0 ? 0xFF000000 : 0xFFFFFFFF }
                    }
                }
                pixels.append(contentsOf: linePixel[0..<width])
            }
            if let image = imageFromARGB32Bitmap(pixels: pixels, width: width, height: height) {
                images.append(image)
            }
        }
    }
    
    /// 每个像素所使用的数据字节数
    /// 如果有透明数据则2个字节，否则1个字节
    private var bytesPerPixel: Int { transparent ? 2 : 1 }
    
    // 每一行需要的 byte 个数
    private var lineBytes: Int { Int(ceil(Float(width) / 8)) * bytesPerPixel }
    
    // 图片数据总长度, 如果包含长宽等信息 需要再加 6
    var imageDataLength: Int {
        return number * Int(ceil(Float(width) / 8)) * height * bytesPerPixel
    }
    
    // 计算变量一定要快
    var image: CGImage? {
        return images.combine(imageWidth: width, imageHeight: height, columnCount: 10)
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
