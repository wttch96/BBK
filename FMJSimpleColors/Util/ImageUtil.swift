//
//  ImageUtil.swift
//  FMJ
//
//  Created by Wttch on 2025/1/2.
//

import AppKit
import CoreGraphics
import Foundation

// MARK: CGImage

extension CGImage {
    /// 将 image 按照 png9 格式转换为新的图片
    /// - Parameters:
    ///  - size: 新图片的大小
    ///  - edgeInsets: 图片的边缘
    func png9(size: CGSize, edgeInsets: NSEdgeInsets) -> CGImage? {
        let image = self
        let left = edgeInsets.left
        let right = edgeInsets.right
        let top = edgeInsets.top
        let bottom = edgeInsets.bottom
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: image.bitmapInfo.rawValue
        )
        
        let topLeft = image.cropping(to: CGRect(x: 0, y: 0, width: left, height: top))
        context?.draw(topLeft!, in: CGRect(x: 0, y: size.height - top, width: left, height: top))
        
        let topCenter = image.cropping(to: CGRect(x: left, y: 0, width: CGFloat(image.width) - left - right, height: top))
        context?.draw(topCenter!, in: CGRect(x: left, y: size.height - top, width: size.width - left - right, height: top))
        
        let topRight = image.cropping(to: CGRect(x: CGFloat(image.width) - right, y: 0, width: right, height: top))
        context?.draw(topRight!, in: CGRect(x: size.width - right, y: size.height - top, width: right, height: top))
        
        let leftCenter = image.cropping(to: CGRect(x: 0, y: top, width: left, height: CGFloat(image.height) - top - bottom))
        context?.draw(leftCenter!, in: CGRect(x: 0, y: bottom, width: left, height: size.height - top - bottom))
        
        let center = image.cropping(to: CGRect(x: left, y: top, width: CGFloat(image.width) - left - right, height: CGFloat(image.height) - top - bottom))
        context?.draw(center!, in: CGRect(x: left, y: bottom, width: size.width - left - right, height: size.height - top - bottom))
        
        let rightCenter = image.cropping(to: CGRect(x: CGFloat(image.width) - right, y: top, width: right, height: CGFloat(image.height) - top - bottom))
        context?.draw(rightCenter!, in: CGRect(x: size.width - right, y: bottom, width: right, height: size.height - top - bottom))
        
        let bottomLeft = image.cropping(to: CGRect(x: 0, y: CGFloat(image.height) - bottom, width: left, height: bottom))
        context?.draw(bottomLeft!, in: CGRect(x: 0, y: 0, width: left, height: bottom))
        
        let bottomCenter = image.cropping(to: CGRect(x: left, y: CGFloat(image.height) - bottom, width: CGFloat(image.width) - left - right, height: bottom))
        context?.draw(bottomCenter!, in: CGRect(x: left, y: 0, width: size.width - left - right, height: bottom))
        
        let bottomRight = image.cropping(to: CGRect(x: CGFloat(image.width) - right, y: CGFloat(image.height) - bottom, width: right, height: bottom))
        context?.draw(bottomRight!, in: CGRect(x: size.width - right, y: 0, width: right, height: bottom))
        
        return context?.makeImage()
    }
}

// MARK: ImageResource

extension ImageResource {
    /// 读取图片资源, CGImage 格式
    var cgImage: CGImage? {
        guard let image = NSImage(resource: self).cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        return image
    }
}
