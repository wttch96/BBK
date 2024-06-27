//
//  GoodEquipment.swift
//  BBK
//
//  Created by Wttch on 2024/6/27.
//

import Foundation

struct GoodEquipment {
    // 基础数据
    let base: GoodBase

    // 真气上限
    let mpMax: Int
    // 生命上限
    let hpMax: Int
    // 防御
    let defence: Int
    // 攻击
    let attack: Int
    // 灵力
    let psychic: Int
    // 身法
    let agility: Int
    // 0、0、0、0（07武器类此处为全体效果）、毒、乱、封、眠（影响免疫效果，07武器类为攻击效果）
    let effect: Int
    // 运气
    let luck: Int
}

extension GoodEquipment {
    init(data: Data, offset: Int) {
        self.base = GoodBase(data: data, offset: offset)
        let data = self.base.data
        self.mpMax = data.get1ByteInt(start: 0x16)
        self.hpMax = data.get1ByteInt(start: 0x17)
        self.defence = data.get1ByteInt(start: 0x18)
        self.attack = data.get1ByteUInt(start: 0x19)
        self.psychic = data.get1ByteInt(start: 0x1a)
        self.agility = data.get1ByteInt(start: 0x1b)
        self.effect = data.get1ByteUInt(start: 0x1c)
        self.luck = data.get1ByteInt(start: 0x1d)
    }
}



// MARK: 游戏逻辑
extension GoodEquipment {
    func putOn() {
        
    }
    
    func takeOff() {
        
    }
}
