//
//  GoodBase.swift
//  BBK
//
//  Created by Wttch on 2024/6/17.
//

import Foundation

// MARK: 数据
struct GoodBase: Identifiable {
    // id
    var id: ResID
    // 原始数据等
    let data: ResData
    // 是否可装备，最低位为主角1
    let enable: Int
    // 持续回合
    let sumRound: Int
    // 图片索引
    let imageIndex: Int
    // 道具名称
    let name: String
    // 买价
    let buyPrice: Int
    // 卖价
    let sellPrice: Int
    // 道具说明
    let description: String
    // 事件 id： 不为0时装备该道具时，就会设置该事件，而卸下时， 就会取消该事件，不能用来典当
    let eventId: Int
}

extension GoodBase {
    init(data: Data, offset: Int) {
        self.data = ResData(data: data, offset: offset)
        self.id = ResID(type: Int(self.data[0]), index: Int(self.data[1]))
     
        self.enable = Int(self.data[3])
        self.sumRound = Int(self.data[4])
        self.imageIndex = Int(self.data[5])
        self.name = self.data.getString(start: 6)
        self.buyPrice = self.data.get2BytesUInt(start: 0x12)
        self.sellPrice = self.data.get2BytesUInt(start: 0x14)
        self.description = self.data.getString(start: 0x1e)
        self.eventId = self.data.get2BytesUInt(start: 0x84)
    }
}
