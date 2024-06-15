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
    
    let imageResTypes: [ResType] = [.til, .acp, .gdp, .ggj, .pic]
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $selection , content: {
                ForEach(ResType.allCases, id: \.self) { resType in
                    Text(resType.name)
                        .tag(resType)
                }
            })
        }, detail: {
            if self.imageResTypes.contains(selection) {
                ImageGalleryView(resType: selection)
            }
        })
    }
}

#Preview {
    ContentView()
}
