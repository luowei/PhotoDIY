import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Metal

// MARK: - 图像处理服务协议
protocol ImageProcessingService {
    func applyFilter(_ filterType: FilterType, to image: UIImage, intensity: Float) async -> UIImage?
    func processImageAsync(_ image: UIImage, with filters: [FilterSetting]) async -> UIImage?
    func generateFilterPreview(_ filterType: FilterType, from image: UIImage) async -> UIImage?
    func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage?
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage?
}

// MARK: - Core Image处理器实现
class CoreImageProcessor: ImageProcessingService {
    private let context: CIContext
    private let device: MTLDevice?

    init() {
        // 优先使用Metal设备以获得最佳性能
        self.device = MTLCreateSystemDefaultDevice()
        if let device = device {
            self.context = CIContext(mtlDevice: device)
        } else {
            self.context = CIContext()
        }
    }

    // MARK: - 应用滤镜
    func applyFilter(_ filterType: FilterType, to image: UIImage, intensity: Float) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let ciImage = CIImage(image: image) else {
                    continuation.resume(returning: nil)
                    return
                }

                let filteredImage = self.processFilter(filterType, on: ciImage, intensity: intensity)
                let result = self.renderImage(filteredImage, size: image.size)
                continuation.resume(returning: result)
            }
        }
    }

    // MARK: - 批量处理滤镜
    func processImageAsync(_ image: UIImage, with filters: [FilterSetting]) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let ciImage = CIImage(image: image) else {
                    continuation.resume(returning: nil)
                    return
                }

                var processedImage = ciImage
                for filterSetting in filters {
                    if let filterType = FilterType(rawValue: filterSetting.filterType) {
                        processedImage = self.processFilter(filterType, on: processedImage, intensity: filterSetting.intensity)
                    }
                }

                let result = self.renderImage(processedImage, size: image.size)
                continuation.resume(returning: result)
            }
        }
    }

    // MARK: - 生成滤镜预览
    func generateFilterPreview(_ filterType: FilterType, from image: UIImage) async -> UIImage? {
        // 生成小尺寸预览以提高性能
        let previewSize = CGSize(width: 150, height: 150)
        guard let resizedImage = resizeImage(image, to: previewSize) else { return nil }
        return await applyFilter(filterType, to: resizedImage, intensity: filterType.defaultIntensity)
    }

    // MARK: - 裁剪图像
    func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - 调整图像大小
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - 私有方法 - 处理具体滤镜
    private func processFilter(_ filterType: FilterType, on image: CIImage, intensity: Float) -> CIImage {
        switch filterType {
        case .brightness:
            return adjustBrightness(image, value: intensity)
        case .contrast:
            return adjustContrast(image, value: intensity)
        case .saturation:
            return adjustSaturation(image, value: intensity)
        case .hue:
            return adjustHue(image, value: intensity)
        case .warmth:
            return adjustWarmth(image, value: intensity)
        case .highlights:
            return adjustHighlights(image, value: intensity)
        case .shadows:
            return adjustShadows(image, value: intensity)
        case .vintage:
            return applyVintageFilter(image, intensity: intensity)
        case .blackAndWhite:
            return applyBlackAndWhiteFilter(image, intensity: intensity)
        case .sepia:
            return applySepiaFilter(image, intensity: intensity)
        case .vignette:
            return applyVignetteFilter(image, intensity: intensity)
        case .dramatic:
            return applyDramaticFilter(image, intensity: intensity)
        case .vivid:
            return applyVividFilter(image, intensity: intensity)
        case .beauty:
            return applyBeautyFilter(image, intensity: intensity)
        case .smooth:
            return applySmoothFilter(image, intensity: intensity)
        case .sharpen:
            return applySharpenFilter(image, intensity: intensity)
        case .gaussianBlur:
            return applyGaussianBlur(image, intensity: intensity)
        case .motionBlur:
            return applyMotionBlur(image, intensity: intensity)
        case .radialBlur:
            return applyRadialBlur(image, intensity: intensity)
        }
    }

    // MARK: - 基础调节滤镜
    private func adjustBrightness(_ image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.brightness = value
        return filter.outputImage ?? image
    }

    private func adjustContrast(_ image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.contrast = 1.0 + value
        return filter.outputImage ?? image
    }

    private func adjustSaturation(_ image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.saturation = value
        return filter.outputImage ?? image
    }

    private func adjustHue(_ image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.hueAdjust()
        filter.inputImage = image
        filter.angle = value * .pi / 180.0 // 转换为弧度
        return filter.outputImage ?? image
    }

    private func adjustWarmth(_ image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = image
        filter.neutral = CIVector(x: 6500 + Double(value * 1000), y: 0)
        return filter.outputImage ?? image
    }

    private func adjustHighlights(_ image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.highlightShadowAdjust()
        filter.inputImage = image
        filter.highlightAmount = 1.0 + value
        return filter.outputImage ?? image
    }

    private func adjustShadows(_ image: CIImage, value: Float) -> CIImage {
        let filter = CIFilter.highlightShadowAdjust()
        filter.inputImage = image
        filter.shadowAmount = 1.0 + value
        return filter.outputImage ?? image
    }

    // MARK: - 艺术效果滤镜
    private func applyVintageFilter(_ image: CIImage, intensity: Float) -> CIImage {
        // 复合滤镜：棕褐色 + 晕影 + 颜色调整
        var result = image

        // 棕褐色效果
        let sepiaFilter = CIFilter.sepiaTone()
        sepiaFilter.inputImage = result
        sepiaFilter.intensity = intensity * 0.8
        result = sepiaFilter.outputImage ?? result

        // 轻微晕影
        let vignetteFilter = CIFilter.vignette()
        vignetteFilter.inputImage = result
        vignetteFilter.intensity = intensity * 0.5
        vignetteFilter.radius = 1.0
        result = vignetteFilter.outputImage ?? result

        return result
    }

    private func applyBlackAndWhiteFilter(_ image: CIImage, intensity: Float) -> CIImage {
        let filter = CIFilter.colorMonochrome()
        filter.inputImage = image
        filter.color = CIColor.white
        filter.intensity = intensity
        return filter.outputImage ?? image
    }

    private func applySepiaFilter(_ image: CIImage, intensity: Float) -> CIImage {
        let filter = CIFilter.sepiaTone()
        filter.inputImage = image
        filter.intensity = intensity
        return filter.outputImage ?? image
    }

    private func applyVignetteFilter(_ image: CIImage, intensity: Float) -> CIImage {
        let filter = CIFilter.vignette()
        filter.inputImage = image
        filter.intensity = intensity
        filter.radius = 1.0
        return filter.outputImage ?? image
    }

    private func applyDramaticFilter(_ image: CIImage, intensity: Float) -> CIImage {
        // 戏剧性效果：高对比度 + 饱和度
        var result = image

        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = result
        contrastFilter.contrast = 1.0 + (intensity * 0.5)
        contrastFilter.saturation = 1.0 + (intensity * 0.3)
        result = contrastFilter.outputImage ?? result

        return result
    }

    private func applyVividFilter(_ image: CIImage, intensity: Float) -> CIImage {
        let filter = CIFilter.vibrance()
        filter.inputImage = image
        filter.amount = intensity
        return filter.outputImage ?? image
    }

    // MARK: - 美颜滤镜
    private func applyBeautyFilter(_ image: CIImage, intensity: Float) -> CIImage {
        // 美颜效果：平滑 + 亮度调整
        var result = image

        // 高斯模糊用于平滑
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = result
        blurFilter.radius = intensity * 2.0
        let blurred = blurFilter.outputImage ?? result

        // 混合原图和模糊图
        let blendFilter = CIFilter.sourceOverCompositing()
        blendFilter.inputImage = blurred
        blendFilter.backgroundImage = result
        result = blendFilter.outputImage ?? result

        // 轻微亮度调整
        let brightnessFilter = CIFilter.colorControls()
        brightnessFilter.inputImage = result
        brightnessFilter.brightness = intensity * 0.1
        result = brightnessFilter.outputImage ?? result

        return result
    }

    private func applySmoothFilter(_ image: CIImage, intensity: Float) -> CIImage {
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = image
        filter.radius = intensity * 3.0
        return filter.outputImage ?? image
    }

    private func applySharpenFilter(_ image: CIImage, intensity: Float) -> CIImage {
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = image
        filter.sharpness = intensity * 2.0
        return filter.outputImage ?? image
    }

    // MARK: - 模糊滤镜
    private func applyGaussianBlur(_ image: CIImage, intensity: Float) -> CIImage {
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = image
        filter.radius = intensity * 10.0
        return filter.outputImage ?? image
    }

    private func applyMotionBlur(_ image: CIImage, intensity: Float) -> CIImage {
        let filter = CIFilter.motionBlur()
        filter.inputImage = image
        filter.radius = intensity * 15.0
        filter.angle = 0 // 水平运动模糊
        return filter.outputImage ?? image
    }

    private func applyRadialBlur(_ image: CIImage, intensity: Float) -> CIImage {
        // Core Image没有直接的径向模糊，使用变换模拟
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = image
        filter.radius = intensity * 8.0
        return filter.outputImage ?? image
    }

    // MARK: - 渲染图像
    private func renderImage(_ ciImage: CIImage, size: CGSize) -> UIImage? {
        let extent = ciImage.extent
        let scaleX = size.width / extent.width
        let scaleY = size.height / extent.height
        let scale = min(scaleX, scaleY)

        let scaledSize = CGSize(
            width: extent.width * scale,
            height: extent.height * scale
        )

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}