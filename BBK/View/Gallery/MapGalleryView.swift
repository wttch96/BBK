//
//  MapGalleryView.swift
//  BBK
//
//  Created by Wttch on 2024/6/17.
//

import SwiftUI

struct MapGalleryView: View {
    
    @State private var typeList: [Int] = []
    @State private var type: Int = 1
    @State private var indexList: [Int] = []
    @State private var index: Int = 1
    
    var body: some View {
            NavigationSplitView(sidebar: {
                List(selection: $type) {
                    ForEach(typeList, id: \.self) { type in
                        Text("Type: \(type)")
                            .tag(type)
                    }
                }
            }, detail: {
                Form {
                    ForEach(indexList, id: \.self) { i in
                        if let map = DatLib.shared.getMap(type: type, index: i) {
                            MapView(map: map)
                        }
                    }
                }
                .formStyle(.grouped)
            })
            .onAppear {
                typeList = DatLib.shared.dataIndex[ResType.map.rawValue]?.keys.sorted() ?? []
                indexList = DatLib.shared.dataIndex[ResType.map.rawValue]?[type] ?? []
            }
    }
}

#Preview {
    MapGalleryView()
}


struct MapView: View {
    let map: ResMap
    
    @State private var showMap = false
    @State private var tapX: Int = 0
    @State private var tapY: Int = 0
    
    var body: some View {
        Section(map.name, content: {
            HStack {
                VStack {
                    Text("地图大小: \(map.width) * \(map.height)")
                    Text("地图贴图Index: \(map.tileIndex)")
                    Button("显示地图", action: {
                        showMap.toggle()
                    })
                    if showMap {
                        ZStack(alignment: .topLeading) {
                            Image(map.image!, scale: 1, label: Text(""))
                                .gesture(SpatialTapGesture().onEnded({ loc in
                                    self.tapX = Int(loc.location.x) / 16
                                    self.tapY = Int(loc.location.y) / 16
                                }))
                            
                            ForEach(0..<map.height, id: \.self) { y in
                                ForEach(0..<map.width, id: \.self) { x in
                                    if !map.canWalk(x: x, y: y) {
                                        Rectangle()
                                            .fill(.red.opacity(0.8))
                                            .frame(width: 16, height: 16)
                                            .offset(x: CGFloat(x * 16), y: CGFloat(y * 16))
                                    }
                                    if map.eventIds[y][x] > 0 {
                                        Rectangle()
                                            .fill(.green.opacity(0.8))
                                            .frame(width: 16, height: 16)
                                            .offset(x: CGFloat(x * 16), y: CGFloat(y * 16))
                                    }
                                }
                            }
                            .allowsHitTesting(false)
                            Rectangle()
                                .stroke(.purple, lineWidth: 2)
                                .frame(width: 16, height: 16)
                                .offset(x: CGFloat(tapX * 16), y: CGFloat(tapY * 16))
                        }
                    }
                }
                VStack {
                    Text("地块信息 Index: \(map.getTileIndex(x: tapX, y: tapY))")
                    Text("可以行走: \(map.canWalk(x: tapX, y: tapY))")
                    if map.eventIds[tapY][tapX] > 0 {
                        Text("事件: \(map.eventIds[tapY][tapX])")
                    }
                    Spacer()
                }
            }
        })
    }
}
