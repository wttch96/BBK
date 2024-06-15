//
//  ResType.swift
//  BBK
//
//  Created by Wttch on 2024/6/15.
//

import Foundation

enum ResType: Int, CaseIterable {
    // 剧情脚本
    case gut = 1
    // 地图
    case map = 2
    // 角色资源
    case ars = 3
    // 魔法资源
    case mrs = 4
    // 特效资源
    case srs = 5
    // 道具资源
    case grs = 6
    // tile 资源
    case til = 7
    // 角色图片
    case acp = 8
    // 道具图片
    case gdp = 9
    // 特效图片
    case ggj = 10
    // 杂项图片
    case pic = 11
    // 链资源
    case mlr = 12
}

extension ResType {
    var name: String {
        let names: [ResType: String] = [
            .gut: "剧情脚本",
            .map: "地图",
            .ars: "角色资源",
            .mrs: "魔法资源",
            .srs: "特效资源",
            .grs: "道具资源",
            .til: "tile 资源",
            .acp: "角色图片",
            .gdp: "道具图片",
            .ggj: "特效图片",
            .pic: "杂项图片",
            .mlr: "链资源",
        ]

        return names[self]!
    }
}
