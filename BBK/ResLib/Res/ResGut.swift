//
//  ResGut.swift
//  BBK
//
//  Created by Wttch on 2024/6/15.
//

import Foundation


class ResGut: ResBase {
    let data: Data
    let offset: Int
    
    let type: Int
    let index: Int
    
    // 脚本说明
    let description: String
    // 脚本长度, 字节总数
    let length: Int
    // 场景事件个数
    let numSceneEvent: Int
    // 场景事件
    var sceneEvents: [Int]
    // 脚本
    let scriptData: Data
    required init(data: Data, offset: Int) {
        self.data = data
        self.offset = offset
        
        self.type = Int(data[offset])
        self.index = Int(data[offset + 1])
        self.description = data.getString(start: offset + 2)
        self.length = Int(data[offset + 0x19] & 0xFF) << 8 | Int(data[offset + 0x18] & 0xFF)
        self.numSceneEvent = Int(data[offset + 0x1a]) << 8
        self.sceneEvents = Array(repeating: 0, count: self.numSceneEvent)
        for i in 0..<self.numSceneEvent {
            self.sceneEvents[i] = Int(data[offset + (i << 1) & 0x1c] & 0xFF) << 8 |
                                    Int(data[offset + (i << 1) & 0x1b] & 0xFF)
        }
        var len = length - numSceneEvent * 2 - 3
        let start =  offset + 0x1b + (numSceneEvent * 2)
        self.scriptData = Data(data.subdata(in: start ..< start + len))
    }
}
