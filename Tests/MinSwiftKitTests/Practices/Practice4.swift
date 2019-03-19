import Foundation
import XCTest
import SwiftSyntax
@testable import MinSwiftKit

class Practice4: ParserTestCase {
    // 4-1
    func testParsingArgument() {
        load("a: Double")

        let argument = parser.parseFunctionDefinitionArgument()
        XCTAssertEqual(argument.label, "a")
        XCTAssertEqual(argument.variableName, "a")
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }

    // 4-2
    func testSimpleFunctionDefinition() {
        load("""
func calculate() -> Double {
    return 1 + 2
}
""")
        // funcKeyword -> identifier("calculate") -> leftParen -> rightParen
        // -> arrow -> identifier("Double") -> leftBrace
        // -> returnKeyword -> integerLiteral("1") -> binaryOperator("+")
        // -> integerLiteral("2") -> rightBrace -> eof

        // You already have `parseExpression` to parse function body.
        let node = parser.parseFunctionDefinition()
        XCTAssertTrue(node is FunctionNode)

        let function = node as! FunctionNode
        XCTAssertEqual(function.name, "calculate")
        XCTAssertEqual(function.returnType, .double)
        XCTAssertTrue(function.arguments.isEmpty)

        XCTAssertTrue(function.body is ReturnNode)

        let expression = (function.body as! ReturnNode).body as! BinaryExpressionNode
        XCTAssertTrue(expression.lhs is NumberNode)
        XCTAssertEqual((expression.lhs as! NumberNode).value, 1)
        XCTAssertTrue(expression.rhs is NumberNode)
        XCTAssertEqual((expression.rhs as! NumberNode).value, 2)
        XCTAssertEqual(expression.operator, .addition)
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }

    // 4-3
    func testFunctionWithArgument() {
        load("""
func square(a: Double) -> Double {
    return a * a
}
""")
        let node = parser.parseFunctionDefinition()
        XCTAssertTrue(node is FunctionNode)

        let function = node as! FunctionNode
        XCTAssertEqual(function.name, "square")
        XCTAssertEqual(function.returnType, .double)
        XCTAssertEqual(function.arguments.count, 1)

        XCTAssertEqual(function.arguments[0].label, "a")
        XCTAssertEqual(function.arguments[0].variableName, "a")
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }

    // 4-4
    func testFunctionWithArguments() {
        load("""
func calculate(a: Double, b: Double) -> Double {
    return a * b
}
""")
        let node = parser.parseFunctionDefinition()
        XCTAssertTrue(node is FunctionNode)

        let function = node as! FunctionNode
        XCTAssertEqual(function.name, "calculate")
        XCTAssertEqual(function.returnType, .double)
        XCTAssertEqual(function.arguments.count, 2)

        XCTAssertEqual(function.arguments[0].label, "a")
        XCTAssertEqual(function.arguments[0].variableName, "a")
        XCTAssertEqual(function.arguments[1].label, "b")
        XCTAssertEqual(function.arguments[1].variableName, "b")
        XCTAssertEqual(parser.currentToken.tokenKind, .eof)
    }

    // If you have a rest time, try them.
    func _testParsingArgumentWithLabel() {
        load("label a: Double")

        let argument = parser.parseFunctionDefinitionArgument()
        XCTAssertEqual(argument.label, "label")
        XCTAssertEqual(argument.variableName, "a")
    }

    func _testParsingArgumentWithWildcard() {
        load("_ a: Double")

        let argument = parser.parseFunctionDefinitionArgument()
        XCTAssertNil(argument.label)
        XCTAssertEqual(argument.variableName, "a")
    }
}
