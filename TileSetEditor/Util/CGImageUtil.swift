//
//  CGImageUtil.swift
//  TileSetEditor
//
//  Created by Wttch on 2024/7/11.
//

import AppKit
import CoreGraphics
import Foundation

extension CGImage {
    func savePNG(to url: URL) -> Bool {
        // 1. 创建一个 NSBitmapImageRep
        let bitmapImageRep = NSBitmapImageRep(cgImage: self)
        
        // 2. 获取 PNG 数据
        guard let pngData = bitmapImageRep.representation(using: .png, properties: [:]) else {
            print("Failed to create PNG data")
            return false
        }
        
        // 3. 写入文件
        do {
            try pngData.write(to: url)
            print("PNG file saved successfully at \(url.path)")
            return true
        } catch {
            print("Failed to save PNG file: \(error)")
            return false
        }
    }
    
    func resize(_ size: CGFloat) -> CGImage? {
        return resize(width: size, height: size)
    }
    
    func resize(width: CGFloat, height: CGFloat) -> CGImage? {
        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: Int(width * 4),
            space: colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        
        // 插值质量
        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return context.makeImage()
    }
}
