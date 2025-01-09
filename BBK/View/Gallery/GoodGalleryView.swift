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
    @State var goods: [Goods] = []

    var body: some View {
        HSplitView {
            List(selection: $type, content: {
                ForEach(GoodType.allCases, id: \.self) { t in
                    Text(t.name)
                        .tag(t)
                }
            })
            .frame(width: 80)

            List(goods) { goodsView($0) }
        }
        .onAppear {
            goodIndexList = DatLib.shared.dataIndex[ResType.grs.rawValue]?[type.rawValue] ?? []
            print("Good Index List: \(goodIndexList)")
            goods = goodIndexList.map { DatLib.shared.getGoods(type: type, index: $0) }.filter { $0 != nil }.map { $0! }
        }
        .onChange(of: type) { _, _ in
            goods = goodIndexList.map { DatLib.shared.getGoods(type: type, index: $0) }.filter { $0 != nil }.map { $0! }
        }
    }
}

extension GoodGalleryView {
    func goodsView(_ goods: Goods) -> some View {
        VStack(alignment: .leading) {
            HStack {
                HStack {
                    if let image = DatLib.shared.getImage(resType: .gdp, type: type.rawValue, index: goods.imageIndex),
                       let image = image.images.first
                    {
                        Image(image, scale: 1, label: Text(""))
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text(goods.name)
                            Text("\(goods.id.index)")
                                .font(.footnote)
                                .padding(.horizontal, 4)
                                .background {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(.pink)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(.pink.opacity(0.8))
                                    }
                                }
                        }
                        Text(goods.description)
                            .font(.footnote)
                    }
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("买入价: \(goods.buyPrice)")
                    Text("卖出价: \(goods.sellPrice)")
                    Text("持续回合: \(goods.sumRound)")
                }
            }
            if let extra = goods.extra as? GoodsEuqipmentExtra {
                VStack(alignment: .leading) {
                    HStack {
                        Text("真气上限: \(extra.mpMax)")
                        Text("血量上限: \(extra.hpMax)")
                        Text("防御: \(extra.defence)")
                        Text("攻击: \(extra.attack)")
                        Text("灵力: \(extra.psychic)")
                        Text("身法: \(extra.agility)")
                        Text("幸运: \(extra.luck)")
                    }
                    HStack {
                        if extra.effect.`poison` {
                            Text("毒")
                                .padding(.horizontal, 4)
                                .background(.purple)
                        }
                        if extra.effect.confusion {
                            Text("乱")
                                .padding(.horizontal, 4)
                                .background(.orange)
                        }
                        if extra.effect.seal {
                            Text("封")
                                .padding(.horizontal, 4)
                                .background(.gray)
                        }
                        if extra.effect.sleep {
                            Text("眠")
                                .padding(.horizontal, 4)
                                .background(.indigo)
                        }
                    }
                }
                .padding()
                .border(.orange)
            }
        }
    }
}

#Preview {
    GoodGalleryView()
}
