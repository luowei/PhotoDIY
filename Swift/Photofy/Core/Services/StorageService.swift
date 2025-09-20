import UIKit
import Photos
import CoreData

// MARK: - 存储服务协议
protocol StorageService {
    func saveImageToPhotoLibrary(_ image: UIImage) async throws
    func saveProject(_ project: EditingProject) async throws
    func loadProjects() async throws -> [EditingProject]
    func deleteProject(_ project: EditingProject) async throws
}

// MARK: - Core Data存储服务实现
class CoreDataStorageService: StorageService {

    // MARK: - Photo Library Operations
    func saveImageToPhotoLibrary(_ image: UIImage) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized || status == .limited else {
                    continuation.resume(throwing: StorageError.photoLibraryAccessDenied)
                    return
                }

                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: error ?? StorageError.saveImageFailed)
                    }
                }
            }
        }
    }

    // MARK: - Project Operations
    func saveProject(_ project: EditingProject) async throws {
        let context = PersistenceController.shared.container.newBackgroundContext()

        try await context.perform {
            // 查找现有项目或创建新项目
            let request: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", project.id.uuidString)

            let existingProjects = try context.fetch(request)
            let entity: ProjectEntity

            if let existing = existingProjects.first {
                entity = existing
            } else {
                entity = ProjectEntity(context: context)
                entity.id = project.id.uuidString
                entity.createdAt = project.createdAt
            }

            // 更新项目数据
            entity.name = project.name
            entity.updatedAt = Date()
            entity.originalImageData = project.originalImageData
            entity.currentImageData = project.currentImageData

            // 保存滤镜设置
            if let filterData = try? JSONEncoder().encode(project.filterSettings) {
                entity.filterSettingsData = filterData
            }

            try context.save()
        }
    }

    func loadProjects() async throws -> [EditingProject] {
        let context = PersistenceController.shared.container.viewContext

        return try await context.perform {
            let request: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

            let entities = try context.fetch(request)

            return entities.compactMap { entity in
                guard let idString = entity.id,
                      let id = UUID(uuidString: idString),
                      let name = entity.name,
                      let createdAt = entity.createdAt else {
                    return nil
                }

                var filterSettings: [FilterSetting] = []
                if let filterData = entity.filterSettingsData {
                    filterSettings = (try? JSONDecoder().decode([FilterSetting].self, from: filterData)) ?? []
                }

                var project = EditingProject(name: name)
                project.originalImageData = entity.originalImageData
                project.currentImageData = entity.currentImageData
                project.filterSettings = filterSettings

                return project
            }
        }
    }

    func deleteProject(_ project: EditingProject) async throws {
        let context = PersistenceController.shared.container.newBackgroundContext()

        try await context.perform {
            let request: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", project.id.uuidString)

            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }

            try context.save()
        }
    }
}

// MARK: - 存储错误
enum StorageError: LocalizedError {
    case photoLibraryAccessDenied
    case saveImageFailed
    case projectNotFound
    case corruptedData

    var errorDescription: String? {
        switch self {
        case .photoLibraryAccessDenied:
            return "Photo library access denied"
        case .saveImageFailed:
            return "Failed to save image to photo library"
        case .projectNotFound:
            return "Project not found"
        case .corruptedData:
            return "Corrupted project data"
        }
    }
}

// MARK: - 持久化控制器
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PhotofyModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // 配置Core Data
        container.persistentStoreDescriptions.forEach { storeDescription in
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Core Data Stack
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Core Data Entities (需要在.xcdatamodeld中定义)

// ProjectEntity
@objc(ProjectEntity)
public class ProjectEntity: NSManagedObject {

}

extension ProjectEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectEntity> {
        return NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var originalImageData: Data?
    @NSManaged public var currentImageData: Data?
    @NSManaged public var filterSettingsData: Data?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
}