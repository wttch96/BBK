//
//  BaseScene.swift
//  FMJ
//
//  Created by Wttch on 2025/1/3.
//

import Foundation
import SpriteKit

class BaseScene: SKScene {
    /// 响应按钮的点击事件
    override func mouseDown(with event: NSEvent) {
        for node in self.nodes(at: event.location(in: self)) {
            if let node = node as? MouseResponder {
                node.mouseDown()
            }
        }
    }

    override func mouseUp(with event: NSEvent) {
        for node in self.nodes(at: event.location(in: self)) {
            if let node = node as? MouseResponder {
                node.mouseUp()
            }
        }
    }
}

protocol SceneLifeCycle {
    func sceneChangeSize(_ size: CGSize)
}
