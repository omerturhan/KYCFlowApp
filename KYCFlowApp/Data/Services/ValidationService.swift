import Foundation

protocol ValidationServiceProtocol {
    func validate(value: Any?, rule: ValidationRule) -> ValidationResult
    func validateField(_ field: FormField, value: Any?) -> ValidationResult
    func validateAllRules(value: Any?, rules: [ValidationRule]) -> ValidationResult
}

final class ValidationService: ValidationServiceProtocol {
    func validate(value: Any?, rule: ValidationRule) -> ValidationResult {
        switch rule.type {
            case .required:
                return validateRequired(value: value, message: rule.message)
            case .regex:
                return validateRegex(value: value, pattern: rule.value ?? "", message: rule.message)
            case .minLength:
                return validateMinLength(value: value, minLength: rule.value ?? "0", message: rule.message)
            case .maxLength:
                return validateMaxLength(value: value, maxLength: rule.value ?? "0", message: rule.message)
            case .minValue:
                return validateMinValue(value: value, minValue: rule.value ?? "0", message: rule.message)
            case .maxValue:
                return validateMaxValue(value: value, maxValue: rule.value ?? "0", message: rule.message)
        }
    }
    
    func validateField(_ field: FormField, value: Any?) -> ValidationResult {
        // Check required first
        if field.required {
            let requiredResult = validateRequired(value: value, message: "This field is required")
            if !requiredResult.isValid {
                return requiredResult
            }
        }
        
        // If field has validation rules, validate them
        if let rules = field.validation {
            return validateAllRules(value: value, rules: rules)
        }
        
        return .valid
    }
    
    func validateAllRules(value: Any?, rules: [ValidationRule]) -> ValidationResult {
        for rule in rules {
            let result = validate(value: value, rule: rule)
            if !result.isValid {
                return result
            }
        }
        return .valid
    }
    
    // MARK: - Private validation methods
    
    private func validateRequired(value: Any?, message: String?) -> ValidationResult {
        let defaultMessage = "This field is required"
        
        if let stringValue = value as? String {
            if !stringValue.isEmpty {
                return .valid
            } else {
                return .invalid(message ?? defaultMessage)
            }
        }
        
        if value != nil && !(value is NSNull) {
            return .valid
        }
        
        return .invalid(message ?? defaultMessage)
    }
    
    private func validateRegex(value: Any?, pattern: String, message: String?) -> ValidationResult {
        guard let stringValue = value as? String else {
            // If regex validation is applied, the value must be a string
            return .invalid(message ?? "Invalid format - expected text value")
        }
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: stringValue.utf16.count)
            
            if regex.firstMatch(in: stringValue, options: [], range: range) != nil {
                return .valid
            } else {
                return .invalid(message ?? "Invalid format")
            }
        } catch {
            return .invalid("Invalid regex pattern")
        }
    }
    
    private func validateMinLength(value: Any?, minLength: String, message: String?) -> ValidationResult {
        guard let stringValue = value as? String else {
            // Min length validation requires a string value
            return .invalid(message ?? "Invalid value - expected text")
        }
        
        guard let min = Int(minLength) else {
            // Invalid min length parameter
            return .invalid("Invalid validation configuration")
        }
        
        if stringValue.count >= min {
            return .valid
        }
        
        return .invalid(message ?? "Must be at least \(min) characters")
    }
    
    private func validateMaxLength(value: Any?, maxLength: String, message: String?) -> ValidationResult {
        guard let stringValue = value as? String else {
            // Max length validation requires a string value
            return .invalid(message ?? "Invalid value - expected text")
        }
        
        guard let max = Int(maxLength) else {
            // Invalid max length parameter
            return .invalid("Invalid validation configuration")
        }
        
        if stringValue.count <= max {
            return .valid
        }
        
        return .invalid(message ?? "Must be at most \(max) characters")
    }
    
    private func validateMinValue(value: Any?, minValue: String, message: String?) -> ValidationResult {
        // First try to parse the validation parameter
        guard let minDouble = Double(minValue) else {
            return .invalid("Invalid validation configuration")
        }
        
        if let intValue = value as? Int {
            if Double(intValue) >= minDouble {
                return .valid
            }
            return .invalid(message ?? "Must be at least \(Int(minDouble))")
        }
        
        if let doubleValue = value as? Double {
            if doubleValue >= minDouble {
                return .valid
            }
            return .invalid(message ?? "Must be at least \(minDouble)")
        }
        
        // Min value validation requires a numeric value
        return .invalid(message ?? "Invalid value - expected number")
    }
    
    private func validateMaxValue(value: Any?, maxValue: String, message: String?) -> ValidationResult {
        // First try to parse the validation parameter
        guard let maxDouble = Double(maxValue) else {
            return .invalid("Invalid validation configuration")
        }
        
        if let intValue = value as? Int {
            if Double(intValue) <= maxDouble {
                return .valid
            }
            return .invalid(message ?? "Must be at most \(Int(maxDouble))")
        }
        
        if let doubleValue = value as? Double {
            if doubleValue <= maxDouble {
                return .valid
            }
            return .invalid(message ?? "Must be at most \(maxDouble)")
        }
        
        // Max value validation requires a numeric value
        return .invalid(message ?? "Invalid value - expected number")
    }
}
