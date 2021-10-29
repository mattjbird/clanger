import Foundation
import XCTest

@testable import clanger

class TestParser: XCTestCase {
  let parser = Parser()

  func testReturn0() {
    let program = try? parser.parse(TestTokenStream([
      .keyword(.int),
      .identifier("main"),
      .openParen,
      .closeParen,
      .openBrace,
      .keyword(.return),
      .intLiteral("0"),
      .semiColon,
      .closeBrace
    ]))
    XCTAssertNotEqual(program, nil)

    let expected = Program(
      Function(
        "main",
        Statement.return(
          Expression.integerConstant(0)
        )
      )
    )
    XCTAssertEqual(program, expected)
  }

  func testMissingBrace() {
    let program = try? parser.parse(TestTokenStream([
      .keyword(.int),
      .identifier("main"),
      .openParen,
      .openBrace,
      .keyword(.return),
      .intLiteral("0"),
      .semiColon,
      .closeBrace
    ]))
    XCTAssertEqual(program, nil)
  }
}
