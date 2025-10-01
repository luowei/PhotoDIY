import SwiftUI

struct EditingHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var historyManager = EditingHistoryManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingClearAllAlert = false
    @State private var selectedHistoryItem: EditingHistoryItem?
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: EditingHistoryItem?

    var body: some View {
        NavigationView {
            Group {
                if historyManager.historyItems.isEmpty {
                    EmptyHistoryView()
                } else {
                    HistoryListView()
                }
            }
            .background(themeManager.currentTheme.backgroundColor)
            .navigationTitle("编辑历史")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.accentColor)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if !historyManager.historyItems.isEmpty {
                        Button("清空") {
                            showingClearAllAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .themedBackground(themeManager.currentTheme)
        .sheet(item: $selectedHistoryItem) { item in
            HistoryDetailView(historyItem: item)
        }
        .alert("清空历史记录", isPresented: $showingClearAllAlert) {
            Button("取消", role: .cancel) { }
            Button("清空", role: .destructive) {
                withAnimation {
                    historyManager.clearAllHistory()
                }
            }
        } message: {
            Text("确定要清空所有编辑历史记录吗？此操作不可撤销。")
        }
        .alert("删除记录", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {
                itemToDelete = nil
            }
            Button("删除", role: .destructive) {
                if let item = itemToDelete {
                    withAnimation {
                        historyManager.deleteHistoryItem(item)
                    }
                    itemToDelete = nil
                }
            }
        } message: {
            Text("确定要删除这条编辑记录吗？")
        }
    }

    @ViewBuilder
    private func HistoryListView() -> some View {
        let groupedHistory = historyManager.getHistoryByDate()
        let sortedDates = groupedHistory.keys.sorted(by: >)

        List {
            ForEach(sortedDates, id: \.self) { date in
                Section(header: Text(date)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .fontWeight(.medium)
                ) {
                    if let items = groupedHistory[date] {
                        ForEach(items) { item in
                            HistoryItemRow(
                                item: item,
                                onTap: { selectedHistoryItem = item },
                                onDelete: {
                                    itemToDelete = item
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                }
                .listRowBackground(themeManager.currentTheme.cardBackgroundColor)
            }
        }
        .scrollContentBackground(.hidden)
    }
}

// MARK: - 空状态视图
struct EmptyHistoryView: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundColor(themeManager.currentTheme.secondaryColor)

            VStack(spacing: 8) {
                Text("暂无编辑历史")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.currentTheme.textColor)

                Text("当您完成图片编辑后，历史记录将显示在这里")
                    .font(.body)
                    .foregroundColor(themeManager.currentTheme.secondaryColor)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - 历史项目行视图
struct HistoryItemRow: View {
    let item: EditingHistoryItem
    let onTap: () -> Void
    let onDelete: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 12) {
            // 缩略图
            AsyncImageView(imageData: item.thumbnailData)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // 编辑信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.editingModeDisplayName)
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.textColor)

                    Spacer()

                    Text(item.formattedDate)
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryColor)
                }

                Text("点击查看详情")
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryColor)
            }

            Spacer()

            // 操作按钮
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("删除", role: .destructive) {
                onDelete()
            }
        }
    }
}

// MARK: - 异步图片视图
struct AsyncImageView: View {
    let imageData: Data
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.5)
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let uiImage = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
        }
    }
}

// MARK: - 历史详情视图
struct HistoryDetailView: View {
    let historyItem: EditingHistoryItem
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingBeforeAfter = false
    @State private var showingSaveAlert = false
    @State private var showingShareSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 编辑后的图片
                    if let editedImage = historyItem.editedImage {
                        VStack(spacing: 12) {
                            Text("编辑结果")
                                .font(.headline)
                                .foregroundColor(themeManager.currentTheme.textColor)

                            Image(uiImage: editedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 8)
                        }
                    }

                    // 编辑信息
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(title: "编辑模式", value: historyItem.editingModeDisplayName)
                        InfoRow(title: "编辑时间", value: historyItem.formattedDate)

                        if !historyItem.settings.isEmpty && historyItem.settings != "{}" {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("编辑参数")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(themeManager.currentTheme.textColor)

                                Text(formatSettings(historyItem.settings))
                                    .font(.caption)
                                    .foregroundColor(themeManager.currentTheme.secondaryColor)
                                    .padding(12)
                                    .background(themeManager.currentTheme.cardBackgroundColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.horizontal)

                    // 操作按钮
                    VStack(spacing: 12) {
                        Button(action: { showingBeforeAfter.toggle() }) {
                            HStack {
                                Image(systemName: "rectangle.split.2x1")
                                Text(showingBeforeAfter ? "隐藏对比" : "显示对比")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(themeManager.currentTheme.buttonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        HStack(spacing: 12) {
                            Button(action: saveToPhotos) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("保存")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }

                            Button(action: { showingShareSheet = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("分享")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.horizontal)

                    // 对比视图
                    if showingBeforeAfter {
                        BeforeAfterView(historyItem: historyItem)
                    }
                }
                .padding()
            }
            .background(themeManager.currentTheme.backgroundColor)
            .navigationTitle("编辑详情")
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
        .alert("保存成功", isPresented: $showingSaveAlert) {
            Button("确定") { }
        } message: {
            Text("图片已保存到相册")
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = historyItem.editedImage {
                ShareSheet(items: [image])
            }
        }
    }

    private func saveToPhotos() {
        guard let image = historyItem.editedImage else { return }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showingSaveAlert = true
    }

    private func formatSettings(_ settingsString: String) -> String {
        guard let data = settingsString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return "无参数信息"
        }

        var formatted = ""
        for (key, value) in json {
            formatted += "\(key): \(value)\n"
        }
        return formatted.isEmpty ? "无参数信息" : formatted
    }
}

// MARK: - 信息行视图
struct InfoRow: View {
    let title: String
    let value: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(themeManager.currentTheme.secondaryColor)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(themeManager.currentTheme.textColor)
        }
    }
}

// MARK: - 对比视图
struct BeforeAfterView: View {
    let historyItem: EditingHistoryItem
    @State private var showingOriginal = false
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Text("对比效果")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.textColor)

            VStack(spacing: 12) {
                if let originalImage = historyItem.originalImage,
                   let editedImage = historyItem.editedImage {

                    HStack(spacing: 12) {
                        VStack(spacing: 8) {
                            Text("编辑前")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.secondaryColor)

                            Image(uiImage: originalImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        VStack(spacing: 8) {
                            Text("编辑后")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.secondaryColor)

                            Image(uiImage: editedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    // 滑动对比
                    VStack(spacing: 8) {
                        Text("滑动查看对比")
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.secondaryColor)

                        ZStack {
                            Image(uiImage: originalImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 250)

                            Image(uiImage: editedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 250)
                                .opacity(showingOriginal ? 0 : 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingOriginal.toggle()
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 分享视图
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 不需要更新
    }
}

// MARK: - Preview
struct EditingHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        EditingHistoryView()
            .environmentObject(EditingHistoryManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}