import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Metal
import MetalKit

class ImageFilterManager: ObservableObject {
    static let shared = ImageFilterManager()

    private let context: CIContext
    private let metalDevice: MTLDevice?

    init() {
        // 优先使用Metal设备进行GPU加速
        self.metalDevice = MTLCreateSystemDefaultDevice()

        if let device = metalDevice {
            self.context = CIContext(mtlDevice: device)
        } else {
            self.context = CIContext()
        }
    }

    // MARK: - 滤镜枚举
    enum FilterType: String, CaseIterable {
        case original = "Original"
        case grayscale = "Grayscale"
        case sepia = "Sepia"
        case noir = "Noir"
        case vintage = "Vintage"
        case vivid = "Vivid"
        case dramatic = "Dramatic"
        case mono = "Mono"
        case silvertone = "Silvertone"
        case sketch = "Sketch"
        case emboss = "Emboss"
        case cartoon = "Cartoon"
        case blur = "Blur"
        case sharpen = "Sharpen"
        case edgeDetection = "Edge Detection"
        case pixellate = "Pixellate"
        case kaleidoscope = "Kaleidoscope"
        case bloom = "Bloom"
        case gloom = "Gloom"
        case crystallize = "Crystallize"
        case pointillize = "Pointillize"
        case comicEffect = "Comic Effect"
        case oilPainting = "Oil Painting"
        case watercolor = "Watercolor"
        case blackAndWhite = "Black & White"
        case highContrast = "High Contrast"
        case lowContrast = "Low Contrast"
        case colorInvert = "Color Invert"
        case thermal = "Thermal"
        case xray = "X-Ray"

        var displayName: String {
            return self.rawValue
        }

        var icon: String {
            switch self {
            case .original: return "photo"
            case .grayscale, .noir, .mono, .silvertone, .blackAndWhite: return "circle.lefthalf.filled"
            case .sepia, .vintage: return "photo.fill.on.rectangle.fill"
            case .vivid, .dramatic: return "paintbrush.fill"
            case .sketch: return "pencil.line"
            case .emboss: return "relief"
            case .cartoon, .comicEffect: return "face.smiling"
            case .blur: return "aqi.medium"
            case .sharpen: return "triangle.fill"
            case .edgeDetection: return "square.stack.3d.down.right"
            case .pixellate, .crystallize: return "grid"
            case .kaleidoscope: return "hexagon.fill"
            case .bloom, .gloom: return "sun.max.fill"
            case .pointillize: return "circle.grid.cross.fill"
            case .oilPainting: return "paintbrush.pointed.fill"
            case .watercolor: return "drop.fill"
            case .highContrast, .lowContrast: return "slider.horizontal.3"
            case .colorInvert: return "arrow.2.squarepath"
            case .thermal: return "thermometer.sun.fill"
            case .xray: return "xmark.square.fill"
            }
        }
    }

