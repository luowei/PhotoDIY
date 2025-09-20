import SwiftUI

// MARK: - 全新的Crop视图组件
struct CropView: View {
    let image: UIImage
    let onCropComplete: (UIImage) -> Void
    let onCancel: () -> Void
    @ObservedObject var viewModel: ContentViewModel

    @State private var cropFrame = CGRect(x: 50, y: 100, width: 250, height: 250)
    @State private var isDragging = false
    @State private var dragStartFrame = CGRect.zero
    @State private var dragStartLocation = CGPoint.zero
    @State private var isResizing = false
    @State private var activeCorner: CornerType?
    @State private var isProcessing = false
    @State private var containerSize = CGSize.zero

    private let minCropSize: CGFloat = 80

    enum CornerType {
        case topLeft, topRight, bottomLeft, bottomRight
        case topEdge, bottomEdge, leftEdge, rightEdge
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景遮罩
                Color.black.ignoresSafeArea()

                // 图片显示 - 直接显示原图，让SwiftUI自动缩放
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 裁剪遮罩层
                CropMaskView(cropFrame: cropFrame, containerSize: geometry.size)

                // 裁剪框和控制点
                CropBoxView(
                    cropFrame: $cropFrame,
                    containerSize: geometry.size,
                    minSize: minCropSize,
                    isDragging: $isDragging,
                    isResizing: $isResizing,
                    activeCorner: $activeCorner
                )
            }
            .onAppear {
                containerSize = geometry.size
                resetCropFrame(in: geometry.size)
            }
            .onChange(of: geometry.size) { newSize in
                containerSize = newSize
                // 当屏幕旋转或尺寸变化时，调整裁剪框
                adjustCropFrameForNewSize(newSize)
            }
            .onChange(of: viewModel.cropResetTrigger) { _ in
                resetCropFrame(in: geometry.size)
            }
            .onChange(of: viewModel.cropApplyTrigger) { _ in
                Task {
                    await performCrop(in: geometry.size)
                }
            }
            .onChange(of: viewModel.selectedCropRatio) { ratio in
                applyAspectRatio(ratio, in: geometry.size)
            }
        }
    }

    // MARK: - 辅助方法

    private func resetCropFrame(in containerSize: CGSize) {
        let margin: CGFloat = 40
        let size = min(containerSize.width, containerSize.height) - margin * 2

        cropFrame = CGRect(
            x: (containerSize.width - size) / 2,
            y: (containerSize.height - size) / 2,
            width: size,
            height: size
        )
    }

    private func adjustCropFrameForNewSize(_ newSize: CGSize) {
        // 确保裁剪框仍在新尺寸的边界内
        let maxX = newSize.width - cropFrame.width
        let maxY = newSize.height - cropFrame.height

        cropFrame = CGRect(
            x: min(max(0, cropFrame.minX), maxX),
            y: min(max(0, cropFrame.minY), maxY),
            width: min(cropFrame.width, newSize.width),
            height: min(cropFrame.height, newSize.height)
        )
    }

    private func applyAspectRatio(_ ratio: CGFloat?, in containerSize: CGSize) {
        guard let ratio = ratio else {
            // 自由比例，保持当前尺寸
            return
        }

        let centerX = cropFrame.midX
        let centerY = cropFrame.midY
        let maxWidth = containerSize.width - 40
        let maxHeight = containerSize.height - 80

        var newWidth: CGFloat
        var newHeight: CGFloat

        if ratio > 1 {
            // 横向比例
            newHeight = min(cropFrame.height, maxHeight)
            newWidth = newHeight * ratio

            if newWidth > maxWidth {
                newWidth = maxWidth
                newHeight = newWidth / ratio
            }
        } else {
            // 纵向比例
            newWidth = min(cropFrame.width, maxWidth)
            newHeight = newWidth / ratio

            if newHeight > maxHeight {
                newHeight = maxHeight
                newWidth = newHeight * ratio
            }
        }

        let newX = centerX - newWidth / 2
        let newY = centerY - newHeight / 2

        // 确保在边界内
        let finalX = max(20, min(newX, containerSize.width - newWidth - 20))
        let finalY = max(40, min(newY, containerSize.height - newHeight - 40))

        withAnimation(.easeInOut(duration: 0.3)) {
            cropFrame = CGRect(x: finalX, y: finalY, width: newWidth, height: newHeight)
        }
    }

    private func performCrop(in containerSize: CGSize) async {
        isProcessing = true

        print("🎯 开始裁剪处理...")
        print("📏 容器尺寸: \(containerSize)")
        print("🖼️ 图片尺寸: \(image.size)")
        print("✂️ 裁剪框: \(cropFrame)")

        // 计算实际图片在屏幕上的显示区域
        let imageDisplayRect = calculateImageDisplayRect(in: containerSize)
        print("📱 图片显示区域: \(imageDisplayRect)")

        // 将屏幕上的裁剪框坐标转换为图片坐标
        let scaleX = image.size.width / imageDisplayRect.width
        let scaleY = image.size.height / imageDisplayRect.height
        print("🔄 缩放比例 X: \(scaleX), Y: \(scaleY)")

        // 计算裁剪框相对于图片显示区域的位置
        let relativeX = cropFrame.minX - imageDisplayRect.minX
        let relativeY = cropFrame.minY - imageDisplayRect.minY
        print("📍 相对位置 X: \(relativeX), Y: \(relativeY)")

        // 转换为图片坐标系中的裁剪区域
        let cropInImageCoords = CGRect(
            x: max(0, relativeX * scaleX),
            y: max(0, relativeY * scaleY),
            width: min(image.size.width, cropFrame.width * scaleX),
            height: min(image.size.height, cropFrame.height * scaleY)
        )
        print("🎯 图片坐标系裁剪区域: \(cropInImageCoords)")

        // 确保裁剪区域不超出图片边界
        let finalCropRect = cropInImageCoords.intersection(
            CGRect(origin: .zero, size: image.size)
        )
        print("✅ 最终裁剪区域: \(finalCropRect)")

        // 检查裁剪区域是否有效
        guard !finalCropRect.isEmpty && finalCropRect.width > 1 && finalCropRect.height > 1 else {
            print("❌ 裁剪区域无效或太小")
            await MainActor.run {
                isProcessing = false
            }
            return
        }

        do {
            let croppedImage = await ImageCropManager.shared.cropImage(image, to: finalCropRect)

            await MainActor.run {
                if let croppedImage = croppedImage {
                    print("✅ 裁剪成功，调用回调")
                    onCropComplete(croppedImage)
                    // 裁剪成功后自动关闭（通过取消回调）
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onCancel()
                    }
                } else {
                    print("❌ 裁剪失败，返回nil")
                }
                isProcessing = false
            }
        } catch {
            print("❌ 裁剪过程中出错: \(error)")
            await MainActor.run {
                isProcessing = false
            }
        }
    }

    private func calculateImageDisplayRect(in containerSize: CGSize) -> CGRect {
        let imageAspectRatio = image.size.width / image.size.height
        let containerAspectRatio = containerSize.width / containerSize.height

        if imageAspectRatio > containerAspectRatio {
            // 图片更宽，以容器宽度为准
            let displayHeight = containerSize.width / imageAspectRatio
            return CGRect(
                x: 0,
                y: (containerSize.height - displayHeight) / 2,
                width: containerSize.width,
                height: displayHeight
            )
        } else {
            // 图片更高，以容器高度为准
            let displayWidth = containerSize.height * imageAspectRatio
            return CGRect(
                x: (containerSize.width - displayWidth) / 2,
                y: 0,
                width: displayWidth,
                height: containerSize.height
            )
        }
    }
}

