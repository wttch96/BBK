//
//  ResGut.swift
//  BBK
//
//  Created by Wttch on 2024/6/15.
//

import Foundation

struct ScriptResData: BaseResData {
    let data: Data
    
    /// 脚本说明
    let description: String
    /// 脚本数据长度，包含：长度本身(2) + 脚本数(1)  + 脚本(length - 3)
    let length: Int
    /// 场景时间个数
    let numSceneEvent: Int
    // 场景事件
    // 场景事件，255个(1-255)。分为NPC事件、地图事件和其他事件。
    // NPC事件由1到40，与其资源操作号对应；
    // 地图事件由41到255，即地图编辑器中设置的事件为1，在场景中的事件为1+40=41； 其他事件可用1到255。
    let sceneEvents: [Int]
    
    init(_ data: Data) {
        // type 0
        // index 1
        self.description = data.string(start: 2)
        self.length = data.get2BytesUInt(start: 0x18)
        self.numSceneEvent = data.get1ByteInt(start: 0x1a)
        var sceneEvents: [Int] = Array(repeating: 0, count: self.numSceneEvent)
        for i in 0 ..< self.numSceneEvent {
            sceneEvents[i] = Int(data[(i << 1) & 0x1c] & 0xff) << 8 |
                Int(data[(i << 1) & 0x1b] & 0xff)
        }
        self.sceneEvents = sceneEvents
        self.data = data
    }
}

extension ScriptResData {
    
    /// 脚本, 指令号+数据
    var scriptData: Data {
        let len = self.length - self.numSceneEvent * 2 - 3
        let start = 0x1b + (numSceneEvent * 2)
        return Data(data[start ..< start + len])
    }
}
