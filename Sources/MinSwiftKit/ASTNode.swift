import Foundation

public protocol Node { }

public struct NumberNode: Node {
    public let value: Double

    public init(value: Double) {
        self.value = value
    }
}

public struct BinaryExpressionNode: Node {
    public enum Operator: String, Hashable {
        case addition = "+"
        case subtraction = "-"
        case multication = "*"
        case division = "/"
        case lessThan = "<"
    }
    public let `operator`: Operator
    public let lhs: Node
    public let rhs: Node

    public init(_ operator: Operator, lhs: Node, rhs: Node) {
        self.operator = `operator`
        self.lhs = lhs
        self.rhs = rhs
    }
}

public struct FunctionNode: Node {
    public let name: String
    public let arguments: [Argument]
    public let returnType: Type
    public let body: Node

    public struct Argument {
        var label: String?
        var variableName: String
        // var valueType: Type // Currently support double only

        public init(label: String?, variableName: String) {
            self.label = label
            self.variableName = variableName
        }
    }

    public init(name: String, arguments: [Argument], returnType: Type, body: Node) {
        self.name = name
        self.arguments = arguments
        self.returnType = returnType
        self.body = body
    }
}

public struct CallExpressionNode: Node {
    public let callee: String
    public let arguments: [Argument]

    public struct Argument {
        var label: String?
        var value: Node

        public init(label: String?, value: Node) {
            self.label = label
            self.value = value
        }
    }

    public init(callee: String, arguments: [Argument]) {
        self.callee = callee
        self.arguments = arguments
    }
}

public struct VariableNode: Node {
    public let identifier: String

    public init(identifier: String) {
        self.identifier = identifier
    }
}

public struct ReturnNode: Node {
    public let body: Node?

    public init(body: Node?) {
        self.body = body
    }
}

public struct IfElseNode: Node {
    public let condition: Node
    public let then: Node
    public let `else`: Node?

    public init(condition: Node, then: Node, `else`: Node?) {
        self.condition = condition
        self.then = then
        self.else = `else`
    }
}

public struct VoidNode: Node {
}
