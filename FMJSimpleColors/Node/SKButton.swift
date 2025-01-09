//
//  SKButton.swift
//  FMJ
//
//  Created by Wttch on 2025/1/6.
//

import Foundation
import SpriteKit

/// UI 按钮
/// 用于响应点击事件
class SKButton: SKNode {
    /// 按钮的图片
    let normalImage: ImageResource
    /// 按钮的点击图片
    let clickedImage: ImageResource
    /// 按钮的文字
    let label: String?
    /// 按钮的点击事件
    let action: () -> Void
    /// 背景节点
    private let backgroundNode: SKImage
    /// label 节点
    private let labelNode: SKLabelNode
    
    init(normalImage: ImageResource, clickedImage: ImageResource,
         label: String? = nil,
         size: CGSize? = nil, scale: CGFloat = 1,
         imageEdgeInsets: NSEdgeInsets? = nil,
         action: @escaping () -> Void = {})
    {
        self.normalImage = normalImage
        self.clickedImage = clickedImage
        self.label = label
        self.action = action
        self.backgroundNode = SKImage(resource: normalImage, size: size,  scale: scale, edgeInsets: imageEdgeInsets)
        self.labelNode = SKLabelNode()
        super.init()
        
        addChild(backgroundNode)
        backgroundNode.zPosition = -1
        
        if let label = self.label, !label.isEmpty {
            // 创建富文本
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 30) // 设置粗体
            ]
            let attributedText = NSAttributedString(string: label, attributes: attributes)
            labelNode.attributedText = attributedText
        }
        addChild(labelNode)
    }
    
    func label(_ block: (SKLabelNode) -> Void) -> Self {
        block(labelNode)
        return self
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SKButton: MouseResponder {
    func mouseDown() {
        backgroundNode.image = clickedImage
    }
    
    func mouseUp() {
        backgroundNode.image = normalImage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.action()
        }
    }
}
