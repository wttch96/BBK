//
//  MapScene.swift
//  BBK-FMJ
//
//  Created by Wttch on 2024/7/14.
//

import Foundation
import SpriteKit

class MapScene: SKScene {
    init(mapName: String) {
        
        var tilesets = Tilesets.tileset2
        var map = Map.load(name: mapName)!
        
        super.init(size: CGSize(width: 800, height: 600))
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        var mapNode = SKTileMapNode(tileSet: tilesets, columns: map.width, rows: map.height, tileSize: CGSize(width: 32, height: 32))
        var dotNode = SKTileMapNode(tileSet: tilesets, columns: map.width, rows: map.height, tileSize: CGSize(width: 32, height: 32))
        dotNode.zPosition = 10
            
        mapNode.enableAutomapping = true
        dotNode.enableAutomapping = true
            
        addChild(mapNode)
        addChild(dotNode)
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                // 判断是否为 dots
                if let dot = map.isDot(x: x, y: y) {
                    if let tileIndex = tilesets.tileGroups.first(where: { $0.name == "\(dot)" }) {
                        mapNode.setTileGroup(tileIndex, forColumn: x, row: map.height - 1 - y)
                    }
                    if let tileIndex = tilesets.tileGroups.first(where: { $0.name == "\(map.tiles[y][x])" }) {
                        dotNode.setTileGroup(tileIndex, forColumn: x, row: map.height - 1 - y)
                    }
                } else {
                    if let tileIndex = tilesets.tileGroups.first(where: { $0.name == "\(map.tiles[y][x])" }) {
                        mapNode.setTileGroup(tileIndex, forColumn: x, row: map.height - 1 - y)
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func didMove(to view: SKView) {}
}
