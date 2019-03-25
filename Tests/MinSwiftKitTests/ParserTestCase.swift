import Foundation
import XCTest
import SwiftSyntax
@testable import MinSwiftKit

class ParserTestCase: XCTestCase {
    let parser = Parser()

    func load(_ content: String) {
        let url = makeTemporaryFile(content)
        defer { removeTempoaryFile(at: url) }
        let sourceFile = try! SyntaxTreeParser.parse(url)
        parser.visit(sourceFile)
        parser.read()
    }
}
