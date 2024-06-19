//
//  ContentView.swift
//  BBK
//
//  Created by Wttch on 2024/6/14.
//

import SwiftUI

struct ContentView: View {
    @State var images: [CGImage] = []
    @State var selection: ResType = .gut
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $selection, content: {
                ForEach(ResType.allCases, id: \.self) { resType in
                    Text(resType.name)
                        .tag(resType)
                }
            })
        }, detail: {
            switch selection {
            case .gut:
                ScriptGalleryView()
            case .map:
                MapGalleryView()
            case .ars:
                EmptyView()
            case .mrs:
                EmptyView()
            case .srs:
                EmptyView()
            case .grs:
                GoodsView()
            case .til:
                ImageGalleryView(resType: selection)
            case .acp:
                ImageGalleryView(resType: selection)
            case .gdp:
                ImageGalleryView(resType: selection)
            case .ggj:
                ImageGalleryView(resType: selection)
            case .pic:
                ImageGalleryView(resType: selection)
            case .mlr:
                EmptyView()
            }
            
        })
    }
}

#Preview {
    ContentView()
}
