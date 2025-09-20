import UIKit
import CoreImage

// MARK: - 滤镜服务协议
protocol FilterService {
    func getAllFilters() -> [FilterType]
    func getFiltersByCategory(_ category: FilterCategory) -> [FilterType]
    func generatePreviewsForFilters(_ filters: [FilterType], from image: UIImage) async -> [FilterType: UIImage]
    func getFilterConfiguration(_ filterType: FilterType) -> FilterConfiguration
}

// MARK: - 滤镜管理器实现
class FilterManager: FilterService {
    @Injected(ImageProcessingService.self)
    private var imageProcessor: ImageProcessingService

    private let previewCache = NSCache<NSString, UIImage>()

    init() {
        configureCache()
    }

    private func configureCache() {
        previewCache.countLimit = 50
        previewCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    // MARK: - 获取滤镜
    func getAllFilters() -> [FilterType] {
        return FilterType.allCases
    }

    func getFiltersByCategory(_ category: FilterCategory) -> [FilterType] {
        return FilterType.allCases.filter { $0.category == category }
    }

    // MARK: - 生成预览
    func generatePreviewsForFilters(_ filters: [FilterType], from image: UIImage) async -> [FilterType: UIImage] {
        // 创建小尺寸预览图以提高性能
        let previewSize = CGSize(width: 120, height: 120)
        guard let previewBaseImage = imageProcessor.resizeImage(image, to: previewSize) else {
            return [:]
        }

        var previews: [FilterType: UIImage] = [:]

        // 并发生成预览
        await withTaskGroup(of: (FilterType, UIImage?).self) { group in
            for filter in filters {
                group.addTask { [weak self] in
                    let cacheKey = "\(filter.rawValue)_\(image.hash)"

                    // 检查缓存
                    if let cachedPreview = self?.previewCache.object(forKey: NSString(string: cacheKey)) {
                        return (filter, cachedPreview)
                    }

                    // 生成新预览
                    let preview = await self?.imageProcessor.generateFilterPreview(filter, from: previewBaseImage)

                    // 缓存预览
                    if let preview = preview {
                        self?.previewCache.setObject(preview, forKey: NSString(string: cacheKey))
                    }

                    return (filter, preview)
                }
            }

            for await (filter, preview) in group {
                if let preview = preview {
                    previews[filter] = preview
                }
            }
        }

        return previews
    }

    // MARK: - 滤镜配置
    func getFilterConfiguration(_ filterType: FilterType) -> FilterConfiguration {
        return FilterConfiguration(
            type: filterType,
            displayName: filterType.displayName,
            category: filterType.category,
            defaultIntensity: filterType.defaultIntensity,
            intensityRange: filterType.intensityRange,
            description: getFilterDescription(filterType),
            isPremium: isPremiumFilter(filterType)
        )
    }

    // MARK: - 私有方法
    private func getFilterDescription(_ filterType: FilterType) -> String {
        switch filterType {
        case .brightness:
            return "Adjust the overall brightness of your image"
        case .contrast:
            return "Enhance or reduce the contrast for more dramatic effects"
        case .saturation:
            return "Control the intensity of colors in your image"
        case .hue:
            return "Shift the color spectrum for creative color effects"
        case .warmth:
            return "Add warmth or coolness to the color temperature"
        case .highlights:
            return "Control the bright areas of your image"
        case .shadows:
            return "Adjust the dark areas to reveal hidden details"
        case .vintage:
            return "Give your photo a classic, aged appearance"
        case .blackAndWhite:
            return "Convert to timeless black and white"
        case .sepia:
            return "Add a warm, nostalgic sepia tone"
        case .vignette:
            return "Create a subtle frame effect around your image"
        case .dramatic:
            return "Enhance contrast and saturation for bold results"
        case .vivid:
            return "Boost colors for vibrant, eye-catching photos"
        case .beauty:
            return "Enhance portraits with subtle skin smoothing"
        case .smooth:
            return "Apply gentle smoothing for softer images"
        case .sharpen:
            return "Increase detail and clarity in your photos"
        case .gaussianBlur:
            return "Apply smooth, even blur effect"
        case .motionBlur:
            return "Create dynamic motion blur effects"
        case .radialBlur:
            return "Add artistic radial blur from the center"
        }
    }

    private func isPremiumFilter(_ filterType: FilterType) -> Bool {
        // 定义哪些滤镜需要付费解锁
        let premiumFilters: [FilterType] = [
            .beauty, .smooth, .dramatic, .vivid, .motionBlur, .radialBlur
        ]
        return premiumFilters.contains(filterType)
    }
}

// MARK: - 滤镜配置模型
struct FilterConfiguration {
    let type: FilterType
    let displayName: String
    let category: FilterCategory
    let defaultIntensity: Float
    let intensityRange: ClosedRange<Float>
    let description: String
    let isPremium: Bool

