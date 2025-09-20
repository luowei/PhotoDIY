import SwiftUI
import Combine

// MARK: - 应用全局状态
class AppState: ObservableObject {
    @Published var currentProject: EditingProject?
    @Published var recentProjects: [EditingProject] = []
    @Published var userPreferences: UserPreferences = .default
    @Published var isPurchased: Bool = false
    @Published var isFirstLaunch: Bool = true

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadUserPreferences()
        loadPurchaseStatus()
    }

    // MARK: - 加载用户偏好
    private func loadUserPreferences() {
        let defaults = UserDefaults.standard
        isPurchased = defaults.bool(forKey: "is_purchased")
        isFirstLaunch = defaults.bool(forKey: "first_launch")

        // 加载用户偏好设置
        if let data = defaults.data(forKey: "user_preferences"),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            userPreferences = preferences
        }
    }

    // MARK: - 保存用户偏好
    func saveUserPreferences() {
        let defaults = UserDefaults.standard
        defaults.set(isPurchased, forKey: "is_purchased")
        defaults.set(false, forKey: "first_launch")

        if let data = try? JSONEncoder().encode(userPreferences) {
            defaults.set(data, forKey: "user_preferences")
        }
    }

    // MARK: - 加载购买状态
    private func loadPurchaseStatus() {
        // 这里将来会集成StoreKit
        // 目前使用UserDefaults模拟
    }

    // MARK: - 设置当前项目
    func setCurrentProject(_ project: EditingProject) {
        currentProject = project
        addToRecentProjects(project)
    }

    // MARK: - 添加到最近项目
    private func addToRecentProjects(_ project: EditingProject) {
        recentProjects.removeAll { $0.id == project.id }
        recentProjects.insert(project, at: 0)

        // 限制最近项目数量
        if recentProjects.count > 10 {
            recentProjects = Array(recentProjects.prefix(10))
        }
    }
}

// MARK: - 编辑项目模型
struct EditingProject: Identifiable, Codable {
    let id = UUID()
    var name: String
    var originalImageData: Data?
    var currentImageData: Data?
    var filterSettings: [FilterSetting]
    var createdAt: Date
    var updatedAt: Date

    init(name: String, imageData: Data? = nil) {
        self.name = name
        self.originalImageData = imageData
        self.currentImageData = imageData
        self.filterSettings = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - 滤镜设置
struct FilterSetting: Identifiable, Codable {
    let id = UUID()
    let filterType: String
    let intensity: Float
    let appliedAt: Date

    init(filterType: String, intensity: Float) {
        self.filterType = filterType
        self.intensity = intensity
        self.appliedAt = Date()
    }
}

// MARK: - 用户偏好设置
struct UserPreferences: Codable {
    var language: String
    var enableHaptics: Bool
    var autoSaveEnabled: Bool
    var exportQuality: ExportQuality
    var showWatermark: Bool

    static let `default` = UserPreferences(
        language: "en",
        enableHaptics: true,
        autoSaveEnabled: true,
        exportQuality: .high,
        showWatermark: false
    )
}

// MARK: - 导出质量
enum ExportQuality: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case original = "original"

    var displayName: String {
        switch self {
        case .low: return "Low (Fast)"
        case .medium: return "Medium"
        case .high: return "High"
        case .original: return "Original (Best)"
        }
    }

    var compressionQuality: CGFloat {
        switch self {
        case .low: return 0.5
        case .medium: return 0.7
        case .high: return 0.9
        case .original: return 1.0
        }
    }
}