//
//  Way8TilesetView.swift
//  TileSetEditor
//
//  Created by Wttch on 2024/6/29.
//

import Combine
import SpriteKit
import SwiftUI

struct SKViewWrapper: NSViewRepresentable {
    let skView: SKView
    
    func updateNSView(_ nsView: NSViewType, context: Context) {}
    
    func makeNSView(context: Context) -> some NSView {
        return skView
    }
}

struct Way8TilesetView: View {
    let images: [CGImage]
    let size: CGFloat
    let croppingImages: [BlobCropping]
    let curFrame: Int
    
    @State private var timer: AnyCancellable? = nil
    
    @Environment(\.pngSaveSize) private var saveSize: CGFloat
    @State private var skView: SKView? = nil
    
    private let rootPath = "/Users/wttch/Downloads/TileEditor"
    
    init(image: [CGImage], size: CGFloat, curFrame: Int) {
        self.images = image
        self.size = size
        self.curFrame = curFrame
        self.croppingImages = images.map { BlobCropping(image: $0, size: size) }
    }
    
    var croppingImage: BlobCropping {
        return croppingImages[curFrame]
    }
    
    var body: some View {
        VStack {
            if let skView = skView {
                SKViewWrapper(skView: skView)
            }
            
            if !croppingImages.isEmpty {
                ScrollView {
                    Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                        ForEach(0..<6, id: \.self) { row in
                            GridRow {
                                ForEach(0..<8, id: \.self) { col in
                                    let index = BlobCropping.examples[row][col]
                                    if let image = croppingImage.copy(BlobCropping.adjacencies[index]) {
                                        showCGImage(image)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Button("保存") {
                self.skView = saveAllCroppingPNG()
            }
        }
        .onAppear {
            print(SKTileAdjacencyMask(rawValue: 0b00000011) == .adjacencyUp | .adjacencyUpperRight)
        }
    }
}

extension Way8TilesetView {
    @ViewBuilder
    private func showCGImage(_ cgImage: CGImage?) -> some View {
        if let image = cgImage {
            Image(image, scale: 1.0, label: Text(""))
        } else {
            Rectangle()
                .frame(width: size, height: size)
                .opacity(0)
        }
    }
    
    private func showAdjacency(_ show: Bool) -> some View {
        Rectangle()
            .fill(show ? .pink : .gray)
            .frame(width: size, height: size)
    }
    
    @ViewBuilder
    private func showAdjacencyImage(_ i: Int, _ image: CGImage) -> some View {
        let adjacency = [
            0b10000000,
            0b00000001,
            0b00000010,
            0b01000000,
            0b00000100,
            0b00100000,
            0b00010000,
            0b00001000,
        ].map { i & $0 == $0 }
        VStack {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    showAdjacency(adjacency[0])
                    showAdjacency(adjacency[1])
                    showAdjacency(adjacency[2])
                }
                GridRow {
                    showAdjacency(adjacency[3])
                    showCGImage(image)
                    showAdjacency(adjacency[4])
                }
                GridRow {
                    showAdjacency(adjacency[5])
                    showAdjacency(adjacency[6])
                    showAdjacency(adjacency[7])
                }
            }
            Text("\(i)")
                .bold()
        }
    }
    
    private func createImage(_ generator: (CGContext) -> Void) -> CGImage? {
        guard let context = CGContext(
            data: nil, width: 32, height: 32,
            bitsPerComponent: images.first!.bitsPerComponent,
            bytesPerRow: images.first!.bitsPerComponent * 32,
            space: images.first!.colorSpace!,
            bitmapInfo: images.first!.bitmapInfo.rawValue)
        else {
            return nil
        }
        
        generator(context)
        
        return context.makeImage()
    }
    
    private func saveAllCroppingPNG() -> SKView? {
        
        for (i, cropping) in BlobCropping.adjacencies {
            if let image = croppingImages[0].copy(cropping) {
                image.savePNG(to: URL(string: "file:///Users/wttch/Downloads/TileEditor/(\(i).png")!)
            }
        }
        
        return nil
    }
}

class TScene: SKScene {
    let tileSet: SKTileSet
    
    init(tileSet: SKTileSet) {
        self.tileSet = tileSet
        
        super.init(size: CGSize(width: 1000, height: 800))
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func didMove(to view: SKView) {
        let map = SKTileMapNode(tileSet: tileSet, columns: 24, rows: 15, tileSize: CGSize(width: 32, height: 32))
        map.setTileGroup(tileSet.defaultTileGroup, forColumn: 10, row: 10)
        map.setTileGroup(tileSet.tileGroups.first(where: { $0.name == "" }), forColumn: 2, row: 5)
        map.setTileGroup(tileSet.tileGroups.first, forColumn: 4, row: 5)
        addChild(map)
        let label = SKLabelNode(text: "Wttch")
        label.fontColor = .systemPink
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        label.position = CGPoint(x: 0, y: 0)
        addChild(label)
    }
}

extension SKTileAdjacencyMask {
    static func | (lhs: Self, rhs: Self) -> Self {
        return lhs.union(rhs)
    }
}
