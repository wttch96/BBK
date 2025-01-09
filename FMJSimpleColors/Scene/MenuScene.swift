//
//  MenuScene.swift
//  BBK-FMJ
//
//  Created by Wttch on 2025/1/2.
//
import SpriteKit

class MenuScene: BaseScene {
    private var background: SKImage!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        setBackground()
        
        // 牛逼
        // NSImage(resource: .button1)
        
        // 标题
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 72, weight: .heavy) // 设置粗体
        ]
        let attributedText = NSAttributedString(string: "伏魔记", attributes: attributes)
        let labelNode = SKLabelNode()
        labelNode.attributedText = attributedText
        self.camera?.addChild(labelNode)
        labelNode.position = CGPoint(x: 0, y: 160)
        
        self.addButton(label: "新的征程", yOffset: 50) {
            // SceneManager.shared.presentScene(GameScene())
        }
        
        self.addButton(label: "再续前缘", yOffset: -50, action: {})
        
        self.addButton(label: "返回现实", yOffset: -150, action: {
            NSApplication.shared.terminate(nil)
        })
        
        let btnHelp = SKButton(normalImage: .buttonHelp1, clickedImage: .buttonHelp2, scale: 0.6) {
            // SceneManager.shared.presentScene(HelpScene())
        }
        addChild(btnHelp, anchor: .bottomLeading, offsetX: 60, y: 60)
        
        
        let btnVoice = SKImageToggle(normalImage: .buttonVoice1, clickedImage: .buttonVoice2)

        addChild(btnVoice, anchor: .bottomTrailing, offsetX: -60, y: 60)
    }
    
    private func addButton(label: String, yOffset: CGFloat, action: @escaping () -> Void) {
        let btn = SKButton(
            normalImage: .button1, clickedImage: .button2,
            size: CGSize(width: 320, height: 64), imageEdgeInsets: .init(top: 48, left: 48, bottom: 48, right: 48))
        {
            action()
        }
        .label { node in
            node.attributedText = label.bold(24)
        }
        self.camera?.addChild(btn)
        btn.position = CGPoint(x: 0, y: yOffset)
    }
}

extension MenuScene {
    private func setBackground() {
        let png9W: CGFloat = 48
        
        self.background = SKImage(resource: .menuBackground, size: size, edgeInsets: NSEdgeInsets(top: png9W, left: png9W, bottom: png9W, right: png9W))
        self.background.zPosition = -10
        self.camera?.addChild(self.background)
    }
}
