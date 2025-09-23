import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import MetalPerformanceShaders
import Metal

class AdvancedStyleProcessor: ObservableObject {
    static let shared = AdvancedStyleProcessor()

    private let context: CIContext
    private let metalDevice: MTLDevice?

    init() {
        self.metalDevice = MTLCreateSystemDefaultDevice()

        if let device = metalDevice {
            self.context = CIContext(mtlDevice: device)
        } else {
            self.context = CIContext()
        }
    }

    // MARK: - 人像处理
    func processPortrait(_ image: UIImage, settings: PortraitSettings) async -> ProcessingResult {
        let faces = await detectFaces(in: image)

        if faces.isEmpty {
            // 没有人物，进行常规美化
            return await enhanceImageGeneral(image, intensity: settings.intensity)
        } else {
            // 有人物，进行人像美化和背景虚化
            return await enhancePortrait(image, faces: faces, settings: settings)
        }
    }

    private func detectFaces(in image: UIImage) async -> [VNFaceObservation] {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: [])
                return
            }

            let request = VNDetectFaceRectanglesRequest { request, error in
                guard let observations = request.results as? [VNFaceObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: observations)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    private func enhancePortrait(_ image: UIImage, faces: [VNFaceObservation], settings: PortraitSettings) async -> ProcessingResult {
        guard let ciImage = CIImage(image: image) else {
            return ProcessingResult(image: image, message: "处理失败")
        }

        var processedImage = ciImage

        // 1. 人像美颜
        let beautificationFilter = CIFilter.colorControls()
        beautificationFilter.inputImage = processedImage
        beautificationFilter.brightness = settings.brightnessAdjust
        beautificationFilter.saturation = 1.0 + settings.saturationBoost
        beautificationFilter.contrast = 1.0 + settings.contrastEnhance
        processedImage = beautificationFilter.outputImage ?? processedImage

        // 2. 皮肤平滑
        let smoothFilter = CIFilter.gaussianBlur()
        smoothFilter.inputImage = processedImage
        smoothFilter.radius = settings.skinSmoothing * 2.0

        if let smoothedImage = smoothFilter.outputImage {
            let blendFilter = CIFilter.lightenBlendMode()
            blendFilter.inputImage = processedImage
            blendFilter.backgroundImage = smoothedImage

            let maskFilter = CIFilter.blendWithAlphaMask()
            maskFilter.inputImage = processedImage
            maskFilter.backgroundImage = blendFilter.outputImage

            // 创建面部蒙版
            let faceMask = createFaceMask(faces: faces, imageSize: processedImage.extent.size)
            maskFilter.maskImage = faceMask

            processedImage = maskFilter.outputImage ?? processedImage
        }

        // 3. 背景虚化
        let backgroundBlur = CIFilter.gaussianBlur()
        backgroundBlur.inputImage = ciImage
        backgroundBlur.radius = settings.backgroundBlur * 10.0

        if let blurredBackground = backgroundBlur.outputImage {
            let composite = CIFilter.blendWithAlphaMask()
            composite.inputImage = processedImage
            composite.backgroundImage = blurredBackground

            // 创建背景蒙版（面部反向）
            let backgroundMask = createBackgroundMask(faces: faces, imageSize: processedImage.extent.size)
            composite.maskImage = backgroundMask

            processedImage = composite.outputImage ?? processedImage
        }

        guard let finalImage = convertToUIImage(processedImage) else {
            return ProcessingResult(image: image, message: "处理失败")
        }

        return ProcessingResult(
            image: finalImage,
            message: "人像美化完成：检测到 \(faces.count) 个人物，已应用美颜和背景虚化效果"
        )
    }

    private func enhanceImageGeneral(_ image: UIImage, intensity: Float) async -> ProcessingResult {
        guard let ciImage = CIImage(image: image) else {
            return ProcessingResult(image: image, message: "处理失败")
        }

        // 常规图片美化
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.brightness = intensity * 0.15
        filter.contrast = 1.0 + intensity * 0.3
        filter.saturation = 1.0 + intensity * 0.25

        guard let outputImage = filter.outputImage,
              let finalImage = convertToUIImage(outputImage) else {
            return ProcessingResult(image: image, message: "处理失败")
        }

        return ProcessingResult(
            image: finalImage,
            message: "图片美化完成：未检测到人物，已应用常规美化效果"
        )
    }

    // MARK: - 证件照处理
    func processIDPhoto(_ image: UIImage, settings: IDPhotoSettings) async -> ProcessingResult {
        let faces = await detectFaces(in: image)

        guard !faces.isEmpty else {
            return ProcessingResult(
                image: image,
                message: "图片中没有检测到人物，请重新选择包含人物肖像的图片"
            )
        }

        return await createIDPhoto(image, faces: faces, settings: settings)
    }

    private func createIDPhoto(_ image: UIImage, faces: [VNFaceObservation], settings: IDPhotoSettings) async -> ProcessingResult {
        guard let ciImage = CIImage(image: image) else {
            return ProcessingResult(image: image, message: "处理失败")
        }

        // 1. 人物抠图
        let segmentedImage = await segmentPerson(from: ciImage)

        // 2. 创建证件照背景
        let backgroundImage = createIDPhotoBackground(
            size: ciImage.extent.size,
            color: settings.backgroundColor
        )

        // 3. 合成证件照
        let composite = CIFilter.sourceOverCompositing()
        composite.inputImage = segmentedImage
        composite.backgroundImage = backgroundImage

        guard let resultImage = composite.outputImage,
              let finalImage = convertToUIImage(resultImage) else {
            return ProcessingResult(image: image, message: "处理失败")
        }

        return ProcessingResult(
            image: finalImage,
            message: "证件照制作完成：已提取人物肖像并更换\(settings.backgroundColor.displayName)背景"
        )
    }

    private func segmentPerson(from ciImage: CIImage) async -> CIImage {
        // 使用 Vision 进行人物分割
        return await withCheckedContinuation { continuation in
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                continuation.resume(returning: ciImage)
                return
            }

            let request = VNGeneratePersonSegmentationRequest { request, error in
                guard let observation = request.results?.first as? VNPixelBufferObservation,
                      let maskImage = CIImage(cvPixelBuffer: observation.pixelBuffer) else {
                    continuation.resume(returning: ciImage)
                    return
                }

                // 使用蒙版进行合成
                let blendFilter = CIFilter.blendWithAlphaMask()
                blendFilter.inputImage = ciImage
                blendFilter.backgroundImage = CIImage.clear
                blendFilter.maskImage = maskImage

                continuation.resume(returning: blendFilter.outputImage ?? ciImage)
            }

            request.qualityLevel = .balanced
            request.outputPixelFormat = kCVPixelFormatType_OneComponent8

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: ciImage)
                }
            }
        }
    }

    // MARK: - 风景处理
    func processLandscape(_ image: UIImage, settings: LandscapeSettings) async -> ProcessingResult {
        guard let ciImage = CIImage(image: image) else {
            return ProcessingResult(image: image, message: "处理失败")
        }

        var processedImage = ciImage

        // 1. 智能色彩增强
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = processedImage
        colorFilter.saturation = 1.0 + settings.saturationBoost
        colorFilter.contrast = 1.0 + settings.contrastEnhance
        colorFilter.brightness = settings.brightnessAdjust
        processedImage = colorFilter.outputImage ?? processedImage

        // 2. 细节增强
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = processedImage
        sharpenFilter.sharpness = settings.sharpness
        processedImage = sharpenFilter.outputImage ?? processedImage

        // 3. 暖色调调整（模拟黄金时光）
        let temperatureFilter = CIFilter.temperatureAndTint()
        temperatureFilter.inputImage = processedImage
        temperatureFilter.neutral = CIVector(x: 6500, y: 0)
        temperatureFilter.targetNeutral = CIVector(x: 5500 + settings.warmthAdjust, y: settings.warmthAdjust * 0.1)
        processedImage = temperatureFilter.outputImage ?? processedImage

        // 4. 轻微的晕影效果
        let vignetteFilter = CIFilter.vignette()
        vignetteFilter.inputImage = processedImage
        vignetteFilter.intensity = settings.vignetteIntensity
        vignetteFilter.radius = 1.5
        processedImage = vignetteFilter.outputImage ?? processedImage

        guard let finalImage = convertToUIImage(processedImage) else {
            return ProcessingResult(image: image, message: "处理失败")
        }

        return ProcessingResult(
            image: finalImage,
            message: "风景增强完成：已优化色彩饱和度、对比度和细节，并添加暖色调效果"
        )
    }

    // MARK: - 电商图片处理
    func processEcommerce(_ image: UIImage, settings: EcommerceSettings) async -> ProcessingResult {
        let hasProducts = await detectObjects(in: image)

        guard hasProducts else {
            return ProcessingResult(
                image: image,
                message: "图像中没有检测到商品，请重新选择包含商品的图片"
            )
        }

        return await enhanceEcommerceImage(image, settings: settings)
    }

    private func detectObjects(in image: UIImage) async -> Bool {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: false)
                return
            }

            let request = VNRecognizeObjectsRequest { request, error in
                guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                    continuation.resume(returning: false)
                    return
                }

                // 检查是否有物体被识别
                let hasObjects = !observations.isEmpty
                continuation.resume(returning: hasObjects)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: false)
                }
            }
        }
    }

    private func enhanceEcommerceImage(_ image: UIImage, settings: EcommerceSettings) async -> ProcessingResult {
        guard let ciImage = CIImage(image: image) else {
            return ProcessingResult(image: image, message: "处理失败")
        }

        var processedImage = ciImage

        // 1. 提高亮度和对比度，突出商品
        let exposureFilter = CIFilter.exposureAdjust()
        exposureFilter.inputImage = processedImage
        exposureFilter.ev = settings.exposureBoost
        processedImage = exposureFilter.outputImage ?? processedImage

        // 2. 色彩校正，确保商品颜色真实
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = processedImage
        colorFilter.saturation = 1.0 + settings.saturationEnhance
        colorFilter.contrast = 1.0 + settings.contrastBoost
        processedImage = colorFilter.outputImage ?? processedImage

        // 3. 减少噪点，提高清晰度
        let noiseFilter = CIFilter.noiseReduction()
        noiseFilter.inputImage = processedImage
        noiseFilter.noiseLevel = settings.noiseReduction
        noiseFilter.sharpness = 0.8
        processedImage = noiseFilter.outputImage ?? processedImage

        // 4. 轻微的高光效果，增加质感
        let highlightFilter = CIFilter.highlightShadowAdjust()
        highlightFilter.inputImage = processedImage
        highlightFilter.highlightAmount = settings.highlightAdjust
        highlightFilter.shadowAmount = settings.shadowAdjust
        processedImage = highlightFilter.outputImage ?? processedImage

        guard let finalImage = convertToUIImage(processedImage) else {
            return ProcessingResult(image: image, message: "处理失败")
        }

        return ProcessingResult(
            image: finalImage,
            message: "电商图片处理完成：已突出商品质感，优化亮度对比度，并增强细节表现"
        )
    }

    // MARK: - 辅助方法
    private func createFaceMask(faces: [VNFaceObservation], imageSize: CGSize) -> CIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return CIImage.clear
        }

        // 创建白色背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))

        // 绘制面部区域为黑色
        context.setFillColor(UIColor.black.cgColor)
        for face in faces {
            let faceRect = VNImageRectForNormalizedRect(face.boundingBox, Int(imageSize.width), Int(imageSize.height))
            let expandedRect = faceRect.insetBy(dx: -faceRect.width * 0.2, dy: -faceRect.height * 0.2)
            context.fillEllipse(in: expandedRect)
        }

        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return CIImage(image: maskImage ?? UIImage()) ?? CIImage.clear
    }

    private func createBackgroundMask(faces: [VNFaceObservation], imageSize: CGSize) -> CIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return CIImage.clear
        }

        // 创建黑色背景
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))

        // 绘制面部区域为白色（保护区域）
        context.setFillColor(UIColor.white.cgColor)
        for face in faces {
            let faceRect = VNImageRectForNormalizedRect(face.boundingBox, Int(imageSize.width), Int(imageSize.height))
            let expandedRect = faceRect.insetBy(dx: -faceRect.width * 0.3, dy: -faceRect.height * 0.3)
            context.fillEllipse(in: expandedRect)
        }

        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return CIImage(image: maskImage ?? UIImage()) ?? CIImage.clear
    }

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

        let colorFilter = CIFilter.constantColorGenerator()
        colorFilter.color = colorValue

        return colorFilter.outputImage?.cropped(to: CGRect(origin: .zero, size: size)) ?? CIImage.clear
    }

    private func convertToUIImage(_ ciImage: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - 数据模型
struct ProcessingResult {
    let image: UIImage
    let message: String
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

// MARK: - 自定义参数结构体
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