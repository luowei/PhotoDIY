import Foundation
import UIKit
import CoreData

// MARK: - 编辑历史项目
struct EditingHistoryItem: Identifiable, Codable {
    let id = UUID()
    let originalImageData: Data
    let editedImageData: Data
    let timestamp: Date
    let editingMode: String
    let settings: String // JSON格式的设置数据
    let thumbnailData: Data

    var originalImage: UIImage? {
        return UIImage(data: originalImageData)
    }

    var editedImage: UIImage? {
        return UIImage(data: editedImageData)
    }

    var thumbnail: UIImage? {
        return UIImage(data: thumbnailData)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: timestamp)
    }

    var editingModeDisplayName: String {
        switch editingMode {
        case "portrait": return "人像"
        case "landscape": return "风景"
        case "food": return "美食"
        case "ecommerce": return "电商"
        case "idPhoto": return "证件照"
        case "filter": return "滤镜"
        case "adjust": return "调整"
        case "crop": return "裁剪"
        default: return "其他"
        }
    }

    static func create(
        originalImage: UIImage,
        editedImage: UIImage,
        editingMode: EditingMode,
        settings: Any? = nil
    ) -> EditingHistoryItem? {
        guard let originalData = originalImage.jpegData(compressionQuality: 0.8),
              let editedData = editedImage.jpegData(compressionQuality: 0.8),
              let thumbnailData = createThumbnail(from: editedImage)?.jpegData(compressionQuality: 0.7) else {
            return nil
        }

        let settingsString: String
        if let settings = settings {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: settings)
                settingsString = String(data: jsonData, encoding: .utf8) ?? "{}"
            } catch {
                settingsString = "{}"
            }
        } else {
            settingsString = "{}"
        }

        return EditingHistoryItem(
            originalImageData: originalData,
            editedImageData: editedData,
            timestamp: Date(),
            editingMode: editingMode.rawValue,
            settings: settingsString,
            thumbnailData: thumbnailData
        )
    }

    private static func createThumbnail(from image: UIImage) -> UIImage? {
        let size = CGSize(width: 120, height: 120)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail
    }
}

// MARK: - 编辑历史管理器
class EditingHistoryManager: ObservableObject {
    static let shared = EditingHistoryManager()

    @Published var historyItems: [EditingHistoryItem] = []
    private let maxHistoryItems = 100 // 最大保存数量

    private init() {
        loadHistory()
    }

    func addHistoryItem(_ item: EditingHistoryItem) {
        historyItems.insert(item, at: 0) // 最新的在前面

        // 限制历史记录数量
        if historyItems.count > maxHistoryItems {
            historyItems = Array(historyItems.prefix(maxHistoryItems))
        }

        saveHistory()
    }

    func addEditingSession(
        originalImage: UIImage,
        editedImage: UIImage,
        editingMode: EditingMode,
        settings: Any? = nil
    ) {
        guard let historyItem = EditingHistoryItem.create(
            originalImage: originalImage,
            editedImage: editedImage,
            editingMode: editingMode,
            settings: settings
        ) else { return }

        addHistoryItem(historyItem)
    }

    func deleteHistoryItem(_ item: EditingHistoryItem) {
        historyItems.removeAll { $0.id == item.id }
        saveHistory()
    }

    func clearAllHistory() {
        historyItems.removeAll()
        saveHistory()
    }

    func getHistoryByDate() -> [String: [EditingHistoryItem]] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: historyItems) { item in
            let components = calendar.dateComponents([.year, .month, .day], from: item.timestamp)
            let date = calendar.date(from: components) ?? item.timestamp
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
        return grouped
    }

    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(historyItems)
            UserDefaults.standard.set(data, forKey: "editingHistory")
        } catch {
            print("Failed to save editing history: \(error)")
        }
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: "editingHistory") else { return }
        do {
            historyItems = try JSONDecoder().decode([EditingHistoryItem].self, from: data)
        } catch {
            print("Failed to load editing history: \(error)")
            historyItems = []
        }
    }
}

