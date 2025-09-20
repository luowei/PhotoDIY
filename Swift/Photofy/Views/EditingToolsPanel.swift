import SwiftUI

struct EditingToolsPanel: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack(spacing: 0) {
            // 主工具栏
            HStack(spacing: 20) {
                ToolButton(
                    icon: "camera.filters",
                    title: "Filters",
                    isSelected: viewModel.editingMode == .filter
                ) {
                    viewModel.editingMode = viewModel.editingMode == .filter ? .none : .filter
                }

                ToolButton(
                    icon: "slider.horizontal.3",
                    title: "Adjust",
                    isSelected: viewModel.editingMode == .adjust
                ) {
                    viewModel.editingMode = viewModel.editingMode == .adjust ? .none : .adjust
                }

                ToolButton(
                    icon: "crop",
                    title: "Crop",
                    isSelected: viewModel.editingMode == .crop
                ) {
                    viewModel.editingMode = viewModel.editingMode == .crop ? .none : .crop
                }

                ToolButton(
                    icon: "textformat",
                    title: "Text",
                    isSelected: viewModel.editingMode == .text
                ) {
                    viewModel.editingMode = viewModel.editingMode == .text ? .none : .text
                }

                ToolButton(
                    icon: "face.smiling",
                    title: "Sticker",
                    isSelected: viewModel.editingMode == .sticker
                ) {
                    viewModel.editingMode = viewModel.editingMode == .sticker ? .none : .sticker
                }

                Spacer()

                // 操作按钮
                HStack(spacing: 16) {
                    Button(action: viewModel.undo) {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(viewModel.canUndo ? .white : .gray)
                    }
                    .disabled(!viewModel.canUndo)

                    Button(action: viewModel.redo) {
                        Image(systemName: "arrow.uturn.forward")
                            .foregroundColor(viewModel.canRedo ? .white : .gray)
                    }
                    .disabled(!viewModel.canRedo)

                    Button(action: viewModel.saveImage) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.white)
                    }

                    Button(action: viewModel.shareImage) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))

            // 动态工具面板
            Group {
                switch viewModel.editingMode {
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