//
//  ResImage.swift
//  BBK
//
//  Created by Wttch on 2024/6/15.
//

import CoreGraphics
import Foundation

class ResImage: ResBase {
    let type: Int
    let index: Int
    
    let width: Int
    let height: Int
    let number: Int
    let transparent: Bool
    let data: Data
    
    var images: [CGImage] = []
    required init(data: Data, offset: Int) {
        self.type = Int(data[offset])
        self.index = Int(data[offset + 1])
        self.width = Int(data[offset + 2])
        self.height = Int(data[offset + 3])
        self.number = Int(data[offset + 4])
        self.transparent = data[offset + 5] == 2
        
        let len: Int = number * (width / 8 + (width % 8 != 0 ? 1 : 0)) * height * Int(data[offset + 5])
        
        self.data = Data(data[offset + 6..<offset + 6 + len])
        
        createImage()
    }
    
    private func createImage() {
        var tmp = [UInt32](repeating: 0, count: width * height)
        
        var iOfData = 0
        
        if transparent {
            for _ in 0..<number {
                var cnt = 0
                var iOfTmp = 0
                for _ in 0..<height {
                    for _ in 0..<width {
                        if (data[iOfData] << cnt) & 0x80 != 0 {
                            tmp[iOfTmp] = 0x00000000
                        } else {
                            tmp[iOfTmp] = ((Int(data[iOfData]) << (cnt + 1)) & 0x80) != 0 ? 0xff000000 : 0xffffffff
                        }
                        
                        iOfTmp += 1
                        cnt += 2
                        if cnt >= 8 {
                            cnt = 0
                            iOfData += 1
                        }
                    }
                    if cnt > 0 && cnt <= 7 {
                        cnt = 0
                        iOfData += 1
                    }
                    if iOfData % 2 != 0 { iOfData += 1 }
                }
                
                if let image = imageFromARGB32Bitmap(pixels: tmp, width: width, height: height) {
                    self.images.append(image)
                }
            }
        } else {
            for _ in 0..<number {
                var cnt = 0
                var iOfTmp = 0

                for _ in 0..<height {
                    for _ in 0..<width {
                        tmp[iOfTmp] = ((data[iOfData] << cnt) & 0x80) != 0 ? 0xff000000 : 0xffffffff
                        iOfTmp += 1
                        cnt += 1
                        if cnt >= 8 {
                            cnt = 0
                            iOfData += 1
                        }
                    }
                    if cnt != 0 {
                        cnt = 0
                        iOfData += 1
                    }
                }
                
                if let image = imageFromARGB32Bitmap(pixels: tmp, width: width, height: height) {
                    self.images.append(image)
                }
            }
        }
    }
    
    private func imageFromARGB32Bitmap(pixels: [UInt32], width: Int, height: Int) -> CGImage? {
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        var data = pixels // Copy to mutable array
        
        let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count * MemoryLayout<UInt32>.size))
        let cgim = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: width * MemoryLayout<UInt32>.size, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue), provider: providerRef!, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        
        return cgim
    }
}