// MARK: - 裁剪遮罩视图
struct CropMaskView: View {
    let cropFrame: CGRect
    let containerSize: CGSize

    var body: some View {
        ZStack {
            // 全屏半透明遮罩
            Rectangle()
                .fill(Color.black.opacity(0.5))
                .frame(width: containerSize.width, height: containerSize.height)

            // 裁剪区域透明窗口
            Rectangle()
                .frame(width: cropFrame.width, height: cropFrame.height)
                .position(x: cropFrame.midX, y: cropFrame.midY)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
    }
}

// MARK: - 裁剪框视图
struct CropBoxView: View {
    @Binding var cropFrame: CGRect
    let containerSize: CGSize
    let minSize: CGFloat
    @Binding var isDragging: Bool
    @Binding var isResizing: Bool
    @Binding var activeCorner: CropView.CornerType?

    @State private var dragStart = CGPoint.zero
    @State private var frameStart = CGRect.zero

    var body: some View {
        ZStack {
            // 裁剪框边框
            Rectangle()
                .stroke(Color.yellow, lineWidth: 2)
                .frame(width: cropFrame.width, height: cropFrame.height)
                .position(x: cropFrame.midX, y: cropFrame.midY)

            // 网格线
            CropGridLinesView()
                .frame(width: cropFrame.width, height: cropFrame.height)
                .position(x: cropFrame.midX, y: cropFrame.midY)

            // 角落控制点
            cornerHandle(.topLeft)
            cornerHandle(.topRight)
            cornerHandle(.bottomLeft)
            cornerHandle(.bottomRight)

            // 边缘控制点
            edgeHandle(.topEdge)
            edgeHandle(.bottomEdge)
            edgeHandle(.leftEdge)
            edgeHandle(.rightEdge)

            // 中心拖拽区域
            Rectangle()
                .fill(Color.clear)
                .frame(width: max(0, cropFrame.width - 40), height: max(0, cropFrame.height - 40))
                .position(x: cropFrame.midX, y: cropFrame.midY)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !isDragging {
                                isDragging = true
                                dragStart = value.startLocation
                                frameStart = cropFrame
                            }

                            let translation = CGPoint(
                                x: value.location.x - dragStart.x,
                                y: value.location.y - dragStart.y
                            )

                            moveCropFrame(by: translation)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
        }
    }

