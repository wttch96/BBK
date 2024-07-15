//
//  Environment.swift
//  TileSetEditor
//
//  Created by Wttch on 2024/7/12.
//

import Foundation
import SwiftUI


private struct PngSaveSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat = 32
}


extension EnvironmentValues {
    var pngSaveSize: CGFloat {
        get {
            self[PngSaveSizeKey.self]
        }
        set {
            self[PngSaveSizeKey.self] = newValue
        }
    }
}
