//
//  Command.swift
//  BBK
//
//  Created by Wttch on 2024/6/18.
//

import Foundation

protocol Command {
    init(data: Data, offset: Int)
    
    var nextPos: Int { get }
}

class CommandBase: Command, CustomStringConvertible {
    let data: Data
    let offset: Int
    fileprivate let realData: Data
    required init(data: Data, offset: Int) {
        self.data = data
        self.offset = offset
        self.realData = Data(data[offset..<data.count])
    }
    
    var nextPos: Int {
        return offset + length
    }
    
    var length: Int {
        fatalError("CommandBase#length 是抽象属性...")
    }
    
    var description: String {
        return "【\(String(describing: type(of: self)))】"
    }
}

// MARK: 1
class CmdLoadMap: CommandBase {
    var type: Int { realData.get2BytesUInt(start: 0) }
    var index: Int { realData.get2BytesUInt(start: 2) }
    var x: Int { realData.get2BytesUInt(start: 4) }
    var y: Int { realData.get2BytesUInt(start: 6) }
    
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
    var actorId: Int { realData.get2BytesUInt(start: 0) }
    var x: Int { realData.get2BytesUInt(start: 2) }
    var y: Int { realData.get2BytesUInt(start: 4) }
    
    override var length: Int { 6 }
    
    override var description: String { "\(super.description) actorId[\(actorId)], pos(\(x), \(y))" }
}

// MARK: 3: Delete NPC
class CmdDeleteNPC: CommandBase {
    lazy var npcId: Int = { realData.get2BytesUInt(start: 0) }()
    
    override var length: Int { 2 }
    
    override var description: String { "\(super.description) [\(npcId)]" }
}

// MARK: 6: Move
class CmdMove: CommandBase {
    lazy var npcId: Int = { realData.get2BytesUInt(start: 0) }()
    lazy var dstX: Int = { realData.get2BytesUInt(start: 2) }()
    lazy var dstY: Int = { realData.get2BytesUInt(start: 4) }()
    
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
    lazy var actorId: Int = { realData.get2BytesUInt(start: 0) }()
    lazy var text: String = { realData.getString(start: 2) }()
    
    override var length: Int { 2 + text.gbkCount + 1 }
    
    override var description: String { "\(super.description) [\(actorId)]: '\(text)'"}
}

// MARK: 14: Start Chapter
class CmdStartChapter: CommandBase {
    lazy var type: Int = { realData.get2BytesUInt(start: 0) }()
    lazy var index: Int = { realData.get2BytesUInt(start: 2) }()
    
    override var length: Int { 4 }
    
    override var description: String { "\(super.description) 开始第\(type).\(index)章" }
}

// MARK: 26: Set Event
class CmdSetEvent: CommandBase {
    lazy var eventId: Int = { realData.get2BytesUInt(start: 0) }()
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
    var operatorId: Int { realData.get2BytesUInt(start: 0) }
    var boxId: Int { realData.get2BytesUInt(start: 2) }
    var x: Int { realData.get2BytesUInt(start: 4) }
    var y: Int { realData.get2BytesUInt(start: 6) }
    
    override var length: Int { 8 }
    
    override var description: String { "\(super.description) 宝箱[\(boxId)]在 (\(x), \(y))处. 操作id(\(operatorId))" }
}

// MARK: 38: CreateNPC
class CmdCreateNPC: CommandBase {
    var operatorId: Int { realData.get2BytesUInt(start: 0) }
    var id: Int { realData.get2BytesUInt(start: 2) }
    var x: Int { realData.get2BytesUInt(start: 4) }
    var y: Int { realData.get2BytesUInt(start: 6) }
    
    override var length: Int { 8 }

    override var description: String {
        "\(super.description) 在(\(x), \(y))创建[\(id)]NPC, 操作id(\(operatorId))"
    }
}

// MARK: 43: Set Money
class CmdSetMoney: CommandBase {
    lazy var money: Int = { realData.get4BytesUInt(start: 0) }()
    override var length: Int { 4 }
    
    override var description: String { "\(super.description) [\(money)]" }
}

// MARK: 53
class CmdNPCStep: CommandBase {
    // 0 为主角
    var id: Int { realData.get2BytesUInt(start: 0) }
    // 0, 1, 2, 3
    // N, E, S, W
    // 北, 东, 南, 西
    var faceTo: Int { realData.get2BytesUInt(start: 2) }
    var step: Int { realData.get2BytesUInt(start: 4) }
    
    override var length: Int { 6 }
    
    override var description: String {
        super.description + " npc[\(id)] 向[\(faceTo)]走[\(step)]步"
    }
}

// MARK: 61
class CmdShowScript: CommandBase {
    lazy var top: Int = { realData.get2BytesUInt(start: 0) }()
    lazy var bottom: Int = { realData.get2BytesUInt(start: 2) }()
    lazy var text: String = { realData.getString(start: 4) }()
    
    override var length: Int { 4 + text.gbkCount + 1 }

    override var description: String { "\(super.description) \(top),\(bottom) [\(text)]" }
}
