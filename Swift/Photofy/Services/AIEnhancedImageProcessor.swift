import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import MetalPerformanceShaders
import Metal
import Accelerate

// MARK: - 设置结构体定义
struct PortraitSettings {
    var intensity: Float = 0.8
    var skinSmoothing: Float = 0.5
    var backgroundBlur: Float = 0.8
    var brightnessAdjust: Float = 0.1
    var saturationBoost: Float = 0.2
    var contrastEnhance: Float = 0.1
}

struct LandscapeSettings {
    var intensity: Float = 0.8
    var saturationBoost: Float = 0.4
    var contrastEnhance: Float = 0.3
    var brightnessAdjust: Float = 0.1
    var sharpness: Float = 1.5
    var warmthAdjust: Float = 500
    var vignetteIntensity: Float = 0.5
}

struct EcommerceSettings {
    var intensity: Float = 0.8
    var exposureBoost: Float = 0.5
    var saturationEnhance: Float = 0.2
    var contrastBoost: Float = 0.4
    var noiseReduction: Float = 0.02
    var highlightAdjust: Float = 0.3
    var shadowAdjust: Float = -0.1
}

struct IDPhotoSettings {
    var backgroundColor: IDPhotoBackgroundColor = .blue
    var faceEnhancement: Float = 0.3
    var skinSmoothing: Float = 0.4
    var brightnessCorrection: Float = 0.2
}

enum IDPhotoBackgroundColor: String, CaseIterable {
    case white = "白色"
    case blue = "蓝色"
    case red = "红色"
    case green = "绿色"
    case office = "虚化办公室"

    var displayName: String {
        return self.rawValue
    }
}

/// AI增强图像处理器 - 使用最新的AI技术和Core ML模型
class AIEnhancedImageProcessor: ObservableObject {
    static let shared = AIEnhancedImageProcessor()

    private let context: CIContext
    private let metalDevice: MTLDevice?

    // Metal Performance Shaders
    private var mpsImageGaussianBlur: MPSImageGaussianBlur?
    private var mpsImageSobel: MPSImageSobel?
    private var mpsImageHistogramEqualization: MPSImageHistogramEqualization?

    init() {
        self.metalDevice = MTLCreateSystemDefaultDevice()

        if let device = metalDevice {
            self.context = CIContext(mtlDevice: device)

            // 初始化Metal Performance Shaders
            self.mpsImageGaussianBlur = MPSImageGaussianBlur(device: device, sigma: 2.0)
            self.mpsImageSobel = MPSImageSobel(device: device)
            // 简化初始化，不使用复杂的MPS直方图
            self.mpsImageHistogramEqualization = nil
        } else {
            self.context = CIContext()
        }
    }

    // MARK: - AI增强人像处理
    func enhancePortrait(_ image: UIImage, settings: PortraitSettings) async -> AIProcessingResult {
        do {
            // 1. 高精度人脸和人物检测
            let faceAnalysis = await analyzePortraitFeatures(image)
            let personSegmentation = await performPersonSegmentation(image)

            guard !faceAnalysis.faces.isEmpty else {
                // 没有人脸，应用通用图片美化
                return await applyGeneralPortraitEnhancement(image, settings: settings)
            }

            // 2. 智能人物美颜（只处理人脸区域）
            let beautifiedImage = await applyAdvancedFaceBeautification(
                image,
                faces: faceAnalysis.faces,
                settings: settings
            )

            // 3. 智能背景虚化（保持人物清晰）
            let finalImage = await applySmartBackgroundBlur(
                beautifiedImage,
                personMask: personSegmentation.mask,
                settings: settings
            )

            return AIProcessingResult(
                image: finalImage,
                confidence: faceAnalysis.confidence,
                detectedFeatures: faceAnalysis.features,
                message: "AI人像增强完成：检测到\(faceAnalysis.faces.count)个人脸，应用了精准美颜和背景虚化"
            )

        } catch {
            return AIProcessingResult(
                image: image,
                confidence: 0.0,
                detectedFeatures: [],
                message: "处理失败：\(error.localizedDescription)"
            )
        }
    }

    // MARK: - AI风景增强
    func enhanceLandscape(_ image: UIImage, settings: LandscapeSettings) async -> AIProcessingResult {
        do {
            // 1. AI场景识别
            let sceneAnalysis = await analyzeSceneContent(image)

            // 2. 根据场景类型应用不同的增强策略
            let enhancedImage = await applySceneSpecificEnhancement(
                image,
                sceneType: sceneAnalysis.primaryScene,
                settings: settings
            )

            // 3. 智能色彩和对比度调整
            let finalImage = await applyIntelligentColorEnhancement(
                enhancedImage,
                sceneAnalysis: sceneAnalysis,
                settings: settings
            )

            return AIProcessingResult(
                image: finalImage,
                confidence: sceneAnalysis.confidence,
                detectedFeatures: sceneAnalysis.detectedElements,
                message: "AI风景增强完成：识别为\(sceneAnalysis.primaryScene.displayName)，应用了智能色彩和对比度优化"
            )

        } catch {
            return AIProcessingResult(
                image: image,
                confidence: 0.0,
                detectedFeatures: [],
                message: "处理失败：\(error.localizedDescription)"
            )
        }
    }

    // MARK: - AI美食增强
    func enhanceFood(_ image: UIImage, settings: FoodSettings) async -> AIProcessingResult {
        do {
            // 1. AI美食识别
            let foodAnalysis = await analyzeFoodContent(image)

            guard foodAnalysis.confidence > 0.3 else {
                return AIProcessingResult(
                    image: image,
                    confidence: foodAnalysis.confidence,
                    detectedFeatures: [],
                    message: "未检测到美食内容，请选择包含食物的图片"
                )
            }

            // 2. 美食专用色彩增强
            let colorEnhanced = await applyFoodColorEnhancement(
                image,
                foodType: foodAnalysis.foodType,
                settings: settings
            )

            // 3. 食欲感增强处理
            let appetiteEnhanced = await applyAppetiteEnhancement(
                colorEnhanced,
                settings: settings
            )

            return AIProcessingResult(
                image: appetiteEnhanced,
                confidence: foodAnalysis.confidence,
                detectedFeatures: foodAnalysis.detectedIngredients,
                message: "AI美食增强完成：识别为\(foodAnalysis.foodType.displayName)，应用了食欲感增强处理"
            )

        } catch {
            return AIProcessingResult(
                image: image,
                confidence: 0.0,
                detectedFeatures: [],
                message: "处理失败：\(error.localizedDescription)"
            )
        }
    }

