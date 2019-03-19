import Foundation
import XCTest
import SwiftSyntax
@testable import MinSwiftKit

class Practice2: ParserTestCase {
    // 2-1
    func testParseInteger() {
        load("42") // integerLiteral("42")

        let node = parser.parseNumber()
        XCTAssertTrue(node is NumberNode)
        let numberNode = node as! NumberNode
        XCTAssertEqual(numberNode.value, 42)
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }

    // 2-2
    func testParseFloatingNumber() {
        load("42.195") // floatingLiteral("42.195")

        let node = parser.parseNumber()
        XCTAssertTrue(node is NumberNode)
        let numberNode = node as! NumberNode
        XCTAssertEqual(numberNode.value, 42.195)
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }

    // 2-3
    func testIdentifier() {
        load("a") // identifier("a")

        let node = parser.parseIdentifierExpression()
        XCTAssertTrue(node is VariableNode)

        let variableNode = node as! VariableNode
        XCTAssertEqual(variableNode.identifier, "a")
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }
}
