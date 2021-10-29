import Foundation
import XCTest

@testable import clanger

class TestParser: XCTestCase {
  let parser = Parser()

  func testReturn0() {
    let program = parser.parse(TestTokenStream([
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
}