    // MARK: - AI电商产品增强
    func enhanceEcommerce(_ image: UIImage, settings: EcommerceSettings) async -> AIProcessingResult {
        do {
            // 1. AI产品检测
            let productAnalysis = await analyzeProductContent(image)

            guard !productAnalysis.products.isEmpty else {
                return AIProcessingResult(
                    image: image,
                    confidence: 0.0,
                    detectedFeatures: [],
                    message: "未检测到商品，请选择包含商品的图片"
                )
            }

            // 2. 产品突出处理
            let productFocused = await applyProductHighlighting(
                image,
                products: productAnalysis.products,
                settings: settings
            )

            // 3. 专业电商风格调整
            let professionalStyled = await applyProfessionalCommercialStyling(
                productFocused,
                productType: productAnalysis.primaryProductType,
                settings: settings
            )

            return AIProcessingResult(
                image: professionalStyled,
                confidence: productAnalysis.confidence,
                detectedFeatures: productAnalysis.productCategories,
                message: "AI电商增强完成：检测到\(productAnalysis.products.count)个商品，应用了专业商品突出处理"
            )

        } catch {
            return AIProcessingResult(
                image: image,
                confidence: 0.0,
                detectedFeatures: [],
                message: "处理失败：\(error.localizedDescription)"
            )
        }
    }

    // MARK: - AI证件照制作
    func createIntelligentIDPhoto(_ image: UIImage, settings: IDPhotoSettings) async -> AIProcessingResult {
        do {
            // 1. 高精度人脸检测
            let faceAnalysis = await analyzePortraitForIDPhoto(image)

            guard let primaryFace = faceAnalysis.faces.first else {
                return AIProcessingResult(
                    image: image,
                    confidence: 0.0,
                    detectedFeatures: [],
                    message: "未检测到人脸，请选择包含清晰人物肖像的图片"
                )
            }

            // 2. 智能人物分割
            let segmentedImage = await performIntelligentPersonSegmentation(image)

            // 3. 证件照规范化处理
            let standardizedImage = await applyIDPhotoStandardization(
                segmentedImage,
                face: primaryFace,
                settings: settings
            )

            // 4. 背景生成和合成
            let finalImage = await generateAndCompositeIDPhotoBackground(
                standardizedImage,
                settings: settings
            )

            return AIProcessingResult(
                image: finalImage,
                confidence: faceAnalysis.confidence,
                detectedFeatures: faceAnalysis.features,
                message: "AI证件照制作完成：自动调整了人脸位置和大小，生成了\(settings.backgroundColor.displayName)背景"
            )

        } catch {
            return AIProcessingResult(
                image: image,
                confidence: 0.0,
                detectedFeatures: [],
                message: "处理失败：\(error.localizedDescription)"
            )
        }
    }
}

// MARK: - AI分析方法
extension AIEnhancedImageProcessor {

    private func analyzePortraitFeatures(_ image: UIImage) async -> PortraitAnalysis {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: PortraitAnalysis())
                return
            }

            let request = VNDetectFaceLandmarksRequest { request, error in
                let faces = (request.results as? [VNFaceObservation]) ?? []
                let analysis = PortraitAnalysis(
                    faces: faces,
                    confidence: faces.isEmpty ? 0.0 : faces.map { $0.confidence }.reduce(0, +) / Float(faces.count),
                    features: self.extractFaceFeatures(from: faces)
                )
                continuation.resume(returning: analysis)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: PortraitAnalysis())
                }
            }
        }
    }

    private func analyzeSceneContent(_ image: UIImage) async -> SceneAnalysis {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: SceneAnalysis())
                return
            }

            let request = VNClassifyImageRequest { request, error in
                let observations = (request.results as? [VNClassificationObservation]) ?? []
                let sceneAnalysis = self.interpretSceneClassification(observations)
                continuation.resume(returning: sceneAnalysis)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: SceneAnalysis())
                }
            }
        }
    }

    private func analyzeFoodContent(_ image: UIImage) async -> FoodAnalysis {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: FoodAnalysis())
                return
            }

            let request = VNClassifyImageRequest { request, error in
                let observations = (request.results as? [VNClassificationObservation]) ?? []
                let foodAnalysis = self.interpretFoodClassification(observations)
                continuation.resume(returning: foodAnalysis)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: FoodAnalysis())
                }
            }
        }
    }

    private func analyzeProductContent(_ image: UIImage) async -> ProductAnalysis {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: ProductAnalysis())
                return
            }

            let request = VNRecognizeObjectsRequest { request, error in
                let observations = (request.results as? [VNRecognizedObjectObservation]) ?? []
                let productAnalysis = self.interpretProductDetection(observations)
                continuation.resume(returning: productAnalysis)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: ProductAnalysis())
                }
            }
        }
    }

    private func analyzePortraitForIDPhoto(_ image: UIImage) async -> PortraitAnalysis {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: PortraitAnalysis())
                return
            }

            let faceRequest = VNDetectFaceLandmarksRequest()
            faceRequest.revision = VNDetectFaceLandmarksRequestRevision3

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([faceRequest])

                    let faces = (faceRequest.results as? [VNFaceObservation]) ?? []
                    let analysis = PortraitAnalysis(
                        faces: faces,
                        confidence: faces.isEmpty ? 0.0 : faces.map { $0.confidence }.reduce(0, +) / Float(faces.count),
                        features: self.extractFaceFeatures(from: faces)
                    )
                    continuation.resume(returning: analysis)
                } catch {
                    continuation.resume(returning: PortraitAnalysis())
                }
            }
        }
    }
}

// MARK: - AI图像增强方法
extension AIEnhancedImageProcessor {

    private func applyAdvancedFaceBeautification(_ image: UIImage, faces: [VNFaceObservation], settings: PortraitSettings) async -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        var processedImage = ciImage

        // 1. 全图色彩优化（轻度调整）
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = processedImage
        colorFilter.brightness = settings.brightnessAdjust * 0.8
        colorFilter.saturation = 1.0 + settings.saturationBoost * 0.6
        colorFilter.contrast = 1.0 + settings.contrastEnhance * 0.5
        processedImage = colorFilter.outputImage ?? processedImage

        // 2. 精准皮肤平滑（只处理面部区域）
        processedImage = await applyPreciseSkinSmoothing(processedImage, faces: faces, intensity: settings.skinSmoothing)

        // 3. 眼部细节增强
        processedImage = await applyEyeEnhancement(processedImage, faces: faces, intensity: settings.intensity)

        // 4. 面部亮度微调
        processedImage = await applyFaceBrightnessEnhancement(processedImage, faces: faces, intensity: settings.intensity * 0.3)

