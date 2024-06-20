//
//  Command.swift
//  BBK
//
//  Created by Wttch on 2024/6/18.
//

import Foundation

protocol Command: ResBase {
    var nextPos: Int { get }
}

class CommandBase: Command, CustomStringConvertible {
    let data: ResData
    required init(data: ResData) {
        self.data = data
    }

    var nextPos: Int {
        return data.offset + length
    }

    var length: Int {
        fatalError("CommandBase#length 是抽象属性...")
    }

    var type: Int {
        fatalError("")
    }

    var index: Int {
        fatalError("")
    }

    var description: String {
        return "【\(String(describing: Swift.type(of: self)))】"
    }
}

class CommandEmpty: CommandBase {
    override var length: Int { 0 }
}

// MARK: 1

class CmdLoadMap: CommandBase {
    override var type: Int { data.get2BytesUInt(start: 0) }
    override var index: Int { data.get2BytesUInt(start: 2) }
    var x: Int { data.get2BytesUInt(start: 4) }
    var y: Int { data.get2BytesUInt(start: 6) }

    override var length: Int { 8 }

    override var description: String {
        if let resMap = DatLib.shared.getMap(type: type, index: index) {
            "加载地图 \(resMap.name) (\(x), \(y))"
        } else {
            "加载地图 \(type),\(index) (\(x), \(y))"
        }
    }
}

// MARK: 2

class CmdCreateActor: CommandBase {
    var actorId: Int { data.get2BytesUInt(start: 0) }
    var x: Int { data.get2BytesUInt(start: 2) }
    var y: Int { data.get2BytesUInt(start: 4) }

    override var length: Int { 6 }

    override var description: String { "创建角色 actorId[\(actorId)], pos(\(x), \(y))" }
}

// MARK: 3: Delete NPC

class CmdDeleteNPC: CommandBase {
    lazy var npcId: Int = data.get2BytesUInt(start: 0)

    override var length: Int { 2 }

    override var description: String { "删除NPC [\(npcId)]" }
}

// MARK: 6: Move

class CmdMove: CommandBase {
    lazy var npcId: Int = data.get2BytesUInt(start: 0)
    lazy var dstX: Int = data.get2BytesUInt(start: 2)
    lazy var dstY: Int = data.get2BytesUInt(start: 4)

    override var length: Int { 6 }

    override var description: String { "NPC[\(npcId)] 移动到 (\(dstX), \(dstY))" }
}

// MARK: 9: Callback

class CmdCallback: CommandEmpty {}

// MARK: 10: Goto

class CmdGoto: CommandBase {
    var gotoIndex: Int { data.get2BytesUInt(start: 0) }
    override var length: Int { 2 }

    override var description: String { "[\(gotoIndex)]" }
}

// MARK: 11: If

class CmdIf: CommandBase {
    var ifIndex: Int { data.get2BytesUInt(start: 0) }
    var gotoIndex: Int { data.get2BytesUInt(start: 2) }

    override var length: Int { 4 }

    override var description: String {
        "如果 [\(ifIndex)] 跳转 [\(gotoIndex)] "
    }
}

// MARK: 12: Set

class CmdSet: CommandBase {
    var valueIndex: Int { data.get2BytesUInt(start: 0) }
    var value: Int { data.get2BytesUInt(start: 2) }
    override var length: Int { 4 }

    override var description: String { "设置[\(valueIndex)]为\(value)" }
}

// MARK: 13: say

class CmdSay: CommandBase {
    // 角色 id
    lazy var actorId: Int = data.get2BytesUInt(start: 0)
    lazy var text: String = data.getString(start: 2)

    override var length: Int { 2 + text.gbkCount + 1 }

    override var description: String { "[\(actorId)]说: '\(text)'" }
}

// MARK: 14: Start Chapter

class CmdStartChapter: CommandBase {
    override var type: Int { data.get2BytesUInt(start: 0) }
    override var index: Int { data.get2BytesUInt(start: 2) }

    override var length: Int { 4 }

    override var description: String { "开始第\(type).\(index)章" }
}

// MARK: 20: Game Over

class CmdGameOver: CommandEmpty {}

// MARK: 21: If Compare

