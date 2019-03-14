import LLVM

public func sayGreeting() throws {
    let module = Module(name: "main")
    let builder = IRBuilder(module: module)

    let functionType = FunctionType(argTypes: [], returnType: IntType.int64)
    let function = builder.addFunction("sayGreeting", type: functionType)
    let entryBasicBlock = function.appendBasicBlock(named: "entry")
    builder.positionAtEnd(of: entryBasicBlock)
    
    builder.buildRet(IntType.int64.constant(42))
    module.dump()
    
    let jit = try JIT(machine: TargetMachine())
    typealias FnPtr = @convention(c) () -> Int64
    _ = try jit.addEagerlyCompiledIR(module) { (name) -> JIT.TargetAddress in
        return JIT.TargetAddress()
    }
    // Retrieve a handle to the function we're going to invoke
    let addr = try jit.address(of: "sayGreeting")
    let fn = unsafeBitCast(addr, to: FnPtr.self)
    // Call the function!
    print(fn())
    print("Welcome to Underground 👿")
}