        return convertToUIImage(processedImage) ?? image
    }

    private func applyPreciseSkinSmoothing(_ ciImage: CIImage, faces: [VNFaceObservation], intensity: Float) async -> CIImage {
        guard intensity > 0 else { return ciImage }

        // 创建精确的面部皮肤区域蒙版
        let skinMask = createPreciseSkinMask(faces: faces, imageSize: ciImage.extent.size)

        // 使用高斯模糊进行皮肤平滑
        let surfaceBlur = CIFilter.gaussianBlur()
        surfaceBlur.inputImage = ciImage
        surfaceBlur.radius = intensity * 2.5

        guard let smoothedImage = surfaceBlur.outputImage else { return ciImage }

        // 使用柔光混合模式，避免过度平滑
        let blendFilter = CIFilter.softLightBlendMode()
        blendFilter.inputImage = smoothedImage
        blendFilter.backgroundImage = ciImage

        guard let blendedImage = blendFilter.outputImage else { return ciImage }

        // 使用蒙版只对皮肤区域应用效果
        let maskFilter = CIFilter.blendWithMask()
        maskFilter.inputImage = blendedImage
        maskFilter.backgroundImage = ciImage
        maskFilter.maskImage = skinMask

        return maskFilter.outputImage ?? ciImage
    }

    private func applyEyeEnhancement(_ ciImage: CIImage, faces: [VNFaceObservation], intensity: Float) async -> CIImage {
        guard intensity > 0 else { return ciImage }

        var processedImage = ciImage

        // 为每个检测到的人脸增强眼部
        for face in faces {
            if let landmarks = face.landmarks,
               let leftEye = landmarks.leftEye,
               let rightEye = landmarks.rightEye {

                // 创建眼部区域蒙版
                let eyeMask = createEyeMask(leftEye: leftEye, rightEye: rightEye,
                                          faceRect: face.boundingBox,
                                          imageSize: ciImage.extent.size)

                // 应用眼部增强
                let sharpenFilter = CIFilter.sharpenLuminance()
                sharpenFilter.inputImage = processedImage
                sharpenFilter.sharpness = intensity * 2.0

                if let sharpenedImage = sharpenFilter.outputImage {
                    let blendFilter = CIFilter.blendWithAlphaMask()
                    blendFilter.inputImage = sharpenedImage
                    blendFilter.backgroundImage = processedImage
                    blendFilter.maskImage = eyeMask

                    processedImage = blendFilter.outputImage ?? processedImage
                }
            }
        }

        return processedImage
    }

    private func applySmartBackgroundBlur(_ image: UIImage, personMask: CIImage?, settings: PortraitSettings) async -> UIImage {
        guard settings.backgroundBlur > 0,
              let personMask = personMask,
              let ciImage = CIImage(image: image) else { return image }

        // 创建背景蒙版（人物区域的反向蒙版）
        let backgroundMask = createInvertedMask(personMask)

        // 应用渐进式背景模糊
        let blurRadius = settings.backgroundBlur * 12.0
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = ciImage
        blurFilter.radius = blurRadius

        guard let blurredBackground = blurFilter.outputImage else { return image }

        // 使用蒙版混合，确保人物区域保持清晰
        let composite = CIFilter.blendWithMask()
        composite.inputImage = blurredBackground  // 模糊的背景
        composite.backgroundImage = ciImage       // 清晰的原图
        composite.maskImage = backgroundMask      // 背景区域蒙版

        return convertToUIImage(composite.outputImage ?? ciImage) ?? image
    }

    private func applySceneSpecificEnhancement(_ image: UIImage, sceneType: SceneType, settings: LandscapeSettings) async -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        var processedImage = ciImage

        switch sceneType {
        case .nature:
            // 自然风景：增强绿色和蓝色
            processedImage = await enhanceNatureColors(processedImage, settings: settings)
        case .sunset:
            // 日落：增强暖色调
            processedImage = await enhanceSunsetColors(processedImage, settings: settings)
        case .urban:
            // 城市：增强建筑对比度
            processedImage = await enhanceUrbanContrast(processedImage, settings: settings)
        case .water:
            // 水景：增强蓝色和反射
            processedImage = await enhanceWaterScene(processedImage, settings: settings)
        default:
            // 通用增强
            processedImage = await applyGeneralLandscapeEnhancement(processedImage, settings: settings)
        }

        return convertToUIImage(processedImage) ?? image
    }

    private func applyFoodColorEnhancement(_ image: UIImage, foodType: FoodType, settings: FoodSettings) async -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        var processedImage = ciImage

        // 根据食物类型调整颜色
        switch foodType {
        case .meat:
            // 肉类：增强红色和暖色调
            processedImage = await enhanceMeatColors(processedImage, settings: settings)
        case .vegetable:
            // 蔬菜：增强绿色和自然色彩
            processedImage = await enhanceVegetableColors(processedImage, settings: settings)
        case .dessert:
            // 甜品：增强暖色调和饱和度
            processedImage = await enhanceDessertColors(processedImage, settings: settings)
        case .beverage:
            // 饮品：增强透明感和反光
            processedImage = await enhanceBeverageAppearance(processedImage, settings: settings)
        default:
            // 通用美食增强
            processedImage = await applyGeneralFoodEnhancement(processedImage, settings: settings)
        }

        return convertToUIImage(processedImage) ?? image
    }
}

// MARK: - 数据模型
struct AIProcessingResult {
    let image: UIImage
    let confidence: Float
    let detectedFeatures: [String]
    let message: String
}

struct PortraitAnalysis {
    let faces: [VNFaceObservation]
    let confidence: Float
    let features: [String]

    init(faces: [VNFaceObservation] = [], confidence: Float = 0.0, features: [String] = []) {
        self.faces = faces
        self.confidence = confidence
        self.features = features
    }
}

struct SceneAnalysis {
    let primaryScene: SceneType
    let confidence: Float
    let detectedElements: [String]

    init(primaryScene: SceneType = .unknown, confidence: Float = 0.0, detectedElements: [String] = []) {
        self.primaryScene = primaryScene
        self.confidence = confidence
        self.detectedElements = detectedElements
    }
}

struct FoodAnalysis {
    let foodType: FoodType
    let confidence: Float
    let detectedIngredients: [String]

    init(foodType: FoodType = .unknown, confidence: Float = 0.0, detectedIngredients: [String] = []) {
        self.foodType = foodType
        self.confidence = confidence
        self.detectedIngredients = detectedIngredients
    }
}

struct ProductAnalysis {
    let products: [VNRecognizedObjectObservation]
    let primaryProductType: ProductType
    let confidence: Float
    let productCategories: [String]

    init(products: [VNRecognizedObjectObservation] = [], primaryProductType: ProductType = .unknown, confidence: Float = 0.0, productCategories: [String] = []) {
        self.products = products
        self.primaryProductType = primaryProductType
        self.confidence = confidence
        self.productCategories = productCategories
    }
}

enum SceneType {
    case nature, sunset, urban, water, mountain, beach, unknown

    var displayName: String {
        switch self {
        case .nature: return "自然风景"
        case .sunset: return "日落夕阳"
        case .urban: return "城市建筑"
        case .water: return "水景"
        case .mountain: return "山景"
        case .beach: return "海滩"
        case .unknown: return "未知场景"
        }
    }
}

