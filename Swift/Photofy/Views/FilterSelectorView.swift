import SwiftUI

struct FilterSelectorView: View {
    let originalImage: UIImage
    @State private var filterPreviews: [ImageFilterManager.FilterType: UIImage] = [:]
    @State private var isLoading = true
    @Binding var selectedFilter: ImageFilterManager.FilterType
    let onFilterSelected: (ImageFilterManager.FilterType) -> Void

    private let filterManager = ImageFilterManager.shared
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("Filters")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Button("Reset") {
                    selectedFilter = .original
                    onFilterSelected(.original)
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))

            // 滤镜网格
            ScrollView {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)

                        Text("Generating Filter Previews...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(ImageFilterManager.FilterType.allCases, id: \.self) { filterType in
                            FilterPreviewCell(
                                filterType: filterType,
                                previewImage: filterPreviews[filterType],
                                isSelected: selectedFilter == filterType
                            ) {
                                selectedFilter = filterType
                                onFilterSelected(filterType)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .frame(height: 240)
            .background(Color.black.opacity(0.9))
        }
        .task {
            await loadFilterPreviews()
        }
    }

    private func loadFilterPreviews() async {
        isLoading = true
        let previews = await filterManager.generateFilterPreviews(for: originalImage)
        await MainActor.run {
            self.filterPreviews = previews
            self.isLoading = false
        }
    }
}

struct FilterPreviewCell: View {
    let filterType: ImageFilterManager.FilterType
    let previewImage: UIImage?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 70, height: 70)

                if let image = previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: filterType.icon)
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                // 选中状态指示器
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 70, height: 70)

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .background(Color.white, in: Circle())
                                .font(.caption)
                                .offset(x: 4, y: 4)
                        }
                    }
                    .frame(width: 70, height: 70)
                }
            }

            Text(filterType.displayName)
                .font(.caption2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 24)
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - 色彩调整视图
struct ColorAdjustmentView: View {
    @Binding var brightness: Float
    @Binding var contrast: Float
    @Binding var saturation: Float
    @Binding var hue: Float

    let onAdjustmentChanged: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("Adjust")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Button("Reset") {
                    brightness = 0
                    contrast = 1
                    saturation = 1
                    hue = 0
                    onAdjustmentChanged()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))

            // 调整滑块
            VStack(spacing: 20) {
                AdjustmentSlider(
                    title: "Brightness",
                    value: $brightness,
                    range: -1...1,
                    icon: "sun.max.fill",
                    onChange: onAdjustmentChanged
                )

                AdjustmentSlider(
                    title: "Contrast",
                    value: $contrast,
                    range: 0...2,
                    icon: "circle.righthalf.filled",
                    onChange: onAdjustmentChanged
                )

                AdjustmentSlider(
                    title: "Saturation",
                    value: $saturation,
                    range: 0...2,
                    icon: "paintbrush.fill",
                    onChange: onAdjustmentChanged
                )

                AdjustmentSlider(
                    title: "Hue",
                    value: $hue,
                    range: -Float.pi...Float.pi,
                    icon: "paintpalette.fill",
                    onChange: onAdjustmentChanged
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.black.opacity(0.9))
        }
    }
}

struct AdjustmentSlider: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let icon: String
    let onChange: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 20)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)

                Spacer()

                Text(String(format: "%.2f", value))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 40, alignment: .trailing)
            }

            Slider(value: $value, in: range) { _ in
                onChange()
            }
            .tint(.blue)
        }
    }
}