class CmdIfCompare: CommandBase {
    var op1Index: Int { data.get2BytesUInt(start: 0) }
    var op2Index: Int { data.get2BytesUInt(start: 2) }
    var gotoIndex: Int { data.get2BytesUInt(start: 4) }

    override var length: Int { 6 }

    override var description: String { "如果 [\(op1Index)] == [\(op2Index)] goto [\(gotoIndex)]" }
}

// MARK: 22: Add

class CmdAdd: CommandBase {
    var valueIndex: Int { data.get2BytesUInt(start: 0) }
    var value: Int { data.get2BytesUInt(start: 2) }
    override var length: Int { 4 }

    override var description: String { "[\(valueIndex)] += \(value)" }
}

// MARK: 23: Sub
class CmdSub: CommandBase {
    var valueIndex: Int { data.get2BytesUInt(start: 0) }
    var value: Int { data.get2BytesUInt(start: 2) }
    override var length: Int { 4 }

    override var description: String { "[\(valueIndex)] -= \(value)" }
}

// MARK: 26: Set Event

class CmdSetEvent: CommandBase {
    lazy var eventId: Int = data.get2BytesUInt(start: 0)
    override var length: Int { 2 }

    override var description: String { "设置事件[\(eventId)]" }
}

// MARK: 27: Clear Event

class CmdClearEvent: CommandBase {
    var eventId: Int { data.get2BytesUInt(start: 0) }

    override var length: Int { 2 }

    override var description: String { "清除事件[\(eventId)]" }
}

// MARK: 28: Buy

class CmdBuy: CommandBase {
    var goodIds: [Int] { data.data.getArray(start: 0) }

    override var length: Int { goodIds.count + 1 }

    override var description: String { "购买: \(goods.map { $0.name })" }

    var goods: [GoodBase] {
        var goods: [GoodBase] = []
        for i in 0..<goodIds.count / 2 {
            // 获取方式也不对
            if let good = DatLib.shared.getGood(type: goodIds[i * 2], index: goodIds[i * 2 + 1]) {
                goods.append(good)
            } else {
                // TODO:
            }
        }
        return goods
    }
}

// MARK: 29: Face To Face

class CmdFaceToFace: CommandBase {
    var character1Id: Int { data.get2BytesUInt(start: 0) }
    var character2Id: Int { data.get2BytesUInt(start: 2) }
    override var length: Int { 4 }

    override var description: String {
        "\(character1Id) <--->\(character2Id) 面对面"
    }
}

// MARK: 30: Movie

class CmdMovie: CommandBase {
    override var length: Int { 10 }
}

// MARK: 31: Choice

class CmdChoice: CommandBase {
    var choice1: String { data.getString(start: 0) }
    var choice2: String { data.getString(start: choice1.gbkCount + 1) }
    var gotoAddress: Int { data.get2BytesUInt(start: choice1.gbkCount + 1 + choice2.gbkCount + 1) }

    override var length: Int { choice1.gbkCount + 1 + choice2.gbkCount + 1 + 2 }

    override var description: String { "选择1: \(choice1), 选择2: \(choice2) 如果选择2跳转[\(gotoAddress)]" }
}

// MARK: 32: CreateBox

class CmdCreateBox: CommandBase {
    // 建一个宝箱，宝箱号码boxindex(角色图片，type为4)，
    // 位置为（x，y），id为操作号（与NPC共用)
    var operatorId: Int { data.get2BytesUInt(start: 0) }
    var boxId: Int { data.get2BytesUInt(start: 2) }
    var x: Int { data.get2BytesUInt(start: 4) }
    var y: Int { data.get2BytesUInt(start: 6) }

    override var length: Int { 8 }

    override var description: String { "创建宝箱[\(boxId)]在 (\(x), \(y))处. 操作id(\(operatorId))" }
}

// MARK: 33: Delete Box

class CmdDeleteBox: CommandBase {
    var boxId: Int { data.get2BytesUInt(start: 0) }

    override var length: Int { 2 }

    override var description: String { "删除宝箱[\(boxId)]" }
}

// MARK: 34: Gain Goods

class CmdGainGoods: CommandBase {
    override var type: Int { data.get2BytesUInt(start: 0) }
    override var index: Int { data.get2BytesUInt(start: 2) }
    override var length: Int { 4 }