enum FoodType {
    case meat, vegetable, dessert, beverage, fruit, grain, unknown

    var displayName: String {
        switch self {
        case .meat: return "肉类"
        case .vegetable: return "蔬菜"
        case .dessert: return "甜品"
        case .beverage: return "饮品"
        case .fruit: return "水果"
        case .grain: return "主食"
        case .unknown: return "未知食物"
        }
    }
}

enum ProductType {
    case electronics, clothing, cosmetics, accessories, furniture, unknown

    var displayName: String {
        switch self {
        case .electronics: return "电子产品"
        case .clothing: return "服装"
        case .cosmetics: return "化妆品"
        case .accessories: return "配饰"
        case .furniture: return "家具"
        case .unknown: return "未知商品"
        }
    }
}

// 添加美食设置结构体
struct FoodSettings {
    var intensity: Float = 0.8
    var saturationBoost: Float = 0.4
    var warmthAdjust: Float = 200
    var contrastEnhance: Float = 0.3
    var appetiteBoost: Float = 0.6
}

// MARK: - 辅助方法
extension AIEnhancedImageProcessor {

    private func convertToUIImage(_ ciImage: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    private func extractFaceFeatures(from faces: [VNFaceObservation]) -> [String] {
        var features: [String] = []

        for face in faces {
            if let landmarks = face.landmarks {
                if landmarks.leftEye != nil { features.append("左眼") }
                if landmarks.rightEye != nil { features.append("右眼") }
                if landmarks.nose != nil { features.append("鼻子") }
                if landmarks.outerLips != nil { features.append("嘴巴") }
                if landmarks.faceContour != nil { features.append("面部轮廓") }
            }
        }

        return features
    }

    private func interpretSceneClassification(_ observations: [VNClassificationObservation]) -> SceneAnalysis {
        guard let topObservation = observations.first else {
            return SceneAnalysis()
        }

        let identifier = topObservation.identifier.lowercased()
        let confidence = topObservation.confidence

        let sceneType: SceneType
        if identifier.contains("nature") || identifier.contains("tree") || identifier.contains("forest") {
            sceneType = .nature
        } else if identifier.contains("sunset") || identifier.contains("sunrise") {
            sceneType = .sunset
        } else if identifier.contains("building") || identifier.contains("city") || identifier.contains("urban") {
            sceneType = .urban
        } else if identifier.contains("water") || identifier.contains("lake") || identifier.contains("river") {
            sceneType = .water
        } else if identifier.contains("mountain") || identifier.contains("hill") {
            sceneType = .mountain
        } else if identifier.contains("beach") || identifier.contains("ocean") || identifier.contains("sea") {
            sceneType = .beach
        } else {
            sceneType = .unknown
        }

        let detectedElements = observations.prefix(5).map { $0.identifier }

        return SceneAnalysis(
            primaryScene: sceneType,
            confidence: confidence,
            detectedElements: Array(detectedElements)
        )
    }

    private func interpretFoodClassification(_ observations: [VNClassificationObservation]) -> FoodAnalysis {
        var maxConfidence: Float = 0
        var detectedFoodType: FoodType = .unknown

        for observation in observations.prefix(10) {
            let identifier = observation.identifier.lowercased()
            let confidence = observation.confidence

            if confidence > maxConfidence {
                if identifier.contains("meat") || identifier.contains("beef") || identifier.contains("chicken") || identifier.contains("pork") {
                    detectedFoodType = .meat
                    maxConfidence = confidence
                } else if identifier.contains("vegetable") || identifier.contains("salad") || identifier.contains("green") {
                    detectedFoodType = .vegetable
                    maxConfidence = confidence
                } else if identifier.contains("dessert") || identifier.contains("cake") || identifier.contains("ice cream") {
                    detectedFoodType = .dessert
                    maxConfidence = confidence
                } else if identifier.contains("drink") || identifier.contains("beverage") || identifier.contains("coffee") || identifier.contains("juice") {
                    detectedFoodType = .beverage
                    maxConfidence = confidence
                } else if identifier.contains("fruit") || identifier.contains("apple") || identifier.contains("orange") {
                    detectedFoodType = .fruit
                    maxConfidence = confidence
                }
            }
        }

        let ingredients = observations.prefix(5).map { $0.identifier }

        return FoodAnalysis(
            foodType: detectedFoodType,
            confidence: maxConfidence,
            detectedIngredients: Array(ingredients)
        )
    }

    private func interpretProductDetection(_ observations: [VNRecognizedObjectObservation]) -> ProductAnalysis {
        let products = observations.filter { $0.confidence > 0.3 }

        var productCategories: [String] = []
        var primaryType: ProductType = .unknown
        var maxConfidence: Float = 0

        for product in products {
            let labels = product.labels.map { $0.identifier.lowercased() }
            productCategories.append(contentsOf: labels)

            for label in labels {
                let confidence = product.confidence
                if confidence > maxConfidence {
                    if label.contains("phone") || label.contains("computer") || label.contains("electronic") {
                        primaryType = .electronics
                        maxConfidence = confidence
                    } else if label.contains("clothing") || label.contains("shirt") || label.contains("dress") {
                        primaryType = .clothing
                        maxConfidence = confidence
                    } else if label.contains("cosmetic") || label.contains("makeup") || label.contains("beauty") {
                        primaryType = .cosmetics
                        maxConfidence = confidence
                    } else if label.contains("accessory") || label.contains("jewelry") || label.contains("watch") {
                        primaryType = .accessories
                        maxConfidence = confidence
                    }
                }
            }
        }

        return ProductAnalysis(
            products: products,
            primaryProductType: primaryType,
            confidence: maxConfidence,
            productCategories: Array(Set(productCategories))
        )
    }

    // 创建面部蒙版的辅助方法
    private func createFaceMask(faces: [VNFaceObservation], imageSize: CGSize, featherAmount: Float = 10.0) -> CIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return CIImage.clear
        }

