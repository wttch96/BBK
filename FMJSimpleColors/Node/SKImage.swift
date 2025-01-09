//
//  SKImage.swift
//  FMJ
//
//  Created by Wttch on 2025/1/6.
//

import Foundation
import SpriteKit

/// png9 图片节点
class SKImage: SKNode {
    // 图片节点
    private let node: SKSpriteNode = .init()
    private let size: CGSize?
    private let scale: CGFloat
    private let edgeInsets: NSEdgeInsets?

    var image: ImageResource {
        didSet {
            presentImage()
        }
    }

    convenience init(resource: ImageResource, size: CGSize? = nil, edgeInsets: NSEdgeInsets? = nil) {
        self.init(resource: resource, size: size, scale: 1, edgeInsets: edgeInsets)
    }

    convenience init(resource: ImageResource, scale: CGFloat) {
        self.init(resource: resource, size: nil, scale: scale, edgeInsets: nil)
    }

    /// 初始化
    /// - Parameters:
    ///  - resource: 图片资源
    ///  - size: 图片大小
    ///  - scale: 图片缩放
    ///  - edgeInsets: png9 参数
    init(resource: ImageResource,
         size: CGSize?,
         scale: CGFloat,
         edgeInsets: NSEdgeInsets?)
    {
        self.size = size
        self.edgeInsets = edgeInsets
        self.scale = scale
        self.image = resource
        super.init()

        if let size = size {
            node.size = size
        }
        addChild(node)
        presentImage()
    }

    /// 使用 ImageResource 生成图片
    // TODO: 优化图片生成
    private func presentImage() {
        if let edgeInsets = edgeInsets,
           let size = size,
           let image = image.cgImage?.png9(size: size, edgeInsets: edgeInsets)
        {
            node.texture = SKTexture(cgImage: image)
        } else {
            let nsImage = NSImage(resource: image)
            node.texture = SKTexture(image: nsImage)
            node.size = nsImage.size.applying(.init(scaleX: scale, y: scale))
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
