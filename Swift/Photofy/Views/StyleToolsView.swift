import SwiftUI

// MARK: - 分类选择器
struct CategorySelector: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ToolCategory.allCases, id: \.self) { category in
                Button(action: {
                    viewModel.selectedToolCategory = category
                    viewModel.editingMode = .none // 切换分类时重置编辑模式
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

// MARK: - 风格处理面板
struct StyleProcessingPanel: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var isProcessing = false
    @State private var styleIntensity: Float = 0.8

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(styleTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                if isProcessing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("处理中...")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
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

            // 风格选项
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(styleOptions, id: \.name) { option in
                        StyleOptionButton(
                            option: option,
                            isSelected: false
                        ) {
                            // TODO: 选中风格选项
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // 强度调节
            if !isProcessing {
                VStack(spacing: 8) {
                    HStack {
                        Text("效果强度")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(styleIntensity * 100))%")
                            .font(.caption)
                            .foregroundColor(.white)
                    }

                    Slider(value: $styleIntensity, in: 0...1)
                        .accentColor(.blue)
                }
                .padding(.horizontal, 16)
            }
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

    private var styleOptions: [StyleOption] {
        switch viewModel.editingMode {
        case .portrait:
            return [
                StyleOption(name: "自然", description: "自然美颜"),
                StyleOption(name: "清新", description: "清新淡雅"),
                StyleOption(name: "甜美", description: "甜美可爱"),
                StyleOption(name: "性感", description: "性感魅力")
            ]
        case .idPhoto:
            return [
                StyleOption(name: "标准", description: "标准证件照"),
                StyleOption(name: "一寸", description: "一寸照片"),
                StyleOption(name: "二寸", description: "二寸照片"),
                StyleOption(name: "护照", description: "护照照片")
            ]
        case .landscape:
            return [
                StyleOption(name: "清晨", description: "清晨阳光"),
                StyleOption(name: "黄昏", description: "黄昏夕阳"),
                StyleOption(name: "雾霾", description: "朦胧雾气"),
                StyleOption(name: "HDR", description: "高动态范围")
            ]
        case .food:
            return [
                StyleOption(name: "诱人", description: "食欲满满"),
                StyleOption(name: "清淡", description: "清爽淡雅"),
                StyleOption(name: "浓郁", description: "色彩浓郁"),
                StyleOption(name: "日式", description: "日式简约")
            ]
        case .ecommerce:
            return [
                StyleOption(name: "清洁", description: "简洁明亮"),
                StyleOption(name: "温暖", description: "温暖色调"),
                StyleOption(name: "冷调", description: "冷酷现代"),
                StyleOption(name: "高端", description: "奢华质感")
            ]
        case .portrait_art:
            return [
                StyleOption(name: "胶片", description: "胶片质感"),
                StyleOption(name: "梦幻", description: "梦幻唯美"),
                StyleOption(name: "黑白", description: "经典黑白"),
                StyleOption(name: "暖调", description: "温暖色调")
            ]
        case .emoji:
            return [
                StyleOption(name: "可爱", description: "萌萌哒"),
                StyleOption(name: "搞笑", description: "逗比风"),
                StyleOption(name: "酷炫", description: "炫酷风"),
                StyleOption(name: "恶搞", description: "恶搞风")
            ]
        case .artistic:
            return [
                StyleOption(name: "油画", description: "油画风格"),
                StyleOption(name: "水墨", description: "水墨画风"),
                StyleOption(name: "版画", description: "版画效果"),
                StyleOption(name: "抽象", description: "抽象艺术")
            ]
        case .vintage:
            return [
                StyleOption(name: "怀旧", description: "怀旧复古"),
                StyleOption(name: "老照片", description: "老照片感"),
                StyleOption(name: "褪色", description: "褪色效果"),
                StyleOption(name: "泛黄", description: "时光泛黄")
            ]
        case .comic:
            return [
                StyleOption(name: "日系", description: "日式漫画"),
                StyleOption(name: "美系", description: "美式漫画"),
                StyleOption(name: "Q版", description: "Q版萌系"),
                StyleOption(name: "写实", description: "写实漫画")
            ]
        case .sketch:
            return [
                StyleOption(name: "铅笔", description: "铅笔素描"),
                StyleOption(name: "炭笔", description: "炭笔素描"),
                StyleOption(name: "钢笔", description: "钢笔画"),
                StyleOption(name: "线稿", description: "纯线稿")
            ]
        case .watercolor:
            return [
                StyleOption(name: "清淡", description: "清淡水彩"),
                StyleOption(name: "浓郁", description: "浓郁色彩"),
                StyleOption(name: "朦胧", description: "朦胧晕染"),
                StyleOption(name: "写意", description: "写意风格")
            ]
        default:
            return [
                StyleOption(name: "轻度", description: "轻度效果"),
                StyleOption(name: "中度", description: "中度效果"),
                StyleOption(name: "重度", description: "重度效果")
            ]
        }
    }

    private func applyStyleEffect() {
        guard let image = viewModel.currentImage else { return }

        isProcessing = true

        Task {
            // 模拟处理进度，实际处理
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒

            let processedImage = await applyStyleProcessing(to: image, style: viewModel.editingMode, intensity: styleIntensity)

            await MainActor.run {
                if let result = processedImage {
                    viewModel.updateProcessedImage(result)
                }
                isProcessing = false
                viewModel.editingMode = .none
            }
        }
    }

    private func applyStyleProcessing(to image: UIImage, style: EditingMode, intensity: Float) async -> UIImage? {
        // 根据不同风格应用不同的处理效果
        switch style {
        case .portrait:
            // 人像美颜：调整亮度和对比度
            if let brightened = await ImageFilterManager.shared.adjustBrightness(image, value: intensity * 0.3) {
                return await ImageFilterManager.shared.adjustSaturation(brightened, value: 1.0 + intensity * 0.2)
            }
        case .vintage:
            // 复古效果：降低饱和度，增加暖色调
            if let desaturated = await ImageFilterManager.shared.adjustSaturation(image, value: 0.7) {
                return await ImageFilterManager.shared.adjustHue(desaturated, angle: intensity * 0.1)
            }
        case .landscape:
            // 风景增强：增加饱和度和对比度
            if let saturated = await ImageFilterManager.shared.adjustSaturation(image, value: 1.0 + intensity * 0.4) {
                return await ImageFilterManager.shared.adjustContrast(saturated, value: 1.0 + intensity * 0.3)
            }
        case .food:
            // 美食滤镜：增加暖色调和饱和度
            if let warmed = await ImageFilterManager.shared.adjustHue(image, angle: intensity * 0.05) {
                return await ImageFilterManager.shared.adjustSaturation(warmed, value: 1.0 + intensity * 0.3)
            }
        case .artistic, .sketch, .watercolor:
            // 艺术效果：调整对比度
            return await ImageFilterManager.shared.adjustContrast(image, value: 1.0 + intensity * 0.5)
        default:
            // 默认处理：轻微调整亮度
            return await ImageFilterManager.shared.adjustBrightness(image, value: intensity * 0.2)
        }

        return image
    }
}

// MARK: - 风格选项
struct StyleOption {
    let name: String
    let description: String
}

struct StyleOptionButton: View {
    let option: StyleOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(option.name)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(option.description)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.white : Color.gray.opacity(0.3)
            )
            .cornerRadius(8)
        }
    }
}