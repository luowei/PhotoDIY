import Foundation

// MARK: - 依赖注入协议
protocol DIContainerProtocol {
    func register()
    func resolve<T>(_ type: T.Type) -> T?
}

// MARK: - 依赖注入容器
class DIContainer: DIContainerProtocol {
    static let shared = DIContainer()

    private var services: [String: Any] = [:]

    private init() {}

    // MARK: - 注册服务
    func register() {
        // 图像处理服务
        register(ImageProcessingService.self) {
            CoreImageProcessor()
        }

        // 滤镜服务
        register(FilterService.self) {
            FilterManager()
        }

        // 存储服务
        register(StorageService.self) {
            CoreDataStorageService()
        }

        // 分享服务
        register(SharingService.self) {
            NativeSharingService()
        }

        // 相册服务
        register(PhotoLibraryService.self) {
            PhotoKitService()
        }
    }

    // MARK: - 注册具体服务
    private func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        services[key] = factory()
    }

    // MARK: - 解析服务
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return services[key] as? T
    }
}

// MARK: - 注入属性包装器
@propertyWrapper
struct Injected<T> {
    private let type: T.Type

    init(_ type: T.Type) {
        self.type = type
    }

    var wrappedValue: T {
        guard let service = DIContainer.shared.resolve(type) else {
            fatalError("Failed to resolve service of type \(type)")
        }
        return service
    }
}