//
//  SceneManager.swift
//  FMJ
//
//  Created by Wttch on 2025/1/3.
//

import Foundation
import SpriteKit

class SceneManager: @unchecked Sendable {
    private init() {}
    
    static let shared = SceneManager()
    
    var skView: SKView!
    
    var currentScene: SKScene?
    
    func viewDidLayout(_ size: CGSize) {
        if let currentScene = currentScene as? SceneLifeCycle {
            currentScene.sceneChangeSize(size)
        }
    }
    
    @MainActor
    func presentScene(_ scene: SKScene) {
        self.skView.presentScene(scene)
    }
}
