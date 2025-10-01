import SwiftUI
import Vision

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
    @State private var processingMessage = ""

    // 参数设置
    @State private var portraitSettings = PortraitSettings()
    @State private var landscapeSettings = LandscapeSettings()
    @State private var ecommerceSettings = EcommerceSettings()
    @State private var idPhotoSettings = IDPhotoSettings()
    @State private var foodSettings = FoodSettings()

    private let styleProcessor = AdvancedStyleProcessor.shared
    private let aiProcessor = AIEnhancedImageProcessor.shared

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
                    Button("AI智能处理") {
                        applyAdvancedStyleEffect()
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }

            // 处理结果消息
            if !processingMessage.isEmpty {
                Text(processingMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                    .multilineTextAlignment(.center)
            }

            // 风格选项
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(styleOptions, id: \.name) { option in
                        StyleOptionButton(
                            option: option,
                            isSelected: false
                        ) {
                            // 风格选项暂时保持原有功能
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // 参数自定义面板
            StyleParametersView(
                editingMode: viewModel.editingMode,
                portraitSettings: $portraitSettings,
                landscapeSettings: $landscapeSettings,
                ecommerceSettings: $ecommerceSettings,
                idPhotoSettings: $idPhotoSettings,
                foodSettings: $foodSettings
            )

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

    private func applyAdvancedStyleEffect() {
        guard let image = viewModel.currentImage else { return }

        isProcessing = true
        processingMessage = ""

        Task {
            let result: ProcessingResult

            switch viewModel.editingMode {
            case .portrait:
                let aiResult = await aiProcessor.enhancePortrait(image, settings: portraitSettings)
                result = ProcessingResult(image: aiResult.image, message: aiResult.message)
            case .idPhoto:
                let aiResult = await aiProcessor.createIntelligentIDPhoto(image, settings: idPhotoSettings)
                result = ProcessingResult(image: aiResult.image, message: aiResult.message)
            case .landscape:
                let aiResult = await aiProcessor.enhanceLandscape(image, settings: landscapeSettings)
                result = ProcessingResult(image: aiResult.image, message: aiResult.message)
            case .ecommerce:
                let aiResult = await aiProcessor.enhanceEcommerce(image, settings: ecommerceSettings)
                result = ProcessingResult(image: aiResult.image, message: aiResult.message)
            case .food:
                let aiResult = await aiProcessor.enhanceFood(image, settings: foodSettings)
                result = ProcessingResult(image: aiResult.image, message: aiResult.message)
            default:
                // 对于其他风格，使用原有的基础处理
                result = await applyBasicStyleProcessing(to: image, style: viewModel.editingMode, intensity: portraitSettings.intensity)
            }

            await MainActor.run {
                viewModel.updateProcessedImage(result.image)
                processingMessage = result.message
                isProcessing = false

                // 延迟重置编辑模式，让用户看到结果消息
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    processingMessage = ""
                    if viewModel.editingMode != .none {
                        viewModel.editingMode = .none
                    }
                }
            }
        }
    }

    private func applyBasicStyleProcessing(to image: UIImage, style: EditingMode, intensity: Float) async -> ProcessingResult {
        // 基础风格处理逻辑保持不变
        var processedImage: UIImage? = nil
        var message = "风格效果已应用"

        switch style {
        case .vintage:
            if let desaturated = await ImageFilterManager.shared.adjustSaturation(image, value: 0.7) {
                processedImage = await ImageFilterManager.shared.adjustHue(desaturated, angle: intensity * 0.1)
            }
            message = "复古效果已应用：降低饱和度并增加暖色调"
        case .food:
            if let warmed = await ImageFilterManager.shared.adjustHue(image, angle: intensity * 0.05) {
                processedImage = await ImageFilterManager.shared.adjustSaturation(warmed, value: 1.0 + intensity * 0.3)
            }
            message = "美食滤镜已应用：增加暖色调和饱和度"
        case .artistic, .sketch, .watercolor:
            processedImage = await ImageFilterManager.shared.adjustContrast(image, value: 1.0 + intensity * 0.5)
            message = "艺术效果已应用：调整对比度增强视觉效果"
        default:
            processedImage = await ImageFilterManager.shared.adjustBrightness(image, value: intensity * 0.2)
        }

        return ProcessingResult(image: processedImage ?? image, message: message)
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

// MARK: - 参数自定义面板
struct StyleParametersView: View {
    let editingMode: EditingMode
    @Binding var portraitSettings: PortraitSettings
    @Binding var landscapeSettings: LandscapeSettings
    @Binding var ecommerceSettings: EcommerceSettings
    @Binding var idPhotoSettings: IDPhotoSettings
    @Binding var foodSettings: FoodSettings

    var body: some View {
        VStack(spacing: 12) {
            switch editingMode {
            case .portrait:
                PortraitParametersView(settings: $portraitSettings)
            case .landscape:
                LandscapeParametersView(settings: $landscapeSettings)
            case .ecommerce:
                EcommerceParametersView(settings: $ecommerceSettings)
            case .idPhoto:
                IDPhotoParametersView(settings: $idPhotoSettings)
            case .food:
                FoodParametersView(settings: $foodSettings)
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - 人像参数面板
struct PortraitParametersView: View {
    @Binding var settings: PortraitSettings

    var body: some View {
        VStack(spacing: 8) {
            Text("人像参数调整")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)

            VStack(spacing: 6) {
                ParameterSlider(
                    title: "效果强度",
                    value: $settings.intensity,
                    range: 0...1
                )
                ParameterSlider(
                    title: "皮肤平滑",
                    value: $settings.skinSmoothing,
                    range: 0...1
                )
                ParameterSlider(
                    title: "背景虚化",
                    value: $settings.backgroundBlur,
                    range: 0...1
                )
                ParameterSlider(
                    title: "亮度调整",
                    value: $settings.brightnessAdjust,
                    range: -0.5...0.5
                )
                ParameterSlider(
                    title: "饱和度",
                    value: $settings.saturationBoost,
                    range: 0...0.5
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - 风景参数面板
struct LandscapeParametersView: View {
    @Binding var settings: LandscapeSettings

    var body: some View {
        VStack(spacing: 8) {
            Text("风景参数调整")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)

            VStack(spacing: 6) {
                ParameterSlider(
                    title: "效果强度",
                    value: $settings.intensity,
                    range: 0...1
                )
                ParameterSlider(
                    title: "饱和度增强",
                    value: $settings.saturationBoost,
                    range: 0...0.8
                )
                ParameterSlider(
                    title: "对比度增强",
                    value: $settings.contrastEnhance,
                    range: 0...0.6
                )
                ParameterSlider(
                    title: "清晰度",
                    value: $settings.sharpness,
                    range: 0...3
                )
                ParameterSlider(
                    title: "暖色调",
                    value: $settings.warmthAdjust,
                    range: 0...1000
                )
                ParameterSlider(
                    title: "晕影效果",
                    value: $settings.vignetteIntensity,
                    range: 0...1
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - 电商参数面板
struct EcommerceParametersView: View {
    @Binding var settings: EcommerceSettings

    var body: some View {
        VStack(spacing: 8) {
            Text("电商参数调整")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)

            VStack(spacing: 6) {
                ParameterSlider(
                    title: "效果强度",
                    value: $settings.intensity,
                    range: 0...1
                )
                ParameterSlider(
                    title: "曝光增强",
                    value: $settings.exposureBoost,
                    range: 0...1
                )
                ParameterSlider(
                    title: "饱和度",
                    value: $settings.saturationEnhance,
                    range: 0...0.5
                )
                ParameterSlider(
                    title: "对比度",
                    value: $settings.contrastBoost,
                    range: 0...0.8
                )
                ParameterSlider(
                    title: "高光调整",
                    value: $settings.highlightAdjust,
                    range: 0...0.6
                )
                ParameterSlider(
                    title: "阴影调整",
                    value: $settings.shadowAdjust,
                    range: -0.3...0.1
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - 证件照参数面板
struct IDPhotoParametersView: View {
    @Binding var settings: IDPhotoSettings

    var body: some View {
        VStack(spacing: 8) {
            Text("证件照参数调整")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)

            // 背景颜色选择
            VStack(spacing: 8) {
                HStack {
                    Text("背景颜色")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(IDPhotoBackgroundColor.allCases, id: \.self) { color in
                            Button(color.displayName) {
                                settings.backgroundColor = color
                            }
                            .font(.caption)
                            .foregroundColor(settings.backgroundColor == color ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                settings.backgroundColor == color ? Color.white : Color.gray.opacity(0.3)
                            )
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            VStack(spacing: 6) {
                ParameterSlider(
                    title: "面部增强",
                    value: $settings.faceEnhancement,
                    range: 0...0.8
                )
                ParameterSlider(
                    title: "皮肤平滑",
                    value: $settings.skinSmoothing,
                    range: 0...0.8
                )
                ParameterSlider(
                    title: "亮度校正",
                    value: $settings.brightnessCorrection,
                    range: 0...0.5
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - 参数滑块组件
struct ParameterSlider: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(String(format: "%.2f", value))
                    .font(.caption)
                    .foregroundColor(.white)
            }

            Slider(value: $value, in: range)
                .accentColor(.blue)
        }
    }
}

// MARK: - 美食参数面板
struct FoodParametersView: View {
    @Binding var settings: FoodSettings

    var body: some View {
        VStack(spacing: 8) {
            Text("美食参数调整")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)

            VStack(spacing: 6) {
                ParameterSlider(
                    title: "效果强度",
                    value: $settings.intensity,
                    range: 0...1
                )
                ParameterSlider(
                    title: "饱和度增强",
                    value: $settings.saturationBoost,
                    range: 0...0.8
                )
                ParameterSlider(
                    title: "暖色调",
                    value: $settings.warmthAdjust,
                    range: 0...500
                )
                ParameterSlider(
                    title: "对比度增强",
                    value: $settings.contrastEnhance,
                    range: 0...0.6
                )
                ParameterSlider(
                    title: "食欲感增强",
                    value: $settings.appetiteBoost,
                    range: 0...1
                )
            }
        }
        .padding(.horizontal, 16)
    }
}