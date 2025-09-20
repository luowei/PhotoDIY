import SwiftUI

@main
struct PhotofyApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .onAppear {
                    setupApp()
                }
        }
    }

    private func setupApp() {
        // 应用初始化配置
        configureDependencyInjection()
        setupUserDefaults()
    }

    private func configureDependencyInjection() {
        // 配置依赖注入容器
        DIContainer.shared.register()
    }

    private func setupUserDefaults() {
        // 设置默认用户偏好
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "first_launch") == nil {
            defaults.set(false, forKey: "first_launch")
            defaults.set(true, forKey: "show_onboarding")
        }
    }
}