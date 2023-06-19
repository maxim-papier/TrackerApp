import Foundation

@propertyWrapper
final class Observable<Value> {
    
    var wrappedValue: Value {
        didSet {
            observer?(wrappedValue)
        }
    }
    
    private var observer: ((Value) -> Void)?

    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    func observe(_ observer: @escaping (Value) -> Void) {
        self.observer = observer
    }

    var projectedValue: Observable<Value> {
        return self
    }
}
