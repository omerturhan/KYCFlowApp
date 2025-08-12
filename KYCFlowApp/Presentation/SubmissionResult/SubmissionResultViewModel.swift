import Foundation
import UIKit
import SwiftUI

@MainActor
final class SubmissionResultViewModel: ObservableObject {
    @Published var isCopied: Bool = false
    @Published var shareError: String?
    
    private let submittedData: [String: Any]
    private var copyResetTask: Task<Void, Never>?
    
    init(submittedData: [String: Any]) {
        self.submittedData = submittedData
    }
    
    deinit {
        copyResetTask?.cancel()
    }
    
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
    
    var hasData: Bool {
        !submittedData.isEmpty
    }
    
    var dataCount: Int {
        submittedData.count
    }
    
    func copyToClipboard() {
        UIPasteboard.general.string = formattedJSON
        
        withAnimation(.spring()) {
            isCopied = true
        }
        
        // Cancel any existing reset task
        copyResetTask?.cancel()
        
        // Reset after 2 seconds
        copyResetTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            if !Task.isCancelled {
                withAnimation {
                    isCopied = false
                }
            }
        }
    }
    
    func shareData() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            shareError = "Unable to present share sheet"
            return
        }
        
        let activityController = UIActivityViewController(
            activityItems: [formattedJSON],
            applicationActivities: nil
        )
        
        // For iPad
        if let popoverController = activityController.popoverPresentationController {
            popoverController.sourceView = window
            popoverController.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        rootViewController.present(activityController, animated: true)
    }
    
    func getSubmittedValue(for key: String) -> String? {
        guard let value = submittedData[key] else {
            return nil
        }
        
        if let stringValue = value as? String {
            return stringValue
        } else if let numberValue = value as? NSNumber {
            return numberValue.stringValue
        } else if let dateValue = value as? Date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: dateValue)
        } else {
            return String(describing: value)
        }
    }
    
    var sortedDataKeys: [String] {
        submittedData.keys.sorted()
    }
}
