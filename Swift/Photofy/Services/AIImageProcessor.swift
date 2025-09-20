import Vision
import CoreML
import UIKit
import CoreImage

class AIImageProcessor: ObservableObject {
    static let shared = AIImageProcessor()

    private init() {}

    // MARK: - 人脸检测
    func detectFaces(in image: UIImage) async -> [VNFaceObservation] {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: [])
                return
            }

            var isResumed = false

            let request = VNDetectFaceRectanglesRequest { request, error in
                guard !isResumed else { return }
                isResumed = true

                guard let results = request.results as? [VNFaceObservation], error == nil else {
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: results)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                guard !isResumed else { return }
                isResumed = true
                continuation.resume(returning: [])
            }
        }
    }

    // MARK: - 人脸特征点检测
    func detectFaceLandmarks(in image: UIImage) async -> [VNFaceObservation] {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: [])
                return
            }

            var isResumed = false

            let request = VNDetectFaceLandmarksRequest { request, error in
                guard !isResumed else { return }
                isResumed = true

                guard let results = request.results as? [VNFaceObservation], error == nil else {
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: results)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                guard !isResumed else { return }
                isResumed = true
                continuation.resume(returning: [])
            }
        }
    }

    // MARK: - 物体识别
    func classifyObjects(in image: UIImage) async -> [VNClassificationObservation] {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: [])
                return
            }

            var isResumed = false

            let request = VNClassifyImageRequest { request, error in
                guard !isResumed else { return }
                isResumed = true

                guard let results = request.results as? [VNClassificationObservation], error == nil else {
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: results)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                guard !isResumed else { return }
                isResumed = true
                continuation.resume(returning: [])
            }
        }
    }

    // MARK: - 文本检测
    func detectText(in image: UIImage) async -> [VNTextObservation] {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: [])
                return
            }

            var isResumed = false

            let request = VNDetectTextRectanglesRequest { request, error in
                guard !isResumed else { return }
                isResumed = true

                guard let results = request.results as? [VNTextObservation], error == nil else {
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: results)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                guard !isResumed else { return }
                isResumed = true
                continuation.resume(returning: [])
            }
        }
    }

    // MARK: - 美颜处理
    func applyBeautyFilter(to image: UIImage, intensity: Float = 0.5) async -> UIImage? {
        // 先检测人脸
        let faces = await detectFaces(in: image)
        guard !faces.isEmpty else { return image }

        guard let ciImage = CIImage(image: image) else { return nil }
        let context = CIContext()

        // 应用简单的模糊效果作为美颜滤镜
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = ciImage
        blurFilter.radius = intensity * 2.0

        guard let smoothedImage = blurFilter.outputImage else { return nil }

        // 调整亮度和对比度
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = smoothedImage
        colorFilter.brightness = intensity * 0.1
        colorFilter.contrast = 1.0 + intensity * 0.2
        colorFilter.saturation = 1.0 + intensity * 0.1

        guard let finalImage = colorFilter.outputImage,
              let cgImage = context.createCGImage(finalImage, from: finalImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - 背景模糊/虚化
    func applyPortraitEffect(to image: UIImage, blurRadius: Float = 10.0) async -> UIImage? {
        // 检测人物
        let faces = await detectFaces(in: image)
        guard !faces.isEmpty else { return image }

        guard let ciImage = CIImage(image: image) else { return nil }
        let context = CIContext()

        // 创建模糊背景
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = ciImage
        blurFilter.radius = blurRadius

        guard let blurredImage = blurFilter.outputImage else { return nil }

        // 这里简化处理，实际应用中需要更复杂的人物分割算法
        // 可以使用Core ML的语义分割模型来实现精确的背景分离

        guard let cgImage = context.createCGImage(blurredImage, from: blurredImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - 自动增强
    func autoEnhance(image: UIImage) async -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let context = CIContext()

        // 自动色调调整
        let autoAdjustFilter = CIFilter.colorControls()
        autoAdjustFilter.inputImage = ciImage

        // 分析图像特征来决定调整参数
        let averageBrightness = calculateAverageBrightness(ciImage: ciImage)

        if averageBrightness < 0.3 {
            // 图像偏暗，增加亮度
            autoAdjustFilter.brightness = 0.2
            autoAdjustFilter.contrast = 1.1
        } else if averageBrightness > 0.7 {
            // 图像偏亮，减少亮度
            autoAdjustFilter.brightness = -0.1
            autoAdjustFilter.contrast = 1.05
        } else {
            // 正常亮度，轻微增强
            autoAdjustFilter.contrast = 1.05
            autoAdjustFilter.saturation = 1.1
        }

        guard let enhancedImage = autoAdjustFilter.outputImage,
              let cgImage = context.createCGImage(enhancedImage, from: enhancedImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - 智能裁剪建议
    func suggestCrop(for image: UIImage) async -> CGRect? {
        let faces = await detectFaces(in: image)

        if !faces.isEmpty {
            // 基于人脸位置建议裁剪
            let imageSize = image.size
            var combinedRect = faces[0].boundingBox

            // 合并所有人脸区域
            for face in faces.dropFirst() {
                combinedRect = combinedRect.union(face.boundingBox)
            }

            // 转换坐标系并扩展区域
            let x = combinedRect.minX * imageSize.width
            let y = (1 - combinedRect.maxY) * imageSize.height
            let width = combinedRect.width * imageSize.width
            let height = combinedRect.height * imageSize.height

            // 扩展区域以包含更多上下文
            let expandedWidth = width * 1.5
            let expandedHeight = height * 1.5
            let expandedX = max(0, x - (expandedWidth - width) / 2)
            let expandedY = max(0, y - (expandedHeight - height) / 2)

            return CGRect(
                x: expandedX,
                y: expandedY,
                width: min(expandedWidth, imageSize.width - expandedX),
                height: min(expandedHeight, imageSize.height - expandedY)
            )
        }

        return nil
    }

    // MARK: - 私有辅助方法
    private func calculateAverageBrightness(ciImage: CIImage) -> Float {
        let context = CIContext()
        let extent = ciImage.extent

        // 缩小图像以提高性能
        let scale: CGFloat = 0.1
        let smallExtent = CGRect(x: 0, y: 0, width: extent.width * scale, height: extent.height * scale)

        let filter = CIFilter.lanczosScaleTransform()
        filter.inputImage = ciImage
        filter.scale = Float(scale)

        guard let scaledImage = filter.outputImage,
              let cgImage = context.createCGImage(scaledImage, from: smallExtent) else {
            return 0.5
        }

        // 计算平均亮度
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let bitmapContext = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return 0.5
        }

        bitmapContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var totalBrightness: Float = 0
        let pixelCount = width * height

        for i in 0..<pixelCount {
            let pixelIndex = i * bytesPerPixel
            let red = Float(pixelData[pixelIndex]) / 255.0
            let green = Float(pixelData[pixelIndex + 1]) / 255.0
            let blue = Float(pixelData[pixelIndex + 2]) / 255.0

            // 使用标准亮度公式
            let brightness = 0.299 * red + 0.587 * green + 0.114 * blue
            totalBrightness += brightness
        }

        return totalBrightness / Float(pixelCount)
    }
}