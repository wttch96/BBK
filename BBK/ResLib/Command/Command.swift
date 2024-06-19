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

// MARK: 1
class CmdLoadMap: CommandBase {
    override var type: Int { data.get2BytesUInt(start: 0) }
    override var index: Int { data.get2BytesUInt(start: 2) }
    var x: Int { data.get2BytesUInt(start: 4) }
    var y: Int { data.get2BytesUInt(start: 6) }
    
    override var length: Int { 8 }
    
    override var description: String {
        if let resMap = DatLib.shared.getMap(type: type, index: index) {
            super.description + "\(resMap.name) (\(x), \(y))"
        } else {
            super.description + "\(type),\(index) (\(x), \(y))"
        }
    }
}

// MARK: 2
class CmdCreateActor: CommandBase {
    var actorId: Int { data.get2BytesUInt(start: 0) }
    var x: Int { data.get2BytesUInt(start: 2) }
    var y: Int { data.get2BytesUInt(start: 4) }
    
    override var length: Int { 6 }
    
    override var description: String { "\(super.description) actorId[\(actorId)], pos(\(x), \(y))" }
}

// MARK: 3: Delete NPC
class CmdDeleteNPC: CommandBase {
    lazy var npcId: Int = { data.get2BytesUInt(start: 0) }()
    
    override var length: Int { 2 }
    
    override var description: String { "\(super.description) [\(npcId)]" }
}

// MARK: 6: Move
class CmdMove: CommandBase {
    lazy var npcId: Int = { data.get2BytesUInt(start: 0) }()
    lazy var dstX: Int = { data.get2BytesUInt(start: 2) }()
    lazy var dstY: Int = { data.get2BytesUInt(start: 4) }()
    
    override var length: Int { 6 }
    
    override var description: String { "\(super.description) NPC[\(npcId)] 移动到 (\(dstX), \(dstY))" }
}

// MARK: 9: Callback
class CmdCallback: CommandBase {
    override var length: Int { 0 }
}

// MARK: 13: say
class CmdSay: CommandBase {
    // 角色 id
    lazy var actorId: Int = { data.get2BytesUInt(start: 0) }()
    lazy var text: String = { data.getString(start: 2) }()
    
    override var length: Int { 2 + text.gbkCount + 1 }
    
    override var description: String { "\(super.description) [\(actorId)]: '\(text)'"}
}

// MARK: 14: Start Chapter
class CmdStartChapter: CommandBase {
    override var type: Int { data.get2BytesUInt(start: 0) }
    override var index: Int { data.get2BytesUInt(start: 2) }
    
    override var length: Int { 4 }
    
    override var description: String { "\(super.description) 开始第\(type).\(index)章" }
}

// MARK: 26: Set Event
class CmdSetEvent: CommandBase {
    lazy var eventId: Int = { data.get2BytesUInt(start: 0) }()
    override var length: Int { 2 }
    
    override var description: String { "\(super.description) [\(eventId)]" }
}

// MARK: 30
class CmdMovie: CommandBase {
    override var length: Int { 10 }
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
    
    override var description: String { "\(super.description) 宝箱[\(boxId)]在 (\(x), \(y))处. 操作id(\(operatorId))" }
}

// MARK: 38: CreateNPC
class CmdCreateNPC: CommandBase {
    var operatorId: Int { data.get2BytesUInt(start: 0) }
    var id: Int { data.get2BytesUInt(start: 2) }
    var x: Int { data.get2BytesUInt(start: 4) }
    var y: Int { data.get2BytesUInt(start: 6) }
    
    override var length: Int { 8 }

    override var description: String {
        "\(super.description) 在(\(x), \(y))创建[\(id)]NPC, 操作id(\(operatorId))"
    }
}

// MARK: 43: Set Money
class CmdSetMoney: CommandBase {
    lazy var money: Int = { data.get4BytesUInt(start: 0) }()
    override var length: Int { 4 }
    
    override var description: String { "\(super.description) [\(money)]" }
}

// MARK: 53
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

// MARK: 61
class CmdShowScript: CommandBase {
    lazy var top: Int = { data.get2BytesUInt(start: 0) }()
    lazy var bottom: Int = { data.get2BytesUInt(start: 2) }()
    lazy var text: String = { data.getString(start: 4) }()
    
    override var length: Int { 4 + text.gbkCount + 1 }

    override var description: String { "\(super.description) \(top),\(bottom) [\(text)]" }
}
