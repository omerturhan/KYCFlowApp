import Foundation

struct FormFieldState: Equatable {
    var value: Any?
    var error: String?
    var isLoading: Bool
    var isReadOnly: Bool
    
    init(
        value: Any? = nil,
        error: String? = nil,
        isLoading: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.value = value
        self.error = error
        self.isLoading = isLoading
        self.isReadOnly = isReadOnly
    }
    
    var hasError: Bool {
        error != nil
    }
    
    var isValid: Bool {
        error == nil
    }
    
    // Custom equality since Any? cannot be directly compared
    static func == (lhs: FormFieldState, rhs: FormFieldState) -> Bool {
        // Compare all properties except value
        let baseEqual = lhs.error == rhs.error &&
                       lhs.isLoading == rhs.isLoading &&
                       lhs.isReadOnly == rhs.isReadOnly
        
        // Compare values based on their types
        switch (lhs.value, rhs.value) {
            case (nil, nil):
                return baseEqual
            case let (lhsVal as String, rhsVal as String):
                return baseEqual && lhsVal == rhsVal
            case let (lhsVal as Int, rhsVal as Int):
                return baseEqual && lhsVal == rhsVal
            case let (lhsVal as Double, rhsVal as Double):
                return baseEqual && lhsVal == rhsVal
            case let (lhsVal as Bool, rhsVal as Bool):
                return baseEqual && lhsVal == rhsVal
            case let (lhsVal as Date, rhsVal as Date):
                return baseEqual && lhsVal == rhsVal
            default:
                return false
        }
    }
}

// Type alias for form state dictionary
typealias FormState = [String: FormFieldState]

// Extension to help with form state management
extension Dictionary where Key == String, Value == FormFieldState {
    
    mutating func updateValue(for fieldId: String, value: Any?) {
        if var state = self[fieldId] {
            state.value = value
            state.error = nil // Clear error when value changes
            self[fieldId] = state
        } else {
            self[fieldId] = FormFieldState(value: value)
        }
    }
    
    mutating func setError(for fieldId: String, error: String?) {
        if var state = self[fieldId] {
            state.error = error
            self[fieldId] = state
        } else {
            self[fieldId] = FormFieldState(error: error)
        }
    }
    
    mutating func setLoading(for fieldId: String, isLoading: Bool) {
        if var state = self[fieldId] {
            state.isLoading = isLoading
            self[fieldId] = state
        } else {
            self[fieldId] = FormFieldState(isLoading: isLoading)
        }
    }
    
    func hasErrors() -> Bool {
        self.values.contains { $0.hasError }
    }
    
    func isValid() -> Bool {
        !hasErrors()
    }
    
    func getValue(for fieldId: String) -> Any? {
        self[fieldId]?.value
    }
    
    func getStringValue(for fieldId: String) -> String? {
        getValue(for: fieldId) as? String
    }
    
    func getIntValue(for fieldId: String) -> Int? {
        getValue(for: fieldId) as? Int
    }
    
    func getDoubleValue(for fieldId: String) -> Double? {
        getValue(for: fieldId) as? Double
    }
    
    func getDateValue(for fieldId: String) -> Date? {
        getValue(for: fieldId) as? Date
    }
}
