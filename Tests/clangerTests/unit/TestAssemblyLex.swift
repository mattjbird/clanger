import Foundation
import XCTest

@testable import clanger

/// Note: this is a test for test utils, rather than the clanger code per se.
/// For the Generation tests we tokenise the assembly we're receiving and
/// expecting to check for equality. This test verifies that the tokenisation
/// is correct.
class TestAssemblyLexer: XCTestCase {
  func testDirectives() {
    testLex(".globl", [.directive(.globl)])
  }

  func testKeywords() {
    testLex("movl", [.keyword(.movl)])
    testLex("ret", [.keyword(.ret)])
    testLex("neg", [.keyword(.neg)])
    testLex("not", [.keyword(.not)])
    testLex("cmpl", [.keyword(.cmpl)])
    testLex("sete", [.keyword(.sete)])
  }

  func testPunctuation() {
    testLex("$", [.punctuation(.literalPrefix)])
    testLex("%", [.punctuation(.registerPrefix)])
    testLex(",", [.punctuation(.comma)])
  }

  func testIdentifier() {
    testLex("hello", [.identifier("hello")])
  }

  func testDeclaration() {
    testLex(
      """
        .globl _meaning_of_life
      _meaning_of_life:
      """,
      [
        .directive(.globl),
        .identifier("_meaning_of_life"),
        .identifier("_meaning_of_life"),
        .punctuation(.colon),
      ]
    )
  }

  func testReturnLiteral() {
    testLex("""
    movl  $9, %eax
    ret
    """,
    [
      .keyword(.movl),
      .punctuation(.literalPrefix),
      .literal("9"),
      .punctuation(.comma),
      .punctuation(.registerPrefix),
      .register(.eax),
      .keyword(.ret)
    ]
    )
  }

  private func testLex(_ src: String, _ expected: [AssemblyToken]) {
    let tokens = AssemblyTokenSequence(CharacterStream(InputStream(string: src)))
    XCTAssertEqual(Array(tokens), expected)
  }
}