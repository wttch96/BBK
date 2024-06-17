//
//  ResMap.swift
//  BBK
//
//  Created by Wttch on 2024/6/17.
//

import Foundation
import CoreGraphics


class ResMap: ResBase {
    
    let type: Int
    let index: Int
    
    let tileIndex: Int
    
    let name: String
    let width: Int
    let height: Int
    
    // 地图数据 两个字节表示一个地图块（从左到右，从上到下） （低字节：最高位1表示可行走，0不可行走。高字节：事件号）
    let mapData: [[[UInt8]]]
    
    var images: [[CGImage?]] = []
    var image: CGImage? = nil
    
    var eventIds: [[Int]] = []
    
    required init(data: Data, offset: Int) {
        let data = data.subdata(in: offset..<data.count)
        type = Int(data[0])
        index = Int(data[1])
        
        tileIndex = Int(data[2])
        
        name = data.getString(start: 3)
        width = Int(data[0x10])
        height = Int(data[0x11])
        
        var mapData: [[[UInt8]]] = Array(repeating: Array(repeating: Array(repeating: 0, count: 2), count: width), count: height)
        
        for y in 0..<height {
            for x in 0..<width {
                let i = 0x12 + (y * width + x) * 2
                mapData[y][x] = [data[i], data[i + 1]]
            }
        }
        self.mapData = mapData
        
        
        images = Array(repeating: Array(repeating: nil, count: width), count: height)
        for y in 0..<height {
            for x in 0..<width {
                let image = DatLib.shared.getImage(resType: .til, type: 1, index: tileIndex)?.images[getTileIndex(x: x, y: y)]
                self.images[y][x] = image
            }
        }
        
        self.image = self.images.map({ $0.map({$0!})}).combine(imageWidth: 16, imageHeight: 16)
        
        eventIds = Array(repeating: Array(repeating: 0, count: width), count: height)
        for y in 0..<height {
            for x in 0..<width {
                let eventId = getEventId(x: x, y: y)
                if eventId > 0 {
                    self.eventIds[y][x] = eventId
                }
            }
        }
    }
    
    func canWalk(x: Int, y: Int) -> Bool {
        guard x >= 0, x < width, y >= 0, y < height else { return false }
        
        return (mapData[y][x][0] & 0x80) != 0
    }
    
    func getTileIndex(x: Int, y: Int) -> Int {
        guard x >= 0, x < width, y >= 0, y < height else { return 0 }
        
        let index = mapData[y][x][0] & 0x7F
        return Int(index)
    }
    
    private func getEventId(x: Int, y: Int) -> Int {
        guard x >= 0, x < width, y >= 0, y < height else { return -1 }
        
        return Int(mapData[y][x][1] & 0xFF)
    }
}
