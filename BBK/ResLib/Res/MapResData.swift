//
//  ResMap.swift
//  BBK
//
//  Created by Wttch on 2024/6/17.
//

import CoreGraphics
import Foundation


/// 地图的数据信息
struct MapResData: BaseResData {
    private let type: Int
    private let index: Int
    
    /// 使用的图块资源的索引号
    let tileIndex: Int
    /// 地图名
    let name: String
    /// 地图宽度
    let width: Int
    /// 地图高度
    let height: Int
    /// 图块索引号
    let tiles: [[Int]]
    /// 是否可以通行
    let walkable: [[Bool]]
    /// 事件号，如果不为零表示该地方有事件
    let eventIds: [[Int]]
    
    init(_ data: Data) {
        self.type = data.uint8(start: 0)
        self.index = data.uint8(start: 1)
        self.tileIndex = data.uint8(start: 2)
        self.name = data.string(start: 3)
        self.width = data.uint8(start: 0x10)
        self.height = data.uint8(start: 0x11)
        
        var tiles = Array(height, width, value: 0)
        var walkable = Array(height, width, value: false)
        var eventIds = Array(height, width, value: 0)
        for y in 0 ..< height {
            for x in 0 ..< width {
                let offset = 0x12 + (y * width + x) * 2
                // 地图数据 两个字节表示一个地图块（从左到右，从上到下） （低字节：最高位1表示可行走，0不可行走。高字节：事件号）
                // 先是是否可以行走和图块索引，然后是事件号
                tiles[y][x] = Int(data[offset] & 0x7F)
                walkable[y][x] = (data[offset] & 0x80) != 0
                eventIds[y][x] = data.uint8(start: offset + 1)
            }
        }
        
        self.tiles = tiles
        self.walkable = walkable
        self.eventIds = eventIds
    }
}

extension MapResData {
    func canWalk(x: Int, y: Int) -> Bool {
        guard x >= 0, x < width, y >= 0, y < height else { return false }
        return walkable[y][x]
    }
    
    func getTileIndex(x: Int, y: Int) -> Int {
        guard x >= 0, x < width, y >= 0, y < height else { return 0 }
        return tiles[y][x]
    }
    
    func getEventId(x: Int, y: Int) -> Int {
        guard x >= 0, x < width, y >= 0, y < height else { return -1 }
        return eventIds[y][x]
    }
    
    /// 获取地图的实际数据
    /// - Returns: 地图大图
    func loadMapImage() -> CGImage? {
        var images: [[CGImage]] = []
        for y in 0..<height {
            var lineImages: [CGImage] = []
            for x in 0..<width {
                if let image = DatLib.shared.getImage(resType: .til, type: 1, index: tileIndex)?.images[getTileIndex(x: x, y: y)] {
                    lineImages.append(image)
                }
            }
            images.append(lineImages)
        }
        return images.combine(imageWidth: 16, imageHeight: 16)
    }
}


extension MapResData: Equatable {
    static func ==(lhs: MapResData, rhs: MapResData) -> Bool {
        return lhs.type == rhs.type && lhs.index == rhs.index
    }
}
