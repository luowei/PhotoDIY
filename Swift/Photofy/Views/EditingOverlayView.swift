import SwiftUI

struct EditingOverlayView: View {
    let editingMode: EditingMode
    let image: UIImage
    let onEditingComplete: (UIImage) -> Void
    let onEditingCancel: () -> Void
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        ZStack {
            switch editingMode {
            case .crop:
                CropView(
                    image: image,
                    onCropComplete: onEditingComplete,
                    onCancel: onEditingCancel,
                    viewModel: viewModel
                )
            case .text:
                TextOverlayView()
            case .sticker:
                StickerOverlayView()
            default:
                EmptyView()
            }
        }
    }
}

struct CropOverlayView: View {
    let image: UIImage
    let onCropComplete: (UIImage) -> Void

    @State private var cropRect = CGRect(x: 0.15, y: 0.15, width: 0.7, height: 0.7)
    @State private var isDragging = false
    @State private var dragOffset = CGSize.zero
    @State private var lastDragValue = CGSize.zero
    @State private var activeHandle: CropHandle?
    @State private var showingCropSuggestions = false
    @State private var cropSuggestions: [CropSuggestion] = []
    @State private var isProcessing = false
    @GestureState private var magnifyBy = 1.0

    enum CropHandle {
        case topLeft, topRight, bottomLeft, bottomRight, center
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 半透明遮罩
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                // 裁剪区域透明窗口
                let cropFrame = getCropFrame(in: geometry.size)
                Rectangle()
                    .path(in: CGRect(origin: .zero, size: geometry.size))
                    .fill(Color.black.opacity(0.6))
                    .mask {
                        Rectangle()
                            .fill(Color.black)
                            .overlay {
                                Rectangle()
                                    .frame(width: cropFrame.width, height: cropFrame.height)
                                    .position(x: cropFrame.midX, y: cropFrame.midY)
                                    .blendMode(.destinationOut)
                            }
                    }

                // 裁剪框边界
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: cropFrame.width, height: cropFrame.height)
                    .position(x: cropFrame.midX, y: cropFrame.midY)

                // 网格线
                CropGridView()
                    .frame(width: cropFrame.width, height: cropFrame.height)
                    .position(x: cropFrame.midX, y: cropFrame.midY)

                // 角落控制点
                Group {
                    CropHandleView()
                        .position(x: cropFrame.minX, y: cropFrame.minY)
                        .gesture(createHandleGesture(.topLeft, in: geometry.size))

                    CropHandleView()
                        .position(x: cropFrame.maxX, y: cropFrame.minY)
                        .gesture(createHandleGesture(.topRight, in: geometry.size))

                    CropHandleView()
                        .position(x: cropFrame.minX, y: cropFrame.maxY)
                        .gesture(createHandleGesture(.bottomLeft, in: geometry.size))

                    CropHandleView()
                        .position(x: cropFrame.maxX, y: cropFrame.maxY)
                        .gesture(createHandleGesture(.bottomRight, in: geometry.size))
                }

