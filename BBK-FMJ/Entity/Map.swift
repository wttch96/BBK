//
//  Map.swift
//  BBK-FMJ
//
//  Created by Wttch on 2024/7/14.
//

import Foundation

struct Map: Codable {
    let name: String
    let width: Int
    let height: Int
    let tiles: [[Int]]
    

    static func load(name: String) -> Map? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            print("文件 \(name) 不存在...")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Map.self, from: data)
        } catch {
            print("文件 \(name) 读取失败:\(error)")
        }

        return nil
    }
}