    override var description: String { "获得: [\(DatLib.shared.getGood(type: type, index: index)?.name ?? "")]" }
}

// MARK: 35: Init Fight

class CmdInitFight: CommandBase {
    // 可能出现的怪物种类
    lazy var monstersType: [Int] = {
        var type = Array(repeating: 0, count: 8)
        for i in 0..<8 {
            type[i] = data.get2BytesUInt(start: i * 2)
        }
        return type
    }()

    // 战斗背景
    var backgroundId: Int { data.get2BytesUInt(start: 16) }
    // 左下角
    var lbId: Int { data.get2BytesUInt(start: 18) }
    // 右上角
    var rtId: Int { data.get2BytesUInt(start: 20) }

    override var length: Int { 22 }

    override var description: String {
        "初始化战斗, 敌人种类: \(monstersType), 战斗背景ID: \(backgroundId), \(lbId), \(rtId)"
    }
}

// MARK: 37: Fight Disable

class CmdFightDisable: CommandEmpty {}

// MARK: 38: CreateNPC

class CmdCreateNPC: CommandBase {
    var operatorId: Int { data.get2BytesUInt(start: 0) }
    var id: Int { data.get2BytesUInt(start: 2) }
    var x: Int { data.get2BytesUInt(start: 4) }
    var y: Int { data.get2BytesUInt(start: 6) }

    override var length: Int { 8 }

    override var description: String {
        "在(\(x), \(y))创建[\(id)]NPC, 操作id(\(operatorId))"
    }
}

// MARK: 39: Enter Fight

class CmdEnterFight: CommandBase {
    // 最大回合数, 0为无限
    var maxRound: Int { data.get2BytesUInt(start: 0) }
    // 三个敌人类型
    lazy var monstersTypes: [Int] = [
        data.get2BytesUInt(start: 2),
        data.get2BytesUInt(start: 4),
        data.get2BytesUInt(start: 6),
    ]
    // 0战斗背景，1左下角图，2右上角图
    lazy var backgrounds: [Int] = [
        data.get2BytesUInt(start: 8),
        data.get2BytesUInt(start: 10),
        data.get2BytesUInt(start: 12),
    ]
    // 0-2 战斗中，触发事件的回合
    lazy var eventRounds: [Int] = [
        data.get2BytesUInt(start: 14),
        data.get2BytesUInt(start: 16),
        data.get2BytesUInt(start: 18),
    ]
    // 0-2 对应的事件号
    lazy var eventIds: [Int] = [
        data.get2BytesUInt(start: 20),
        data.get2BytesUInt(start: 22),
        data.get2BytesUInt(start: 24),
    ]
    // 失败跳转
    var lossTo: Int { data.get2BytesUInt(start: 26) }
    // 胜利跳转
    var winTo: Int { data.get2BytesUInt(start: 28) }

    override var length: Int { 30 }

    override var description: String {
        "进入战斗, 最大回合: \(maxRound), 敌人类型: \(monstersTypes), 战斗背景Id: \(backgrounds), 事件回合: \(eventRounds), 事件: \(eventIds), 胜利?[\(winTo)]:[\(lossTo)]"
    }
}

// MARK: 40: Delete Actor

class CmdDeleteActor: CommandBase {
    var actorId: Int { data.get2BytesUInt(start: 0) }

    override var length: Int { 2 }

    override var description: String { "[\(actorId)]离队" }
}

// MARK: 41: Gain Money

class CmdGainMoney: CommandBase {
    var money: Int { data.get4BytesUInt(start: 0) }
    override var length: Int { 4 }

    override var description: String { "获得金钱: \(money)" }
}

// MARK: 42: Use Money

class CmdUseMoney: CommandBase {
    lazy var money: Int = data.get4BytesUInt(start: 0)
    override var length: Int { 4 }

    override var description: String { "使用金钱: \(money)" }
}

// MARK: 43: Set Money

class CmdSetMoney: CommandBase {
    lazy var money: Int = data.get4BytesUInt(start: 0)
    override var length: Int { 4 }

    override var description: String { "设置金钱为[\(money)]" }
}

// MARK: 44: Learn Magic

