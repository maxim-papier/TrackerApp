enum Event {
    case open(screen: Scene)
    case close(screen: Scene)
    case click(screen: Scene, item: String)
    
    var eventName: String {
        switch self {
        case .open: return "open"
        case .close: return "close"
        case .click: return "click"
        }
    }
}

enum Scene: String {
    case main = "Main"
}
