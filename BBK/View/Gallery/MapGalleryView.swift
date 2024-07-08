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
        VStack {
            if let map = DatLib.shared.getMap(type: type, index: index) {
                MapView(map: map)
            }
        }
        .toolbar { toolbars }
        .onChange(of: type) { _, _ in
            indexList = DatLib.shared.dataIndex[ResType.map.rawValue]?[type] ?? []
        }
        .onAppear {
            typeList = DatLib.shared.dataIndex[ResType.map.rawValue]?.keys.sorted() ?? []
            indexList = DatLib.shared.dataIndex[ResType.map.rawValue]?[type] ?? []
        }
    }
}

extension MapGalleryView {
    /// 工具栏的类型和索引选择
    @ToolbarContentBuilder
    private var toolbars: some ToolbarContent {
        ToolbarItem(placement: .navigation, content: {
            Picker("", selection: $type, content: {
                ForEach(typeList, id: \.self) { type in
                    Text("Type: \(type)")
                        .tag(type)
                }
            })
        })
        ToolbarItem(placement: .navigation, content: {
            Picker("", selection: $index, content: {
                ForEach(indexList, id: \.self) { index in
                    Text("Index: \(index)")
                        .tag(index)
                }
            })
        })
    }
}

#Preview {
    MapGalleryView()
}

struct MapView: View {
    let map: MapResData

    @State private var tapX: Int = 0
    @State private var tapY: Int = 0
    @State private var mapImage: CGImage? = nil
    @State private var showWalkableLayer: Bool = false
    @State private var showEventLayer: Bool = false

    var body: some View {
        HSplitView {
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    if let mapImage = mapImage {
                        Image(mapImage, scale: 1, label: Text(""))
                            .gesture(SpatialTapGesture().onEnded { loc in
                                self.tapX = Int(loc.location.x) / 16
                                self.tapY = Int(loc.location.y) / 16
                            })
                    }
                    layers
                    Rectangle()
                        .stroke(.purple, lineWidth: 2)
                        .frame(width: 16, height: 16)
                        .offset(x: CGFloat(tapX * 16), y: CGFloat(tapY * 16))
                }
                Spacer()
            }
            VStack {
                Text("地块信息 Index: \(map.getTileIndex(x: tapX, y: tapY))")
                Text("可以行走: \(map.canWalk(x: tapX, y: tapY))")
                if map.eventIds[tapY][tapX] > 0 {
                    Text("事件: \(map.eventIds[tapY][tapX])")
                }
                Spacer()
            }
            .frame(width: 200)
        }
        .navigationTitle(map.name)
        .navigationSubtitle("\(map.width) * \(map.height) 贴图集[\(map.tileIndex)]")
        .onAppear {
            self.mapImage = map.loadMapImage()
        }
        .onChange(of: map) { _, _ in
            self.mapImage = map.loadMapImage()
        }
        .toolbar {
            ToolbarItem {
                Toggle("显示行走", isOn: $showWalkableLayer)
                    .toggleStyle(.checkbox)
            }
            ToolbarItem {
                Toggle("显示事件", isOn: $showEventLayer)
                    .toggleStyle(.checkbox)
            }
        }
    }
}

extension MapView {
    @ViewBuilder
    private var layers: some View {
        ForEach(0..<map.height, id: \.self) { y in
            ForEach(0..<map.width, id: \.self) { x in
                if showWalkableLayer && !map.canWalk(x: x, y: y) {
                    Rectangle()
                        .fill(.red.opacity(0.8))
                        .frame(width: 16, height: 16)
                        .offset(x: CGFloat(x * 16), y: CGFloat(y * 16))
                }
                if showEventLayer && map.eventIds[y][x] > 0 {
                    Rectangle()
                        .fill(.green.opacity(0.8))
                        .frame(width: 16, height: 16)
                        .offset(x: CGFloat(x * 16), y: CGFloat(y * 16))
                }
            }
        }
        .allowsHitTesting(false)
    }
}
