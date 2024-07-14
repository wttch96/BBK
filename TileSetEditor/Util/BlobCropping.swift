//
//  BlobCorpping.swift
//  TileSetEditor
//
//  Created by Wttch on 2024/7/11.
//

import CoreImage
import Foundation
import SpriteKit

/// RPGMaker 的图片切割
/// 处理图片的格式为 2 * 3  大格子。
///
/// 将源图片处理为 4 * 6 = 24 个小格子，目的图片处理为 2 * 2 = 4 个小格子，在格子之间进行复制。
class BlobCropping {
    public static let examples: [[Int]] = [
        [20, 68, 92, 112, 28, 124, 116, 80],
        [21, 84, 87, 221, 127, 255, 241, 17],
        [29, 117, 85, 95, 247, 215, 209, 1],
        [23, 213, 81, 31, 253, 125, 113, 16],
        [5, 69, 93, 119, 223, 255, 245, 65],
        [0, 4, 71, 193, 7, 199, 197, 64],
    ]
    
    /// 要切割的图片
    let image: CGImage
    /// 每一个格子的大小
    let size: CGFloat
    /// 4 * 6 = 24 个小的子图片
    let subImages: [CGImage?]
    
    init(image: CGImage, size: CGFloat = 32) {
        self.image = image
        self.size = size
        
        var subImages: [CGImage?] = []
        let size = CGFloat(size)
        for y in 0 ..< 6 {
            for x in 0 ..< 4 {
                subImages.append(image.cropping(to: CGRect(x: CGFloat(x) * 0.5 * size, y: CGFloat(y) * 0.5 * size, width: 0.5 * size, height: 0.5 * size)))
            }
        }
        self.subImages = subImages
    }
    
    /// 生成一个 size * size 的图片
    /// - Parameter generator: 图片生成器，对 CGContext 操作以绘制图片
    /// - Returns: 绘制的图片结果，可能为 nil
    private func createImage(_ generator: (CGContext) -> Void) -> CGImage? {
        guard let context = CGContext(
            data: nil, width: Int(size), height: Int(size),
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: image.bitsPerComponent * Int(size),
            space: image.colorSpace!,
            bitmapInfo: image.bitmapInfo.rawValue
        )
        else {
            return nil
        }
        
        generator(context)
        
        return context.makeImage()
    }
    
    // 00, 01, 02, 03
    // 04, 05, 06, 07
    // 08, 09, 10, 11
    // 12, 13, 14, 15
    // 16, 17, 18, 19
    // 20, 21, 22, 23
    
    // http://www.boristhebrave.com/permanent/24/06/cr31/stagecast/wang/blob.html
    static let adjacencies: [Int: [Int]] = [
        // 000
        // 0*0
        // 000, 四边
        0b00000000: [0, 1, 4, 5],
        // 010
        // 0*0
        // 000, 竖线下端
        0b00000001: [16, 19, 20, 23],
        // 000
        // 0*1
        // 000, 横线左端
        0b00000100: [8, 9, 20, 21],
        // 010
        // 0*1
        // 000, 连接上右
        0b00000101: [16, 3, 20, 21],
        // 011
        // 0*1
        // 000, 左下边
        0b00000111: [16, 17, 20, 21],
        // 000
        // 0*0
        // 010, 竖线上端
        0b00010000: [8, 11, 12, 15],
        // 010
        // 0*0
        // 010, 竖线
        0b00010001: [12, 15, 16, 19],
        // 000
        // 0*1
        // 010, 连接右下
        0b00010100: [8, 9, 12, 7],
        // 010
        // 0*1
        // 010, T-左
        0b00010101: [12, 3, 16, 7],
        // 011
        // 0*1
        // 010,
        0b00010111: [12, 13, 16, 7],
        // 000
        // 0*1
        // 011, 左上边
        0b00011100: [8, 9, 12, 13],
        // 010
        // 0*1
        // 011,
        0b00011101: [12, 3, 16, 17],
        // 011
        // 0*1
        // 011, 左边
        0b00011111: [12, 13, 16, 17],
        
        // 000
        // 1*0
        // 000, 横线右端
        0b01000000: [10, 11, 22, 23],
        // 010
        // 1*0
        // 000, 左上连接
        0b01000001: [2, 19, 22, 23],
        
        // 000
        // 1*1
        // 000, 横线
        0b01000100: [9, 10, 21, 22],
        // 010
        // 1*1
        // 000, T-下
        0b01000101: [2, 3, 21, 22],
        // 011
        // 1*1
        // 000,
        0b01000111: [2, 18, 21, 22],
        // 000
        // 1*0
        // 010, 左下连接
        0b01010000: [10, 11, 6, 15],
        // 010
        // 1*0
        // 010, T-右
        0b01010001: [2, 15, 6, 19],
        // 000
        // 1*1
        // 010, T-上
        0b01010100: [9, 10, 6, 7],
        // 010
        // 1*1
        // 010, cross
        0b01010101: [2, 3, 6, 7],
       
        // 011
        // 1*1
        // 010, ↗️鱼
        0b01010111: [2, 14, 6, 7],
        // 000
        // 1*1
        // 011
        0b01011100: [9, 10, 6, 14],
        // 010
        // 1*1
        // 011, ↘️鱼
        0b01011101: [2, 3, 6, 18],
        // 011
        // 1*1
        // 011, ⬅️由
        0b01011111: [2, 14, 6, 18],
        // 000
        // 1*0
        // 110, 右上边
        0b01110000: [10, 11, 14, 15],
        // 010
        // 1*0
        // 110,
        0b01110001: [2, 15, 18, 19],
        
        // 000
        // 1*1
        // 110,
        0b01110100: [9, 10, 13, 7],
        // 010
        // 1*1
        // 110, ↙️鱼
        0b01110101: [2, 3, 17, 7],
        
        // 011
        // 1*1
        // 110, 右上-左下 对角
        0b01110111: [2, 14, 17, 7],
        
        // 000
        // 1*1
        // 111, 上边
        0b01111100: [9, 10, 13, 14],
        // 010
        // 1*1
        // 111, ⬆️由
        0b01111101: [2, 3, 13, 14],
        // 011
        // 1*1
        // 111, ↖️内角
        0b01111111: [2, 14, 17, 18],
        // 110
        // 1*0
        // 000, 右下边
        0b11000001: [18, 19, 22, 23],
        
        // 110
        // 1*1
        // 000,
        0b11000101: [17, 3, 21, 22],
        
        // 111
        // 1*1
        // 000, 下边
        0b11000111: [17, 18, 21, 22],
        // 110
        // 1*0
        // 010
        0b11010001: [14, 15, 6, 19],
       
        // 110
        // 1*1
        // 010 ↖️鱼
        0b11010101: [13, 3, 6, 7],
        
        // 111
        // 1*1
        // 010, ⬇️由
        0b11010111: [13, 14, 6, 7],
        
        // 110
        // 1*1
        // 011, 左上-右下 对角
        0b11011101: [13, 3, 6, 18],
       
        // 111
        // 1*1
        // 011, 左下内角
        0b11011111: [13, 14, 6, 18],
        
        // 110
        // 1*0
        // 110, 右边
        0b11110001: [14, 15, 18, 19],
        
        // 110
        // 1*1
        // 110, ➡️由
        0b11110101: [13, 3, 17, 7],
        
        // 111
        // 1*1
        // 110, 右下内角
        0b11110111: [13, 14, 17, 7],
        
        // 110
        // 1*1
        // 111, 右上内角
        0b11111101: [13, 3, 17, 18],
        
        // 111
        // 1*1
        // 111,
        0b11111111: [13, 14, 17, 18],
    ]
}

