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
        let actual = self.loadAndLex(fileName: "valid/return0.c")
        XCTAssertEqual(expected, actual)
    }

    func testReturnMultiDigit() {
        let expected: [CToken] = [
            .keyword(.integer),
            .identifier("main"),
            .openParenthesis,
            .closeParenthesis,
            .openBrace,
            .keyword(.return),
            .integerLiteral(360),
            .semiColon,
            .closeBrace
        ]
        let actual = self.loadAndLex(fileName: "valid/return360.c")
        XCTAssertEqual(expected, actual)
    }

    func testWhitespaces() {
        let programs = [
            "valid/return0cramped.c",
            "valid/return0LotsOfSpaces.c",
            "valid/return0LotsOfNewlines.c",
        ]
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

        for program in programs {
            XCTAssertEqual(self.loadAndLex(fileName: program), expected)
        }
    }

    // Note that the Lexer is *not* responsible for checking that the files are valid C.
    func testInvalidFiles() {
        XCTAssertEqual(
            self.loadAndLex(fileName: "invalid/missingClosingParenthesis.c"),
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
            self.loadAndLex(fileName: "invalid/missingReturnValue.c"),
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
            self.loadAndLex(fileName: "invalid/missingClosingBrace.c"),
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
            self.loadAndLex(fileName: "invalid/missingSemicolon.c"),
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
            self.loadAndLex(fileName: "invalid/missingSpaceAfterReturn.c"),
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
            self.loadAndLex(fileName: "invalid/shouty.c"),
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

    // Helper which loads a test case and feeds it into the lexer
    private func loadAndLex(fileName: String) -> [CToken] {
        print(FileManager.default.currentDirectoryPath)
        let testDataDirectory = URL(fileURLWithPath: "Tests/clangerTests/data/")
        let file = testDataDirectory.appendingPathComponent(fileName)
        let contents = try! String(contentsOf: file, encoding: .utf8)
        let lexer = Lexer(InputStream(string: contents))
        return Array(lexer.tokens)
    }
}