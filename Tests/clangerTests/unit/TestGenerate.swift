import Foundation
import XCTest

@testable import clanger

/// Tests the contract between the Parser and the assembly Generator
class testGenerator: XCTestCase {
  // MARK: Expressions
  func testConstants() {
    self.testExpression( .integerConstant(9001), "movl    $9001, %eax" )
  }

  func testUnaryOps() {
    self.testExpression(
      .unaryOp(.negation, .integerConstant(3)),
      """
      movl    $3, %eax
      neg    %eax
      """
    )

    // Nested
    self.testExpression(
      .unaryOp(.negation, .unaryOp(.negation, .integerConstant(842))),
      """
      movl    $842, %eax
      neg    %eax
      neg    %eax
      """
    )
  }

  // MARK: Statements
  func testReturn() {
    self.testStatement(
      Statement.return( Expression.integerConstant(42)),
      """
      movl    $42, %eax
      ret
      """
    )
  }

  // MARK: Functions
  func testFunctionSimpleReturn() {
    self.testFunction(
      Function(
        "meaning_of_life",
        Statement.return( Expression.integerConstant(42))
      ),
      """
          .globl _meaning_of_life
      _meaning_of_life:
          movl    $42, %eax
          ret
      """
    )
  }

  // Programs
  func testReturn0() {
    self.testProgram(
      Program(
        Function(
          "main",
          Statement.return( Expression.integerConstant(0))
        )
      ),
      """
          .globl _main
      _main:
          movl    $0, %eax
          ret
      """
    )
  }

  // MARK: - Private
  private func testProgram(_ program: Program, _ expected: String) {
    self.test({ $0.emitProgram(program) }, expected)
  }

  private func testFunction(_ function: Function, _ expected: String) {
    self.test({ $0.emitFunction(function) }, expected)
  }

  private func testStatement(_ statement: Statement, _ expected: String) {
    self.test({ $0.emitStatement(statement) }, expected)
  }

  private func testExpression(_ expression: Expression, _ expected: String) {
    self.test({ $0.emitExpression(expression) }, expected)
  }

  private func test(_ genF: (Generator) -> (), _ expected: String) {
    let out = TestOutputHandler()
    let gen = Generator(out)
    genF(gen)
    XCTAssertEqual(out.value.removingIndentation(), expected.removingIndentation())
  }
}

// We don't care about indentation here
// TODO: need to replace indenations and also convert all 2+ spaces into 2 spaces
extension String {
  func removingIndentation() -> String {
      return self.replacingOccurrences(
        of: "\n[\\s]+",
        with: "\n",
        options: .regularExpression,
        range: nil
      )
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
