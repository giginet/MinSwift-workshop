import Foundation
import XCTest
import SwiftSyntax
import FileCheck
@testable import MinSwiftKit

class Practice6: ParserTestCase {
    // 6-1
    func testGenerateNumberNode() {
        let numberNode = NumberNode(value: 42)
        let context = BuildContext()
        let generated = generateIRValue(from: numberNode, with: context)
        XCTAssertTrue(generated.isAConstantFP)
        XCTAssertEqual(generated.kind, .constantFloat)
        XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["NumberNode"]) {
            // NumberNode: double 4.200000e+01
            generated.dump()
        })
    }

    // 6-2
    func testVariableNode() {
        let context = BuildContext()
        let argumentNode = NumberNode(value: 42)
        context.namedValues["a"] = generateIRValue(from: argumentNode, with: context)

        let variableNode = VariableNode(identifier: "a") // inject
        let generated = generateIRValue(from: variableNode, with: context)
        XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["VariableNode"]) {
            // VariableNode: double 4.200000e+01
            generated.dump()
        })
    }

    // 6-3
    func testBinaryExpressionNode() {
        do {
            let context = BuildContext()

            let node = BinaryExpressionNode(.addition,
                                            lhs: NumberNode(value: 21),
                                            rhs: NumberNode(value: 2))
            let generated = generateIRValue(from: node, with: context)
            XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["AdditionNode"]) {
                // AdditionNode: double 2.300000e+01
                generated.dump()
            })
        }

        do {
            let context = BuildContext()

            let node = BinaryExpressionNode(.subtraction,
                                            lhs: NumberNode(value: 21),
                                            rhs: NumberNode(value: 2))
            let generated = generateIRValue(from: node, with: context)
            XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["SubtractionNode"]) {
                // SubtractionNode: double 1.900000e+01
                generated.dump()
            })
        }

        do {
            let context = BuildContext()

            let additionNode = BinaryExpressionNode(.multication,
                                                    lhs: NumberNode(value: 21),
                                                    rhs: NumberNode(value: 2))
            let generated = generateIRValue(from: additionNode, with: context)
            XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["MulticationNode"]) {
                // MulticationNode: double 4.200000e+01
                generated.dump()
            })
        }

        do {
            let context = BuildContext()

            let node = BinaryExpressionNode(.division,
                                            lhs: NumberNode(value: 21),
                                            rhs: NumberNode(value: 2))
            let generated = generateIRValue(from: node, with: context)
            XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["DivisionNode"]) {
                // DivisionNode: double 1.050000e+01
                generated.dump()
            })
        }
    }

    // 6-4
    func testFunctionNode() {
        let context = BuildContext()

        let body = VariableNode(identifier: "a")
        let node = FunctionNode(name: "main",
                                arguments: [.init(label: nil, variableName: "a")],
                                returnType: .double,
                                body: body)
        build([node], context: context)
        XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["FunctionNode"]) {
            // FunctionNode: ; ModuleID = 'main'
            // FunctionNode-NEXT: source_filename = "main"

            // FunctionNode: define double @main(double) {
            // FunctionNode-NEXT:     entry:
            // FunctionNode-NEXT:     ret double %0
            // FunctionNode-NEXT: }
            context.dump()
        })
    }

    // 6-5
    func testCallExpressionNode() {
        let context = BuildContext()

        let functionNode = FunctionNode(name: "main",
                                        arguments: [.init(label: nil, variableName: "a")],
                                        returnType: .double,
                                        body: ReturnNode(body: VariableNode(identifier: "a")))
        let call = CallExpressionNode(callee: "main",
                                      arguments: [.init(label: nil, value: NumberNode(value: 42))])
        generateIRValue(from: functionNode, with: context)
        let generated = generateIRValue(from: call, with: context)
        XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["CallExpressionNode"]) {
            // CallExpressionNode: %calltmp = call double @main(double 4.200000e+01)
            generated.dump()
        })
    }

    // 6-6
    func testBuilder() {
        XCTAssertTrue(fileCheckOutput(of: .stderr, withPrefixes: ["FunctionWithArgument"]) {
            // FunctionWithArgument: ; ModuleID = 'main'
            // FunctionWithArgument-NEXT: source_filename = "main"

            // FunctionWithArgument: define double @square(double) {
            // FunctionWithArgument-NEXT:     entry:
            // FunctionWithArgument-NEXT:     %multmp = fmul double %0, %0
            // FunctionWithArgument-NEXT:     ret double %multmp
            // FunctionWithArgument-NEXT: }
            let buildContext = BuildContext()
            let body = BinaryExpressionNode(.multication,
                                            lhs: VariableNode(identifier: "x"),
                                            rhs: VariableNode(identifier: "x"))
            let returnNode = ReturnNode(body: body)
            build([
                FunctionNode(name: "square", arguments: [.init(label: nil, variableName: "x")], returnType: .double, body: returnNode)
                ],
                  context: buildContext)
            buildContext.dump()
        })
    }
}
