//
//  GoodsView.swift
//  BBK
//
//  Created by Wttch on 2024/6/17.
//

import SwiftUI

struct GoodsView: View {
    
    @State var typeList: [Int] = []
    @State var type: Int = 1
    
    @State var goodIndexList: [Int] = []
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), sidebar: {
            List(selection: $type, content: {
                ForEach(typeList, id: \.self) { t in
                    Text("Type: \(t)")
                        .tag(t)
                }
            })
        }, detail: {
            ScrollView {
                Form {
                    ForEach(goodIndexList, id: \.self) { goodIndex in
                        if let good = DatLib.shared.getGood(type: type, index: goodIndex) {
                            Section("\(goodIndex):\(good.name)", content: {
                                HStack {
                                    Text("买入价:\(good.buyPrice)")
                                    Text("卖出价:\(good.sellPrice)")
                                    Text("可用:\(String(good.enable, radix: 2))")
                                    Text("持续回合:\(good.sumRound)")
                                    Spacer()
                                }
                                if let image = DatLib.shared.getImage(resType: .gdp, type: type, index: good.imageIndex) {
                                    ForEach(0..<image.images.count, id: \.self) { i in
                                        Image(image.images[i], scale: 1, label: Text(""))
                                    }
                                }
                                Text(good.description)
                            })
                        }
                    }
                }
                .formStyle(.grouped)
            }
        })
        .onAppear {
            typeList = DatLib.shared.dataIndex[ResType.grs.rawValue]?.keys.sorted() ?? []
            print("Goods Type List: \(typeList)")
            goodIndexList = DatLib.shared.dataIndex[ResType.grs.rawValue]?[type] ?? []
            print("Good Index List: \(goodIndexList)")
        }
        .onChange(of: type, { oldValue, newValue in
            goodIndexList = DatLib.shared.dataIndex[ResType.grs.rawValue]?[newValue] ?? []
            print("Good Index List: \(goodIndexList)")
        })
    }
}

#Preview {
    GoodsView()
}
