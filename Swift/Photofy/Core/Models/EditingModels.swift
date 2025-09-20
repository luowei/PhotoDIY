import UIKit
import Foundation

// MARK: - 编辑模式
enum EditingMode: String, CaseIterable, Identifiable {
    case view = "view"
    case filter = "filter"
    case crop = "crop"
    case draw = "draw"
    case text = "text"
    case sticker = "sticker"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .view: return "View"
        case .filter: return "Filters"
        case .crop: return "Crop"
        case .draw: return "Draw"
        case .text: return "Text"
        case .sticker: return "Stickers"
        }
    }

    var iconName: String {
        switch self {
        case .view: return "eye"
        case .filter: return "camera.filters"
        case .crop: return "crop"
        case .draw: return "pencil"
        case .text: return "textformat"
        case .sticker: return "face.smiling"
        }
    }
}

// MARK: - 滤镜类型
enum FilterType: String, CaseIterable, Identifiable {
    // 基础调节
    case brightness = "brightness"
    case contrast = "contrast"
    case saturation = "saturation"
    case hue = "hue"
    case warmth = "warmth"
    case highlights = "highlights"
    case shadows = "shadows"

    // 艺术效果
    case vintage = "vintage"
    case blackAndWhite = "blackAndWhite"
    case sepia = "sepia"
    case vignette = "vignette"
    case dramatic = "dramatic"
    case vivid = "vivid"

    // 美颜效果
    case beauty = "beauty"
    case smooth = "smooth"
    case sharpen = "sharpen"

    // 模糊效果
    case gaussianBlur = "gaussianBlur"
    case motionBlur = "motionBlur"
    case radialBlur = "radialBlur"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .brightness: return "Brightness"
        case .contrast: return "Contrast"
        case .saturation: return "Saturation"
        case .hue: return "Hue"
        case .warmth: return "Warmth"
        case .highlights: return "Highlights"
        case .shadows: return "Shadows"
        case .vintage: return "Vintage"
        case .blackAndWhite: return "B&W"
        case .sepia: return "Sepia"
        case .vignette: return "Vignette"
        case .dramatic: return "Dramatic"
        case .vivid: return "Vivid"
        case .beauty: return "Beauty"
        case .smooth: return "Smooth"
        case .sharpen: return "Sharpen"
        case .gaussianBlur: return "Blur"
        case .motionBlur: return "Motion"
        case .radialBlur: return "Radial"
        }
    }

    var category: FilterCategory {
        switch self {
        case .brightness, .contrast, .saturation, .hue, .warmth, .highlights, .shadows:
            return .basic
        case .vintage, .blackAndWhite, .sepia, .vignette, .dramatic, .vivid:
            return .artistic
        case .beauty, .smooth, .sharpen:
            return .beauty
        case .gaussianBlur, .motionBlur, .radialBlur:
            return .blur
        }
    }

    var defaultIntensity: Float {
        switch self {
        case .brightness, .contrast, .saturation, .hue, .warmth, .highlights, .shadows:
            return 0.0 // 基础调节默认为0（无变化）
        default:
            return 1.0 // 其他滤镜默认为满强度
        }
    }

    var intensityRange: ClosedRange<Float> {
        switch self {
        case .brightness, .contrast, .highlights, .shadows:
            return -1.0...1.0
        case .saturation, .warmth:
            return 0.0...2.0
        case .hue:
            return -180.0...180.0
        default:
            return 0.0...1.0
        }
    }
}

// MARK: - 滤镜分类
enum FilterCategory: String, CaseIterable {
    case basic = "basic"
    case artistic = "artistic"
    case beauty = "beauty"
    case blur = "blur"

    var displayName: String {
        switch self {
        case .basic: return "Basic"
        case .artistic: return "Artistic"
        case .beauty: return "Beauty"
        case .blur: return "Blur"
        }
    }
}

// MARK: - 绘画工具类型
enum DrawingTool: String, CaseIterable, Identifiable {
    case pen = "pen"
    case marker = "marker"
    case pencil = "pencil"
    case brush = "brush"
    case eraser = "eraser"
    case mosaic = "mosaic"
    case blur = "blur"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pen: return "Pen"
        case .marker: return "Marker"
        case .pencil: return "Pencil"
        case .brush: return "Brush"
        case .eraser: return "Eraser"
        case .mosaic: return "Mosaic"
        case .blur: return "Blur"
        }
    }

    var iconName: String {
        switch self {
        case .pen: return "pencil"
        case .marker: return "highlighter"
        case .pencil: return "pencil.tip"
        case .brush: return "paintbrush"
        case .eraser: return "trash"
        case .mosaic: return "square.grid.3x3"
        case .blur: return "camera.filters"
        }
    }

    var defaultSize: CGFloat {
        switch self {
        case .pen: return 5.0
        case .marker: return 15.0
        case .pencil: return 3.0
        case .brush: return 20.0
        case .eraser: return 25.0
        case .mosaic: return 30.0
        case .blur: return 35.0
        }
    }
}

// MARK: - 文字样式
struct TextStyle {
    var fontName: String
    var fontSize: CGFloat
    var color: UIColor
    var alignment: NSTextAlignment
    var isBold: Bool
    var isItalic: Bool
    var shadowOffset: CGSize
    var shadowColor: UIColor?
    var strokeWidth: CGFloat
    var strokeColor: UIColor?

    static let `default` = TextStyle(
        fontName: "Helvetica",
        fontSize: 24.0,
        color: .white,
        alignment: .center,
        isBold: false,
        isItalic: false,
        shadowOffset: .zero,
        shadowColor: nil,
        strokeWidth: 0.0,
        strokeColor: nil
    )
}

// MARK: - 贴纸类型
enum StickerType: String, CaseIterable, Identifiable {
    case emoji = "emoji"
    case shapes = "shapes"
    case decorations = "decorations"
    case frames = "frames"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .emoji: return "Emoji"
        case .shapes: return "Shapes"
        case .decorations: return "Decorations"
        case .frames: return "Frames"
        }
    }
}

// MARK: - 编辑历史步骤
struct EditingStep {
    let id = UUID()
    let type: EditingStepType
    let imageData: Data
    let timestamp: Date
    let description: String

    init(type: EditingStepType, imageData: Data, description: String) {
        self.type = type
        self.imageData = imageData
        self.timestamp = Date()
        self.description = description
    }
}

// MARK: - 编辑步骤类型
enum EditingStepType: String {
    case original = "original"
    case filter = "filter"
    case crop = "crop"
    case draw = "draw"
    case text = "text"
    case sticker = "sticker"
    case transform = "transform"
}

// MARK: - 裁剪比例
enum CropAspectRatio: CaseIterable, Identifiable {
    case free
    case square
    case ratio3x4
    case ratio4x3
    case ratio9x16
    case ratio16x9

    var id: String {
        switch self {
        case .free: return "free"
        case .square: return "1:1"
        case .ratio3x4: return "3:4"
        case .ratio4x3: return "4:3"
        case .ratio9x16: return "9:16"
        case .ratio16x9: return "16:9"
        }
    }

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .square: return "Square"
        case .ratio3x4: return "3:4"
        case .ratio4x3: return "4:3"
        case .ratio9x16: return "9:16"
        case .ratio16x9: return "16:9"
        }
    }

    var ratio: CGFloat? {
        switch self {
        case .free: return nil
        case .square: return 1.0
        case .ratio3x4: return 3.0/4.0
        case .ratio4x3: return 4.0/3.0
        case .ratio9x16: return 9.0/16.0
        case .ratio16x9: return 16.0/9.0
        }
    }
}