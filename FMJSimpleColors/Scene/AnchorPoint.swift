//
//  AnchorPoint.swift
//  FMJ
//
//  Created by Wttch on 2025/1/7.
//

import Foundation
import SpriteKit


/// 锚点
struct AnchorPoint {
    let point: CGPoint
    private init(_ point: CGPoint) {
        self.point = point
    }
}

extension AnchorPoint {
    static let topLeading = AnchorPoint(.init(x: -0.5, y: 0.5))
    static let top = AnchorPoint(.init(x: 0, y: 0.5))
    static let topTrailing = AnchorPoint(.init(x: 0.5, y: 0.5))
    static let leading = AnchorPoint(.init(x: -0.5, y: 0))
    static let center = AnchorPoint(.init(x: 0, y: 0))
    static let trailing = AnchorPoint(.init(x: 0.5, y: 0))
    static let bottomLeading = AnchorPoint(.init(x: -0.5, y: -0.5))
    static let bottom = AnchorPoint(.init(x: 0, y: -0.5))
    static let bottomTrailing = AnchorPoint(.init(x: 0.5, y: -0.5))
}

extension BaseScene {
    
    /// 添加子节点
    /// - Parameters:
    ///  - node: 子节点
    ///  - anchor: 锚点
    ///  - offsetX: X轴偏移量
    ///  - y: Y轴偏移量
    func addChild(_ node: SKNode, anchor: AnchorPoint, offsetX: CGFloat, y: CGFloat) {
        let anchorPoint = CGPoint(
            x: self.size.width * anchor.point.x + offsetX,
            y: self.size.height * anchor.point.y + y)
        
        node.position = anchorPoint
        addChild(node)
    }
}
