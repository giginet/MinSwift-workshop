import Foundation
import XCTest
import SwiftSyntax
@testable import MinSwiftKit

class Practice3: ParserTestCase {
    // 3-1
    func testExtractBinaryOperator() {
        load("1 + 2")
        parser.read()

        let op = parser.extractBinaryOperator(from: parser.currentToken!)
        XCTAssertEqual(op, .addition)
        XCTAssertEqual(parser.currentToken.tokenKind, .spacedBinaryOperator("+"))
    }

    // 3-2
    func testSimpleExpression() {
        load("10 + 20")
        // lhs: 10
        // rhs: 20
        // operator: +

        let expression = parser.parseExpression()
        XCTAssertTrue(expression is BinaryExpressionNode)

        let binaryNode = expression as! BinaryExpressionNode
        XCTAssertEqual(binaryNode.operator, .addition)

        let lhs = binaryNode.lhs as! NumberNode
        let rhs = binaryNode.rhs as! NumberNode
        XCTAssertEqual(lhs.value, 10)
        XCTAssertEqual(rhs.value, 20)
    }

    // 3-3
    func testExpressionWithMultipleOperators() {
        load("10 + 20 * 30")
        // lhs: 10
        // rhs:
        //     lhs: 20
        //     rhs: 30
        //     operator: *
        // operator: +

        let expression = parser.parseExpression()
        XCTAssertTrue(expression is BinaryExpressionNode)

        let binaryNode = expression as! BinaryExpressionNode
        XCTAssertEqual(binaryNode.operator, .addition)

        let lhs = binaryNode.lhs as! NumberNode
        let rhs = binaryNode.rhs as! BinaryExpressionNode
        XCTAssertEqual(lhs.value, 10)
        XCTAssertEqual(rhs.operator, .multication)

        XCTAssertEqual((rhs.lhs as! NumberNode).value, 20)
        XCTAssertEqual((rhs.rhs as! NumberNode).value, 30)
    }

    // 3-4
    func testExpressionWithParen() {
        load("(10 + 20) * 30")
        // lhs:
        //     lhs: 10
        //     rhs: 20
        //     operator: +
        // rhs: 30
        // operator: *

        let expression = parser.parseExpression()
        XCTAssertTrue(expression is BinaryExpressionNode)

        let binaryNode = expression as! BinaryExpressionNode
        XCTAssertEqual(binaryNode.operator, .multication)

        let lhs = binaryNode.lhs as! BinaryExpressionNode
        let rhs = binaryNode.rhs as! NumberNode
        XCTAssertEqual((lhs.lhs as! NumberNode).value, 10)
        XCTAssertEqual((lhs.rhs as! NumberNode).value, 20)
        XCTAssertEqual(lhs.operator, .addition)

        XCTAssertEqual(rhs.value, 30)
    }

    // 3-5
    func testExpressionWithVariable() {
        load("a - b")
        // lhs: a
        // rhs: b
        // operator: -

        let expression = parser.parseExpression()
        XCTAssertTrue(expression is BinaryExpressionNode)

        let binaryNode = expression as! BinaryExpressionNode
        XCTAssertEqual(binaryNode.operator, .subtraction)

        let lhs = binaryNode.lhs as! VariableNode
        let rhs = binaryNode.rhs as! VariableNode
        XCTAssertEqual(lhs.identifier, "a")
        XCTAssertEqual(rhs.identifier, "b")
    }

    // 3-6
    func testComplexExpression() {
        load("(a - 20) * 10 / b")
        // please parse on yourself because I'm tired 😛

        let expression = parser.parseExpression()
        XCTAssertTrue(expression is BinaryExpressionNode)

        let binaryNode = expression as! BinaryExpressionNode
        XCTAssertEqual(binaryNode.operator, .division)

        let lhs = binaryNode.lhs as! BinaryExpressionNode
        let rhs = binaryNode.rhs as! VariableNode
        XCTAssertTrue(lhs.lhs is BinaryExpressionNode)
        XCTAssertTrue(lhs.rhs is NumberNode)
        XCTAssertEqual(lhs.operator, .multication)

        XCTAssertEqual(rhs.identifier, "b")
    }
}
