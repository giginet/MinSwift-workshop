import Foundation
import XCTest
import SwiftSyntax
@testable import MinSwiftKit

class Practice5: ParserTestCase {
    func testFunctionCalling() {
        load("doSomething()") // identifier, leftParen, rightParen

        let node = parser.parseIdentifierExpression()
        XCTAssertTrue(node is CallExpressionNode)

        let callExpressionNode = node as! CallExpressionNode
        XCTAssertEqual(callExpressionNode.callee, "doSomething")
        XCTAssertTrue(callExpressionNode.arguments.isEmpty)
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }

    func testFunctionCallingWithLabel() {
        load("doSomething(a: 10 + 20)") // identifier, leftParen, identifier, colon, <some expression> , rightParen

        let node = parser.parseIdentifierExpression()
        XCTAssertTrue(node is CallExpressionNode)

        let callExpressionNode = node as! CallExpressionNode
        XCTAssertEqual(callExpressionNode.callee, "doSomething")
        XCTAssertEqual(callExpressionNode.arguments.count, 1)

        let firstArgument = callExpressionNode.arguments.first!.value as! BinaryExpressionNode
        XCTAssertEqual(firstArgument.operator, .addition)
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }

    func testFunctionCallingWithLabels() {
        load("doSomething(a: 10 + 20, b: x)")
        // identifier, leftParen,
        //     identifier, colon, <some expression>, comma
        //     identifier, colon, <some expression> ...
        // rightParen

        let node = parser.parseIdentifierExpression()
        XCTAssertTrue(node is CallExpressionNode)

        let callExpressionNode = node as! CallExpressionNode
        XCTAssertEqual(callExpressionNode.callee, "doSomething")
        XCTAssertEqual(callExpressionNode.arguments.count, 2)

        let firstArgument = callExpressionNode.arguments.first!.value as! BinaryExpressionNode
        XCTAssertEqual(firstArgument.operator, .addition)

        let secondArgument = callExpressionNode.arguments[1].value as! VariableNode
        XCTAssertEqual(secondArgument.identifier, "x")
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }

    // If you have a rest time, try them.
    func _testFunctionCallingWithLiteralArguments() {
        load("doSomething(10)") // identifier, leftParen, <some expression> , rightParen

        let node = parser.parseIdentifierExpression()
        XCTAssertTrue(node is CallExpressionNode)

        let callExpressionNode = node as! CallExpressionNode
        XCTAssertEqual(callExpressionNode.callee, "doSomething")
        XCTAssertEqual(callExpressionNode.arguments.count, 1)

        let firstArgument = callExpressionNode.arguments.first!.value as! NumberNode
        XCTAssertEqual(firstArgument.value, 10)
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }

    func _testFunctionCallingWithVariableArguments() {
        load("doSomething(a)") // identifier, leftParen, <some expression> , rightParen

        let node = parser.parseIdentifierExpression()
        XCTAssertTrue(node is CallExpressionNode)

        let callExpressionNode = node as! CallExpressionNode
        XCTAssertEqual(callExpressionNode.callee, "doSomething")
        XCTAssertEqual(callExpressionNode.arguments.count, 1)

        let firstArgument = callExpressionNode.arguments.first!.value as! VariableNode
        XCTAssertEqual(firstArgument.identifier, "a")
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }
}
