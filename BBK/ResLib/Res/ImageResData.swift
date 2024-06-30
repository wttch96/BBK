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
        // type 0
        // index 1
        self.width = Int(data[2])
        self.height = Int(data[3])
        self.number = Int(data[4])
        self.transparent = data[5] == 2
        let length = number * Int(ceil(Float(width) / 8 )) * height * Int(data[5])
        
        self.data = data.subdata(in: 0..<6+length)
    }
    
    private var bytesPerPixel: Int { transparent ? 2 : 1 }
    
    // 每一行需要的 byte 个数
    private var lineBytes: Int { Int(ceil(Float(width) / 8)) * bytesPerPixel }
    
    // 图片数据总长度, 如果包含长宽等信息 需要再加 6
    var length: Int {
        return number * Int(ceil(Float(width) / 8 )) * height * bytesPerPixel
    }
    
    var image: CGImage? {
        return images.combine(imageWidth: self.width, imageHeight: self.height, columnCount: 10)
    }
    
    var images: [CGImage] {
        let imageData = Data(data[6..<6 + length])
        var images: [CGImage] = []
        
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
                        return (0..<8).map({ ((byte << $0) & 0x80) != 0 ? 0xFF000000 : 0xFFFFFFFF })
                    }
                }
                pixels.append(contentsOf: linePixel[0..<width])
            }
            if let image = imageFromARGB32Bitmap(pixels: pixels, width: width, height: height) {
                images.append(image)
            }
        }
        
        return images
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
        
        let lineBytes = Int(ceil(Float(width) / 8))
        for _ in 0..<number {
            if transparent {
                // 2byte 8个像素点
                tmp = (0..<height).flatMap({ h in
                    let lineData = imageData.subdata(in: h * lineBytes * 2..<((h+1) * lineBytes * 2))
                    // byte 处理
                    let linePixelData: [UInt32] = lineData.flatMap { byte in
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
                    }
                    return linePixelData[0..<self.width]
                })
            } else {
                // 1byte 8个像素点
                tmp = (0..<height).flatMap({ h in
                    let lineData = imageData.subdata(in: (h * lineBytes)..<((h+1) * lineBytes))
                    // byte 处理
                    let linePixelData: [UInt32] = lineData.flatMap { byte in
                        (0..<8).map({ ((byte << $0) & 0x80) != 0 ? 0xFF000000 : 0xFFFFFFFF })
                    }
                    return linePixelData[0..<self.width]
                })
            }
            
            
            if let image = imageFromARGB32Bitmap(pixels: tmp, width: self.width, height: height) {
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
