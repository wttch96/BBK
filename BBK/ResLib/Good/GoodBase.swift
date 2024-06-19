//
//  GoodBase.swift
//  BBK
//
//  Created by Wttch on 2024/6/17.
//

import Foundation

class GoodBase: ResBase {
    let data: ResData
    
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
    
    
    required init(data: ResData) {
        self.data = data
        self.type = Int(data[0])
        self.index = Int(data[1])
     
        self.enable = Int(data[3])
        self.sumRound = Int(data[4])
        self.imageIndex = Int(data[5])
        self.name = data.getString(start: 6)
        self.buyPrice = data.get2BytesUInt(start: 0x12)
        self.sellPrice = data.get2BytesUInt(start: 0x14)
        self.description = data.getString(start: 0x1e)
    }
}
