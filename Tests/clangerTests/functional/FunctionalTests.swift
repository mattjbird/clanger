import Foundation
import XCTest

@testable import clanger

/// These functional tests use the full C files in Tests/clangerTests/data.
/// In each test, a file is compiled, the executable is run, and its return code
/// is checked against an expected value.
class FunctionalTests: FunctionalTestCase {
  func test01ReturnIntConstant() {
    self.compileAndAssert(testData("01ReturnIntConstant.c"), returns: 43)
  }

  func test02ReturnNegIntConstant() {
    // -43 => 213
    self.compileAndAssert(testData("02ReturnNegIntConstant.c"), returns: 213)
  }

  func test03ReturnBitwiseComplement() {
    // ~4 => 251 for 8 bits
    self.compileAndAssert(testData("03ReturnBitwiseComplement.c"), returns: 251)
  }

  // MARK: - Private
  func testData(_ file: String) -> String {
    return "Tests/clangerTests/data/\(file)"
  }
}