//
//  GoodsEffect.swift
//  BBK
//
//  Created by Wttch on 2024/6/27.
//

import Foundation

struct GoodsEffect {
    // 毒、乱、封、眠
    let value: Int
    
    var poison: Bool {
        return mask(0b1000)
    }
    
    var confusion: Bool {
        return mask(0b0100)
    }
    
    var seal: Bool {
        return mask(0b0010)
    }
    
    var sleep: Bool {
        return mask(0b0001)
    }
    
    func mask(_ mask: Int) -> Bool {
        return (value & mask) == mask
    }
}
