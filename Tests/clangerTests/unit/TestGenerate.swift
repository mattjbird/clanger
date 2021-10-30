import Foundation
import XCTest

@testable import clanger

/// Tests the contract between the Parser and the assembly Generator
class testGenerator: XCTestCase {
  func testReturn0() {
    self.testGenProgram(
      Program(
        Function(
          "meaning_of_life",
          Statement.return( Expression.integerConstant(42))
        )
      ),
      """
          .globl _meaning_of_life
      _meaning_of_life:
          movl    $42, %eax
          ret
      """
    )
  }

  // MARK: - Private
  private func testGenProgram(_ program: Program, _ expected: String) {
    let out = TestOutputHandler()
    let gen = Generator(out)
    gen.emitProgram(program)
    XCTAssertEqual(out.value, expected)
  }
}
