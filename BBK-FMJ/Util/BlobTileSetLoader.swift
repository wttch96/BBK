//
//  BlobLoader.swift
//  BBK-FMJ
//
//  Created by Wttch on 2024/7/14.
//

import AppKit
import Foundation
import SpriteKit

class BlobTileSetLoader {
    static func load(name: String, size: Int, frames: Int = 1) -> SKTileGroup? {
        // 加载图片
        guard let nsImage = NSImage(named: name) else { return nil }
        var rect = CGRect(origin: .zero, size: nsImage.size)
        guard let image = nsImage.cgImage(forProposedRect: &rect, context: nil, hints: nil) else { return nil }

        var images: [CGImage] = []
        for i in 0 ..< frames {
            guard let subImage = image.cropping(to: CGRect(x: size * i, y: 0, width: size * 2, height: size * 3)) else { return nil }
            images.append(subImage)
        }

        let croppings = BlobCroppings(images: images, size: CGFloat(size))

        let tileGroup = croppings.croppings.toTileGroup()
        tileGroup.name = "1"
        return tileGroup
    }
}