                // 中心拖拽区域
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: cropFrame.width, height: cropFrame.height)
                    .position(x: cropFrame.midX, y: cropFrame.midY)
                    .gesture(createCenterDragGesture(in: geometry.size))

                // 控制按钮
                VStack {
                    Spacer()
                    HStack {
                        Button("比例") {
                            showingCropSuggestions.toggle()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)

                        Spacer()

                        Button("重置") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                cropRect = CGRect(x: 0.15, y: 0.15, width: 0.7, height: 0.7)
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)

                        Spacer()

                        Button(isProcessing ? "处理中..." : "确认") {
                            Task {
                                await performCrop(in: geometry.size)
                            }
                        }
                        .disabled(isProcessing)
                        .foregroundColor(.white)
                        .padding()
                        .background(isProcessing ? Color.gray : Color.yellow)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }

                // 裁剪比例建议
                if showingCropSuggestions {
                    VStack {
                        HStack {
                            Text("裁剪比例")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button("关闭") {
                                showingCropSuggestions = false
                            }
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(cropSuggestions) { suggestion in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            applyCropSuggestion(suggestion, in: geometry.size)
                                        }
                                        showingCropSuggestions = false
                                    }) {
                                        VStack {
                                            Image(systemName: suggestion.icon)
                                                .font(.title2)
                                                .foregroundColor(.white)
                                            Text(suggestion.name)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                        .padding(8)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .background(Color.black.opacity(0.8))
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.15)
                }
            }
        }
        .onAppear {
            loadCropSuggestions()
        }
    }

    private func loadCropSuggestions() {
        Task {
            cropSuggestions = await ImageCropManager.shared.suggestCropRectangles(for: image)
        }
    }

    private func applyCropSuggestion(_ suggestion: CropSuggestion, in size: CGSize) {
        if let aspectRatio = suggestion.aspectRatio {
            // 根据容器尺寸和所需的长宽比计算最佳裁剪区域
            let containerAspectRatio = size.width / size.height

            if aspectRatio > containerAspectRatio {
                // 按宽度计算
                let width: CGFloat = 0.8
                let height = width / aspectRatio
                let y = (1.0 - height) / 2
                cropRect = CGRect(x: 0.1, y: y, width: width, height: height)
            } else {
                // 按高度计算
                let height: CGFloat = 0.8
                let width = height * aspectRatio
                let x = (1.0 - width) / 2
                cropRect = CGRect(x: x, y: 0.1, width: width, height: height)
            }
        } else {
            cropRect = suggestion.rect
        }
    }

    private func performCrop(in size: CGSize) async {
        isProcessing = true

        let cropFrame = getCropFrame(in: size)

        if let croppedImage = await ImageCropManager.shared.cropImage(image, to: cropFrame, imageViewSize: size) {
            await MainActor.run {
                onCropComplete(croppedImage)
                isProcessing = false
            }
        } else {
            await MainActor.run {
                isProcessing = false
            }
        }
    }

    private func getCropFrame(in size: CGSize) -> CGRect {
        return CGRect(
            x: cropRect.minX * size.width,
            y: cropRect.minY * size.height,
            width: cropRect.width * size.width,
            height: cropRect.height * size.height
        )
    }

    private func createHandleGesture(_ handle: CropHandle, in size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation
                let normalizedTranslation = CGSize(
                    width: translation.width / size.width,
                    height: translation.height / size.height
                )

                switch handle {
                case .topLeft:
                    let newX = min(cropRect.maxX - 0.1, cropRect.minX + normalizedTranslation.width)
                    let newY = min(cropRect.maxY - 0.1, cropRect.minY + normalizedTranslation.height)
                    let newWidth = cropRect.maxX - max(0, newX)
                    let newHeight = cropRect.maxY - max(0, newY)
                    cropRect = CGRect(x: max(0, newX), y: max(0, newY), width: newWidth, height: newHeight)

                case .topRight:
                    let newWidth = min(1 - cropRect.minX, cropRect.width + normalizedTranslation.width)
                    let newY = min(cropRect.maxY - 0.1, cropRect.minY + normalizedTranslation.height)
                    let newHeight = cropRect.maxY - max(0, newY)
                    cropRect = CGRect(x: cropRect.minX, y: max(0, newY), width: max(0.1, newWidth), height: newHeight)

                case .bottomLeft:
                    let newX = min(cropRect.maxX - 0.1, cropRect.minX + normalizedTranslation.width)
                    let newWidth = cropRect.maxX - max(0, newX)
                    let newHeight = min(1 - cropRect.minY, cropRect.height + normalizedTranslation.height)
                    cropRect = CGRect(x: max(0, newX), y: cropRect.minY, width: newWidth, height: max(0.1, newHeight))

                case .bottomRight:
                    let newWidth = min(1 - cropRect.minX, cropRect.width + normalizedTranslation.width)
                    let newHeight = min(1 - cropRect.minY, cropRect.height + normalizedTranslation.height)
                    cropRect = CGRect(x: cropRect.minX, y: cropRect.minY, width: max(0.1, newWidth), height: max(0.1, newHeight))

                default:
                    break
                }
            }
    }

    private func createCenterDragGesture(in size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let normalizedTranslation = CGSize(
                    width: value.translation.width / size.width,
                    height: value.translation.height / size.height
                )

                let newX = max(0, min(1 - cropRect.width, cropRect.minX + normalizedTranslation.width - lastDragValue.width))
                let newY = max(0, min(1 - cropRect.height, cropRect.minY + normalizedTranslation.height - lastDragValue.height))

                cropRect = CGRect(x: newX, y: newY, width: cropRect.width, height: cropRect.height)
                lastDragValue = normalizedTranslation
            }
            .onEnded { _ in
                lastDragValue = .zero
            }
    }
}

struct CropHandleView: View {
    var body: some View {
        Circle()
            .fill(Color.yellow)
            .frame(width: 24, height: 24)
            .overlay {
                Circle()
                    .stroke(Color.white, lineWidth: 3)
            }
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

struct CropGridView: View {
    var body: some View {
        ZStack {
            // 水平线
            VStack {
                Spacer()
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.yellow.opacity(0.6))
                Spacer()
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.yellow.opacity(0.6))
                Spacer()
            }

            // 垂直线
            HStack {
                Spacer()
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(.yellow.opacity(0.6))
                Spacer()
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(.yellow.opacity(0.6))
                Spacer()
            }
        }
    }
}

struct TextOverlayView: View {
    @State private var textElements: [TextElement] = []
    @State private var showingTextEditor = false
    @State private var selectedTextElement: TextElement?

