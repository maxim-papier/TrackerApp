import UIKit

struct Tracker {
    var id = UUID()
    let title: String
    let emoji: String
    let color: UIColor
    let day: Set<WeekDay>?
    
    var isPinned: Bool
    var createdAt = Date()
    
    init(
        id: UUID = UUID(),
        title: String,
        emoji: String,
        color: UIColor,
        day: Set<WeekDay>?,
        isPinned: Bool = false,
        createdAt: Date = Date()) {
            self.id = id
            self.title = title
            self.emoji = emoji
            self.color = color
            self.day = day
            self.isPinned = isPinned
            self.createdAt = createdAt
        }
}
