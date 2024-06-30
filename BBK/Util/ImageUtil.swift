//
//  ImageUtil.swift
//  BBK
//
//  Created by Wttch on 2024/6/17.
//

import Foundation
import CoreGraphics

extension Array where Element == Array<CGImage> {
    func combine(imageWidth: Int, imageHeight: Int) -> CGImage? {
        guard let colCount = self.first?.count else { return nil }
        let images = self.flatMap({ $0 })
        return images.combine(imageWidth: imageWidth, imageHeight: imageHeight, columnCount: colCount)
    }
}

extension Array where Element == CGImage {
    
    func combine(imageWidth: Int, imageHeight: Int, columnCount: Int) -> CGImage? {
        guard let firstImage = self.first else { return nil }
        
        let rowCount = self.count / columnCount + (self.count % columnCount == 0 ? 0 : 1)
        
        let combinedWidth = columnCount * imageWidth
        let combinedHeight = rowCount * imageHeight
        
        
        // 创建一个画布
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: combinedWidth,
            height: combinedHeight,
            bitsPerComponent: firstImage.bitsPerComponent,
            bytesPerRow: firstImage.bytesPerRow * columnCount,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        // context?.setFillColor(.white)
        // context?.fill([CGRect(origin: .zero, size: CGSize(width: combinedWidth, height: combinedHeight))])
        
        // 绘制每个图像到组合图像上
        for (index, image) in self.enumerated() {
            let col = index % columnCount
            let row = index / columnCount
            let xPosition = col * imageWidth
            // CGImage 绘制应该是从左下到右上
            let yPosition = (rowCount - 1 - row) * imageHeight
            context?.draw(image, in: CGRect(x: xPosition, y: yPosition, width: imageWidth, height: imageHeight))
        }
        
        // 从上下文中获取组合后的图像
        return context?.makeImage()
    }
}
