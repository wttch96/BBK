//
//  GoodBase.swift
//  BBK
//
//  Created by Wttch on 2024/6/17.
//

import Foundation

class GoodBase: ResBase {
    let data: Data
    let offset: Int
    
    let type: Int
    let index: Int
    
    // 是否可装备，最低位为主角1
    let enable: Int
    // 持续回合
    let sumRound: Int
    let imageIndex: Int
    let name: String
    let buyPrice: Int
    let sellPrice: Int
    let description: String
    
    
    required init(data: Data, offset: Int) {
        self.data = data
        self.offset = offset
        self.type = Int(data[offset])
        self.index = Int(data[offset + 1])
     
        self.enable = Int(data[offset + 3])
        self.sumRound = Int(data[offset + 4])
        self.imageIndex = Int(data[offset + 5])
        self.name = data.getString(start: offset + 6)
        self.buyPrice = data.get2BytesUInt(start: offset + 0x12)
        self.sellPrice = data.get2BytesUInt(start: offset + 0x14)
        self.description = data.getString(start: offset + 0x1e)
    }
}
