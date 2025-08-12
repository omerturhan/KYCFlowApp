import SwiftUI

struct FormFieldView: View {
    let field: FormField
    @Binding var fieldState: FormFieldState

    var body: some View {
        InputFieldView(
            field: field,
            value: Binding(
                get: {
                    // Convert the value to string for display
                    if let stringValue = fieldState.value as? String {
                        return stringValue
                    } else if let intValue = fieldState.value as? Int {
                        return String(intValue)
                    } else if let doubleValue = fieldState.value as? Double {
                        return String(doubleValue)
                    }
                    return ""
                },
                set: {
                    // Store the value based on field type
                    switch field.type {
                        case .text, .date:
                            fieldState.value = $0
                        case .number:
                        // Store as string but validate it's numeric
                        fieldState.value = $0.filter { $0.isNumber }
                    }
                }
            ),
            error: fieldState.error,
            isLoading: fieldState.isLoading
        )
    }
}

// MARK: - Preview Provider

// swiftlint:disable closure_body_length
struct FormFieldView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Text field
            FormFieldView(
                field: FormField(
                    id: "first_name",
                    label: "First Name",
                    type: .text,
                    required: true,
                    validation: nil,
                    dataSource: nil,
                    readOnly: false
                ),
                fieldState: .constant(FormFieldState(
                    value: "John",
                    error: nil,
                    isLoading: false,
                    isReadOnly: false
                ))
            )

            // Number field with error
            FormFieldView(
                field: FormField(
                    id: "age",
                    label: "Age",
                    type: .number,
                    required: true,
                    validation: nil,
                    dataSource: nil,
                    readOnly: false
                ),
                fieldState: .constant(FormFieldState(
                    value: "17",
                    error: "Must be at least 18 years old",
                    isLoading: false,
                    isReadOnly: false
                ))
            )

            // Date field read-only
            FormFieldView(
                field: FormField(
                    id: "birth_date",
                    label: "Birth Date",
                    type: .date,
                    required: true,
                    validation: nil,
                    dataSource: "api",
                    readOnly: true
                ),
                fieldState: .constant(FormFieldState(
                    value: "1985-03-15",
                    error: nil,
                    isLoading: false,
                    isReadOnly: true
                ))
            )

            // Loading field
            FormFieldView(
                field: FormField(
                    id: "username",
                    label: "Username",
                    type: .text,
                    required: false,
                    validation: nil,
                    dataSource: nil,
                    readOnly: false
                ),
                fieldState: .constant(FormFieldState(
                    value: "",
                    error: nil,
                    isLoading: true,
                    isReadOnly: false
                ))
            )
        }
        .padding()
    }
}
// swiftlint:enable closure_body_length
