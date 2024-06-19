//
//  WalkingSprite.swift
//  BBK
//
//  Created by Wttch on 2024/6/19.
//

import Foundation
import CoreGraphics

class WalkingSprite {
    // 脚步的偏移
    private static let STEP_OFFSET = [0, 1, 2, 1]
    // 图片资源
    private let resImage: ResImage
    // 面向的偏移
    private var offset: Int = 1
    // 脚步
    private var stepIndex: Int = 0
    
    var id: Int { resImage.index }
    
    init(type: Int, index: Int) {
        guard let resImage = DatLib.shared.getImage(resType: .acp, type: type, index: index) else {
            fatalError("WalkingSprite ResImage 为空, type: \(type), index: \(index)")
        }
        
        self.resImage = resImage
    }
    
    func walk(_ direction: Direction) {
        self.direction = direction
        walk()
    }
    
    func walk() {
        stepIndex += 1
        stepIndex %= 4
    }
    
    func getImage() -> CGImage? {
        return resImage.images[offset + WalkingSprite.STEP_OFFSET[stepIndex] - 1]
    }
    
}


extension WalkingSprite {
    
    var step:Int {
        get { stepIndex }
        set { stepIndex = newValue % 4 }
    }

    var direction: Direction {
        get {
            switch offset {
            case 1: .north
            case 4: .east
            case 7: .south
            case 10: .east
            default: .north
            }
        }
        set {
            switch newValue {
            case .north:
                offset = 1
            case .east:
                offset = 4
            case .south:
                offset = 7
            case .west:
                offset = 10
            }
        }
    }
}