    var body: some View {
        ZStack {
            // 文本元素
            ForEach(textElements) { element in
                DraggableTextView(element: element) { updatedElement in
                    if let index = textElements.firstIndex(where: { $0.id == element.id }) {
                        textElements[index] = updatedElement
                    }
                }
                .onTapGesture {
                    selectedTextElement = element
                    showingTextEditor = true
                }
            }

            // 添加文本提示
            if textElements.isEmpty {
                VStack {
                    Spacer()
                    Text("Tap to add text")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                    Spacer()
                }
                .onTapGesture {
                    addNewTextElement()
                }
            }
        }
        .sheet(isPresented: $showingTextEditor) {
            if let element = selectedTextElement {
                TextEditorView(element: element) { updatedElement in
                    if let index = textElements.firstIndex(where: { $0.id == element.id }) {
                        textElements[index] = updatedElement
                    }
                }
            }
        }
    }

    private func addNewTextElement() {
        let newElement = TextElement(
            text: "Tap to edit",
            position: CGPoint(x: 200, y: 300),
            font: .systemFont(ofSize: 24),
            color: .white
        )
        textElements.append(newElement)
        selectedTextElement = newElement
        showingTextEditor = true
    }
}

struct TextElement: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var font: UIFont
    var color: UIColor
    var rotation: Double = 0
    var scale: CGFloat = 1.0
}

struct DraggableTextView: View {
    let element: TextElement
    let onUpdate: (TextElement) -> Void

    @State private var dragOffset = CGSize.zero

    var body: some View {
        Text(element.text)
            .font(Font(element.font))
            .foregroundColor(Color(element.color))
            .scaleEffect(element.scale)
            .rotationEffect(.degrees(element.rotation))
            .position(x: element.position.x + dragOffset.width, y: element.position.y + dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        var updatedElement = element
                        updatedElement.position = CGPoint(
                            x: element.position.x + value.translation.width,
                            y: element.position.y + value.translation.height
                        )
                        onUpdate(updatedElement)
                        dragOffset = .zero
                    }
            )
    }
}

struct TextEditorView: View {
    let element: TextElement
    let onUpdate: (TextElement) -> Void

    @State private var text: String
    @State private var fontSize: CGFloat
    @State private var selectedColor: Color
    @Environment(\.dismiss) private var dismiss

    init(element: TextElement, onUpdate: @escaping (TextElement) -> Void) {
        self.element = element
        self.onUpdate = onUpdate
        self._text = State(initialValue: element.text)
        self._fontSize = State(initialValue: element.font.pointSize)
        self._selectedColor = State(initialValue: Color(element.color))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 文本输入
                TextField("Enter text", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.headline)

                // 字体大小
                VStack(alignment: .leading) {
                    Text("Font Size: \(Int(fontSize))")
                        .font(.subheadline)
                    Slider(value: $fontSize, in: 12...72, step: 1)
                }

                // 颜色选择
                VStack(alignment: .leading) {
                    Text("Color")
                        .font(.subheadline)
                    ColorPicker("Text Color", selection: $selectedColor)
                }

                // 预览
                Text(text.isEmpty ? "Preview" : text)
                    .font(.system(size: fontSize))
                    .foregroundColor(selectedColor)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("Edit Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        var updatedElement = element
                        updatedElement.text = text
                        updatedElement.font = UIFont.systemFont(ofSize: fontSize)
                        updatedElement.color = UIColor(selectedColor)
                        onUpdate(updatedElement)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StickerOverlayView: View {
    @State private var stickerElements: [StickerElement] = []

    var body: some View {
        ZStack {
            // 贴纸元素
            ForEach(stickerElements) { element in
                DraggableStickerView(element: element) { updatedElement in
                    if let index = stickerElements.firstIndex(where: { $0.id == element.id }) {
                        stickerElements[index] = updatedElement
                    }
                }
            }

            // 添加贴纸提示
            if stickerElements.isEmpty {
                VStack {
                    Spacer()
                    Text("Select a sticker from the toolbar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                    Spacer()
                }
            }
        }
    }
}

struct StickerElement: Identifiable {
    let id = UUID()
    var emoji: String
    var position: CGPoint
    var scale: CGFloat = 1.0
    var rotation: Double = 0
}

struct DraggableStickerView: View {
    let element: StickerElement
    let onUpdate: (StickerElement) -> Void

    @State private var dragOffset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0

    var body: some View {
        Text(element.emoji)
            .font(.system(size: 60))
            .scaleEffect(element.scale * scale)
            .rotationEffect(.degrees(element.rotation + rotation))
            .position(x: element.position.x + dragOffset.width, y: element.position.y + dragOffset.height)
            .gesture(
                SimultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            var updatedElement = element
                            updatedElement.position = CGPoint(
                                x: element.position.x + value.translation.width,
                                y: element.position.y + value.translation.height
                            )
                            onUpdate(updatedElement)
                            dragOffset = .zero
                        },

                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                        .onEnded { value in
                            var updatedElement = element
                            updatedElement.scale *= value
                            onUpdate(updatedElement)
                            scale = 1.0
                        }
                )
            )
    }
}