    @ViewBuilder
    private func cornerHandle(_ corner: CropView.CornerType) -> some View {
        let position = getCornerPosition(corner)

        Circle()
            .fill(Color.yellow)
            .frame(width: 20, height: 20)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isResizing {
                            isResizing = true
                            activeCorner = corner
                            dragStart = value.startLocation
                            frameStart = cropFrame
                        }

                        resizeCropFrame(corner: corner, dragValue: value)
                    }
                    .onEnded { _ in
                        isResizing = false
                        activeCorner = nil
                    }
            )
    }

    @ViewBuilder
    private func edgeHandle(_ edge: CropView.CornerType) -> some View {
        let (position, size) = getEdgePositionAndSize(edge)

        Rectangle()
            .fill(Color.clear)
            .frame(width: size.width, height: size.height)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isResizing {
                            isResizing = true
                            activeCorner = edge
                            dragStart = value.startLocation
                            frameStart = cropFrame
                        }

                        resizeCropFrame(corner: edge, dragValue: value)
                    }
                    .onEnded { _ in
                        isResizing = false
                        activeCorner = nil
                    }
            )
    }

    private func getCornerPosition(_ corner: CropView.CornerType) -> CGPoint {
        switch corner {
        case .topLeft:
            return CGPoint(x: cropFrame.minX, y: cropFrame.minY)
        case .topRight:
            return CGPoint(x: cropFrame.maxX, y: cropFrame.minY)
        case .bottomLeft:
            return CGPoint(x: cropFrame.minX, y: cropFrame.maxY)
        case .bottomRight:
            return CGPoint(x: cropFrame.maxX, y: cropFrame.maxY)
        default:
            return CGPoint.zero
        }
    }

    private func getEdgePositionAndSize(_ edge: CropView.CornerType) -> (CGPoint, CGSize) {
        let handleThickness: CGFloat = 20

        switch edge {
        case .topEdge:
            return (
                CGPoint(x: cropFrame.midX, y: cropFrame.minY),
                CGSize(width: cropFrame.width - 40, height: handleThickness)
            )
        case .bottomEdge:
            return (
                CGPoint(x: cropFrame.midX, y: cropFrame.maxY),
                CGSize(width: cropFrame.width - 40, height: handleThickness)
            )
        case .leftEdge:
            return (
                CGPoint(x: cropFrame.minX, y: cropFrame.midY),
                CGSize(width: handleThickness, height: cropFrame.height - 40)
            )
        case .rightEdge:
            return (
                CGPoint(x: cropFrame.maxX, y: cropFrame.midY),
                CGSize(width: handleThickness, height: cropFrame.height - 40)
            )
        default:
            return (CGPoint.zero, CGSize.zero)
        }
    }

    private func moveCropFrame(by translation: CGPoint) {
        let newFrame = CGRect(
            x: frameStart.minX + translation.x,
            y: frameStart.minY + translation.y,
            width: frameStart.width,
            height: frameStart.height
        )

        // 边界检查
        let maxX = containerSize.width - newFrame.width
        let maxY = containerSize.height - newFrame.height

        cropFrame = CGRect(
            x: max(0, min(newFrame.minX, maxX)),
            y: max(0, min(newFrame.minY, maxY)),
            width: newFrame.width,
            height: newFrame.height
        )
    }

    private func resizeCropFrame(corner: CropView.CornerType, dragValue: DragGesture.Value) {
        let translation = CGPoint(
            x: dragValue.location.x - dragStart.x,
            y: dragValue.location.y - dragStart.y
        )

        var newFrame = frameStart

        switch corner {
        case .topLeft:
            newFrame.origin.x = frameStart.minX + translation.x
            newFrame.origin.y = frameStart.minY + translation.y
            newFrame.size.width = frameStart.width - translation.x
            newFrame.size.height = frameStart.height - translation.y

        case .topRight:
            newFrame.origin.y = frameStart.minY + translation.y
            newFrame.size.width = frameStart.width + translation.x
            newFrame.size.height = frameStart.height - translation.y

        case .bottomLeft:
            newFrame.origin.x = frameStart.minX + translation.x
            newFrame.size.width = frameStart.width - translation.x
            newFrame.size.height = frameStart.height + translation.y

        case .bottomRight:
            newFrame.size.width = frameStart.width + translation.x
            newFrame.size.height = frameStart.height + translation.y

        case .topEdge:
            newFrame.origin.y = frameStart.minY + translation.y
            newFrame.size.height = frameStart.height - translation.y

        case .bottomEdge:
            newFrame.size.height = frameStart.height + translation.y

        case .leftEdge:
            newFrame.origin.x = frameStart.minX + translation.x
            newFrame.size.width = frameStart.width - translation.x

        case .rightEdge:
            newFrame.size.width = frameStart.width + translation.x
        }

        // 尺寸限制
        if newFrame.width < minSize {
            if corner == .topLeft || corner == .bottomLeft || corner == .leftEdge {
                newFrame.origin.x = frameStart.maxX - minSize
            }
            newFrame.size.width = minSize
        }

        if newFrame.height < minSize {
            if corner == .topLeft || corner == .topRight || corner == .topEdge {
                newFrame.origin.y = frameStart.maxY - minSize
            }
            newFrame.size.height = minSize
        }

        // 边界限制
        newFrame.origin.x = max(0, min(newFrame.origin.x, containerSize.width - newFrame.width))
        newFrame.origin.y = max(0, min(newFrame.origin.y, containerSize.height - newFrame.height))
        newFrame.size.width = min(newFrame.width, containerSize.width - newFrame.origin.x)
        newFrame.size.height = min(newFrame.height, containerSize.height - newFrame.origin.y)

        cropFrame = newFrame
    }
}

// MARK: - 网格线视图
struct CropGridLinesView: View {
    var body: some View {
        ZStack {
            // 水平线
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color.yellow.opacity(0.6))
                    .frame(height: 1)
                Spacer()
                Rectangle()
                    .fill(Color.yellow.opacity(0.6))
                    .frame(height: 1)
                Spacer()
            }

            // 垂直线
            HStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color.yellow.opacity(0.6))
                    .frame(width: 1)
                Spacer()
                Rectangle()
                    .fill(Color.yellow.opacity(0.6))
                    .frame(width: 1)
                Spacer()
            }
        }
    }
}