// MARK: - 编辑模式扩展
extension EditingMode {
    var rawValue: String {
        switch self {
        case .none: return "none"
        case .filter: return "filter"
        case .adjust: return "adjust"
        case .crop: return "crop"
        case .text: return "text"
        case .sticker: return "sticker"
        case .draw: return "draw"
        case .portrait: return "portrait"
        case .idPhoto: return "idPhoto"
        case .landscape: return "landscape"
        case .food: return "food"
        case .ecommerce: return "ecommerce"
        case .portrait_art: return "portrait_art"
        case .emoji: return "emoji"
        case .artistic: return "artistic"
        case .vintage: return "vintage"
        case .comic: return "comic"
        case .sketch: return "sketch"
        case .watercolor: return "watercolor"
        }
    }
}

// MARK: - 用户偏好设置
class UserPreferences: ObservableObject {
    static let shared = UserPreferences()

    @Published var autoSaveEnabled: Bool = true {
        didSet { UserDefaults.standard.set(autoSaveEnabled, forKey: "autoSaveEnabled") }
    }

    @Published var imageQuality: ImageQuality = .high {
        didSet { UserDefaults.standard.set(imageQuality.rawValue, forKey: "imageQuality") }
    }

    @Published var processingQuality: ProcessingQuality = .high {
        didSet { UserDefaults.standard.set(processingQuality.rawValue, forKey: "processingQuality") }
    }

    @Published var showProcessingProgress: Bool = true {
        didSet { UserDefaults.standard.set(showProcessingProgress, forKey: "showProcessingProgress") }
    }

    @Published var enableHapticFeedback: Bool = true {
        didSet { UserDefaults.standard.set(enableHapticFeedback, forKey: "enableHapticFeedback") }
    }

    @Published var cacheSize: CacheSize = .medium {
        didSet { UserDefaults.standard.set(cacheSize.rawValue, forKey: "cacheSize") }
    }

    private init() {
        loadPreferences()
    }

    private func loadPreferences() {
        autoSaveEnabled = UserDefaults.standard.bool(forKey: "autoSaveEnabled")

        if let qualityRaw = UserDefaults.standard.string(forKey: "imageQuality"),
           let quality = ImageQuality(rawValue: qualityRaw) {
            imageQuality = quality
        }

        if let processingRaw = UserDefaults.standard.string(forKey: "processingQuality"),
           let processing = ProcessingQuality(rawValue: processingRaw) {
            processingQuality = processing
        }

        showProcessingProgress = UserDefaults.standard.bool(forKey: "showProcessingProgress")
        enableHapticFeedback = UserDefaults.standard.bool(forKey: "enableHapticFeedback")

        if let cacheSizeRaw = UserDefaults.standard.string(forKey: "cacheSize"),
           let cache = CacheSize(rawValue: cacheSizeRaw) {
            cacheSize = cache
        }
    }
}

enum ImageQuality: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case original = "original"

    var displayName: String {
        switch self {
        case .low: return "低质量 (节省空间)"
        case .medium: return "中等质量"
        case .high: return "高质量"
        case .original: return "原始质量"
        }
    }

    var compressionQuality: CGFloat {
        switch self {
        case .low: return 0.3
        case .medium: return 0.6
        case .high: return 0.8
        case .original: return 1.0
        }
    }
}

enum ProcessingQuality: String, CaseIterable {
    case fast = "fast"
    case balanced = "balanced"
    case high = "high"

    var displayName: String {
        switch self {
        case .fast: return "快速处理"
        case .balanced: return "平衡质量"
        case .high: return "高质量处理"
        }
    }
}

enum CacheSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"

    var displayName: String {
        switch self {
        case .small: return "小 (50MB)"
        case .medium: return "中 (200MB)"
        case .large: return "大 (500MB)"
        }
    }

    var sizeInBytes: Int {
        switch self {
        case .small: return 50 * 1024 * 1024
        case .medium: return 200 * 1024 * 1024
        case .large: return 500 * 1024 * 1024
        }
    }
}