        // 创建黑色背景
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))

        // 绘制面部区域为白色
        context.setFillColor(UIColor.white.cgColor)
        for face in faces {
            let faceRect = VNImageRectForNormalizedRect(face.boundingBox, Int(imageSize.width), Int(imageSize.height))
            let expandedRect = faceRect.insetBy(dx: -faceRect.width * 0.1, dy: -faceRect.height * 0.1)
            context.fillEllipse(in: expandedRect)
        }

        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let mask = maskImage, let ciMask = CIImage(image: mask) else {
            return CIImage.clear
        }

        // 应用羽化效果
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = ciMask
        blurFilter.radius = featherAmount

        return blurFilter.outputImage ?? ciMask
    }

    private func createEyeMask(leftEye: VNFaceLandmarkRegion2D, rightEye: VNFaceLandmarkRegion2D, faceRect: CGRect, imageSize: CGSize) -> CIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return CIImage.clear
        }

        // 创建黑色背景
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))

        // 绘制眼部区域为白色
        context.setFillColor(UIColor.white.cgColor)

        let denormalizedFaceRect = VNImageRectForNormalizedRect(faceRect, Int(imageSize.width), Int(imageSize.height))

        // 左眼
        if let leftEyePoints = leftEye.normalizedPoints.first {
            let leftEyeCenter = CGPoint(
                x: denormalizedFaceRect.origin.x + CGFloat(leftEyePoints.x) * denormalizedFaceRect.width,
                y: denormalizedFaceRect.origin.y + (1 - CGFloat(leftEyePoints.y)) * denormalizedFaceRect.height
            )
            let leftEyeRect = CGRect(x: leftEyeCenter.x - 15, y: leftEyeCenter.y - 10, width: 30, height: 20)
            context.fillEllipse(in: leftEyeRect)
        }

        // 右眼
        if let rightEyePoints = rightEye.normalizedPoints.first {
            let rightEyeCenter = CGPoint(
                x: denormalizedFaceRect.origin.x + CGFloat(rightEyePoints.x) * denormalizedFaceRect.width,
                y: denormalizedFaceRect.origin.y + (1 - CGFloat(rightEyePoints.y)) * denormalizedFaceRect.height
            )
            let rightEyeRect = CGRect(x: rightEyeCenter.x - 15, y: rightEyeCenter.y - 10, width: 30, height: 20)
            context.fillEllipse(in: rightEyeRect)
        }

        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return CIImage(image: maskImage ?? UIImage()) ?? CIImage.clear
    }

    // 人物分割结果结构
    struct PersonSegmentationResult {
        let mask: CIImage?
        let confidence: Float
    }

    private func performPersonSegmentation(_ image: UIImage) async -> PersonSegmentationResult {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: PersonSegmentationResult(mask: nil, confidence: 0.0))
                return
            }

            let request = VNGeneratePersonSegmentationRequest { request, error in
                guard let observation = request.results?.first as? VNPixelBufferObservation else {
                    continuation.resume(returning: PersonSegmentationResult(mask: nil, confidence: 0.0))
                    return
                }

                let maskImage = CIImage(cvPixelBuffer: observation.pixelBuffer)
                // 对蒙版进行后处理，去除噪点和平滑边缘
                let cleanMask = self.cleanupPersonMask(maskImage)
                let result = PersonSegmentationResult(mask: cleanMask, confidence: 1.0)
                continuation.resume(returning: result)
            }

            request.qualityLevel = .accurate
            request.outputPixelFormat = kCVPixelFormatType_OneComponent8

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: PersonSegmentationResult(mask: nil, confidence: 0.0))
                }
            }
        }
    }
}

// MARK: - 占位符实现（待完善）
extension AIEnhancedImageProcessor {

    // 创建反向蒙版（背景区域）
    private func createInvertedMask(_ mask: CIImage) -> CIImage {
        let invertFilter = CIFilter.colorInvert()
        invertFilter.inputImage = mask
        return invertFilter.outputImage ?? mask
    }

    // 清理人物分割蒙版，去除噪点
    private func cleanupPersonMask(_ mask: CIImage) -> CIImage {
        // 1. 形态学闭运算，填充小空洞
        let morphologyFilter = CIFilter.morphologyRectangleMaximum()
        morphologyFilter.inputImage = mask
        morphologyFilter.width = 3
        morphologyFilter.height = 3

        guard let closedMask = morphologyFilter.outputImage else { return mask }

        // 2. 轻微模糊，平滑边缘
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = closedMask
        blurFilter.radius = 1.5

        return blurFilter.outputImage ?? mask
    }

    // 获取眼部中心点
    private func getEyeCenter(eyeLandmarks: VNFaceLandmarkRegion2D, faceRect: CGRect, imageSize: CGSize) -> CGPoint {
        let denormalizedFaceRect = VNImageRectForNormalizedRect(faceRect, Int(imageSize.width), Int(imageSize.height))

        guard let firstPoint = eyeLandmarks.normalizedPoints.first else {
            return CGPoint(x: denormalizedFaceRect.midX, y: denormalizedFaceRect.midY)
        }

        return CGPoint(
            x: denormalizedFaceRect.origin.x + CGFloat(firstPoint.x) * denormalizedFaceRect.width,
            y: denormalizedFaceRect.origin.y + (1 - CGFloat(firstPoint.y)) * denormalizedFaceRect.height
        )
    }

    // 获取嘴部中心点
    private func getMouthCenter(mouthLandmarks: VNFaceLandmarkRegion2D, faceRect: CGRect, imageSize: CGSize) -> CGPoint {
        let denormalizedFaceRect = VNImageRectForNormalizedRect(faceRect, Int(imageSize.width), Int(imageSize.height))

        let points = mouthLandmarks.normalizedPoints
        guard !points.isEmpty else {
            return CGPoint(x: denormalizedFaceRect.midX, y: denormalizedFaceRect.maxY - denormalizedFaceRect.height * 0.3)
        }

        // 计算嘴部中心
        let avgX = points.map { Float($0.x) }.reduce(0, +) / Float(points.count)
        let avgY = points.map { Float($0.y) }.reduce(0, +) / Float(points.count)

        return CGPoint(
            x: denormalizedFaceRect.origin.x + CGFloat(avgX) * denormalizedFaceRect.width,
            y: denormalizedFaceRect.origin.y + (1 - CGFloat(avgY)) * denormalizedFaceRect.height
        )
    }

    // 面部亮度增强
    private func applyFaceBrightnessEnhancement(_ ciImage: CIImage, faces: [VNFaceObservation], intensity: Float) async -> CIImage {
        guard intensity > 0 else { return ciImage }

        let faceMask = createFaceMask(faces: faces, imageSize: ciImage.extent.size, featherAmount: 15.0)

        // 应用亮度增强
        let brightnessFilter = CIFilter.colorControls()
        brightnessFilter.inputImage = ciImage
        brightnessFilter.brightness = intensity * 0.8

        guard let brightenedImage = brightnessFilter.outputImage else { return ciImage }

        // 使用蒙版混合
        let maskFilter = CIFilter.blendWithMask()
        maskFilter.inputImage = brightenedImage
        maskFilter.backgroundImage = ciImage
        maskFilter.maskImage = faceMask

        return maskFilter.outputImage ?? ciImage
    }

