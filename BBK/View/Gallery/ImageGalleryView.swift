//
//  ImageGalleryView.swift
//  BBK
//
//  Created by Wttch on 2024/6/15.
//

import Foundation
import SwiftUI

struct ImageGalleryView: View {
    let resType: ResType
    
    @State private var type: Int = 1
    private let walkingSprite = WalkingSprite(type: 1, index: 1)
    @State private var image: CGImage? = nil
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $type, content: {
                ForEach(indexes.keys.sorted(), id: \.self, content: { k in
                    Text("Type: \(k)")
                        .tag(k)
                })
            })
        }, detail: {
            Form {
                ForEach(selectIndexes, id: \.self, content: { index in
                    Section("Index: \(index)", content: {
                        if let image = DatLib.shared.getImage(resType: resType, type: type, index: index) {
                            Text("W:\(image.width) H:\(image.height)")
                            Text("\(image.images.count)")
                            if let image = image.image {
                                Image(image, scale: 1, label: Text(""))
                            }
                            Button("左", action: {
                                walkingSprite.walk(.west)
                                self.image = walkingSprite.getImage()
                            })
                            Button("右", action: {
                                walkingSprite.walk(.east)
                                self.image = walkingSprite.getImage()
                            })
                            Button("上", action: {
                                walkingSprite.walk(.north)
                                self.image = walkingSprite.getImage()
                            })
                            Button("下", action: {
                                walkingSprite.walk(.south)
                                self.image = walkingSprite.getImage()
                            })
                            if let image = self.image {
                                Image(image, scale: 1, label: Text(""))
                            }
                        }
                    })
                })
            }
            .formStyle(.grouped)
        })
    }
    
    private var indexes: [Int: [Int]] {
        return DatLib.shared.dataIndex[resType.rawValue] ?? [:]
    }
    
    private var selectIndexes: [Int] {
        return (DatLib.shared.dataIndex[resType.rawValue] ?? [:])[type] ?? []
    }
}

#Preview {
    ImageGalleryView(resType: .til)
}
