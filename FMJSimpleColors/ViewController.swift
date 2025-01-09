//
//  ViewController.swift
//  FMJ
//
//  Created by Wttch on 2024/7/15.
//

import Cocoa
import SpriteKit
import GameplayKit

import SwiftLogMacro


@Log("ViewController", level: .debug)
class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    private let sceneManager = SceneManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let view = self.skView {
            sceneManager.skView = view
            // Load the SKScene from 'GameScene.sks'
            sceneManager.currentScene = SKScene(fileNamed: "MenuScene")
            if let scene = sceneManager.currentScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    
    
    override func viewDidLayout() {
        logger.debug("viewDidLayout")
        print(self.skView.frame.size)
        sceneManager.viewDidLayout(self.skView.bounds.size)
    }
}