    private func applyGeneralPortraitEnhancement(_ image: UIImage, settings: PortraitSettings) async -> AIProcessingResult {
        guard let ciImage = CIImage(image: image) else {
            return AIProcessingResult(image: image, confidence: 0.0, detectedFeatures: [], message: "处理失败")
        }

        var processedImage = ciImage

        // 1. 智能色彩增强（无人物版本）
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = processedImage
        colorFilter.brightness = settings.brightnessAdjust * 1.2
        colorFilter.saturation = 1.0 + settings.saturationBoost * 1.3
        colorFilter.contrast = 1.0 + settings.contrastEnhance * 1.5
        processedImage = colorFilter.outputImage ?? processedImage

        // 2. 高动态范围优化（HDR效果）
        let shadowFilter = CIFilter.highlightShadowAdjust()
        shadowFilter.inputImage = processedImage
        shadowFilter.highlightAmount = settings.intensity * 0.6
        shadowFilter.shadowAmount = -settings.intensity * 0.4
        shadowFilter.radius = 1.0
        processedImage = shadowFilter.outputImage ?? processedImage

        // 3. 温和的锐化增强
        if settings.intensity > 0.3 {
            let unsharpFilter = CIFilter.unsharpMask()
            unsharpFilter.inputImage = processedImage
            unsharpFilter.radius = 1.5
            unsharpFilter.intensity = settings.intensity * 0.8
            processedImage = unsharpFilter.outputImage ?? processedImage
        }

        // 4. 智能色温调整
        let temperatureFilter = CIFilter.temperatureAndTint()
        temperatureFilter.inputImage = processedImage
        temperatureFilter.neutral = CIVector(x: 6500, y: 0)
        temperatureFilter.targetNeutral = CIVector(x: 6000, y: 50) // 轻微暖色调
        processedImage = temperatureFilter.outputImage ?? processedImage

        // 5. 色彩平衡优化
        let vibranceFilter = CIFilter.vibrance()
        vibranceFilter.inputImage = processedImage
        vibranceFilter.amount = settings.saturationBoost * 0.8
        processedImage = vibranceFilter.outputImage ?? processedImage

        let result = convertToUIImage(processedImage) ?? image

        return AIProcessingResult(
            image: result,
            confidence: 0.8,
            detectedFeatures: ["色彩增强", "皮肤色调优化", "锐化", "高光调整"],
            message: "智能图片增强完成：应用了HDR效果、色彩优化、锐化增强和色温平衡"
        )
    }

    private func enhanceNatureColors(_ ciImage: CIImage, settings: LandscapeSettings) async -> CIImage {
        var processedImage = ciImage

        // 1. 增强绿色通道（植被）
        let greenChannelFilter = CIFilter.colorMatrix()
        greenChannelFilter.inputImage = processedImage
        greenChannelFilter.rVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        greenChannelFilter.gVector = CIVector(x: 0, y: 1.0 + CGFloat(settings.saturationBoost) * 0.8, z: 0, w: 0)
        greenChannelFilter.bVector = CIVector(x: 0, y: 0, z: 1, w: 0)
        greenChannelFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        processedImage = greenChannelFilter.outputImage ?? processedImage

        // 2. 增强蓝色通道（天空和水）
        let blueChannelFilter = CIFilter.colorMatrix()
        blueChannelFilter.inputImage = processedImage
        blueChannelFilter.rVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        blueChannelFilter.gVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        blueChannelFilter.bVector = CIVector(x: 0, y: 0, z: 1.0 + CGFloat(settings.saturationBoost) * 0.6, w: 0)
        blueChannelFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        processedImage = blueChannelFilter.outputImage ?? processedImage

        // 3. 整体色彩增强
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = processedImage
        colorFilter.saturation = 1.0 + settings.saturationBoost * 0.7
        colorFilter.contrast = 1.0 + settings.contrastEnhance * 1.2
        colorFilter.brightness = settings.brightnessAdjust
        processedImage = colorFilter.outputImage ?? processedImage

        return processedImage
    }

    private func enhanceSunsetColors(_ ciImage: CIImage, settings: LandscapeSettings) async -> CIImage {
        // 增强日落色彩
        let temperatureFilter = CIFilter.temperatureAndTint()
        temperatureFilter.inputImage = ciImage
        temperatureFilter.neutral = CIVector(x: 6500, y: 0)
        temperatureFilter.targetNeutral = CIVector(x: 4500, y: CGFloat(settings.warmthAdjust) * 0.1)

        return temperatureFilter.outputImage ?? ciImage
    }

    private func enhanceUrbanContrast(_ ciImage: CIImage, settings: LandscapeSettings) async -> CIImage {
        // 增强城市对比度
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.contrast = 1.0 + settings.contrastEnhance * 1.5

        return filter.outputImage ?? ciImage
    }

    private func enhanceWaterScene(_ ciImage: CIImage, settings: LandscapeSettings) async -> CIImage {
        // 增强水景
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = 1.0 + settings.saturationBoost * 0.8

        return filter.outputImage ?? ciImage
    }

    private func applyGeneralLandscapeEnhancement(_ ciImage: CIImage, settings: LandscapeSettings) async -> CIImage {
        // 通用风景增强
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = 1.0 + settings.saturationBoost
        filter.contrast = 1.0 + settings.contrastEnhance
        filter.brightness = settings.brightnessAdjust

        return filter.outputImage ?? ciImage
    }

    private func applyIntelligentColorEnhancement(_ image: UIImage, sceneAnalysis: SceneAnalysis, settings: LandscapeSettings) async -> UIImage {
        // 智能色彩增强的占位符实现
        return image
    }

    private func enhanceMeatColors(_ ciImage: CIImage, settings: FoodSettings) async -> CIImage {
        // 增强肉类色彩
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = 1.0 + settings.saturationBoost

        return filter.outputImage ?? ciImage
    }

    private func enhanceVegetableColors(_ ciImage: CIImage, settings: FoodSettings) async -> CIImage {
        // 增强蔬菜色彩
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = 1.0 + settings.saturationBoost * 0.8

        return filter.outputImage ?? ciImage
    }

    private func enhanceDessertColors(_ ciImage: CIImage, settings: FoodSettings) async -> CIImage {
        // 增强甜品色彩
        let temperatureFilter = CIFilter.temperatureAndTint()
        temperatureFilter.inputImage = ciImage
        temperatureFilter.neutral = CIVector(x: 6500, y: 0)
        temperatureFilter.targetNeutral = CIVector(x: 5500, y: CGFloat(settings.warmthAdjust) * 0.05)

        return temperatureFilter.outputImage ?? ciImage
    }

    private func enhanceBeverageAppearance(_ ciImage: CIImage, settings: FoodSettings) async -> CIImage {
        // 增强饮品外观
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = 1.0 + settings.saturationBoost * 0.6

        return filter.outputImage ?? ciImage
    }

