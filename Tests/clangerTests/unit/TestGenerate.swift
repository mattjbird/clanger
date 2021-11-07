import Foundation
import XCTest

@testable import clanger

/// Tests the contract between the Parser and the assembly Generator
class testGenerator: XCTestCase {
  // MARK: Expressions
  func testConstants() {
    self.testExpression( .integerConstant(9001), "movl  $9001, %eax" )
  }

  func testUnaryOps() {
    self.testExpression(
      .unaryOp(.negation, .integerConstant(3)),
      """
      movl    $3, %eax
      neg     %eax
      """
    )

    // Nested
    self.testExpression(
      .unaryOp(.negation, .unaryOp(.negation, .integerConstant(842))),
      """
      movl    $842, %eax
      neg     %eax
      neg     %eax
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
    AssertAssemblyEqual(out.value, expected)
  }

  func testCustomAssert() {
    AssertAssemblyEqual("", "")
    AssertAssemblyEqual("a", "a")
    AssertAssemblyEqual("ab", "ab")
    AssertAssemblyEqual("abc", "abc")
    AssertAssemblyEqual("abc  ", "abc")
    AssertAssemblyEqual("     abc  ", "abc")

    AssertAssemblyEqual("ab\n  c", "ab\nc")
    AssertAssemblyEqual("ab\n  c\n  d", "ab\nc\nd")

    XCTAssertFalse(assemblyEqual("a", "b"))
    XCTAssertFalse(assemblyEqual("ab", "a"))
    XCTAssertFalse(assemblyEqual("a", "abc"))
    XCTAssertFalse(assemblyEqual("ab   a", "ab"))
  }
}

fileprivate func AssertAssemblyEqual(
  _ string1: String,
  _ string2: String,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  if assemblyEqual(string1, string2) { return }
  XCTFail("""
    XCTAssertion fail: assembly not equal:

    \(string1)

    does not equal

    \(string2)
    """,
    file: file,
    line: line
  )
}

// TODO: rewrite this
// This is a sort of poor man's tokeniser which goes through each string in
// linear time and ignores whitespace. We might consider switching to something
// more heavy duty here, although keeping things as strings does make the tests
// easier to read.
// A major drawback of this way of checking for equality is that while we do
// properly consider newlines, spaces which break up tokens are ignoed: e.g.
// "ret" == "re  t", which is incorrect!
fileprivate func assemblyEqual( _ string1: String, _ string2: String) -> Bool {
  let string1 = Array(string1)
  let string2 = Array(string2)
  var index1 = 0
  var index2 = 0

  func getNextNonSpace(_ str: [Character], _ index: inout Int) -> Character? {
    guard index < str.count else { return nil }
    var c = str[index]
    while c == " " {
      index += 1
      if index >= str.count { return nil }
      c = str[index]
    }
    return c
  }

  while (index1 < string1.count) && (index2 < string2.count) {
    guard let char1 = getNextNonSpace(string1, &index1) else { break }
    guard let char2 = getNextNonSpace(string2, &index2) else { break }
    if char1 != char2 {
      return false
    }
    index1 += 1
    index2 += 1
  }
  while (index1 < string1.count) {
    if !string1[index1].isWhitespace { return false }
    index1 += 1
  }
  while (index2 < string2.count) {
    if !string2[index2].isWhitespace { return false }
    index2 += 1
  }
  return true
}
