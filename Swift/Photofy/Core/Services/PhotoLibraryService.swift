import Foundation
import Photos
import UIKit

// MARK: - 相册服务协议
protocol PhotoLibraryService {
    func requestPhotoLibraryPermission() async -> PHAuthorizationStatus
    func fetchRecentPhotos(limit: Int) async throws -> [PhotoAsset]
    func loadImage(from asset: PhotoAsset, targetSize: CGSize) async throws -> UIImage?
    func loadFullResolutionImage(from asset: PhotoAsset) async throws -> UIImage?
}

// MARK: - PhotoKit服务实现
class PhotoKitService: PhotoLibraryService {

    // MARK: - 权限管理
    func requestPhotoLibraryPermission() async -> PHAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                continuation.resume(returning: status)
            }
        }
    }

    // MARK: - 获取最近照片
    func fetchRecentPhotos(limit: Int = 100) async throws -> [PhotoAsset] {
        let status = await requestPhotoLibraryPermission()
        guard status == .authorized || status == .limited else {
            throw PhotoLibraryError.permissionDenied
        }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = limit

                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

                var assets: [PhotoAsset] = []
                fetchResult.enumerateObjects { (asset, _, _) in
                    assets.append(PhotoAsset(phAsset: asset))
                }

                continuation.resume(returning: assets)
            }
        }
    }

    // MARK: - 加载图片
    func loadImage(from asset: PhotoAsset, targetSize: CGSize = CGSize(width: 300, height: 300)) async throws -> UIImage? {
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true

            PHImageManager.default().requestImage(
                for: asset.phAsset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: image)
                }
            }
        }
    }

    func loadFullResolutionImage(from asset: PhotoAsset) async throws -> UIImage? {
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            PHImageManager.default().requestImage(
                for: asset.phAsset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .default,
                options: options
            ) { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: image)
                }
            }
        }
    }

    // MARK: - 获取照片元数据
    func getPhotoMetadata(from asset: PhotoAsset) -> PhotoMetadata {
        let phAsset = asset.phAsset
        return PhotoMetadata(
            localIdentifier: phAsset.localIdentifier,
            creationDate: phAsset.creationDate,
            modificationDate: phAsset.modificationDate,
            location: phAsset.location,
            pixelWidth: phAsset.pixelWidth,
            pixelHeight: phAsset.pixelHeight,
            duration: phAsset.duration,
            mediaType: phAsset.mediaType,
            mediaSubtypes: phAsset.mediaSubtypes
        )
    }

    // MARK: - 创建相册
    func createAlbum(named title: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
            }) { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? PhotoLibraryError.createAlbumFailed)
                }
            }
        }
    }

    // MARK: - 保存图片到指定相册
    func saveImage(_ image: UIImage, to albumTitle: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                // 创建图片资源
                let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)

                // 查找相册
                let albumFetchResult = PHAssetCollection.fetchAssetCollections(
                    with: .album,
                    subtype: .any,
                    options: nil
                )

                var targetAlbum: PHAssetCollection?
                albumFetchResult.enumerateObjects { album, _, stop in
                    if album.localizedTitle == albumTitle {
                        targetAlbum = album
                        stop.pointee = true
                    }
                }

                // 如果相册不存在，创建新相册
                if targetAlbum == nil {
                    let albumCreationRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumTitle)
                    targetAlbum = albumCreationRequest.placeholderForCreatedAssetCollection
                }

                // 将图片添加到相册
                if let album = targetAlbum,
                   let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                   let placeholder = creationRequest.placeholderForCreatedAsset {
                    albumChangeRequest.addAssets([placeholder] as NSArray)
                }

            }) { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? PhotoLibraryError.saveImageFailed)
                }
            }
        }
    }
}

// MARK: - 照片资源模型
struct PhotoAsset: Identifiable, Hashable {
    let id: String
    let phAsset: PHAsset

    init(phAsset: PHAsset) {
        self.id = phAsset.localIdentifier
        self.phAsset = phAsset
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - 照片元数据
struct PhotoMetadata {
    let localIdentifier: String
    let creationDate: Date?
    let modificationDate: Date?
    let location: CLLocation?
    let pixelWidth: Int
    let pixelHeight: Int
    let duration: TimeInterval
    let mediaType: PHAssetMediaType
    let mediaSubtypes: PHAssetMediaSubtype

    var aspectRatio: CGFloat {
        guard pixelHeight > 0 else { return 1.0 }
        return CGFloat(pixelWidth) / CGFloat(pixelHeight)
    }

    var isPortrait: Bool {
        return pixelHeight > pixelWidth
    }

    var isLandscape: Bool {
        return pixelWidth > pixelHeight
    }

    var isSquare: Bool {
        return pixelWidth == pixelHeight
    }
}

// MARK: - 相册错误
enum PhotoLibraryError: LocalizedError {
    case permissionDenied
    case assetNotFound
    case loadImageFailed
    case saveImageFailed
    case createAlbumFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Photo library permission denied"
        case .assetNotFound:
            return "Photo asset not found"
        case .loadImageFailed:
            return "Failed to load image from photo library"
        case .saveImageFailed:
            return "Failed to save image to photo library"
        case .createAlbumFailed:
            return "Failed to create album"
        }
    }
}