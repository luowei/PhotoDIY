import UIKit
import Social

// MARK: - 分享服务协议
protocol SharingService {
    func shareImage(_ image: UIImage, text: String)
    func shareToInstagram(_ image: UIImage)
    func shareImageWithCustomOptions(_ image: UIImage, text: String, excludedTypes: [UIActivity.ActivityType])
}

// MARK: - 原生分享服务实现
class NativeSharingService: SharingService {

    // MARK: - 通用分享
    func shareImage(_ image: UIImage, text: String) {
        shareImageWithCustomOptions(image, text: text, excludedTypes: [])
    }

    func shareImageWithCustomOptions(_ image: UIImage, text: String, excludedTypes: [UIActivity.ActivityType]) {
        let activityItems: [Any] = [image, text]

        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: [InstagramStoryActivity()]
        )

        // 排除特定分享类型
        activityViewController.excludedActivityTypes = excludedTypes

        // iPad适配
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = topViewController()?.view
            popover.sourceRect = CGRect(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        // 分享完成回调
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                print("分享成功: \(activityType?.rawValue ?? "Unknown")")
            } else if let error = error {
                print("分享失败: \(error.localizedDescription)")
            }
        }

        topViewController()?.present(activityViewController, animated: true)
    }

    // MARK: - Instagram分享
    func shareToInstagram(_ image: UIImage) {
        guard let instagramURL = URL(string: "instagram://app") else {
            // Instagram未安装，使用通用分享
            shareImage(image, text: "Created with Photofy")
            return
        }

        if UIApplication.shared.canOpenURL(instagramURL) {
            // Instagram已安装，使用Instagram Stories API
            shareToInstagramStories(image)
        } else {
            // 降级到通用分享
            shareImage(image, text: "Created with Photofy")
        }
    }

    // MARK: - 私有方法
    private func shareToInstagramStories(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else { return }

        // 保存到临时文件
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("photofy_share.jpg")

        do {
            try imageData.write(to: tempURL)

            // 使用Instagram Stories分享
            let storyShareURL = URL(string: "instagram-stories://share")!

            if UIApplication.shared.canOpenURL(storyShareURL) {
                let pasteboardItems = [
                    ["com.instagram.sharedSticker.backgroundImage": imageData]
                ]
                UIPasteboard.general.setItems(pasteboardItems)
                UIApplication.shared.open(storyShareURL)
            }
        } catch {
            print("Failed to share to Instagram: \(error)")
        }
    }

    private func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }

        var topViewController = window.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }

        return topViewController
    }
}

// MARK: - 自定义Instagram活动
class InstagramStoryActivity: UIActivity {

    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("com.photofy.instagram.story")
    }

    override var activityTitle: String? {
        return "Instagram Story"
    }

    override var activityImage: UIImage? {
        return UIImage(systemName: "camera.fill")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        guard let instagramURL = URL(string: "instagram://app") else { return false }
        return UIApplication.shared.canOpenURL(instagramURL) &&
               activityItems.contains { $0 is UIImage }
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        for item in activityItems {
            if let image = item as? UIImage {
                shareToInstagramStories(image)
                break
            }
        }
    }

    private func shareToInstagramStories(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            activityDidFinish(false)
            return
        }

        let pasteboardItems = [
            ["com.instagram.sharedSticker.backgroundImage": imageData]
        ]
        UIPasteboard.general.setItems(pasteboardItems)

        if let url = URL(string: "instagram-stories://share") {
            UIApplication.shared.open(url) { [weak self] success in
                self?.activityDidFinish(success)
            }
        } else {
            activityDidFinish(false)
        }
    }
}