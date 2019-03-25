import Foundation
import XCTest
import FileCheck
@testable import MinSwiftKit

final class Practice7: ParserTestCase {
    // 7-1
    func testParsingComparisonOperator() {
        load("a < b + 20")
        // lhs: a
        // rhs:
        //     lhs: b
        //     rhs: 20
        //     operator: +
        // operator: <

        let node = parser.parseExpression()
        XCTAssertTrue(node is BinaryExpressionNode)
        let comparison = node as! BinaryExpressionNode
        XCTAssertTrue(comparison.lhs is VariableNode)
        XCTAssertTrue(comparison.rhs is BinaryExpressionNode)

        let rhsNode = comparison.rhs as! BinaryExpressionNode
        XCTAssertTrue(rhsNode.lhs is VariableNode)
        XCTAssertTrue(rhsNode.rhs is NumberNode)
        XCTAssertEqual(rhsNode.operator, .addition)
    }

    // 7-2
    func testParsingIfElse() {
        load("""
    if a < 10 {
        foo(a: a)
    } else {
        foo(a: a + 10)
    }
    """)

        let node = parser.parseIfElse()

        let ifNode = node as! IfElseNode
        XCTAssertTrue(ifNode.condition is BinaryExpressionNode)
        let condition = ifNode.condition as! BinaryExpressionNode
        XCTAssertTrue(condition.lhs is VariableNode)
        XCTAssertTrue(condition.rhs is NumberNode)

        let thenBlock = ifNode.then
        XCTAssertTrue(thenBlock is CallExpressionNode)
        XCTAssertEqual((thenBlock as! CallExpressionNode).callee, "foo")

        let elseBlock = ifNode.else
        XCTAssertTrue(elseBlock is CallExpressionNode)
        XCTAssertEqual((elseBlock as! CallExpressionNode).callee, "foo")
    }

    // 7-3
    func testGenerateCompOperator() {
        let variableNode = VariableNode(identifier: "a")
        let numberNode = NumberNode(value: 10)
        let body = BinaryExpressionNode(.lessThan, lhs: variableNode, rhs: numberNode)
        let node = FunctionNode(name: "main",
                                arguments: [.init(label: nil, variableName: "a")],
                                returnType: .double,
                                body: body)

        let buildContext = BuildContext()
        build([node], context: buildContext)
        XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["CompOperator"]) {
            // CompOperator: ; ModuleID = 'main'
            // CompOperator-NEXT: source_filename = "main"

            // CompOperator: define double @main(double) {
            // CompOperator-NEXT:     entry:
            // CompOperator-NEXT:     %cmptmp = fcmp olt double %0, 1.000000e+01
            // CompOperator-NEXT:     %1 = sitofp i1 %cmptmp to double
            // CompOperator-NEXT:     ret double %1
            // CompOperator-NEXT: }
            buildContext.dump()
        })
    }

    // 7-4
    func testGenerateIfElse() {
        let variableNode = VariableNode(identifier: "a")
        let numberNode = NumberNode(value: 10)
        let condition = BinaryExpressionNode(.lessThan, lhs: variableNode, rhs: numberNode)
        let elseBlock = NumberNode(value: 42)
        let thenBlock = NumberNode(value: 142)

        let ifElseNode = IfElseNode(condition: condition, then: thenBlock, else: elseBlock)

        let globalFunctionNode = FunctionNode(name: "main",
                                              arguments: [.init(label: nil, variableName: "a")],
                                              returnType: .double,
                                              body: ifElseNode)
        let buildContext = BuildContext()
        build([globalFunctionNode], context: buildContext)
        XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["IfElse"]) {
            // IfElse: ; ModuleID = 'main'
            // IfElse-NEXT: source_filename = "main"
            // IfElse: define double @main(double) {
            // IfElse-NEXT:     entry:
            // IfElse-NEXT:     %cmptmp = fcmp olt double %0, 1.000000e+01
            // IfElse-NEXT:     %1 = sitofp i1 %cmptmp to double
            // IfElse-NEXT:     %ifcond = fcmp one double %1, 0.000000e+00
            // IfElse-NEXT:     %local = alloca double
            // IfElse-NEXT:     br i1 %ifcond, label %then, label %else
            //
            // IfElse:     then:                                             ; preds = %entry
            // IfElse-NEXT:     br label %merge
            //
            // IfElse:     else:                                             ; preds = %entry
            // IfElse-NEXT:     br label %merge
            //
            // IfElse:     merge:                                            ; preds = %else, %then
            // IfElse-NEXT:     %phi = phi double [ 1.420000e+02, %then ], [ 4.200000e+01, %else ]
            // IfElse-NEXT:     store double %phi, double* %local
            // IfElse-NEXT:     ret double %phi
            // IfElse-NEXT: }
            buildContext.dump()
        })
    }
}
