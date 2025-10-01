import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var userPreferences = UserPreferences.shared
    @State private var showingEditingHistory = false
    @State private var showingAbout = false
    @State private var showingClearCacheAlert = false

    var body: some View {
        NavigationView {
            List {
                // 主题设置部分
                Section("主题设置") {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        HStack {
                            // 主题图标
                            Image(systemName: theme.icon)
                                .foregroundColor(theme.primaryColor)
                                .frame(width: 24, height: 24)

                            // 主题名称
                            Text(theme.displayName)
                                .foregroundColor(themeManager.currentTheme.textColor)

                            Spacer()

                            // 选中指示器
                            if themeManager.currentTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(theme.accentColor)
                                    .fontWeight(.semibold)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.setTheme(theme)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowBackground(themeManager.currentTheme.cardBackgroundColor)

                // 图片处理设置
                Section("图片处理") {
                    // 图片质量设置
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("图片质量")
                                .foregroundColor(themeManager.currentTheme.textColor)
                            Spacer()
                            Text(userPreferences.imageQuality.displayName)
                                .foregroundColor(themeManager.currentTheme.secondaryColor)
                                .font(.caption)
                        }

                        Picker("图片质量", selection: $userPreferences.imageQuality) {
                            ForEach(ImageQuality.allCases, id: \.self) { quality in
                                Text(quality.displayName).tag(quality)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    // 处理质量设置
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "cpu")
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("处理质量")
                                .foregroundColor(themeManager.currentTheme.textColor)
                            Spacer()
                            Text(userPreferences.processingQuality.displayName)
                                .foregroundColor(themeManager.currentTheme.secondaryColor)
                                .font(.caption)
                        }

                        Picker("处理质量", selection: $userPreferences.processingQuality) {
                            ForEach(ProcessingQuality.allCases, id: \.self) { quality in
                                Text(quality.displayName).tag(quality)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    // 缓存大小设置
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "internaldrive")
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("缓存大小")
                                .foregroundColor(themeManager.currentTheme.textColor)
                            Spacer()
                            Text(userPreferences.cacheSize.displayName)
                                .foregroundColor(themeManager.currentTheme.secondaryColor)
                                .font(.caption)
                        }

                        Picker("缓存大小", selection: $userPreferences.cacheSize) {
                            ForEach(CacheSize.allCases, id: \.self) { size in
                                Text(size.displayName).tag(size)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .listRowBackground(themeManager.currentTheme.cardBackgroundColor)

                // 用户体验设置
                Section("用户体验") {
                    // 自动保存
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                        Text("自动保存")
                            .foregroundColor(themeManager.currentTheme.textColor)
                        Spacer()
                        Toggle("", isOn: $userPreferences.autoSaveEnabled)
                            .tint(themeManager.currentTheme.accentColor)
                    }

                    // 显示处理进度
                    HStack {
                        Image(systemName: "progress.indicator")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                        Text("显示处理进度")
                            .foregroundColor(themeManager.currentTheme.textColor)
                        Spacer()
                        Toggle("", isOn: $userPreferences.showProcessingProgress)
                            .tint(themeManager.currentTheme.accentColor)
                    }

                    // 触觉反馈
                    HStack {
                        Image(systemName: "hand.tap")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                        Text("触觉反馈")
                            .foregroundColor(themeManager.currentTheme.textColor)
                        Spacer()
                        Toggle("", isOn: $userPreferences.enableHapticFeedback)
                            .tint(themeManager.currentTheme.accentColor)
                    }
                }
                .listRowBackground(themeManager.currentTheme.cardBackgroundColor)

                // 编辑历史
                Section("编辑历史") {
                    Button(action: { showingEditingHistory = true }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("查看编辑历史")
                                .foregroundColor(themeManager.currentTheme.textColor)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(themeManager.currentTheme.secondaryColor)
                                .font(.caption)
                        }
                    }
                }
                .listRowBackground(themeManager.currentTheme.cardBackgroundColor)

                // 存储管理
                Section("存储管理") {
                    Button(action: { showingClearCacheAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("清除缓存")
                                .foregroundColor(.red)
                        }
                    }
                }
                .listRowBackground(themeManager.currentTheme.cardBackgroundColor)

                // 关于
                Section("关于") {
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("关于 Photofy")
                                .foregroundColor(themeManager.currentTheme.textColor)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(themeManager.currentTheme.secondaryColor)
                                .font(.caption)
                        }
                    }
                }
                .listRowBackground(themeManager.currentTheme.cardBackgroundColor)
            }
            .background(themeManager.currentTheme.backgroundColor)
            .scrollContentBackground(.hidden)
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
        }
        .themedBackground(themeManager.currentTheme)
        .sheet(isPresented: $showingEditingHistory) {
            EditingHistoryView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .alert("清除缓存", isPresented: $showingClearCacheAlert) {
            Button("取消", role: .cancel) { }
            Button("清除", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("确定要清除所有缓存数据吗？这将释放存储空间，但可能影响应用性能。")
        }
    }

    private func clearCache() {
        // 清除缓存逻辑
        URLCache.shared.removeAllCachedResponses()

        // 清除临时文件
        let tempDirectory = FileManager.default.temporaryDirectory
        try? FileManager.default.removeItem(at: tempDirectory)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        // 触觉反馈
        if userPreferences.enableHapticFeedback {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - 关于页面
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App图标和信息
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 80))
                            .foregroundColor(themeManager.currentTheme.accentColor)

                        VStack(spacing: 8) {
                            Text("Photofy")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.textColor)

                            Text("专业级AI照片编辑器")
                                .font(.subtitle)
                                .foregroundColor(themeManager.currentTheme.secondaryColor)

                            Text("版本 1.0.0")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.secondaryColor)
                        }
                    }

                    // 功能特色
                    VStack(alignment: .leading, spacing: 16) {
                        Text("主要功能")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.textColor)

                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "brain.head.profile", title: "AI智能处理", description: "先进的人工智能算法，自动优化照片效果")
                            FeatureRow(icon: "paintbrush", title: "多样化滤镜", description: "丰富的滤镜效果，满足不同风格需求")
                            FeatureRow(icon: "crop", title: "精准裁剪", description: "智能裁剪工具，完美构图")
                            FeatureRow(icon: "slider.horizontal.3", title: "专业调节", description: "亮度、对比度、饱和度等参数精细调节")
                            FeatureRow(icon: "person.crop.circle", title: "人像美化", description: "专业人像处理，自然美颜效果")
                        }
                    }
                    .padding(.horizontal)

                    // 版权信息
                    VStack(spacing: 8) {
                        Text("© 2024 Photofy")
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.secondaryColor)

                        Text("由 AI 技术驱动")
                            .font(.caption2)
                            .foregroundColor(themeManager.currentTheme.secondaryColor)
                    }
                }
                .padding()
            }
            .background(themeManager.currentTheme.backgroundColor)
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
        }
        .themedBackground(themeManager.currentTheme)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(themeManager.currentTheme.accentColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.currentTheme.textColor)

                Text(description)
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryColor)
            }

            Spacer()
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager.shared)
            .environmentObject(UserPreferences.shared)
    }
}