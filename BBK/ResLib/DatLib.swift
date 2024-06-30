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
    
    private var mapCache: [Int: ResMap] = [:]
    
    static let shared = DatLib(url: Bundle.main.url(forResource: "DAT", withExtension: ".LIB")!)
    
    private var images: [ResType: [Int: [Int:ImageResData]]] = [:]
    
    private init(url: URL) {
        self.url = url
        self.data = try! Data(contentsOf: url)
        
        loadData()
    }
    
    func loadData() {
        getAllResOffset()
        
        loadImages()
    }
    
    private func loadImages() {
        let time = Date()
        print("开始加载 images..")
        let imageTypes: [ResType] = [.til, .acp, .gdp, .ggj, .pic]
        for t in imageTypes {
            images[t] = [:]
            for (type, indeies) in dataIndex[t.rawValue] ?? [:] {
                images[t]![type] = [:]
                for index in indeies {
                    images[t]![type]![index] = loadImage(resType: t, type: type, index: index)
                }
            }
        }
        print("image 资源加载完毕, 用时:\(Date().timeIntervalSince1970 - time.timeIntervalSince1970)")
    }
    
    private func loadImage(resType: ResType, type: Int, index: Int) -> ImageResData? {
        guard let offset = getDataOffset(resType: resType.rawValue, type: type, index: index) else { return nil }
        let key = getKey(resType: resType.rawValue, type: type, index: index)
    
        let image = ImageResData(data: data, start: offset)
        return image
    }
    
    func getScript(type: Int, index: Int) -> ScriptResData? {
        guard let offset = getDataOffset(resType: ResType.gut.rawValue, type: type, index: index) else { return nil }
        
        return ScriptResData(data: data, start: offset)
    }
    
    func getMap(type: Int, index: Int) -> ResMap? {
        guard let offset = getDataOffset(resType: ResType.map.rawValue, type: type, index: index) else { return nil }
        
        let resMap = mapCache[offset] ?? ResMap(data: data, offset: offset)
        
        mapCache[offset] = resMap
        
        return resMap
    }
    
    func getImage(resType: ResType, type: Int, index: Int) -> ImageResData? {
        return images[resType]?[type]?[index]
    }
    
    func getGoods(type: GoodType?, index: Int) -> Goods? {
        guard let type = type else { return nil }
        guard let offset = getDataOffset(resType: ResType.grs.rawValue, type: type.rawValue, index: index) else { return nil }
        
        var extra: (any GoodsExtra.Type)!
        
        switch type {
        case .helmet: fallthrough
        case .cloth: fallthrough
        case .boot: fallthrough
        case .armor: fallthrough
        case .brace:
            extra = GoodsEuqipmentExtra.self
        default:
            return nil
        }
        
        return Goods(data: data, offset: offset, extra: { extra.init($0) })
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
            let low = Int(data[j + 1])
            let high = Int(data[j + 2])
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
