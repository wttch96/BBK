//
//  Character.swift
//  BBK
//
//  Created by Wttch on 2024/6/19.
//

import Foundation


enum CharacterState: Int {
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

protocol CharacterData: BaseResData {
    var name: String { get }
    var state: CharacterState { get }
}

extension CharacterData {
}


class CharacterBase: ResBase {
    var type: Int = 0
    var index: Int = 0
    
    var name: String = ""
    // 角色的动作状态
    var state: State = .stop
    // 角色在地图中的位置
    var pos: (Int, Int) = (0, 0)
    var x: Int {
        get { pos.0 }
        set { pos.0 = newValue }
    }
    var y: Int {
        get { pos.1 }
        set { pos.1 = newValue }
    }
    // 角色在地图中的朝向
    var direction: Direction = .south {
        didSet {
            walkingSprite.direction = direction
        }
    }
    
    var walkingSprite: WalkingSprite! {
        didSet {
            walkingSprite.direction = direction
        }
    }
    
    var walkingSpriteId: Int {
        walkingSprite.id
    }
    
    let data: ResData
    
    required init(data: ResData) {
        self.data = data
    }
}

extension CharacterBase {
    
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
    
    /// 角色移动
    func walk() {
        walkingSprite.walk()
        updatePos(direction)
    }
    
    // 角色朝指定方向移动
    func walk(_ d: Direction) {
        if self.direction == d {
            walkingSprite.walk()
        } else {
            walkingSprite.walk(d)
            self.direction = d
        }
        updatePos(d)
    }
    
    // 原地踏步, 面向不变
    func walkStay() {
        walkingSprite.walk()
    }
    
    // 原地踏步
    func walkStay(_ d: Direction) {
        if self.direction == d {
            walkingSprite.walk()
        } else {
            walkingSprite.walk(d)
            self.direction = d
        }
    }
    
    func updatePos(_ d: Direction) {
        switch d {
        case .east: x += 1
        case .west: x -= 1
        case .north: y -= 1
        case .south: y += 1
        }
    }
    
    // 脚步:  0—迈左脚；1—立正；2—迈右脚
    var step: Int {
        get { walkingSprite.step }
        set { walkingSprite.step = newValue }
    }
}
