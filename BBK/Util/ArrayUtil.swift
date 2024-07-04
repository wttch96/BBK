//
//  ArrayUtil.swift
//  BBK
//
//  Created by Wttch on 2024/7/2.
//

import Foundation


extension Array {
    init<T>(_ dim1: Int, _ dim2: Int, value: T) where Element == Array<T> {
        self.init(repeating: [T].init(repeating: value, count: dim2), count: dim1)
    }
}
