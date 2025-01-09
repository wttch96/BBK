//
//  GameScene.swift
//  FMJ
//
//  Created by Wttch on 2024/7/15.
//

import Combine
import GameplayKit
import SpriteKit

class GameScene: SKScene {
    private var labelLoadingInfo: SKLabelNode?
    private var cancellable: AnyCancellable? = nil

    override func didMove(to view: SKView) {
        labelLoadingInfo = childNode(withName: "labelLoadingInfo") as? SKLabelNode

//        cancellable = Just([ResType.map, .acp, .gdp, .ggj, .pic, .srs])
//            .subscribe(on: DispatchQueue.global(qos: .background))
//            .map { [weak self] resTypes in
//                for resType in resTypes {
//                    DispatchQueue.main.async {
//                        self?.labelLoadingInfo?.text = "正在加载[\(resType.name)]..."
//                    }
//                    // Loader.shared.load(resType)
//                    DispatchQueue.main.async {
//                        self?.labelLoadingInfo?.text = "已加载\(resType.name)"
//                    }
//                    Thread.sleep(forTimeInterval: 0.2)
//                }
//            }
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: {})
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
