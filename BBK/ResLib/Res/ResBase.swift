//
//  ResBase.swift
//  BBK
//
//  Created by Wttch on 2024/6/15.
//

import Foundation

/// 资源 id
struct ResID: Hashable {
    let type: Int
    let index: Int
}

struct ResData {
    let data: Data
    let offset: Int
    
    init(data: Data, offset: Int) {
        self.data = Data(data[offset..<data.count])
        self.offset = offset
    }
    
    @inlinable subscript (index: Data.Index) -> UInt8 {
        return data[index]
    }
    
    @inlinable subscript (bounds: Range<Data.Index>) -> Data {
        return data[bounds]
    }
    
    @inlinable var count: Int { data.count }
}

extension ResData {
    func checkIndex(_ start: Int) -> Bool {
        if start >= count {
            print("Data get string error: start \(start), length: \(count).")
            return false
        }
        
        return true
    }
    
    func getString(start: Int) -> String {
        guard checkIndex(start) else {
            return ""
        }
        
        var i = 0
        
        while start + i < count && self[start + i] != 0 {
            i += 1
        }
        // 通过指定范围创建子数据
        let subData: Data = self[start ..< (start + i)]
        
        // 尝试将子数据转换为字符串，使用 GBK 编码
        if let string = String(data: subData, encoding: .gbk) {
            return string
        }
        
        return ""
    }
    
    func get2BytesUInt(start: Int) -> Int {
        guard checkIndex(start) else { return 0 }
        
        let value = UInt16(self[start]) | (UInt16(self[start + 1]) << 8)
        
        return Int(value)
    }
    
    func get4BytesUInt(start: Int) -> Int {
        guard checkIndex(start), checkIndex(start + 3) else { return 0 }
        
        let value: Int = (Int(self[start]) & 0xFF) | (Int(self[start + 1]) << 8 & 0xFF00) |
            (Int(self[start + 2] << 16) & 0xFF0000) | (Int(self[start + 3]) << 24)
        
        return value
    }
    
    func get2BytesInt(start: Int) -> Int {
        // 提取两个字节，并合并为一个有符号的 Int16
        let byte1 = Int16(self[start])
        let byte2 = Int16(self[start + 1])

        // 合并低字节和高字节，注意高字节的符号位
        let value = (byte1 & 0x00FF) | ((byte2 & 0x7F) << 8)
        if (byte2 & 0x80) != 0 {
            // 如果最高位为 1，表示负数
            return Int(-value)
        } else {
            // 返回正数
            return Int(value)
        }
    }
    
    func get1ByteInt(start: Int) -> Int {
        let byte = Int16(self[start]) & 0x7F

        if (byte & 0x80) != 0 {
            // 如果最高位为 1，表示负数
            return Int(-byte)
        } else {
            // 返回正数
            return Int(byte)
        }
    }
    
    func get1ByteUInt(start: Int) -> Int {
        return Int(self[start] & 0xFF)
    }
}


protocol ResBase {
    init(data: ResData)
    
    var data: ResData { get }
}

extension ResBase {
    init(data: Data, offset: Int) {
        self.init(data: ResData(data: data, offset: offset))
    }
}
