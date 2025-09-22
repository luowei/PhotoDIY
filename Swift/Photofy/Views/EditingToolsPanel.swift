import SwiftUI

struct EditingToolsPanel: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack(spacing: 0) {
            // 分类选择器
            CategorySelectorView(viewModel: viewModel)

            // 主工具栏
            HStack(spacing: 12) {
                // 工具按钮区域
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(ToolItem.tools(for: viewModel.selectedToolCategory), id: \.mode) { tool in
                            ToolButton(
                                icon: tool.icon,
                                title: tool.title,
                                isSelected: viewModel.editingMode == tool.mode
                            ) {
                                viewModel.editingMode = viewModel.editingMode == tool.mode ? .none : tool.mode
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // 操作按钮
                HStack(spacing: 12) {
                    Button(action: viewModel.undo) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.title3)
                            .foregroundColor(viewModel.canUndo ? .white : .gray)
                    }
                    .disabled(!viewModel.canUndo)

                    Button(action: viewModel.redo) {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.title3)
                            .foregroundColor(viewModel.canRedo ? .white : .gray)
                    }
                    .disabled(!viewModel.canRedo)

                    Button(action: viewModel.saveImage) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title3)
                            .foregroundColor(.white)
                    }

                    Button(action: viewModel.shareImage) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 16)
            }
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))

            // 动态工具面板
            Group {
                switch viewModel.editingMode {
                // 常规工具
                case .filter:
                    if let image = viewModel.currentImage {
                        FilterSelectorView(
                            originalImage: image,
                            selectedFilter: $viewModel.selectedFilter
                        ) { filterType in
                            Task {
                                await viewModel.applyFilter(filterType)
                            }
                        }
                        .transition(.move(edge: .bottom))
                    }

                case .adjust:
                    ColorAdjustmentView(
                        brightness: $viewModel.brightness,
                        contrast: $viewModel.contrast,
                        saturation: $viewModel.saturation,
                        hue: $viewModel.hue
                    ) {
                        Task {
                            await viewModel.applyColorAdjustments()
                        }
                    }
                    .transition(.move(edge: .bottom))

                case .crop:
                    CropControlPanel(viewModel: viewModel)
                        .transition(.move(edge: .bottom))

                case .text:
                    TextToolsView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))

                case .sticker:
                    StickerToolsView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))

                // 风格工具
                case .portrait, .idPhoto, .landscape, .food, .ecommerce, .portrait_art,
                     .emoji, .artistic, .vintage, .comic, .sketch, .watercolor:
                    StyleProcessingView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))

                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.editingMode)
        }
    }
}

struct ToolButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .blue : .white)
        }
    }
}


// MARK: - 文本工具
struct TextToolsView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Text")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Button("Add Text") {
                    viewModel.addText()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.availableFonts, id: \.self) { fontName in
                        Button(fontName) {
                            viewModel.setTextFont(fontName)
                        }
                        .font(.custom(fontName, size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.9))
        }
    }
}

// MARK: - 裁剪控制面板
struct CropControlPanel: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var showingRatioMenu = false

    var body: some View {
        VStack(spacing: 0) {
            // 主控制栏
            HStack {
                Text("Crop")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Button("重置") {
                    // 调用重置裁剪功能
                    viewModel.resetCrop()
                }
                .font(.subheadline)
                .foregroundColor(.blue)

                Button("完成") {
                    // 调用应用裁剪功能
                    viewModel.applyCrop()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.leading, 16)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))

            // 比例选择栏
            HStack(spacing: 15) {
                Text("比例:")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CropRatioButton(title: "自由", ratio: nil) {
                            viewModel.setCropRatio(nil)
                        }

                        CropRatioButton(title: "1:1", ratio: 1.0) {
                            viewModel.setCropRatio(1.0)
                        }

                        CropRatioButton(title: "4:3", ratio: 4.0/3.0) {
                            viewModel.setCropRatio(4.0/3.0)
                        }

                        CropRatioButton(title: "3:2", ratio: 3.0/2.0) {
                            viewModel.setCropRatio(3.0/2.0)
                        }

                        CropRatioButton(title: "16:9", ratio: 16.0/9.0) {
                            viewModel.setCropRatio(16.0/9.0)
                        }

                        CropRatioButton(title: "9:16", ratio: 9.0/16.0) {
                            viewModel.setCropRatio(9.0/16.0)
                        }

                        CropRatioButton(title: "4:5", ratio: 4.0/5.0) {
                            viewModel.setCropRatio(4.0/5.0)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.9))
        }
    }
}

struct CropRatioButton: View {
    let title: String
    let ratio: CGFloat?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(6)
        }
    }
}

// MARK: - 贴纸工具
struct StickerToolsView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Stickers")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.availableStickers, id: \.self) { sticker in
                        Button(action: {
                            viewModel.addSticker(sticker)
                        }) {
                            Text(sticker)
                                .font(.largeTitle)
                                .frame(width: 60, height: 60)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.9))
        }
    }
}

// MARK: - 分类选择器
struct CategorySelectorView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ToolCategory.allCases, id: \.self) { category in
                Button(action: {
                    viewModel.selectedToolCategory = category
                    viewModel.editingMode = .none
                }) {
                    Text(category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(viewModel.selectedToolCategory == category ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.selectedToolCategory == category
                                ? Color.white
                                : Color.clear
                        )
                }
            }
        }
        .background(Color.black.opacity(0.9))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.6))
    }
}

// MARK: - 风格处理视图
struct StyleProcessingView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(styleTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Button("应用效果") {
                        applyStyleEffect()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.9))
    }

    private var styleTitle: String {
        switch viewModel.editingMode {
        case .portrait: return "人像美化"
        case .idPhoto: return "证件照"
        case .landscape: return "风景增强"
        case .food: return "美食滤镜"
        case .ecommerce: return "电商修图"
        case .portrait_art: return "写真风格"
        case .emoji: return "表情包制作"
        case .artistic: return "艺术创作"
        case .vintage: return "复古风格"
        case .comic: return "漫画风格"
        case .sketch: return "素描效果"
        case .watercolor: return "水彩画风"
        default: return "风格处理"
        }
    }

    private func applyStyleEffect() {
        guard let image = viewModel.currentImage else { return }
        isProcessing = true

        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            await MainActor.run {
                Task {
                    if let processedImage = await ImageFilterManager.shared.adjustBrightness(image, value: 0.1) {
                        viewModel.updateProcessedImage(processedImage)
                    }
                    isProcessing = false
                    viewModel.editingMode = .none
                }
            }
        }
    }
}
