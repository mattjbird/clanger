import Foundation
import XCTest

@testable import clanger

class TestLexer: XCTestCase {
  func testKeywords() {
    testLex("return", [.keyword(.return)])
    testLex("int", [.keyword(.int)])
  }

  func testPunctuation() {
    testLex("{}();", [
      .openBrace,
      .closeBrace,
      .openParen,
      .closeParen,
      .semiColon,
    ])
  }

  func testIntegerLiterals() {
    // Decimals
    for i in stride(from: 0, to: 33, by: 1) {
      let n = UInt32(UInt64((1 << i) - 1))
      testLex("\(n)", [.intLiteral("\(n)")])
    }

    // Hexadecimal
    testLex("0x1", [.intLiteral("0x1")])
    testLex("0x10", [.intLiteral("0x10")])
    testLex("0x100", [.intLiteral("0x100")])
    testLex("0xFFFFFFFF", [.intLiteral("0xFFFFFFFF")])

    // Octals
    testLex("010", [.intLiteral("010")])
    testLex("0101", [.intLiteral("0101")])
    testLex("01010", [.intLiteral("01010")])
    testLex("037777777777", [.intLiteral("037777777777")])
  }

  func testIdentifiers() {
    testLex("mains f bar; aaaa", [
      .identifier("mains"),
      .identifier("f"),
      .identifier("bar"),
      .semiColon,
      .identifier("aaaa"),
    ])
  }

  func testWhitespaces() {
    testLex("return\nfoo\n{\n;", [
      .keyword(.return),
      .identifier("foo"),
      .openBrace,
      .semiColon,
    ])
    testLex("int  foo  {", [
      .keyword(.int),
      .identifier("foo"),
      .openBrace,
    ])
    testLex("f(){bar;}", [
      .identifier("f"),
      .openParen,
      .closeParen,
      .openBrace,
      .identifier("bar"),
      .semiColon,
      .closeBrace,
    ])
  }

  func testCasing() {
    testLex("INT MAIN FOO", [
      .identifier("INT"),
      .identifier("MAIN"),
      .identifier("FOO"),
    ])
  }

  func testBasicFunction() {
    testLex("int f() { return 42; }", [
      .keyword(.int),
      .identifier("f"),
      .openParen,
      .closeParen,
      .openBrace,
      .keyword(.return),
      .intLiteral("42"),
      .semiColon,
      .closeBrace,
    ])
  }

  private func testLex(_ src: String, _ expected: [CToken]) {
    let tokens = TokenSequence(CharacterStream(InputStream(string: src)))
    XCTAssertEqual(Array(tokens), expected)
  }
}
