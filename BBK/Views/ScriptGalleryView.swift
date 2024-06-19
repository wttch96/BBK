//
//  ScriptGalleryView.swift
//  BBK
//
//  Created by Wttch on 2024/6/18.
//

import SwiftUI

struct ScriptGalleryView: View {
    @State private var typeList: [Int] = []
    @State private var selectionType: Int = 1
    @State private var indexList: [Int] = []

    var body: some View {
        HStack {
            List(selection: $selectionType, content: {
                ForEach(typeList, id: \.self) { type in
                    Text("Type \(type)")
                        .tag(type)
                }
            })

            Form {
                ForEach(indexList, id: \.self) { index in
                    if let script = DatLib.shared.getScript(type: selectionType, index: index) {
                        Section("Index \(index)", content: {
                            Text("\(script.description)")
                            Text("场景事件个数: \(script.numSceneEvent)")

                            let executor = ScriptProcess(script: script)
                        })
                    }
                }
            }
            .formStyle(.grouped)
        }
        .onChange(of: selectionType) { _, _ in

            indexList = DatLib.shared.dataIndex[ResType.gut.rawValue]?[selectionType] ?? []
        }
        .onAppear {
            typeList = DatLib.shared.dataIndex[ResType.gut.rawValue]?.keys.sorted() ?? []
            indexList = DatLib.shared.dataIndex[ResType.gut.rawValue]?[selectionType] ?? []
        }
    }
}

#Preview {
    ScriptGalleryView()
}