extension BlobCropping {
    func copy(_ index: [Int?]?) -> CGImage? {
        guard let index = index, index.count == 4 else { return nil }
        
        return createImage { ctx in
            for (i, index) in index.enumerated() {
                if let index = index {
                    copy(index, ctx: ctx, dstIndex: i)
                }
            }
        }
    }

    private func copy(_ index: Int, ctx: CGContext, dstIndex: Int) {
        let dstX = dstIndex % 2
        let dstY = 1 - dstIndex / 2
        guard let image = subImages[index] else { return }
        ctx.draw(image, in: CGRect(x: CGFloat(dstX) * size / 2, y: CGFloat(dstY) * size / 2, width: size / 2, height: size / 2))
    }
}

class BlobCroppings {
    let croppings: [BlobCropping]

    init(images: [CGImage], size: CGFloat) {
        self.croppings = images.map { BlobCropping(image: $0, size: size) }
    }
    
    func toTileGroup() -> SKTileGroup {
        return croppings.toTileGroup()
    }
}

private func adjacencyMark(_ adjacency: Int) -> [SKTileAdjacencyMask] {
    let adjacencyMarkMap: [Int: SKTileAdjacencyMask] = [
        0b00000001: .adjacencyUp,
        0b00000010: .adjacencyUpperRight,
        0b00000100: .adjacencyRight,
        0b00001000: .adjacencyLowerRight,
        0b00010000: .adjacencyDown,
        0b00100000: .adjacencyLowerLeft,
        0b01000000: .adjacencyLeft,
        0b10000000: .adjacencyUpperLeft,
    ]
    let marks = adjacencyMarkMap.filter { i, _ in
        i & adjacency == i
    }.map { $1 }
    return marks
}

extension Array where Element == BlobCropping {
    func toTileGroup() -> SKTileGroup {
        var rules: [SKTileGroupRule] = []
        
        let adjacencies = BlobCropping.adjacencies.map { ($0, $1, adjacencyMark($0))}
            .sorted { $0.2.count > $1.2.count }
            .map({ ($0, $1, $2.reduce(SKTileAdjacencyMask(), { $0.union($1) })) })
        for (adjacency, tileIndex, mark) in adjacencies {
            // 所有要处理的 47 个图块
            
            var tileDefinitions: [SKTileDefinition] = []
            for cropping in self {
                // 第 i 帧 & 第 i 帧的裁剪对象
                // 要将这些转换为 tileDefinition
                if let image = cropping.copy(tileIndex) {
                    tileDefinitions.append(
                        SKTileDefinition(texture: SKTexture(cgImage: image))
                    )
                }
            }
            rules.append(SKTileGroupRule(adjacency: mark, tileDefinitions: tileDefinitions))
        }
        
        return SKTileGroup(rules: rules)
    }
}
