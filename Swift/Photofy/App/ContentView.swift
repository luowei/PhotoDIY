import SwiftUI
import PhotosUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ContentViewModel()
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingSettings = false
    @State private var showingAIFeatures = false
    @State private var showingClearConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 导航栏
                    NavigationBarView(
                        onSettingsAction: { showingSettings = true },
                        onAIFeaturesAction: { showingAIFeatures = true },
                        onClearCanvasAction: {
                            if viewModel.currentImage != nil {
                                showingClearConfirmation = true
                            }
                        },
                        hasImage: viewModel.currentImage != nil
                    )

                    // 主编辑区域
                    if let image = viewModel.currentImage {
                        ZStack {
                            // 可缩放的图片视图
                            ZoomableImageView(
                                image: viewModel.processedImage ?? image,
                                scale: $viewModel.zoomScale,
                                offset: $viewModel.panOffset
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                            // 编辑覆盖层
                            EditingOverlayView(
                                editingMode: viewModel.editingMode,
                                image: image,
                                onEditingComplete: { editedImage in
                                    viewModel.updateProcessedImage(editedImage)
                                },
                                onEditingCancel: {
                                    viewModel.exitEditingMode()
                                },
                                viewModel: viewModel
                            )
                        }
                    } else {
                        EmptyStateView(
                            onSelectPhoto: { showingImagePicker = true },
                            onTakePhoto: { showingCamera = true }
                        )
                    }

                    // 编辑工具面板
                    if viewModel.currentImage != nil {
                        EditingToolsPanel(viewModel: viewModel)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .photosPicker(
            isPresented: $showingImagePicker,
            selection: $viewModel.selectedPhoto,
            matching: .images
        )
        .sheet(isPresented: $showingCamera) {
            CameraPickerView { image in
                viewModel.updateImage(image)
                showingCamera = false
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAIFeatures) {
            if let image = viewModel.currentImage {
                AIFeaturesView(image: image) { processedImage in
                    viewModel.updateProcessedImage(processedImage)
                }
            }
        }
        .onChange(of: viewModel.selectedPhoto) { _ in
            viewModel.loadSelectedPhoto()
        }
        .alert("清除画布", isPresented: $showingClearConfirmation) {
            Button("取消", role: .cancel) { }
            Button("清除", role: .destructive) {
                viewModel.clearCanvas()
            }
        } message: {
            Text("确定要清除当前画布吗？这将删除当前正在编辑的图片。")
        }
    }
}

// MARK: - 空状态视图
struct EmptyStateView: View {
    let onSelectPhoto: () -> Void
    let onTakePhoto: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text("Welcome to Photofy")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("选择照片或拍照开始编辑")
                    .font(.body)
                    .foregroundColor(.gray)
            }

            VStack(spacing: 16) {
                // 选择照片按钮
                Button(action: onSelectPhoto) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("选择照片")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                }

                // 拍照按钮
                Button(action: onTakePhoto) {
                    HStack {
                        Image(systemName: "camera")
                        Text("拍照")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 导航栏视图
struct NavigationBarView: View {
    let onSettingsAction: () -> Void
    let onAIFeaturesAction: () -> Void
    let onClearCanvasAction: () -> Void
    let hasImage: Bool

    var body: some View {
        HStack {
            // 左上角：AI智能处理
            Button(action: onAIFeaturesAction) {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()

            // 中间：App标题
            Text("Photofy")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            // 右上角：清除按钮（只在有图片时显示）和设置按钮
            HStack(spacing: 16) {
                if hasImage {
                    Button(action: onClearCanvasAction) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }

                Button(action: onSettingsAction) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.8))
    }
}

// MARK: - Camera Picker View
struct CameraPickerView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false

        // 启用所有相机功能
        picker.cameraDevice = .rear
        picker.cameraFlashMode = .auto
        picker.showsCameraControls = true

        // 支持所有媒体类型
        picker.mediaTypes = ["public.image"]

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // 不需要更新
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}