//
//  ContentView.swift
//  TileSetEditor
//
//  Created by Wttch on 2024/6/28.
//

import Combine
import SwiftUI

enum CropType: String {
    case single
    case way8
    case way8Animation
}

struct ContentView: View {
    @State private var url: URL? = nil
    @State private var cellSize: CGFloat = 32
    
    // 点击的坐标
    @State private var selectX: CGFloat? = nil
    @State private var selectY: CGFloat? = nil
    // 边框大小
    @State private var selectWidth: CGFloat = 0
    @State private var selectHeight: CGFloat = 0
    
    @State private var showInspector: Bool = false
    
    @State private var subImage: CGImage? = nil
    @State private var subImages: [CGImage] = []
    
    @State private var cropType: CropType = .way8
    @State private var animationFrame: Int = 1
    
    @State private var anyCancellable: AnyCancellable? = nil
    @State private var curFrame: Int = 1
    
    /// png 保存的大小
    @State private var pngSaveSize: CGFloat = 32
    
    var body: some View {
        NavigationSplitView(sidebar: {
            VStack {}
        }, detail: {
            ZStack {
                VStack {
                    HStack(spacing: 20) {
                        cellSizeTextField
                        cropTypePicker
                        
                        if cropType == .way8Animation {
                            animationFrameTextField
                        }
                        Spacer()
                        
                        pngSaveSizeTextField
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(.thinMaterial)
                    Spacer()
                }
                .zIndex(100)
                HStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            if let url = url,
                               let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
                               let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, nil)
                            {
                                ZStack(alignment: .topLeading) {
                                    Image(image, scale: 1.0, label: Text(""))
                                        .gesture(SpatialTapGesture().onEnded {
                                            onSpatialTapGesture(image, $0)
                                        })
                                    if let selectX = selectX, let selectY = selectY {
                                        Rectangle()
                                            .stroke(.pink)
                                            .frame(width: selectWidth * CGFloat(animationFrame), height: selectHeight)
                                            .offset(x: selectX * selectWidth, y: selectY * selectHeight)
                                    }
                                }
                            }
                            
                            if let subImage = subImage {
                                HStack {
                                    Image(subImage, scale: 1.0, label: Text(""))
                                    VStack(alignment: .leading) {
                                        Text("宽: \(subImage.width)")
                                        Text("高: \(subImage.height)")
                                    }
                                    .bold()
                                    
                                    Button("保存") {
                                        subImage
                                            .resize(width: pngSaveSize / cellSize * selectWidth * CGFloat(animationFrame), height: pngSaveSize / cellSize * selectHeight)!
                                            .savePNG(to: URL(string: "file:///Users/wttch/Downloads/TileEditor/subImage.png")!)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .offset(y: 48)
                    }
                    
                    VStack {
                        switch cropType {
                        case .single:
                            if let image = subImages.first {
                                SingleCroppingView(image: image)
                            }
                        case .way8:
                            if !subImages.isEmpty {
                                Way8TilesetView(image: subImages, size: cellSize, curFrame: 0)
                            }
                            
                        default:
                            Way8TilesetView(image: subImages, size: cellSize, curFrame: curFrame)
                        }
                        Spacer()
                    }
                    .offset(y: 48)
                    
                    Spacer()
                }
            }
        })
        .navigationTitle("主题")
        .navigationSubtitle("测试")
        .environment(\.pngSaveSize, pngSaveSize)
        .onAppear {
            selectWidth = cellSize
            selectHeight = cellSize
        }
        .onChange(of: cropType) { _, newValue in
            // 重置选择
            selectX = nil
            selectY = nil
            if newValue == .way8 {
                animationFrame = 1
            }
        }
        .inspector(isPresented: $showInspector) {
            Text("Right")
                .inspectorColumnWidth(ideal: 100.0)
                .toolbar {
                    ToolbarItem {
                        Button("测试") {
                            showInspector.toggle()
                        }
                    }
                }
        }
        .toolbar {
            ToolbarItem(content: {
                Button("打开文件") {
                    let openPanel = NSOpenPanel()
                    openPanel.title = "选择图片"
                    openPanel.prompt = "选择"
                    openPanel.canChooseFiles = true
                    openPanel.canChooseDirectories = false
                    openPanel.allowsMultipleSelection = false
                    openPanel.allowedContentTypes = [.png]
                    
                    if openPanel.runModal() == .OK, let url = openPanel.url {
                        self.url = url
                    }
                }
            })
        }
        .onAppear {
            url = URL(string: "file:///Users/wttch/资源/PRGMaker/中国风rpg游戏地图元件-vx用中国风元件_爱给网_aigei_com/TileA2.png")
            
            self.anyCancellable = Timer.publish(every: 0.2, on: .main, in: .common)
                .autoconnect()
                .sink(receiveValue: { _ in
                    curFrame += 1
                    curFrame %= animationFrame
                })
        }
    }
}

// MARK: UI

extension ContentView {
    /// 格子像素大小的输入框
    private var cellSizeTextField: some View {
        TextField("", value: $cellSize, formatter: NumberFormatter())
            .bold()
            .foregroundColor(.gray)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(width: 48)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor)
            )
    }
    
    /// 动画帧数的输入框
    private var animationFrameTextField: some View {
        TextField("", value: $animationFrame, formatter: NumberFormatter())
            .bold()
            .foregroundColor(.gray)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(width: 48)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor)
            )
    }

    /// 保存图片大小
    private var pngSaveSizeTextField: some View {
        TextField("", value: $pngSaveSize, formatter: NumberFormatter())
            .bold()
            .foregroundColor(.gray)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(width: 48)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor)
            )
    }
    
    /// 裁剪的类型选择
    private var cropTypePicker: some View {
        Picker("选择格式", selection: $cropType, content: {
            Text("单块")
                .tag(CropType.single)
            Text("8-Way")
                .tag(CropType.way8)
            Text("动画")
                .tag(CropType.way8Animation)
        })
        .pickerStyle(.menu)
        .frame(width: 140)
    }
}

// MARK: ACTION

extension ContentView {
    private func onSpatialTapGesture(_ image: CGImage, _ value: SpatialTapGesture.Value) {
        let x = value.location.x
        let y = value.location.y
        switch cropType {
        case .single:
            selectX = floor(x / cellSize)
            selectY = floor(y / cellSize)
            selectWidth = cellSize
            selectHeight = cellSize
            
            subImages = [image.cropping(to: CGRect(x: selectX! * selectWidth, y: selectY! * selectHeight, width: selectWidth, height: selectHeight))!]
            subImage = subImages.first
        case .way8:
            fallthrough
        case .way8Animation:
            selectX = floor(x / cellSize / 2)
            selectY = floor(y / cellSize / 3)
            selectWidth = cellSize * 2
            selectHeight = cellSize * 3
            
            subImage = image.cropping(to: CGRect(x: (selectX! + CGFloat(animationFrame - 1)) * cellSize * 2, y: selectY! * cellSize * 3, width: cellSize * 2, height: cellSize * 3))
            subImages = []
            for i in 0 ..< animationFrame {
                subImages.append(image.cropping(to: CGRect(x: (selectX! + CGFloat(i)) * cellSize * 2, y: selectY! * cellSize * 3, width: cellSize * 2, height: cellSize * 3))!)
            }
        }
    }
}

#Preview {
    ContentView()
}
