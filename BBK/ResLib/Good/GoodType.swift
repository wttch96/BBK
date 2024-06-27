//
//  GoodType.swift
//  BBK
//
//  Created by Wttch on 2024/6/26.
//

import Foundation

enum GoodType: Int, CaseIterable {
    // 冠
    case helmet = 1
    // 衣
    case cloth
    // 鞋
    case boot
    // 甲
    case armor
    // 腕
    case brace
    // 饰品
    case trinket
    // 武器
    case weapon
    // 暗器
    case hiddenWeapon
    // 药物
    case medicine
}

extension GoodType {
    var name: String {
        let names: [GoodType: String] = [
            .helmet: "冠",
            .cloth: "衣",
            .boot: "鞋",
            .armor: "甲",
            .brace: "腕",
            .trinket: "饰",
            .weapon: "武器",
            .hiddenWeapon: "暗器",
            .medicine: "药物"
        ]
        
        return names[self]!
    }
}
