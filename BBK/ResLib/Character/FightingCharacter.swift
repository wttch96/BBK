//
//  FightingCharacterData.swift
//  BBK
//
//  Created by Wttch on 2024/6/30.
//

import Foundation


protocol FightingCharacterData: CharacterResData {
    var level: Int { get }
    var maxHp: Int { get }
    var maxMp: Int { get }
    var hp: Int { get }
    var mp: Int { get }
}
