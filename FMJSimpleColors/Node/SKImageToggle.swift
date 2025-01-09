//
//  SKToggle.swift
//  FMJ
//
//  Created by Wttch on 2025/1/7.
//

import Foundation
import SpriteKit

class SKImageToggle: SKNode {
    var isOn: Bool = false
    private let normalImage: ImageResource
    private let clickedImage: ImageResource

    private let imageNode: SKImage
    
    init(normalImage: ImageResource, clickedImage: ImageResource) {
        self.normalImage = normalImage
        self.clickedImage = clickedImage
        self.imageNode = SKImage(resource: normalImage, scale: 0.6)
        super.init()
        self.addChild(imageNode)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SKImageToggle: MouseResponder {
    func mouseUp() {}

    func mouseDown() {
        isOn.toggle()
        
        self.imageNode.image = (isOn ? clickedImage : normalImage)
    }
}