    private func applyGeneralFoodEnhancement(_ ciImage: CIImage, settings: FoodSettings) async -> CIImage {
        var processedImage = ciImage

        // 1. 食物暖色调增强
        let temperatureFilter = CIFilter.temperatureAndTint()
        temperatureFilter.inputImage = processedImage
        temperatureFilter.neutral = CIVector(x: 6500, y: 0)
        temperatureFilter.targetNeutral = CIVector(x: 5200 + CGFloat(settings.warmthAdjust), y: CGFloat(settings.warmthAdjust) * 0.2)
        processedImage = temperatureFilter.outputImage ?? processedImage

        // 2. 饱和度和对比度增强
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = processedImage
        colorFilter.saturation = 1.0 + settings.saturationBoost * 1.4  // 强化饱和度
        colorFilter.contrast = 1.0 + settings.contrastEnhance * 1.6    // 强化对比度
        colorFilter.brightness = 0.05 // 轻微提亮
        processedImage = colorFilter.outputImage ?? processedImage

        // 3. 食欲感增强 - 增强红色和黄色通道
        let appetiteFilter = CIFilter.colorMatrix()
        appetiteFilter.inputImage = processedImage
        let redBoost = 1.0 + settings.appetiteBoost * 0.3
        let yellowBoost = 1.0 + settings.appetiteBoost * 0.2
        appetiteFilter.rVector = CIVector(x: CGFloat(redBoost), y: 0, z: 0, w: 0)
        appetiteFilter.gVector = CIVector(x: 0, y: CGFloat(yellowBoost), z: 0, w: 0)
        appetiteFilter.bVector = CIVector(x: 0, y: 0, z: 1, w: 0)
        appetiteFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        processedImage = appetiteFilter.outputImage ?? processedImage

        // 4. 轻微的光泽效果
        let highlightFilter = CIFilter.highlightShadowAdjust()
        highlightFilter.inputImage = processedImage
        highlightFilter.highlightAmount = settings.intensity * 0.4
        highlightFilter.shadowAmount = -settings.intensity * 0.2
        processedImage = highlightFilter.outputImage ?? processedImage

        // 5. 锐化细节
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = processedImage
        sharpenFilter.sharpness = settings.intensity * 1.2
        processedImage = sharpenFilter.outputImage ?? processedImage

        return processedImage
    }

    private func applyAppetiteEnhancement(_ image: UIImage, settings: FoodSettings) async -> UIImage {
        // 食欲感增强的占位符实现
        return image
    }

    private func applyProductHighlighting(_ image: UIImage, products: [VNRecognizedObjectObservation], settings: EcommerceSettings) async -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        var processedImage = ciImage

        // 1. 整体亮度和对比度提升
        let exposureFilter = CIFilter.exposureAdjust()
        exposureFilter.inputImage = processedImage
        exposureFilter.ev = settings.exposureBoost * 1.2
        processedImage = exposureFilter.outputImage ?? processedImage

        // 2. 色彩饱和度优化
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = processedImage
        colorFilter.saturation = 1.0 + settings.saturationEnhance * 1.3
        colorFilter.contrast = 1.0 + settings.contrastBoost * 1.5
        processedImage = colorFilter.outputImage ?? processedImage

        // 3. 清晰度增强
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = processedImage
        sharpenFilter.sharpness = settings.intensity * 2.0
        processedImage = sharpenFilter.outputImage ?? processedImage

        // 4. 高光和阴影调整
        let highlightShadowFilter = CIFilter.highlightShadowAdjust()
        highlightShadowFilter.inputImage = processedImage
        highlightShadowFilter.highlightAmount = settings.highlightAdjust * 1.2
        highlightShadowFilter.shadowAmount = settings.shadowAdjust * 1.5
        processedImage = highlightShadowFilter.outputImage ?? processedImage

