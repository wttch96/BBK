//
//  ResGut.swift
//  BBK
//
//  Created by Wttch on 2024/6/15.
//

import Foundation


class ResScript: ResBase {
    let data: ResData
    
    let type: Int
    let index: Int
    
    // 脚本说明
    let description: String
    // 脚本长度, 字节总数
    let length: Int
    // 场景事件个数
    let numSceneEvent: Int
    // 场景事件
    // 场景事件，255个(1-255)。分为NPC事件、地图事件和其他事件。 
    // NPC事件由1到40，与其资源操作号对应；
    // 地图事件由41到255，即地图编辑器中设置的事件为1，在场景中的事件为1+40=41； 其他事件可用1到255。
    var sceneEvents: [Int]
    // 脚本, 指令号+数据
    let scriptData: Data
    required init(data: ResData) {
        self.data = data
        
        self.type = Int(data[0])
        self.index = Int(data[1])
        self.description = data.getString(start: 2)
        self.length = Int(data[0x19] & 0xFF) << 8 | Int(data[0x18] & 0xFF)
        self.numSceneEvent = Int(data[0x1a]) & 0xFF
        self.sceneEvents = Array(repeating: 0, count: self.numSceneEvent)
        for i in 0..<self.numSceneEvent {
            self.sceneEvents[i] = Int(data[(i << 1) & 0x1c] & 0xFF) << 8 |
                                    Int(data[(i << 1) & 0x1b] & 0xFF)
        }
        var len = length - numSceneEvent * 2 - 3
        let start =  0x1b + (numSceneEvent * 2)
        self.scriptData = Data(data[start ..< start + len])
    }
}
