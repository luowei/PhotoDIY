import SwiftUI
import Vision

struct AIFeaturesView: View {
    let image: UIImage
    let onImageProcessed: (UIImage) -> Void

    @State private var isProcessing = false
    @State private var processingStatus = ""
    @State private var detectedFaces: [VNFaceObservation] = []
    @State private var detectedObjects: [VNClassificationObservation] = []
    @State private var processedImage: UIImage?

    @Environment(\.dismiss) private var dismiss

    private let aiProcessor = AIImageProcessor.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 图片预览
                    ImagePreviewSection(
                        originalImage: image,
                        processedImage: processedImage
                    )

                    // AI 功能按钮
                    AIFeaturesGrid(
                        image: image,
                        isProcessing: $isProcessing,
                        processingStatus: $processingStatus,
                        onImageProcessed: { processedImg in
                            processedImage = processedImg
                        }
                    )

                    // 检测结果
                    if !detectedFaces.isEmpty || !detectedObjects.isEmpty {
                        DetectionResultsSection(
                            faces: detectedFaces,
                            objects: detectedObjects
                        )
                    }

                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("AI Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        if let processed = processedImage {
                            onImageProcessed(processed)
                        }
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .disabled(processedImage == nil)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .overlay {
                if isProcessing {
                    ProcessingOverlay(status: processingStatus)
                }
            }
            .task {
                await performInitialDetection()
            }
        }
    }

    private func performInitialDetection() async {
        isProcessing = true
        processingStatus = "Analyzing image..."

        async let faces = aiProcessor.detectFaces(in: image)
        async let objects = aiProcessor.classifyObjects(in: image)

        let (detectedFaceResults, detectedObjectResults) = await (faces, objects)

        await MainActor.run {
            self.detectedFaces = detectedFaceResults
            self.detectedObjects = Array(detectedObjectResults.prefix(5)) // 显示前5个结果
            self.isProcessing = false
            self.processingStatus = ""
        }
    }
}

struct ImagePreviewSection: View {
    let originalImage: UIImage
    let processedImage: UIImage?

    var body: some View {
        VStack(spacing: 16) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Image(uiImage: originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .cornerRadius(12)

                    Text("Original")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                if let processed = processedImage {
                    VStack(spacing: 8) {
                        Image(uiImage: processed)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .cornerRadius(12)

                        Text("Processed")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct AIFeaturesGrid: View {
    let image: UIImage
    @Binding var isProcessing: Bool
    @Binding var processingStatus: String
    let onImageProcessed: (UIImage) -> Void

    private let aiProcessor = AIImageProcessor.shared

    var body: some View {
        VStack(spacing: 16) {
            Text("AI Features")
                .font(.headline)
                .foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                AIFeatureButton(
                    title: "Face Beauty",
                    icon: "face.smiling.fill",
                    description: "Enhance facial features"
                ) {
                    await applyBeautyFilter()
                }

                AIFeatureButton(
                    title: "Portrait Blur",
                    icon: "camera.aperture",
                    description: "Blur background"
                ) {
                    await applyPortraitEffect()
                }

                AIFeatureButton(
                    title: "Auto Enhance",
                    icon: "wand.and.stars",
                    description: "Intelligent enhancement"
                ) {
                    await applyAutoEnhance()
                }

                AIFeatureButton(
                    title: "Smart Crop",
                    icon: "crop.rotate",
                    description: "AI-suggested crop"
                ) {
                    await applySuggestedCrop()
                }

                AIFeatureButton(
                    title: "Object Detection",
                    icon: "viewfinder",
                    description: "Identify objects"
                ) {
                    await performObjectDetection()
                }

                AIFeatureButton(
                    title: "Text Detection",
                    icon: "doc.text.viewfinder",
                    description: "Find text in image"
                ) {
                    await performTextDetection()
                }
            }
        }
    }

    private func applyBeautyFilter() async {
        isProcessing = true
        processingStatus = "Applying beauty filter..."

        if let result = await aiProcessor.applyBeautyFilter(to: image) {
            await MainActor.run {
                onImageProcessed(result)
                isProcessing = false
            }
        } else {
            await MainActor.run {
                isProcessing = false
            }
        }
    }

    private func applyPortraitEffect() async {
        isProcessing = true
        processingStatus = "Creating portrait effect..."

        if let result = await aiProcessor.applyPortraitEffect(to: image) {
            await MainActor.run {
                onImageProcessed(result)
                isProcessing = false
            }
        } else {
            await MainActor.run {
                isProcessing = false
            }
        }
    }

    private func applyAutoEnhance() async {
        isProcessing = true
        processingStatus = "Auto enhancing image..."

        if let result = await aiProcessor.autoEnhance(image: image) {
            await MainActor.run {
                onImageProcessed(result)
                isProcessing = false
            }
        } else {
            await MainActor.run {
                isProcessing = false
            }
        }
    }

    private func applySuggestedCrop() async {
        isProcessing = true
        processingStatus = "Analyzing composition..."

        if let cropRect = await aiProcessor.suggestCrop(for: image) {
            // 应用建议的裁剪
            if let croppedImage = cropImage(image, to: cropRect) {
                await MainActor.run {
                    onImageProcessed(croppedImage)
                    isProcessing = false
                }
                return
            }
        }

        await MainActor.run {
            isProcessing = false
        }
    }

    private func performObjectDetection() async {
        isProcessing = true
        processingStatus = "Detecting objects..."

        let _ = await aiProcessor.classifyObjects(in: image)

        await MainActor.run {
            isProcessing = false
        }
    }

    private func performTextDetection() async {
        isProcessing = true
        processingStatus = "Detecting text..."

        let _ = await aiProcessor.detectText(in: image)

        await MainActor.run {
            isProcessing = false
        }
    }

    private func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let croppedCGImage = cgImage.cropping(to: rect)
        return croppedCGImage.map { UIImage(cgImage: $0) }
    }
}

struct AIFeatureButton: View {
    let title: String
    let icon: String
    let description: String
    let action: () async -> Void

    @State private var isProcessing = false

    var body: some View {
        Button {
            Task {
                isProcessing = true
                await action()
                isProcessing = false
            }
        } label: {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(.blue)

                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(16)
            .overlay {
                if isProcessing {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.white)
                }
            }
        }
        .disabled(isProcessing)
    }
}

struct DetectionResultsSection: View {
    let faces: [VNFaceObservation]
    let objects: [VNClassificationObservation]

    var body: some View {
        VStack(spacing: 16) {
            Text("Detection Results")
                .font(.headline)
                .foregroundColor(.white)

            if !faces.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Faces Detected: \(faces.count)")
                        .font(.subheadline)
                        .foregroundColor(.green)

                    ForEach(Array(faces.enumerated()), id: \.offset) { index, face in
                        HStack {
                            Text("Face \(index + 1)")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Confidence: \(Int(face.confidence * 100))%")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            }

            if !objects.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Objects Detected:")
                        .font(.subheadline)
                        .foregroundColor(.green)

                    ForEach(Array(objects.enumerated()), id: \.offset) { index, object in
                        HStack {
                            Text(object.identifier.capitalized)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(Int(object.confidence * 100))%")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            }
        }
    }
}

struct ProcessingOverlay: View {
    let status: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text(status)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(32)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(16)
        }
    }
}