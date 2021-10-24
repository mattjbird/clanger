import Foundation
import XCTest

@testable import clanger

// Tests the lexing of a basic C program which returns an integer.
class TestReturn: XCTestCase {
    func testReturn0() {
        let expected: [CToken] = [
            .keyword(.integer),
            .identifier("main"),
            .openParenthesis,
            .closeParenthesis,
            .openBrace,
            .keyword(.return),
            .integerLiteral(0),
            .semiColon,
            .closeBrace
        ]
        XCTAssertEqual(self.lex(TestPrograms.Valid.return0), expected)
    }

    func testWhitespaces() {
        let programs = [
            TestPrograms.Valid.newlines,
            TestPrograms.Valid.cramped,
            TestPrograms.Valid.spaces
        ]
        let expected: [CToken] = [
            .keyword(.integer),
            .identifier("main"),
            .openParenthesis,
            .closeParenthesis,
            .openBrace,
            .keyword(.return),
            .integerLiteral(42),
            .semiColon,
            .closeBrace
        ]

        for program in programs {
            XCTAssertEqual(self.lex(program), expected)
        }
    }

    // Note that the Lexer is *not* responsible for checking that the files are valid C.
    func testInvalidFiles() {
        XCTAssertEqual(
            self.lex(TestPrograms.Invalid.missingClosingParen),
            [
                .keyword(.integer),
                .identifier("main"),
                .openParenthesis,
                //
                .openBrace,
                .keyword(.return),
                .integerLiteral(0),
                .semiColon,
                .closeBrace
            ]
        )
        XCTAssertEqual(
            self.lex(TestPrograms.Invalid.missingReturnValue),
            [
                .keyword(.integer),
                .identifier("main"),
                .openParenthesis,
                .closeParenthesis,
                .openBrace,
                //
                .integerLiteral(0),
                .semiColon,
                .closeBrace
            ]
        )
        XCTAssertEqual(
            self.lex(TestPrograms.Invalid.missingClosingBrace),
            [
                .keyword(.integer),
                .identifier("main"),
                .openParenthesis,
                .closeParenthesis,
                .openBrace,
                .keyword(.return),
                .integerLiteral(0),
                .semiColon,
                //
            ]
        )
        XCTAssertEqual(
            self.lex(TestPrograms.Invalid.missingSemiColon),
            [
                .keyword(.integer),
                .identifier("main"),
                .openParenthesis,
                .closeParenthesis,
                .openBrace,
                .keyword(.return),
                .integerLiteral(0),
                //
                .closeBrace,
            ]
        )
        XCTAssertEqual(
            self.lex(TestPrograms.Invalid.missingSpaceBetweenReturnAndReturned),
            [
                .keyword(.integer),
                .identifier("main"),
                .openParenthesis,
                .closeParenthesis,
                .openBrace,
                .identifier("return0"), //
                .integerLiteral(0),
                .semiColon,
                .closeBrace,
            ]
        )
        XCTAssertEqual(
            self.lex(TestPrograms.Invalid.shouty),
            [
                .identifier("INT"), //
                .identifier("MAIN"), //
                .openParenthesis,
                .closeParenthesis,
                .openBrace,
                .identifier("RETURN"),
                .integerLiteral(0),
                .semiColon,
                .closeBrace,
            ]
        )
    }

    // Helper which feeds the string into a lexer
    private func lex(_ str: String) -> [CToken] {
        return Array(Lexer(InputStream(string: str)).tokens)
    }
}