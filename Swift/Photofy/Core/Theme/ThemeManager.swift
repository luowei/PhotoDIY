import SwiftUI
import Foundation

// MARK: - 主题管理器
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: AppTheme = .dark {
        didSet {
            saveTheme()
        }
    }

    private init() {
        loadTheme()
    }

    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
    }

    private func loadTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }

    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
}

// MARK: - 应用主题枚举
enum AppTheme: String, CaseIterable {
    case dark = "dark"
    case light = "light"
    case blue = "blue"
    case purple = "purple"
    case green = "green"
    case orange = "orange"

    var displayName: String {
        switch self {
        case .dark: return "深色主题"
        case .light: return "浅色主题"
        case .blue: return "蓝色主题"
        case .purple: return "紫色主题"
        case .green: return "绿色主题"
        case .orange: return "橙色主题"
        }
    }

    var icon: String {
        switch self {
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        case .blue: return "drop.fill"
        case .purple: return "heart.fill"
        case .green: return "leaf.fill"
        case .orange: return "flame.fill"
        }
    }
}

// MARK: - 主题颜色定义
extension AppTheme {
    var backgroundColor: Color {
        switch self {
        case .dark: return Color.black
        case .light: return Color.white
        case .blue: return Color(red: 0.05, green: 0.15, blue: 0.25)
        case .purple: return Color(red: 0.15, green: 0.05, blue: 0.25)
        case .green: return Color(red: 0.05, green: 0.2, blue: 0.1)
        case .orange: return Color(red: 0.2, green: 0.1, blue: 0.05)
        }
    }

    var primaryColor: Color {
        switch self {
        case .dark: return Color.white
        case .light: return Color.black
        case .blue: return Color.blue
        case .purple: return Color.purple
        case .green: return Color.green
        case .orange: return Color.orange
        }
    }

    var secondaryColor: Color {
        switch self {
        case .dark: return Color.gray
        case .light: return Color.gray
        case .blue: return Color.cyan
        case .purple: return Color.pink
        case .green: return Color.mint
        case .orange: return Color.yellow
        }
    }

    var accentColor: Color {
        switch self {
        case .dark: return Color.blue
        case .light: return Color.blue
        case .blue: return Color.cyan
        case .purple: return Color.pink
        case .green: return Color.mint
        case .orange: return Color.yellow
        }
    }

    var textColor: Color {
        switch self {
        case .dark: return Color.white
        case .light: return Color.black
        case .blue: return Color.white
        case .purple: return Color.white
        case .green: return Color.white
        case .orange: return Color.white
        }
    }

    var cardBackgroundColor: Color {
        switch self {
        case .dark: return Color(white: 0.15)
        case .light: return Color(white: 0.95)
        case .blue: return Color(red: 0.1, green: 0.2, blue: 0.35)
        case .purple: return Color(red: 0.25, green: 0.15, blue: 0.35)
        case .green: return Color(red: 0.1, green: 0.3, blue: 0.2)
        case .orange: return Color(red: 0.3, green: 0.2, blue: 0.1)
        }
    }

    var buttonGradient: LinearGradient {
        switch self {
        case .dark:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .light:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .blue:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .purple:
            return LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.pink]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .green:
            return LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.mint]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .orange:
            return LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.yellow]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

// MARK: - 主题环境键
struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppTheme = .dark
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - 主题修饰符
struct ThemedBackground: ViewModifier {
    let theme: AppTheme

    func body(content: Content) -> some View {
        content
            .background(theme.backgroundColor)
            .foregroundColor(theme.textColor)
    }
}

struct ThemedCard: ViewModifier {
    let theme: AppTheme

    func body(content: Content) -> some View {
        content
            .background(theme.cardBackgroundColor)
            .foregroundColor(theme.textColor)
            .cornerRadius(12)
    }
}

extension View {
    func themedBackground(_ theme: AppTheme) -> some View {
        modifier(ThemedBackground(theme: theme))
    }

    func themedCard(_ theme: AppTheme) -> some View {
        modifier(ThemedCard(theme: theme))
    }
}