class CmdLearnMagic: CommandBase {
    var actorId: Int { data.get2BytesUInt(start: 0) }
    override var type: Int { data.get2BytesUInt(start: 2) }
    override var index: Int { data.get2BytesUInt(start: 4) }
    override var length: Int { 6 }
    
    override var description: String { "角色[\(actorId)]学会了[\(type),\(index)]" }
}

// MARK: 45: Sale

class CmdSale: CommandEmpty {}

// MARK: 46: NPC Move Mod

// 修改 NPC 状态
class CmdNPCMoveMod: CommandBase {
    var npcId: Int { data.get2BytesUInt(start: 0) }
    var stateId: Int { data.get2BytesUInt(start: 2) }

    var state: CharacterBase.State? {
        return CharacterBase.State(rawValue: stateId)
    }

    override var length: Int { 4 }

    override var description: String { "修改NPC[\(npcId)]状态为[\(state.map { String(describing: $0) } ?? "<nil>")]" }
}

// MARK: 47: Message

class CmdMessage: CommandBase {
    var text: String { data.getString(start: 0) }

    override var length: Int { text.gbkCount + 1 }

    override var description: String { "\(super.description): '\(text)'" }
}

// MARK: 49: Resume Actor HP

class CmdResumeActorHP: CommandBase {
    // 角色id
    var actorId: Int { data.get2BytesUInt(start: 0) }
    // 恢复到的百分比
    var hpRate: Int { data.get2BytesUInt(start: 2) }

    override var length: Int { 4 }

    override var description: String { "[\(actorId)]HP恢复至 \(hpRate)%" }
}

// MARK: 52: Delete All NPC

class CmdDeleteAllNPC: CommandEmpty {}

// MARK: 53: NPC Step

class CmdNPCStep: CommandBase {
    // 0 为主角
    var id: Int { data.get2BytesUInt(start: 0) }
    // 0, 1, 2, 3
    // N, E, S, W
    // 北, 东, 南, 西
    var faceTo: Int { data.get2BytesUInt(start: 2) }
    var step: Int { data.get2BytesUInt(start: 4) }

    override var length: Int { 6 }

    override var description: String {
        super.description + " npc[\(id)] 向[\(faceTo)]走[\(step)]步"
    }
}

// MARK: 54: Set Scene Name

class CmdSetSceneName: CommandBase {
    lazy var name: String = data.getString(start: 0)

    override var length: Int { name.gbkCount + 1 }

    override var description: String { "设置场景名称: [\(name)]" }
}

// MARK: 55: Show Scene Name

class CmdShowSceneName: CommandEmpty {}

// MARK: 56: Show Screen

class CmdShowScreen: CommandEmpty {}

// MARK: 57: Use Goods

class CmdUseGoods: CommandBase {
    override var type: Int { data.get2BytesUInt(start: 0) }
    override var index: Int { data.get2BytesUInt(start: 2) }
    var gotoAddress: Int { data.get2BytesUInt(start: 4) }

    override var length: Int { 6 }

    override var description: String { "使用物品[\(DatLib.shared.getGood(type: type, index: index)?.name ?? "<nil>")], 使用成功则跳转[\(gotoAddress)]" }
}

// MARK: 61

class CmdShowScript: CommandBase {
    lazy var top: Int = data.get2BytesUInt(start: 0)
    lazy var bottom: Int = data.get2BytesUInt(start: 2)
    lazy var text: String = data.getString(start: 4)

    override var length: Int { 4 + text.gbkCount + 1 }

    override var description: String { "\(top),\(bottom) [\(text)]" }
}

// MARK: 64: Menu

class CmdMenu: CommandBase {
    var id: Int { data.get2BytesUInt(start: 0) }
    var text: String { data.getString(start: 2) }

    override var length: Int { 2 + text.gbkCount + 1 }

    override var description: String { "菜单: [\(id)]-\(text)" }
}

// MARK: 68: Return

class CmdReturn: CommandEmpty {}

// MARK: 70: Disaable Save

class CmdDisableSave: CommandEmpty {
    override var description: String { "禁止保存" }
}

// MARK: 71: Enable Save

class CmdEnableSave: CommandEmpty {
    override var description: String { "允许保存" }
}
