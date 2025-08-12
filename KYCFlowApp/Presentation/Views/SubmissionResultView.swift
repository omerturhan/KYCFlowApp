import SwiftUI

struct SubmissionResultView: View {
    let submittedData: [String: Any]
    let onDone: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isCopied = false
    
    init(submittedData: [String: Any], onDone: @escaping () -> Void = {}) {
        self.submittedData = submittedData
        self.onDone = onDone
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Success header
                successHeader
                
                // JSON display
                jsonDisplay
                
                // Action buttons
                actionButtons
            }
            .padding()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Submission Complete")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    onDone()
                }
            }
        }
    }
}

// MARK: - View Components

private extension SubmissionResultView {
    
    var successHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Form Submitted Successfully!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your KYC information has been recorded")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    var jsonDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Submitted Data")
                    .font(.headline)
                
                Spacer()
                
                if isCopied {
                    Label("Copied", systemImage: "checkmark")
                        .font(.caption)
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(formattedJSON)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: copyToClipboard) {
                HStack {
                    Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    Text(isCopied ? "Copied to Clipboard" : "Copy JSON")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(action: shareData) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.systemBackground))
                .foregroundColor(.blue)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 2)
                )
            }
        }
    }
}

// MARK: - Actions

private extension SubmissionResultView {
    
    func copyToClipboard() {
        UIPasteboard.general.string = formattedJSON
        
        withAnimation(.spring()) {
            isCopied = true
        }
        
        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isCopied = false
            }
        }
    }
    
    func shareData() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let activityController = UIActivityViewController(
            activityItems: [formattedJSON],
            applicationActivities: nil
        )
        
        window.rootViewController?.present(activityController, animated: true)
    }
}

// MARK: - Helper Methods

private extension SubmissionResultView {
    
    var formattedJSON: String {
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: submittedData,
                options: [.prettyPrinted, .sortedKeys]
            )
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            return "Error formatting JSON: \(error.localizedDescription)"
        }
    }
}

// MARK: - Preview Provider

struct SubmissionResultView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SubmissionResultView(
                submittedData: [
                    "first_name": "John",
                    "last_name": "Doe",
                    "birth_date": "1990-01-15",
                    "email": "john.doe@example.com",
                    "phone": "+1234567890",
                    "address": "123 Main St, New York, NY 10001"
                ]
            )
            .previewDisplayName("With Data")
            
            SubmissionResultView(
                submittedData: [:]
            )
            .previewDisplayName("Empty Data")
            
            SubmissionResultView(
                submittedData: [
                    "name": "Test User",
                    "id": "12345"
                ]
            )
            .previewDisplayName("Minimal Data")
        }
    }
}