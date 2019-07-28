import Foundation
import SwiftSyntax

class Parser: SyntaxVisitorBase {
    private(set) var tokens: [TokenSyntax] = []
    private var index = 0
    private(set) var currentToken: TokenSyntax!

    // MARK: Practice 1
    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
        tokens.append(token)
        return .visitChildren
    }

    @discardableResult
    func read() -> TokenSyntax {
        currentToken = tokens[index]
        index += 1
        return currentToken
    }

    func peek(_ n: Int = 0) -> TokenSyntax {
        return tokens[index + n]
    }

    // MARK: Practice 2

    private func extractNumberLiteral(from token: TokenSyntax) -> Double? {
        return Double(token.text)
    }

    func parseNumber() -> Node {
        guard let value = extractNumberLiteral(from: currentToken) else {
            fatalError("any number is expected")
        }
        read() // eat literal
        return NumberNode(value: value)
    }

    func parseIdentifierExpression() -> Node {        
        let node = VariableNode(identifier: currentToken.text)
        read()
        return node
    }

    // MARK: Practice 3

    func extractBinaryOperator(from token: TokenSyntax) -> BinaryExpressionNode.Operator? {
        switch token.text {
        case "+":
            return .addition
        case "-":
            return .subtraction
        case "*":
            return .multication
        case "/":
            return .division
        default:
            return nil
        }
    }

    private func parseBinaryOperatorRHS(expressionPrecedence: Int, lhs: Node) -> Node? {
        var lhs = lhs
        
        while true {
            guard let binaryOperator = extractBinaryOperator(from: currentToken) else {
                break
            }
            
            let operatorPrecedence = binaryOperator.precedence

            // Compare between operatorPrecedence and expressionPrecedence
            if operatorPrecedence < expressionPrecedence {
                break
            }

            read() // eat binary operator
            
            guard var rhs = parsePrimary() else {
                return nil
            }

            // If binOperator binds less tightly with RHS than the operator after RHS, let
            // the pending operator take RHS as its LHS.
            if let nextOperator = extractBinaryOperator(from: currentToken!) {
                if nextOperator.precedence > expressionPrecedence {
                    // Search next RHS from currentRHS
                    // next precedence will be `operatorPrecedence + 1`
                    
                    guard let newRHS = parseBinaryOperatorRHS(expressionPrecedence: operatorPrecedence + 1,
                                                              lhs: rhs) else
                    {
                        return nil
                    }
                    
                    rhs = newRHS
                }
            }

            lhs = BinaryExpressionNode(binaryOperator,
                                       lhs: lhs,
                                       rhs: rhs)
        }
        
        return lhs
    }

    // MARK: Practice 4

    func parseFunctionDefinitionArgument() -> FunctionNode.Argument {
        fatalError("Not Implemented")
    }

    func parseFunctionDefinition() -> Node {
        fatalError("Not Implemented")
    }

    // MARK: Practice 7

    func parseIfElse() -> Node {
        fatalError("Not Implemented")
    }

    // PROBABLY WORKS WELL, TRUST ME

    func parse() -> [Node] {
        var nodes: [Node] = []
        read()
        while true {
            switch currentToken.tokenKind {
            case .eof:
                return nodes
            case .funcKeyword:
                let node = parseFunctionDefinition()
                nodes.append(node)
            default:
                if let node = parseTopLevelExpression() {
                    nodes.append(node)
                    break
                } else {
                    read()
                }
            }
        }
        return nodes
    }

    private func parsePrimary() -> Node? {
        switch currentToken.tokenKind {
        case .identifier:
            return parseIdentifierExpression()
        case .integerLiteral, .floatingLiteral:
            return parseNumber()
        case .leftParen:
            return parseParen()
        case .funcKeyword:
            return parseFunctionDefinition()
        case .returnKeyword:
            return parseReturn()
        case .ifKeyword:
            return parseIfElse()
        case .eof:
            return nil
        default:
            fatalError("Unexpected token \(currentToken.tokenKind) \(currentToken.text)")
        }
        return nil
    }

    func parseExpression() -> Node? {
        guard let lhs = parsePrimary() else {
            return nil
        }
        return parseBinaryOperatorRHS(expressionPrecedence: 0, lhs: lhs)
    }

    private func parseReturn() -> Node {
        guard case .returnKeyword = currentToken.tokenKind else {
            fatalError("returnKeyword is expected but received \(currentToken.tokenKind)")
        }
        read() // eat return
        if let expression = parseExpression() {
            return ReturnNode(body: expression)
        } else {
            // return nothing
            return ReturnNode(body: nil)
        }
    }

    private func parseParen() -> Node? {
        read() // eat (
        guard let v = parseExpression() else {
            return nil
        }

        guard case .rightParen = currentToken.tokenKind else {
                fatalError("expected ')'")
        }
        read() // eat )

        return v
    }

    private func parseTopLevelExpression() -> Node? {
        if let expression = parseExpression() {
            // we treat top level expressions as anonymous functions
            let anonymousPrototype = FunctionNode(name: "main", arguments: [], returnType: .int, body: expression)
            return anonymousPrototype
        }
        return nil
    }
}

private extension BinaryExpressionNode.Operator {
    var precedence: Int {
        switch self {
        case .addition, .subtraction: return 20
        case .multication, .division: return 40
        case .lessThan:
            fatalError("Not Implemented")
        }
    }
}
