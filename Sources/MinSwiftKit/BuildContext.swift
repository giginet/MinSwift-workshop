import Foundation
import LLVM

class BuildContext {
    public let module = Module(name: "main")
    let builder: IRBuilder
    var namedValues: [String: IRValue] = [:]

    init() {
        builder = IRBuilder(module: module)
    }

    func dump() {
        module.dump()
    }
}

func build(_ nodes: [Node], context: BuildContext) {
    for node in nodes {
        generateIRValue(from: node, with: context)
    }
}
