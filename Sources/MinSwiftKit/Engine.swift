import Foundation
import SwiftSyntax
import LLVM

public final class Engine {
    private let buildContext = BuildContext()

    public init() { }

    public func load(from url: URL) throws {
        let sourceFile = try SyntaxParser.parse(url)
        let parser = Parser()
        parser.visit(sourceFile)
        let nodes = parser.parse()
        build(nodes, context: buildContext)
    }

    public func load(from source: String) throws {
        let url = makeTemporaryFile(source)
        defer { removeTempoaryFile(at: url) }
        try load(from: url)
    }

    public func run<U>(_ functionName: String, of type: U.Type, handler: (U) -> Void) throws {
        let module = buildContext.module
        let jit = try JIT(machine: TargetMachine())
        _ = try jit.addEagerlyCompiledIR(module) { (_) -> JIT.TargetAddress in
            return JIT.TargetAddress()
        }
        let address = try jit.address(of: functionName)
        let function = unsafeBitCast(address, to: type)
        handler(function)
    }

    public func dump() {
        buildContext.module.dump()
    }
}
