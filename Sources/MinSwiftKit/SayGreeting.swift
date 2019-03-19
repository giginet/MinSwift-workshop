import LLVM
import Foundation

public func sayGreeting() throws {
    let strings = "Welcome to the Underground 😈".utf8CString

    let module = Module(name: "main")
    let builder = IRBuilder(module: module)

    let functionType = FunctionType(argTypes: [], returnType: ArrayType(elementType: IntType.int8, count: strings.count))
    let function = builder.addFunction("sayGreeting", type: functionType)
    let entryBasicBlock = function.appendBasicBlock(named: "entry")
    builder.positionAtEnd(of: entryBasicBlock)

    let values = strings.map { IntType.int8.constant($0) }

    builder.buildRet(ArrayType.constant(values, type: IntType.int8))
    module.dump()

    let jit = try JIT(machine: TargetMachine())
    typealias FnPtr = @convention(c) () -> UnsafePointer<CChar>
    _ = try jit.addEagerlyCompiledIR(module) { (_) -> JIT.TargetAddress in
        return JIT.TargetAddress()
    }
    // Retrieve a handle to the function we're going to invoke
    let addr = try jit.address(of: "sayGreeting")
    let fn = unsafeBitCast(addr, to: FnPtr.self)
    // Call the function!
    let ptr = fn()
    let greeting = String(cString: ptr, encoding: .utf8)!
    print(greeting)
}
