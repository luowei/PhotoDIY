import Foundation
import UIKit

// MARK: - 编辑历史
struct EditingHistory {
    var steps: [UIImage] = []
    var currentIndex: Int = -1

    mutating func add(_ image: UIImage) {
        // 删除当前位置之后的历史
        if currentIndex < steps.count - 1 {
            steps.removeSubrange((currentIndex + 1)...)
        }

        steps.append(image)
        currentIndex = steps.count - 1

        // 限制历史记录数量
        if steps.count > 20 {
            steps.removeFirst()
            currentIndex -= 1
        }
    }

    var canUndo: Bool {
        currentIndex > 0
    }

    var canRedo: Bool {
        currentIndex < steps.count - 1
    }

    mutating func undo() -> UIImage? {
        guard canUndo else { return nil }
        currentIndex -= 1
        return steps[currentIndex]
    }

    mutating func redo() -> UIImage? {
        guard canRedo else { return nil }
        currentIndex += 1
        return steps[currentIndex]
    }
}