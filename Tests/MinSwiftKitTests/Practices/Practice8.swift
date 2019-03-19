import Foundation
import XCTest
@testable import MinSwiftKit

final class Practice8: XCTestCase {
    private let engine = Engine()

    // Don't worry, you already have everything 😈

    // 8-1
    func testCube() {
        let source = """
// WRITE YOUR OWN CODE
"""
        try! engine.load(from: source)
        typealias FunctionType = @convention(c) (Double) -> Double
        try! engine.run("cube", of: FunctionType.self) { cube in
            XCTAssertEqual(cube(3), 27)
            XCTAssertEqual(cube(42), 74088)
        }
    }

    // 8-2
    func testFactorial() {
        let source = """
// WRITE YOUR OWN CODE
"""
        try! engine.load(from: source)
        typealias FunctionType = @convention(c) (Double) -> Double
        try! engine.run("factorial", of: FunctionType.self) { factorial in
            XCTAssertEqual(factorial(4), 24)
            XCTAssertEqual(factorial(6), 720)
            XCTAssertEqual(factorial(10), 3628800)
        }
    }

    // 8-3
    func testFibonacci() {
        let source = """
// WRITE YOUR OWN CODE
"""
        try! engine.load(from: source)
        typealias FunctionType = @convention(c) (Double) -> Double
        try! engine.run("fibonacci", of: FunctionType.self) { fib in
            XCTAssertEqual(fib(10), 55)
            XCTAssertEqual(fib(20), 6765)
        }
    }
}