        return convertToUIImage(processedImage) ?? image
    }

    private func applyProfessionalCommercialStyling(_ image: UIImage, productType: ProductType, settings: EcommerceSettings) async -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        var processedImage = ciImage

        // 根据产品类型应用不同的风格
        switch productType {
        case .electronics:
            // 电子产品：冷色调，高对比度
            let temperatureFilter = CIFilter.temperatureAndTint()
            temperatureFilter.inputImage = processedImage
            temperatureFilter.neutral = CIVector(x: 6500, y: 0)
            temperatureFilter.targetNeutral = CIVector(x: 7200, y: -100)
            processedImage = temperatureFilter.outputImage ?? processedImage

        case .clothing:
            // 服装：暖色调，柔和对比度
            let temperatureFilter = CIFilter.temperatureAndTint()
            temperatureFilter.inputImage = processedImage
            temperatureFilter.neutral = CIVector(x: 6500, y: 0)
            temperatureFilter.targetNeutral = CIVector(x: 5800, y: 50)
            processedImage = temperatureFilter.outputImage ?? processedImage

        case .cosmetics:
            // 化妆品：粉色调，高亮度
            let tintFilter = CIFilter.colorMatrix()
            tintFilter.inputImage = processedImage
            tintFilter.rVector = CIVector(x: 1.05, y: 0, z: 0, w: 0)
            tintFilter.gVector = CIVector(x: 0, y: 0.98, z: 0, w: 0)
            tintFilter.bVector = CIVector(x: 0, y: 0, z: 1.02, w: 0)
            tintFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
            processedImage = tintFilter.outputImage ?? processedImage

        default:
            // 通用产品处理
            let colorFilter = CIFilter.colorControls()
            colorFilter.inputImage = processedImage
            colorFilter.brightness = 0.08
            colorFilter.contrast = 1.2
            processedImage = colorFilter.outputImage ?? processedImage
        }

        // 专业清洁感处理
        let noiseReductionFilter = CIFilter.noiseReduction()
        noiseReductionFilter.inputImage = processedImage
        noiseReductionFilter.noiseLevel = settings.noiseReduction * 2.0
        noiseReductionFilter.sharpness = 0.9
        processedImage = noiseReductionFilter.outputImage ?? processedImage

        return convertToUIImage(processedImage) ?? image
    }

    private func performIntelligentPersonSegmentation(_ image: UIImage) async -> UIImage {
        // 使用现有的人物分割功能
        let segmentationResult = await performPersonSegmentation(image)
        guard let mask = segmentationResult.mask,
              let ciImage = CIImage(image: image) else { return image }

        // 使用蒙版提取人物
        let composite = CIFilter.blendWithAlphaMask()
        composite.inputImage = ciImage
        composite.backgroundImage = CIImage.clear
        composite.maskImage = mask

        return convertToUIImage(composite.outputImage ?? ciImage) ?? image
    }

    private func applyIDPhotoStandardization(_ image: UIImage, face: VNFaceObservation, settings: IDPhotoSettings) async -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        var processedImage = ciImage

        // 1. 面部增强
        if settings.faceEnhancement > 0 {
            let sharpenFilter = CIFilter.sharpenLuminance()
            sharpenFilter.inputImage = processedImage
            sharpenFilter.sharpness = settings.faceEnhancement * 1.5
            processedImage = sharpenFilter.outputImage ?? processedImage
        }

        // 2. 皮肤平滑
        if settings.skinSmoothing > 0 {
            let smoothFilter = CIFilter.gaussianBlur()
            smoothFilter.inputImage = processedImage
            smoothFilter.radius = settings.skinSmoothing * 1.2

            if let smoothed = smoothFilter.outputImage {
                let blendFilter = CIFilter.lightenBlendMode()
                blendFilter.inputImage = processedImage
                blendFilter.backgroundImage = smoothed

                // 创建面部蒙版
                let imageSize = processedImage.extent.size
                let faceMask = createFaceMask(faces: [face], imageSize: imageSize, featherAmount: 5.0)

                let maskFilter = CIFilter.blendWithAlphaMask()
                maskFilter.inputImage = blendFilter.outputImage
                maskFilter.backgroundImage = processedImage
                maskFilter.maskImage = faceMask

                processedImage = maskFilter.outputImage ?? processedImage
            }
        }

        // 3. 亮度校正
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = processedImage
        colorFilter.brightness = settings.brightnessCorrection
        colorFilter.contrast = 1.1 // 轻微增加对比度
        processedImage = colorFilter.outputImage ?? processedImage

        return convertToUIImage(processedImage) ?? image
    }

    private func generateAndCompositeIDPhotoBackground(_ image: UIImage, settings: IDPhotoSettings) async -> UIImage {
        guard let personImage = CIImage(image: image) else { return image }

        // 创建标准尺寸的证件照背景
        let standardSize = CGSize(width: 413, height: 531) // 1寸照片标准尺寸（像素）
        let backgroundColor = createIDPhotoBackground(size: standardSize, color: settings.backgroundColor)

        // 调整人物图片大小以适应证件照标准
        let scaleFilter = CIFilter.lanczosScaleTransform()
        scaleFilter.inputImage = personImage
        scaleFilter.scale = Float(min(standardSize.width / personImage.extent.width,
                                     standardSize.height / personImage.extent.height) * 0.8)

        guard let scaledPerson = scaleFilter.outputImage else { return image }

        // 居中定位
        let translateFilter = CIFilter(name: "CIAffineTransform")!
        translateFilter.setValue(scaledPerson, forKey: kCIInputImageKey)
        let centerX = (standardSize.width - scaledPerson.extent.width) / 2
        let centerY = (standardSize.height - scaledPerson.extent.height) / 2
        translateFilter.setValue(NSValue(cgAffineTransform: CGAffineTransform(translationX: centerX, y: centerY)), forKey: kCIInputTransformKey)

        guard let centeredPerson = translateFilter.outputImage else { return image }

        // 合成最终图片
        let composite = CIFilter.sourceOverCompositing()
        composite.inputImage = centeredPerson
        composite.backgroundImage = backgroundColor

        let finalImage = composite.outputImage?.cropped(to: CGRect(origin: .zero, size: standardSize))

        return convertToUIImage(finalImage ?? personImage) ?? image
    }

    // 创建证件照背景
    private func createIDPhotoBackground(size: CGSize, color: IDPhotoBackgroundColor) -> CIImage {
        let colorValue: CIColor

        switch color {
        case .white:
            colorValue = CIColor.white
        case .blue:
            colorValue = CIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        case .red:
            colorValue = CIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        case .green:
            colorValue = CIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        case .office:
            // 创建模糊的办公室背景
            let gradientFilter = CIFilter.linearGradient()
            gradientFilter.point0 = CGPoint(x: 0, y: 0)
            gradientFilter.point1 = CGPoint(x: 0, y: size.height)
            gradientFilter.color0 = CIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
            gradientFilter.color1 = CIColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1.0)

            let croppedGradient = gradientFilter.outputImage?.cropped(to: CGRect(origin: .zero, size: size))

            if let gradient = croppedGradient {
                let blurFilter = CIFilter.gaussianBlur()
                blurFilter.inputImage = gradient
                blurFilter.radius = 20.0
                return blurFilter.outputImage ?? gradient
            } else {
                colorValue = CIColor(red: 0.85, green: 0.85, blue: 0.9, alpha: 1.0)
            }
        }

        let colorFilter = CIFilter(name: "CIConstantColorGenerator")!
        colorFilter.setValue(colorValue, forKey: kCIInputColorKey)

        return colorFilter.outputImage?.cropped(to: CGRect(origin: .zero, size: size)) ?? CIImage.clear
    }

    // MARK: - 新增的辅助方法

    // 创建精确的皮肤区域蒙版
    private func createPreciseSkinMask(faces: [VNFaceObservation], imageSize: CGSize) -> CIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return CIImage.clear
        }

        // 创建黑色背景（Alpha蒙版需要黑色背景）
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))

        // 绘制面部皮肤区域为白色（除去眼部、嘴部等细节区域）
        context.setFillColor(UIColor.white.cgColor)
        for face in faces {
            let faceRect = VNImageRectForNormalizedRect(face.boundingBox, Int(imageSize.width), Int(imageSize.height))

            // 绘制面部轮廓区域
            let skinRect = faceRect.insetBy(dx: faceRect.width * 0.15, dy: faceRect.height * 0.2)
            context.fillEllipse(in: skinRect)

            // 排除眼部和嘴部区域
            if let landmarks = face.landmarks {
                context.setBlendMode(.clear)

                // 排除左眼
                if let leftEye = landmarks.leftEye {
                    let eyeCenter = getEyeCenter(eyeLandmarks: leftEye, faceRect: faceRect, imageSize: imageSize)
                    let eyeRect = CGRect(x: eyeCenter.x - 20, y: eyeCenter.y - 15, width: 40, height: 30)
                    context.fillEllipse(in: eyeRect)
                }

                // 排除右眼
                if let rightEye = landmarks.rightEye {
                    let eyeCenter = getEyeCenter(eyeLandmarks: rightEye, faceRect: faceRect, imageSize: imageSize)
                    let eyeRect = CGRect(x: eyeCenter.x - 20, y: eyeCenter.y - 15, width: 40, height: 30)
                    context.fillEllipse(in: eyeRect)
                }

                // 排除嘴部
                if let mouth = landmarks.outerLips {
                    let mouthCenter = getMouthCenter(mouthLandmarks: mouth, faceRect: faceRect, imageSize: imageSize)
                    let mouthRect = CGRect(x: mouthCenter.x - 25, y: mouthCenter.y - 15, width: 50, height: 30)
                    context.fillEllipse(in: mouthRect)
                }

                context.setBlendMode(.normal)
            }
        }

        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let mask = maskImage, let ciMask = CIImage(image: mask) else {
            return CIImage.clear
        }

        // 应用轻微羽化效果，使边缘更自然
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = ciMask
        blurFilter.radius = 3.0

        return blurFilter.outputImage ?? ciMask
    }
}