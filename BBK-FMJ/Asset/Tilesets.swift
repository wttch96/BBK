//
//  Tilesets.swift
//  BBK-FMJ
//
//  Created by Wttch on 2024/7/14.
//

import Foundation
import SpriteKit

class Tilesets {
    static let tileset1 = SKTileSet(tileGroups: [
        loadTile(type: 1, index: 1)!,
        loadBlob(type: 1, index: 38)!,
        loadTile(type: 1, index: 50)!,
        loadTile(type: 1, index: 51)!,
        loadTile(type: 1, index: 52)!,
        loadTile(type: 1, index: 53)!,
        loadTile(type: 1, index: 54)!,
        loadTile(type: 1, index: 55)!,
        loadTile(type: 1, index: 56)!,
        loadTile(type: 1, index: 58)!,
        loadTile(type: 1, index: 59)!,
        loadTile(type: 1, index: 67)!,
        loadTile(type: 1, index: 68)!,
    ])
    
    static let tileset2 = SKTileSet(tileGroups: [
        loadBlob(type: 2, index: 1)!,
        loadTiles(type: 2, index: 15, count: 4)!,
        loadTile(type: 2, index: 16)!,
        loadTiles(type: 2, index: 17, count: 4)!,
    ])

    static func loadTile(type: Int, index: Int, size: Int = 32) -> SKTileGroup? {
        // 加载图片
        guard let nsImage = NSImage(named: tilesetPrefix(type: type, index: index)) else { return nil }

        let tileGroup = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(image: nsImage)))
        tileGroup.name = "\(index)"
        return tileGroup
    }

    static func loadTiles(type: Int, index: Int, count: Int, size: Int = 32) -> SKTileGroup? {
        var images: [NSImage] = []
        let files = (1 ... count).map { "\(tilesetPrefix(type: type, index: index))/\($0)" }
        for file in files {
            if let image = NSImage(named: file) {
                images.append(image)
            }
        }
        let rules: [SKTileDefinition] = images.map { SKTileDefinition(texture: SKTexture(image: $0)) }
        let tileGroup = SKTileGroup(rules: [SKTileGroupRule(adjacency: SKTileAdjacencyMask(), tileDefinitions: rules)])
        tileGroup.name = "\(index)"
        return tileGroup
    }

    static func loadBlob(type: Int, index: Int, size: Int = 32, frames: Int = 1) -> SKTileGroup? {
        // 加载图片
        guard let nsImage = NSImage(named: tilesetPrefix(type: type, index: index)) else { return nil }
        var rect = CGRect(origin: .zero, size: nsImage.size)
        guard let image = nsImage.cgImage(forProposedRect: &rect, context: nil, hints: nil) else { return nil }

        var images: [CGImage] = []
        for i in 0 ..< frames {
            guard let subImage = image.cropping(to: CGRect(x: size * i, y: 0, width: size * 2, height: size * 3)) else { return nil }
            images.append(subImage)
        }

        let croppings = BlobCroppings(images: images, size: CGFloat(size))

        let tileGroup = croppings.croppings.toTileGroup()
        tileGroup.name = "\(index)"
        return tileGroup
    }

    private static func tilesetPrefix(type: Int, index: Int) -> String {
        "Tileset/\(type)/\(index)"
    }
}
