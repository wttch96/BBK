//
//  SingleCroppingView.swift
//  TileSetEditor
//
//  Created by Wttch on 2024/7/12.
//

import SwiftUI

struct SingleCroppingView: View {
    let image: CGImage
    var body: some View {
        VStack {
            Image(image, scale: 1.0, label: Text(""))
            
            Button("保存") {
                
            }
        }
    }
}
