//
//  ScriptGalleryView.swift
//  BBK
//
//  Created by Wttch on 2024/6/18.
//

import SwiftUI

struct ScriptGalleryView: View {
    @State private var typeList: [Int] = []
    @State private var selectionType: Int = 0
    @State private var indexList: [Int] = []
    @State private var selectionIndex: Int = 0
    @State private var script: ResScript? = nil
    @State private var executor: ScriptProcess? = nil

    var body: some View {
        VStack {
            HStack {
                Picker(selection: $selectionType, content: {
                    ForEach(typeList, id: \.self) { type in
                        Text("第 \(type) 章")
                            .tag(type)
                    }
                }, label: {
                    
                })
                Picker(selection: $selectionIndex, content: {
                    ForEach(indexList, id: \.self) { index in
                        Text("第 \(index) 节")
                            .tag(index)
                    }
                }, label: { })
            }
            .frame(width: 200)

            VStack {
                if let script = self.script,
                   let executor = self.executor
                {
                    Text("\(script.description)")
                    Text("场景事件个数: \(script.numSceneEvent)")

                    ForEach(0 ..< executor.commands.count, id: \.self) { i in
                        HStack {
                            Text("\(String(describing: type(of: executor.commands[i])))")
                                .frame(width: 200)
                            Text("\(executor.commands[i])")

                            Spacer()
                        }
                    }
                    Spacer()
                }
            }

            Spacer()
        }
        .onChange(of: selectionType) { _, _ in
            indexList = DatLib.shared.dataIndex[ResType.gut.rawValue]?[selectionType] ?? []
            selectionIndex = 0
        }
        .onChange(of: selectionIndex) { _, _ in
            script = DatLib.shared.getScript(type: selectionType, index: selectionIndex)
            if let script = self.script {
                executor = ScriptProcess(script: script)
            }
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
