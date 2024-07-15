//
//  ViewController.swift
//  BBK-FMJ
//
//  Created by Wttch on 2024/6/28.
//

import Cocoa
import GameplayKit
import SpriteKit

class ViewController: NSViewController {
    @IBOutlet var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = skView {
            // Load the SKScene from 'GameScene.sks'
            let scene = MapScene(mapName: "1-2")
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill

            // Present the scene
            view.presentScene(scene)

            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}
