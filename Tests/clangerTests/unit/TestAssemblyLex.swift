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
    testLex("movq", [.keyword(.movq)])
    testLex("ret", [.keyword(.ret)])
    testLex("neg", [.keyword(.neg)])
    testLex("not", [.keyword(.not)])
    testLex("cmpq", [.keyword(.cmpq)])
    testLex("sete", [.keyword(.sete)])
    testLex("pushq", [.keyword(.pushq)])
    testLex("popq", [.keyword(.popq)])
  }

  func testPunctuation() {
    testLex(",", [.punctuation(.comma)])
    testLex(":", [.punctuation(.colon)])
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

  func testDirective() {
    testLex(
      "movq  $42, %rax",
      [.keyword(.movq), .literal("42"), .punctuation(.comma), .register(.rax)]
    )
  }

  func testMultiline() {
    testLex("""
      movq    $1, %rax
      cmpq    $0, %rax
      """,
      [
        .keyword(.movq),
        .literal("1"),
        .punctuation(.comma),
        .register(.rax),

        .keyword(.cmpq),
        .literal("0"),
        .punctuation(.comma),
        .register(.rax),
      ]
    )
  }

  func testWhitespace() {
    testLex("""
      movq $1,                %rax



      cmpq          $0,%rax
      """,
      [
        .keyword(.movq),
        .literal("1"),
        .punctuation(.comma),
        .register(.rax),

        .keyword(.cmpq),
        .literal("0"),
        .punctuation(.comma),
        .register(.rax),
      ]
    )
  }
}

// MARK: Private
private extension TestAssemblyLexer {
  private func testLex(_ src: String, _ expected: [AssemblyToken]) {
    func get(_ arr: [AssemblyToken], _ i: Int) -> AssemblyToken? {
      guard i < arr.count else { return nil }
      return arr[i]
    }
    let tokens = Array(AssemblyTokenSequence(CharacterStream(InputStream(string: src))))
    for i in stride(from: 0, through: max(tokens.count, expected.count) - 1, by: 1) {
      if i >= expected.count {
        return XCTFail("Expected end of tokens but got \(tokens[i])")
      }
      if i >= tokens.count {
        return XCTFail("Expected \(expected[i]) but got end of tokens")
      }
      XCTAssertEqual(tokens[i], expected[i])
    }
  }
}