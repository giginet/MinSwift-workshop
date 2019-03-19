import Foundation
import XCTest
import SwiftSyntax
@testable import MinSwiftKit

class Practice1: ParserTestCase {
    let source = """
func sayHello() {
    print("Welcome to Cookpad 🍳")
}
"""

    private func prepare() {
        let url = makeTemporaryFile(source)
        defer { removeTempoaryFile(at: url) }
        let sourceFile = try! SyntaxTreeParser.parse(url)
        parser.visit(sourceFile)
    }

    // 1-1
    func testToken() {
        prepare()

        let kinds = parser.tokens.map { $0.tokenKind }
        XCTAssertEqual(kinds, [
            .funcKeyword,
            .identifier("sayHello"),
            .leftParen,
            .rightParen,
            .leftBrace,
            .identifier("print"),
            .leftParen,
            .stringLiteral("\"Welcome to Cookpad 🍳\""),
            .rightParen,
            .rightBrace,
            .eof])
    }

    // 1-2
    func testSeek() {
        prepare()

        XCTAssertEqual(parser.seek().tokenKind, .funcKeyword)
        XCTAssertEqual(parser.currentToken.tokenKind, .funcKeyword)

        XCTAssertEqual(parser.seek().tokenKind, .identifier("sayHello")) // eat func
        XCTAssertEqual(parser.currentToken.tokenKind, .identifier("sayHello"))

        XCTAssertEqual(parser.seek().tokenKind, .leftParen) // eat sayHello
        XCTAssertEqual(parser.currentToken.tokenKind, .leftParen)

        // skip the rest
    }

    // 1-3
    func testPeek() {
        prepare()

        XCTAssertEqual(parser.seek().tokenKind, .funcKeyword)
        XCTAssertEqual(parser.peek().tokenKind, .identifier("sayHello"))
        XCTAssertEqual(parser.peek(1).tokenKind, .leftParen)
        XCTAssertEqual(parser.peek(2).tokenKind, .rightParen)
        XCTAssertEqual(parser.peek(8).tokenKind, .rightBrace)

        XCTAssertEqual(parser.currentToken.tokenKind, .funcKeyword)
    }
}
