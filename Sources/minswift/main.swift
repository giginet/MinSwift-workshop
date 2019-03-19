import MinSwiftKit
import Foundation

if CommandLine.arguments.count == 1 {
    try! sayGreeting()
} else {
    let file = CommandLine.arguments[1]
    let url = URL(fileURLWithPath: file)

    let engine = Engine()
    try! engine.load(from: url)
    engine.dump()
}
