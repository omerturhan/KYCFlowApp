import XCTest
import SnapshotTesting
import SwiftUI

class BaseSnapshotTest: XCTestCase {
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

// MARK: - Common Test Devices

extension BaseSnapshotTest {
    enum Size {
        // Custom sizes for form fields
        static let formFieldSize = CGSize(width: 375, height: 120)
        static let formFieldWithErrorSize = CGSize(width: 375, height: 150)
        static let formFieldWithMultipleErrorsSize = CGSize(width: 375, height: 180)
    }
}
