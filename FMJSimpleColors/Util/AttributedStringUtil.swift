//
//  AttributedStringUtil.swift
//  FMJ
//
//  Created by Wttch on 2025/1/6.
//

import AppKit
import Foundation

enum AttributedStringUtil {}

extension String {
    /// 加粗
    /// - Parameter size: 字体大小
    func bold(_ size: CGFloat) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: size)
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }

    /// 正常
    /// - Parameter weight: 字体粗细
    func regular(_ size: CGFloat) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: size)
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }
}
