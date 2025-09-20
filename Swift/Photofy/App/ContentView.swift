import SwiftUI
import PhotosUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ContentViewModel()
    @State private var showingImagePicker = false
    @State private var showingSettings = false
    @State private var showingAIFeatures = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 导航栏
                    NavigationBarView(
                        onSettingsAction: { showingSettings = true },
                        onSelectPhotoAction: { showingImagePicker = true },
                        onAIFeaturesAction: { showingAIFeatures = true }
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
                        EmptyStateView {
                            showingImagePicker = true
                        }
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
    }
}

// MARK: - 空状态视图
struct EmptyStateView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text("Welcome to Photofy")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("Select a photo to start editing")
                    .font(.body)
                    .foregroundColor(.gray)
            }

            Button(action: action) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Select Photo")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 导航栏视图
struct NavigationBarView: View {
    let onSettingsAction: () -> Void
    let onSelectPhotoAction: () -> Void
    let onAIFeaturesAction: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onSettingsAction) {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Button(action: onAIFeaturesAction) {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()

            Text("Photofy")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            Button(action: onSelectPhotoAction) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.8))
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}