    var intensityStep: Float {
        let range = intensityRange.upperBound - intensityRange.lowerBound
        return range / 100.0 // 100步精度
    }
}

// MARK: - 滤镜预设
struct FilterPreset: Identifiable, Codable {
    let id = UUID()
    let name: String
    let filters: [FilterSetting]
    let thumbnailData: Data?
    let createdAt: Date

    init(name: String, filters: [FilterSetting], thumbnailData: Data? = nil) {
        self.name = name
        self.filters = filters
        self.thumbnailData = thumbnailData
        self.createdAt = Date()
    }
}

// MARK: - 滤镜组合器
class FilterComposer {
    @Injected(ImageProcessingService.self)
    private var imageProcessor: ImageProcessingService

    // MARK: - 预设滤镜组合
    static let popularPresets: [FilterPreset] = [
        FilterPreset(
            name: "Portrait",
            filters: [
                FilterSetting(filterType: FilterType.beauty.rawValue, intensity: 0.6),
                FilterSetting(filterType: FilterType.warmth.rawValue, intensity: 0.3),
                FilterSetting(filterType: FilterType.highlights.rawValue, intensity: 0.2)
            ]
        ),
        FilterPreset(
            name: "Landscape",
            filters: [
                FilterSetting(filterType: FilterType.vivid.rawValue, intensity: 0.8),
                FilterSetting(filterType: FilterType.contrast.rawValue, intensity: 0.3),
                FilterSetting(filterType: FilterType.shadows.rawValue, intensity: 0.4)
            ]
        ),
        FilterPreset(
            name: "Vintage",
            filters: [
                FilterSetting(filterType: FilterType.vintage.rawValue, intensity: 0.9),
                FilterSetting(filterType: FilterType.vignette.rawValue, intensity: 0.5),
                FilterSetting(filterType: FilterType.warmth.rawValue, intensity: 0.4)
            ]
        ),
        FilterPreset(
            name: "Dramatic",
            filters: [
                FilterSetting(filterType: FilterType.dramatic.rawValue, intensity: 1.0),
                FilterSetting(filterType: FilterType.shadows.rawValue, intensity: -0.3),
                FilterSetting(filterType: FilterType.highlights.rawValue, intensity: 0.2)
            ]
        ),
        FilterPreset(
            name: "Soft Focus",
            filters: [
                FilterSetting(filterType: FilterType.smooth.rawValue, intensity: 0.7),
                FilterSetting(filterType: FilterType.brightness.rawValue, intensity: 0.2),
                FilterSetting(filterType: FilterType.saturation.rawValue, intensity: 0.8)
            ]
        )
    ]

    // MARK: - 应用预设
    func applyPreset(_ preset: FilterPreset, to image: UIImage) async -> UIImage? {
        return await imageProcessor.processImageAsync(image, with: preset.filters)
    }

    // MARK: - 创建自定义预设
    func createCustomPreset(name: String, filters: [FilterSetting], from image: UIImage) async -> FilterPreset {
        // 生成缩略图
        let thumbnailSize = CGSize(width: 100, height: 100)
        var thumbnailData: Data?

        if let thumbnail = imageProcessor.resizeImage(image, to: thumbnailSize),
           let processedThumbnail = await imageProcessor.processImageAsync(thumbnail, with: filters) {
            thumbnailData = processedThumbnail.jpegData(compressionQuality: 0.8)
        }

        return FilterPreset(
            name: name,
            filters: filters,
            thumbnailData: thumbnailData
        )
    }
}

// MARK: - 扩展UIImage以支持哈希
extension UIImage {
    var hash: Int {
        var hasher = Hasher()
        if let data = self.pngData() {
            hasher.combine(data)
        }
        return hasher.finalize()
    }
}