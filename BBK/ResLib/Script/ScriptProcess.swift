//
//  ScriptProcess.swift
//  BBK
//
//  Created by Wttch on 2024/6/18.
//

import Foundation

class ScriptProcess {
    private let commands: [(any Command.Type)?]
    
    let script: ResScript
    
    init(script: ResScript) {
        commands = [
            nil, // 0
            CmdLoadMap.self, // 1
            CmdCreateActor.self, // 2
            CmdDeleteNPC.self, // 3
            nil, // 4
            nil, // 5
            CmdMove.self, // 6
            nil, // 7
            nil, // 8
            CmdCallback.self, // 9
            CmdGoto.self, // 10
            CmdIf.self, // 11
            nil, // 12
            CmdSay.self, // 13
            CmdStartChapter.self, // 14
            nil, // 15
            nil, // 16
            nil, // 17
            nil, // 18
            nil, // 19
            CmdGameOver.self, // 20
            CmdIfCompare.self, // 21
            nil, // 22
            nil, // 23
            nil, // 24
            nil, // 25
            CmdSetEvent.self, // 26
            CmdClearEvent.self, // 27
            CmdBuy.self, // 28
            CmdFaceToFace.self, // 29
            CmdMovie.self, // 30
            nil, // 31
            CmdCreateBox.self, // 32
            CmdDeleteBox.self, // 33
            CmdGainGoods.self, // 34
            CmdInitFight.self, // 35
            nil, // 36
            CmdFightDisable.self, // 37
            CmdCreateNPC.self, // 38
            CmdEnterFight.self, // 39
            CmdDeleteActor.self, // 40
            CmdGainMoney.self, // 41
            CmdUseMoney.self, // 42
            CmdSetMoney.self, // 43
            nil, // 44
            nil, // 45
            CmdNPCMoveMod.self, // 46
            CmdMessage.self, // 47
            nil, // 48
            CmdResumeActorHP.self, // 49
            nil, // 50
            nil, // 51
            CmdDeleteAllNPC.self, // 52
            CmdNPCStep.self, // 53
            CmdSetSceneName.self, // 54
            CmdShowSceneName.self, // 55
            CmdShowScreen.self, // 56
            nil, // 57
            nil, // 58
            nil, // 59
            nil, // 60
            CmdShowScript.self, // 61
            nil, // 62
            nil, // 63
            CmdMenu.self, // 64
            nil, // 65
            nil, // 66
            nil, // 67
            CmdReturn.self, // 68
            nil, // 69
            CmdDisableSave.self, // 70
            CmdEnableSave.self, // 71
            nil, // 72
            nil, // 73
            nil, // 74
            nil, // 75
            nil, // 76
            nil, // 77
        ]
        self.script = script
        
        getExecutor()
    }
    
    func getExecutor() {
        let code = script.scriptData
        var pointer = 0
        // offsetAddr --> index of operate
        var map: [Int: Int] = [:]
        var iOfOperator = 0
        var operatorList: [Int] = []
        
        while (pointer < code.count) {
            map[pointer] = iOfOperator
            iOfOperator += 1
            let cmdIndex = Int(code[pointer])
            guard cmdIndex < commands.count,
                  let cmdType = commands[cmdIndex] else {
                print("尚未实现的 Command[\(cmdIndex)]")
                break
            }
            let cmd = cmdType.init(data: code, offset: pointer + 1)
            print(cmd)
            pointer = cmd.nextPos
        }
    }
}
