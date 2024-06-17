//
//  DatLib.swift
//  BBK
//
//  Created by Wttch on 2024/6/14.
//

import Foundation

class DatLib {
    private let url: URL
    private let data: Data
    
    private var dataOffset: [Int: Int] = [:]
    
    var dataIndex: [Int: [Int: [Int]]] = [:]
    
    private var imageCache: [Int: ResImage] = [:]
    private var mapCache: [Int: ResMap] = [:]
    
    static let shared = DatLib(url: Bundle.main.url(forResource: "DAT", withExtension: ".LIB")!)
    
    private init(url: URL) {
        self.url = url
        self.data = try! Data(contentsOf: url)
        
        getAllResOffset()
    }
    
    func getGut(type: Int, index: Int) -> ResGut? {
        guard let offset = getDataOffset(resType: 1, type: type, index: index) else { return nil }
        
        return ResGut(data: data, offset: offset)
    }
    
    func getMap(type: Int, index: Int) -> ResMap? {
        guard let offset = getDataOffset(resType: ResType.map.rawValue, type: type, index: index) else { return nil }
        
        let resMap = self.mapCache[offset] ?? ResMap(data: data, offset: offset)
        
        self.mapCache[offset] = resMap
        
        return resMap
    }
    
    func getImage(resType: ResType, type: Int, index: Int) -> ResImage? {
        guard let offset = getDataOffset(resType: resType.rawValue, type: type, index: index) else { return nil }
        let key = getKey(resType: resType.rawValue, type: type, index: index)
        if let cache = imageCache[key] {
            return cache
        } else {
            let image = ResImage(data: data, offset: offset)
            imageCache[key] = image
            return image
        }
    }
    
    func getGood(type: Int, index: Int) -> GoodBase? {
        guard let offset = getDataOffset(resType: ResType.grs.rawValue, type: type, index: index) else { return nil }
        
        let good = GoodBase(data: data, offset: offset)
        
        return good
    }
    
    private func getAllResOffset() {
        dataOffset = [:]
        // 初始化 i 和 j
        var i = 0x10 // 16
        var j = 0x2000 // 8192
        
        while data[i] != 255 {
            let resType = Int(data[i])
            let type = Int(data[i + 1])
            let index = Int(data[i + 2])
            let key = getKey(resType: resType, type: type, index: index)
            
            if dataIndex[resType] == nil {
                dataIndex[resType] = [:]
            }
            if dataIndex[resType]![type] == nil {
                dataIndex[resType]![type] = []
            }
            
            dataIndex[resType]![type]!.append(index)
            
            i += 3
            // 读取 block, low, high
            let block = Int(data[j])
            let low = Int(data[j+1])
            let high = Int(data[j+2])
            j += 3
            // 计算 value
            let value = block * 0x4000 | (high << 8 | low)
            
            // 将 key-value 对存入字典
            dataOffset[key] = value
        }
    }
    
    private func getDataOffset(resType: Int, type: Int, index: Int) -> Int? {
        let key = getKey(resType: resType, type: type, index: index)
        return dataOffset[key]
    }
    
    private func getKey(resType: Int, type: Int, index: Int) -> Int {
        return resType << 16 | type << 8 | index
    }

    private func getKey(resType: UInt8, type: UInt8, index: UInt8) -> Int {
        return getKey(resType: Int(resType), type: Int(type), index: Int(index))
    }
}
