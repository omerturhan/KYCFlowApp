import SwiftUI

/// An input field view that handles all field types (text, number, date)
/// with consistent styling and behavior
struct InputFieldView: View {
    let field: FormField
    @Binding var value: String
    let error: String?
    let isLoading: Bool
    
    // Date picker state
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Common label for all field types
            fieldLabel
            
            // Field input based on type
            HStack {
                if field.readOnly {
                    readOnlyField
                } else {
                    editableField
                }
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            // Common error display
            errorView
        }
        .animation(.easeInOut(duration: 0.2), value: error)
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
    }
}

// MARK: - View Components

private extension InputFieldView {
    
    /// Common label with required indicator
    var fieldLabel: some View {
        HStack(alignment: .top) {
            Text(field.label)
                .font(.headline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            
            if field.required {
                Text("*")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
    }
    
    /// Read-only field display
    var readOnlyField: some View {
        Text(displayValue)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.horizontal)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
    
    /// Editable field based on type
    @ViewBuilder
    var editableField: some View {
        switch field.type {
        case .text:
            textInput
        case .number:
            numberInput
        case .date:
            dateInput
        }
    }
    
    /// Text input field
    var textInput: some View {
        TextField(field.label, text: $value)
            .padding(.horizontal)
            .frame(height: 44)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(error != nil ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .disabled(isLoading)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    /// Number input field
    var numberInput: some View {
        TextField(field.label, text: Binding(
            get: { value },
            set: { newValue in
                // Filter to only allow numeric input
                value = newValue.filter { $0.isNumber }
            }
        ))
        .padding(.horizontal)
        .frame(height: 44)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(error != nil ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .keyboardType(.numberPad)
        .disabled(isLoading)
    }
    
    /// Date input field
    var dateInput: some View {
        Button(action: {
            showDatePicker.toggle()
        }) {
            HStack {
                Text(displayValue)
                    .foregroundColor(value.isEmpty ? .gray : .primary)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
            }
            .frame(height: 44)
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(error != nil ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(isLoading)
    }
    
    /// Error message view
    @ViewBuilder
    var errorView: some View {
        if let error = error {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(error.components(separatedBy: "\n"), id: \.self) { errorLine in
                    HStack(alignment: .top, spacing: 4) {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text(errorLine)
                            .font(.caption)
                            .foregroundColor(.red)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .transition(.opacity)
        }
    }
    
    /// Date picker sheet
    var datePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showDatePicker = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        value = DateFormatters.isoFormatter.string(from: selectedDate)
                        showDatePicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let date = DateFormatters.isoFormatter.date(from: value) {
                selectedDate = date
            } else {
                selectedDate = Date()
            }
        }
    }
}

// MARK: - Display Value Logic

private extension InputFieldView {
    
    /// Computed display value based on field type
    var displayValue: String {
        switch field.type {
        case .text:
            return value.isEmpty && field.readOnly ? "-" : value
            
        case .number:
            if value.isEmpty {
                return field.readOnly ? "-" : ""
            }
            return field.readOnly ? formatNumber(value) : value
            
        case .date:
            if value.isEmpty {
                return field.readOnly ? "-" : "Select date"
            }
            if let date = DateFormatters.isoFormatter.date(from: value) {
                return DateFormatters.displayFormatter.string(from: date)
            }
            return value
        }
    }
    
    /// Format number with thousands separator for display
    func formatNumber(_ value: String) -> String {
        guard let number = Int(value) else { return value }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? value
    }
}

// MARK: - Date Formatters

private enum DateFormatters {
    static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - Preview Provider

// swiftlint:disable closure_body_length
struct InputFieldView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Text field
            InputFieldView(
                field: FormField(
                    id: "first_name",
                    label: "First Name",
                    type: .text,
                    required: true,
                    validation: nil,
                    dataSource: nil,
                    readOnly: false
                ),
                value: .constant("John"),
                error: nil,
                isLoading: false
            )
            
            // Number field with error
            InputFieldView(
                field: FormField(
                    id: "age",
                    label: "Age",
                    type: .number,
                    required: true,
                    validation: nil,
                    dataSource: nil,
                    readOnly: false
                ),
                value: .constant("17"),
                error: "Must be at least 18 years old",
                isLoading: false
            )
            
            // Date field read-only
            InputFieldView(
                field: FormField(
                    id: "birth_date",
                    label: "Birth Date",
                    type: .date,
                    required: true,
                    validation: nil,
                    dataSource: "api",
                    readOnly: true
                ),
                value: .constant("1985-03-15"),
                error: nil,
                isLoading: false
            )
            
            // Loading field
            InputFieldView(
                field: FormField(
                    id: "username",
                    label: "Username",
                    type: .text,
                    required: false,
                    validation: nil,
                    dataSource: nil,
                    readOnly: false
                ),
                value: .constant(""),
                error: nil,
                isLoading: true
            )
        }
        .padding()
    }
}
// swiftlint:enable closure_body_length
