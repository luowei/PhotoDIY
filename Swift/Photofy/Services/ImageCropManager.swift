import UIKit
import CoreImage

class ImageCropManager: ObservableObject {
    static let shared = ImageCropManager()

    private init() {}

    // MARK: - 图片裁剪
    func cropImage(_ image: UIImage, to cropRect: CGRect, imageViewSize: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.performCrop(image: image, cropRect: cropRect, imageViewSize: imageViewSize)
                continuation.resume(returning: result)
            }
        }
    }

    // 重载方法：直接使用图片坐标进行裁剪（用于新的CropView）
    func cropImage(_ image: UIImage, to cropRect: CGRect) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.performDirectCrop(image: image, cropRect: cropRect)
                continuation.resume(returning: result)
            }
        }
    }

    private func performCrop(image: UIImage, cropRect: CGRect, imageViewSize: CGSize) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        // 计算图片在显示视图中的实际位置和大小
        let imageSize = image.size
        let aspectRatio = imageSize.width / imageSize.height
        let viewAspectRatio = imageViewSize.width / imageViewSize.height

        var displayedImageRect: CGRect

        if aspectRatio > viewAspectRatio {
            // 图片较宽，以宽度为准
            let displayedHeight = imageViewSize.width / aspectRatio
            displayedImageRect = CGRect(
                x: 0,
                y: (imageViewSize.height - displayedHeight) / 2,
                width: imageViewSize.width,
                height: displayedHeight
            )
        } else {
            // 图片较高，以高度为准
            let displayedWidth = imageViewSize.height * aspectRatio
            displayedImageRect = CGRect(
                x: (imageViewSize.width - displayedWidth) / 2,
                y: 0,
                width: displayedWidth,
                height: imageViewSize.height
            )
        }

        // 将裁剪区域从视图坐标转换为图片坐标
        let scaleX = imageSize.width / displayedImageRect.width
        let scaleY = imageSize.height / displayedImageRect.height

        let imageCropRect = CGRect(
            x: max(0, (cropRect.minX - displayedImageRect.minX) * scaleX),
            y: max(0, (cropRect.minY - displayedImageRect.minY) * scaleY),
            width: min(imageSize.width, cropRect.width * scaleX),
            height: min(imageSize.height, cropRect.height * scaleY)
        )

        // 执行裁剪
        guard let croppedCGImage = cgImage.cropping(to: imageCropRect) else { return nil }

        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    private func performDirectCrop(image: UIImage, cropRect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        // 确保裁剪区域在图片范围内
        let imageBounds = CGRect(origin: .zero, size: image.size)
        let validCropRect = cropRect.intersection(imageBounds)

        guard !validCropRect.isEmpty else { return nil }

        // 执行裁剪
        guard let croppedCGImage = cgImage.cropping(to: validCropRect) else { return nil }

        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - 智能裁剪建议
    func suggestCropRectangles(for image: UIImage) async -> [CropSuggestion] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                var suggestions: [CropSuggestion] = []

                // 添加标准比例的裁剪建议
                suggestions.append(contentsOf: self.createStandardCropSuggestions())

                // TODO: 可以结合AI分析图片内容来提供智能建议

                continuation.resume(returning: suggestions)
            }
        }
    }

    private func createStandardCropSuggestions() -> [CropSuggestion] {
        return [
            CropSuggestion(
                name: "原始比例",
                aspectRatio: nil,
                rect: CGRect(x: 0.05, y: 0.05, width: 0.9, height: 0.9)
            ),
            CropSuggestion(
                name: "正方形 1:1",
                aspectRatio: 1.0,
                rect: CGRect(x: 0.1, y: 0.2, width: 0.8, height: 0.6)
            ),
            CropSuggestion(
                name: "Instagram 4:5",
                aspectRatio: 4.0/5.0,
                rect: CGRect(x: 0.15, y: 0.1, width: 0.7, height: 0.8)
            ),
            CropSuggestion(
                name: "宽屏 16:9",
                aspectRatio: 16.0/9.0,
                rect: CGRect(x: 0.05, y: 0.3, width: 0.9, height: 0.4)
            ),
            CropSuggestion(
                name: "经典 3:2",
                aspectRatio: 3.0/2.0,
                rect: CGRect(x: 0.1, y: 0.25, width: 0.8, height: 0.5)
            ),
            CropSuggestion(
                name: "竖屏 9:16",
                aspectRatio: 9.0/16.0,
                rect: CGRect(x: 0.3, y: 0.05, width: 0.4, height: 0.9)
            )
        ]
    }

    // MARK: - 旋转和翻转
    func rotateImage(_ image: UIImage, degrees: CGFloat) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.performRotation(image: image, degrees: degrees)
                continuation.resume(returning: result)
            }
        }
    }

    private func performRotation(image: UIImage, degrees: CGFloat) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let radians = degrees * .pi / 180
        let rotatedSize = CGSize(
            width: abs(image.size.width * cos(radians)) + abs(image.size.height * sin(radians)),
            height: abs(image.size.width * sin(radians)) + abs(image.size.height * cos(radians))
        )

        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: radians)
        context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)

        image.draw(in: CGRect(origin: .zero, size: image.size))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage
    }

    func flipImage(_ image: UIImage, horizontally: Bool) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.performFlip(image: image, horizontally: horizontally)
                continuation.resume(returning: result)
            }
        }
    }

    private func performFlip(image: UIImage, horizontally: Bool) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        if horizontally {
            context.translateBy(x: image.size.width, y: 0)
            context.scaleBy(x: -1, y: 1)
        } else {
            context.translateBy(x: 0, y: image.size.height)
            context.scaleBy(x: 1, y: -1)
        }

        image.draw(in: CGRect(origin: .zero, size: image.size))

        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return flippedImage
    }
}

// MARK: - 裁剪建议数据模型
struct CropSuggestion: Identifiable {
    let id = UUID()
    let name: String
    let aspectRatio: CGFloat?
    let rect: CGRect

    var icon: String {
        switch name {
        case "正方形 1:1": return "square"
        case "Instagram 4:5": return "rectangle.portrait"
        case "宽屏 16:9": return "rectangle"
        case "经典 3:2": return "rectangle.landscape"
        case "竖屏 9:16": return "rectangle.portrait"
        default: return "crop"
        }
    }
}