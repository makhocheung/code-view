import XCTest
@testable import CodeView

final class CodeViewTests: XCTestCase {
    func testExample() throws {
        let bundleURL = Bundle.module.resourceURL!.appendingPathComponent("CodeView")
                .appendingPathExtension("bundle")
        let bundle = Bundle(url: bundleURL)!
        print(bundle.bundleURL.absoluteString)
        let str = try String(contentsOf: bundle.url(forResource: "codeview", withExtension: "html")!)
        print(str)
    }
}
