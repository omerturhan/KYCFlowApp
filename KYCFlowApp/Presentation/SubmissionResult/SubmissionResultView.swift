import SwiftUI

struct SubmissionResultView: View {
    @ObservedObject var viewModel: SubmissionResultViewModel
    let onDone: () -> Void
    @Environment(\.dismiss)
    private var dismiss

    init(viewModel: SubmissionResultViewModel, onDone: @escaping () -> Void = {}) {
        self.viewModel = viewModel
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

                if viewModel.isCopied {
                    Label("Copied", systemImage: "checkmark")
                        .font(.caption)
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(viewModel.formattedJSON)
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
            Button(action: viewModel.copyToClipboard) {
                HStack {
                    Image(systemName: viewModel.isCopied ? "checkmark" : "doc.on.doc")
                    Text(viewModel.isCopied ? "Copied to Clipboard" : "Copy JSON")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            Button(action: viewModel.shareData) {
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


// MARK: - Preview Provider

struct SubmissionResultView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SubmissionResultView(
                viewModel: SubmissionResultViewModel(
                    submittedData: [
                        "first_name": "John",
                        "last_name": "Doe",
                        "birth_date": "1990-01-15",
                        "email": "john.doe@example.com",
                        "phone": "+1234567890",
                        "address": "123 Main St, New York, NY 10001"
                    ]
                )
            )
            .previewDisplayName("With Data")

            SubmissionResultView(
                viewModel: SubmissionResultViewModel(submittedData: [:])
            )
            .previewDisplayName("Empty Data")

            SubmissionResultView(
                viewModel: SubmissionResultViewModel(
                    submittedData: [
                        "name": "Test User",
                        "id": "12345"
                    ]
                )
            )
            .previewDisplayName("Minimal Data")
        }
    }
}
