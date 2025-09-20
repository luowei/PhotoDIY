import SwiftUI
import UIKit

struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    let onImageChanged: ((UIImage) -> Void)?

    init(image: UIImage, scale: Binding<CGFloat> = .constant(1.0), offset: Binding<CGSize> = .constant(.zero), onImageChanged: ((UIImage) -> Void)? = nil) {
        self.image = image
        self._scale = scale
        self._offset = offset
        self.onImageChanged = onImageChanged
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let imageView = UIImageView(image: image)

        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 0.5
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        scrollView.addSubview(imageView)

        // 设置自动布局
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        if let imageView = uiView.subviews.first as? UIImageView {
            imageView.image = image
        }
        uiView.setZoomScale(scale, animated: false)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: ZoomableImageView

        init(_ parent: ZoomableImageView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            parent.scale = scrollView.zoomScale
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.offset = CGSize(width: scrollView.contentOffset.x, height: scrollView.contentOffset.y)
        }
    }
}