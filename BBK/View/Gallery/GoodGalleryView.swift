//
//  GoodsView.swift
//  BBK
//
//  Created by Wttch on 2024/6/17.
//

import SwiftUI

struct GoodGalleryView: View {
    @State var type: GoodType = .helmet

    @State var goodIndexList: [Int] = []
    @State var goods: [GoodBase] = []

    var body: some View {
        HSplitView {
            List(selection: $type, content: {
                ForEach(GoodType.allCases, id: \.self) { t in
                    Text(t.name)
                        .tag(t)
                }
            })
            .frame(width: 200)
            Table(goods) {
                TableColumn("类型", value: \.id.type.description)
                    .width(32)
                TableColumn("索引", value: \.id.index.description)
                    .width(32)
                TableColumn("名称", value: \.name)
                    .width(64)
                TableColumn("图标") { good in
                    if let image = DatLib.shared.getImage(resType: .gdp, type: type.rawValue, index: good.imageIndex) {
                        ForEach(0 ..< image.images.count, id: \.self) { i in
                            Image(image.images[i], scale: 1, label: Text(""))
                        }
                    }
                }.width(32)
                TableColumn("持续回合", value: \.sumRound.description)
                    .width(64)
                TableColumn("买入价", value: \.buyPrice.description)
                    .width(64)
                TableColumn("卖出价", value: \.sellPrice.description)
                    .width(64)
                TableColumn("描述", value: \.description)
            }
        }
        .onAppear {
            goodIndexList = DatLib.shared.dataIndex[ResType.grs.rawValue]?[type.rawValue] ?? []
            print("Good Index List: \(goodIndexList)")
            goods = goodIndexList.map { DatLib.shared.getGood(type: type, index: $0) }.filter { $0 != nil }.map { $0! }
        }
        .onChange(of: type) { _, _ in
            goods = goodIndexList.map { DatLib.shared.getGood(type: type, index: $0) }.filter { $0 != nil }.map { $0! }
        }
    }
}

#Preview {
    GoodGalleryView()
}
