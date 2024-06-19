//
//  Character.swift
//  BBK
//
//  Created by Wttch on 2024/6/19.
//

import Foundation

class OffsetData {
    let data: Data
    let offset: Int
    lazy var realData: Data = { Data(data[offset..<data.count]) }()
    init(data: Data, offset: Int) {
        self.data = data
        self.offset = offset
    }
}


class CharacterProperty: OffsetData {
    var type: Int = 0
    var index: Int = 0
    
    var name: String = ""
    // 角色的动作状态
    var state: State = .stop
    // 角色在地图中的位置
    var x: Int = 0
    var y: Int = 0
    // 角色在地图中的朝向
    var direction: Direction = .south
    
    var walkingSprite: WalkingSprite! {
        didSet {
            walkingSprite.direction = direction
        }
    }
}


extension CharacterProperty {
    enum State: Int {
        // 停止状态，不作运动驱动
        case stop = 0
        // 强制移动状态，效果同2
        case forceMove = 1
        // 巡逻状态，自由行走
        case walking = 2
        // 暂停状态，等到延时到了后转变为巡逻状态
        case pause = 3
        // 激活状态，只换图片，不改变位置（适合动态的场景对象，比如：伏魔灯）
        case active = 4
    }
}



class CharacterBase: CharacterProperty, ResBase {
    required override init(data: Data, offset: Int) {
        super.init(data: data, offset: offset)
    }
}