    // MARK: - 应用滤镜
    func applyFilter(_ filterType: FilterType, to image: UIImage, intensity: Float = 1.0) async -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let filteredImage = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.processFilter(filterType, ciImage: ciImage, intensity: intensity)
                continuation.resume(returning: result)
            }
        }

        return filteredImage
    }

    private func processFilter(_ filterType: FilterType, ciImage: CIImage, intensity: Float) -> UIImage? {
        var outputImage: CIImage = ciImage

        switch filterType {
        case .original:
            outputImage = ciImage

        case .grayscale:
            let filter = CIFilter.colorMonochrome()
            filter.inputImage = ciImage
            filter.color = CIColor.gray
            filter.intensity = intensity
            outputImage = filter.outputImage ?? ciImage

        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.inputImage = ciImage
            filter.intensity = intensity
            outputImage = filter.outputImage ?? ciImage

        case .noir:
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = ciImage
            outputImage = filter.outputImage ?? ciImage

        case .vintage:
            let filter = CIFilter.photoEffectTransfer()
            filter.inputImage = ciImage
            outputImage = filter.outputImage ?? ciImage

        case .vivid:
            guard let filter = CIFilter(name: "CIPhotoEffectVivid") else {
                outputImage = ciImage
                break
            }
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            outputImage = filter.outputImage ?? ciImage

        case .dramatic:
            let filter = CIFilter.photoEffectProcess()
            filter.inputImage = ciImage
            outputImage = filter.outputImage ?? ciImage

        case .mono:
            let filter = CIFilter.photoEffectMono()
            filter.inputImage = ciImage
            outputImage = filter.outputImage ?? ciImage

        case .silvertone:
            let filter = CIFilter.photoEffectTonal()
            filter.inputImage = ciImage
            outputImage = filter.outputImage ?? ciImage

        case .sketch:
            // 组合滤镜创建素描效果
            let edges = CIFilter.edgeWork()
            edges.inputImage = ciImage
            edges.radius = 3.0

            if let edgeImage = edges.outputImage {
                let invert = CIFilter.colorInvert()
                invert.inputImage = edgeImage
                outputImage = invert.outputImage ?? ciImage
            }

        case .emboss:
            let filter = CIFilter.heightFieldFromMask()
            filter.inputImage = ciImage
            filter.radius = 10.0
            outputImage = filter.outputImage ?? ciImage

        case .cartoon:
            // 使用可用的滤镜创建卡通效果
            let edges = CIFilter.edgeWork()
            edges.inputImage = ciImage
            edges.radius = 2.0

            if let edgeImage = edges.outputImage {
                let composite = CIFilter.multiplyBlendMode()
                composite.inputImage = ciImage
                composite.backgroundImage = edgeImage
                outputImage = composite.outputImage ?? ciImage
            }

        case .blur:
            let filter = CIFilter.gaussianBlur()
            filter.inputImage = ciImage
            filter.radius = intensity * 10.0
            outputImage = filter.outputImage ?? ciImage

        case .sharpen:
            let filter = CIFilter.sharpenLuminance()
            filter.inputImage = ciImage
            filter.sharpness = intensity * 2.0
            outputImage = filter.outputImage ?? ciImage

        case .edgeDetection:
            let filter = CIFilter.edgeWork()
            filter.inputImage = ciImage
            filter.radius = intensity * 5.0
            outputImage = filter.outputImage ?? ciImage

        case .pixellate:
            let filter = CIFilter.pixellate()
            filter.inputImage = ciImage
            filter.scale = intensity * 20.0
            outputImage = filter.outputImage ?? ciImage

        case .kaleidoscope:
            let filter = CIFilter.kaleidoscope()
            filter.inputImage = ciImage
            filter.count = Int(intensity * 6) + 3
            filter.angle = 0
            outputImage = filter.outputImage ?? ciImage

        case .bloom:
            let filter = CIFilter.bloom()
            filter.inputImage = ciImage
            filter.radius = intensity * 20.0
            filter.intensity = intensity
            outputImage = filter.outputImage ?? ciImage

        case .gloom:
            let filter = CIFilter.gloom()
            filter.inputImage = ciImage
            filter.radius = intensity * 20.0
            filter.intensity = intensity
            outputImage = filter.outputImage ?? ciImage

        case .crystallize:
            let filter = CIFilter.crystallize()
            filter.inputImage = ciImage
            filter.radius = intensity * 30.0
            outputImage = filter.outputImage ?? ciImage

        case .pointillize:
            let filter = CIFilter.pointillize()
            filter.inputImage = ciImage
            filter.radius = intensity * 20.0
            outputImage = filter.outputImage ?? ciImage

        case .comicEffect:
            let filter = CIFilter.comicEffect()
            filter.inputImage = ciImage
            outputImage = filter.outputImage ?? ciImage

        case .oilPainting:
            // 使用模糊效果模拟油画
            let filter = CIFilter.gaussianBlur()
            filter.inputImage = ciImage
            filter.radius = 2.0
            outputImage = filter.outputImage ?? ciImage

        case .watercolor:
            // 组合多个滤镜创建水彩效果
            let bloom = CIFilter.bloom()
            bloom.inputImage = ciImage
            bloom.radius = 5.0
            bloom.intensity = 0.5
            outputImage = bloom.outputImage ?? ciImage

        case .blackAndWhite:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 0
            filter.contrast = intensity * 0.5 + 1.0
            outputImage = filter.outputImage ?? ciImage

        case .highContrast:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.contrast = intensity * 2.0 + 1.0
            outputImage = filter.outputImage ?? ciImage

        case .lowContrast:
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.contrast = 1.0 - intensity * 0.5
            outputImage = filter.outputImage ?? ciImage

        case .colorInvert:
            let filter = CIFilter.colorInvert()
            filter.inputImage = ciImage
            outputImage = filter.outputImage ?? ciImage

        case .thermal:
            let filter = CIFilter.falseColor()
            filter.inputImage = ciImage
            filter.color0 = CIColor.blue
            filter.color1 = CIColor.red
            outputImage = filter.outputImage ?? ciImage

        case .xray:
            let invert = CIFilter.colorInvert()
            invert.inputImage = ciImage

            if let invertedImage = invert.outputImage {
                let mono = CIFilter.colorMonochrome()
                mono.inputImage = invertedImage
                mono.color = CIColor.white
                mono.intensity = 1.0
                outputImage = mono.outputImage ?? ciImage
            }
        }

        return convertToUIImage(outputImage)
    }

    private func convertToUIImage(_ ciImage: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    // MARK: - 批量应用滤镜（用于预览）
    func generateFilterPreviews(for image: UIImage, size: CGSize = CGSize(width: 100, height: 100)) async -> [FilterType: UIImage] {
        var previews: [FilterType: UIImage] = [:]

        // 先缩放图片以提高性能
        let resizedImage = await resizeImage(image, to: size)

        await withTaskGroup(of: (FilterType, UIImage?).self) { group in
            for filterType in FilterType.allCases {
                group.addTask {
                    let filteredImage = await self.applyFilter(filterType, to: resizedImage, intensity: 1.0)
                    return (filterType, filteredImage)
                }
            }

            for await (filterType, image) in group {
                if let image = image {
                    previews[filterType] = image
                }
            }
        }

        return previews
    }

    private func resizeImage(_ image: UIImage, to size: CGSize) async -> UIImage {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                image.draw(in: CGRect(origin: .zero, size: size))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
                UIGraphicsEndImageContext()
                continuation.resume(returning: resizedImage)
            }
        }
    }
}

// MARK: - 扩展：色彩调整
extension ImageFilterManager {
    func adjustBrightness(_ image: UIImage, value: Float) async -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.brightness = value

        guard let outputImage = filter.outputImage else { return nil }
        return convertToUIImage(outputImage)
    }

    func adjustContrast(_ image: UIImage, value: Float) async -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.contrast = value

        guard let outputImage = filter.outputImage else { return nil }
        return convertToUIImage(outputImage)
    }

    func adjustSaturation(_ image: UIImage, value: Float) async -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = value

        guard let outputImage = filter.outputImage else { return nil }
        return convertToUIImage(outputImage)
    }

    func adjustHue(_ image: UIImage, angle: Float) async -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let filter = CIFilter.hueAdjust()
        filter.inputImage = ciImage
        filter.angle = angle

        guard let outputImage = filter.outputImage else { return nil }
        return convertToUIImage(outputImage)
    }
}