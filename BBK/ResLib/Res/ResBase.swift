//
//  ResBase.swift
//  BBK
//
//  Created by Wttch on 2024/6/15.
//

import Foundation

protocol ResBase {
    init(data: Data, offset: Int)
    
    var type: Int { get }
    var index: Int { get }
}

