import XCTest

@testable import clanger

class ExampleUnitTest: XCTestCase {
    func testUnitTests() {
        let foo = Foo()
        XCTAssert(foo.getFoo() == "Foo")
    }
}