import XCTest
import SnapshotTesting
import SwiftUI

class BaseSnapshotTest: XCTestCase {
    
    // MARK: - Configuration
    
    /// Set this to true to record new snapshots for all tests
    /// Can be overridden by environment variable SNAPSHOT_RECORDING
    static var isRecordingMode: Bool = false
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        // Check environment variable for recording mode
        if ProcessInfo.processInfo.environment["SNAPSHOT_RECORDING"] == "true" {
            isRecording = true
        } else {
            isRecording = Self.isRecordingMode
        }
        
        // Configure snapshot testing
        // Use a fixed size for consistent snapshots across different devices
        SnapshotTesting.diffTool = "ksdiff"
        
        // Set default image precision if needed
        // This helps with minor rendering differences between test runs
        // SnapshotTesting.defaultImagePrecision = 0.98
    }
    
    override func tearDown() {
        super.tearDown()
        isRecording = false
    }
    
    // MARK: - Helper Methods
    
    /// Records new snapshots for a specific test
    func recordSnapshot() {
        isRecording = true
    }
    
    /// Returns whether we're in recording mode
    var isInRecordingMode: Bool {
        isRecording ?? false
    }
    
    /// Asserts a snapshot with consistent configuration
    /// - Parameters:
    ///   - view: The view to snapshot
    ///   - name: Optional name for the snapshot
    ///   - device: The device configuration to use (defaults to iPhone 13)
    ///   - file: The file where the assertion is made
    ///   - testName: The name of the test
    ///   - line: The line number where the assertion is made
    func assertSnapshot<Value>(
        of value: Value,
        as snapshotting: Snapshotting<Value, UIImage>,
        named name: String? = nil,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        SnapshotTesting.assertSnapshot(
            of: value,
            as: snapshotting,
            named: name,
            file: file,
            testName: testName,
            line: line
        )
    }
    
    /// Asserts a snapshot of a view with a specific size
    /// - Parameters:
    ///   - view: The view to snapshot
    ///   - size: The size for the snapshot
    ///   - name: Optional name for the snapshot
    ///   - file: The file where the assertion is made
    ///   - testName: The name of the test
    ///   - line: The line number where the assertion is made
    func assertSnapshot<V: SwiftUI.View>(
        of view: V,
        size: CGSize = CGSize(width: 375, height: 812),
        named name: String? = nil,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(origin: .zero, size: size)
        
        SnapshotTesting.assertSnapshot(
            of: controller,
            as: .image,
            named: name,
            file: file,
            testName: testName,
            line: line
        )
    }
}

// MARK: - Test Configuration Extension

extension BaseSnapshotTest {
    
    /// Enables recording mode for all snapshot tests
    static func enableRecordingMode() {
        isRecordingMode = true
    }
    
    /// Disables recording mode for all snapshot tests
    static func disableRecordingMode() {
        isRecordingMode = false
    }
    
    /// Runs a test in recording mode
    /// - Parameter testBlock: The test block to run
    func withRecordingMode(_ testBlock: () throws -> Void) rethrows {
        let previousValue = isRecording
        isRecording = true
        defer { isRecording = previousValue }
        try testBlock()
    }
}

// MARK: - Common Test Devices

extension BaseSnapshotTest {
    enum TestDevice {
        static let iPhone13 = ViewImageConfig.iPhone13
        static let iPhone13Pro = ViewImageConfig.iPhone13Pro
        static let iPhone13ProMax = ViewImageConfig.iPhone13ProMax
        static let iPhoneSe = ViewImageConfig.iPhoneSe
        static let iPad = ViewImageConfig.iPadPro11
        
        // Custom sizes for form fields
        static let formFieldSize = CGSize(width: 375, height: 120)
        static let formFieldWithErrorSize = CGSize(width: 375, height: 150)
        static let formFieldWithMultipleErrorsSize = CGSize(width: 375, height: 180)
    }
}
