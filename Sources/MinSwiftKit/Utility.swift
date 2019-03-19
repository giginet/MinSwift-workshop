import Foundation

func makeTemporaryFile(_ content: String) -> URL {
    let contentURL = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("swift")
    FileManager.default.createFile(atPath: contentURL.path,
                           contents: content.data(using: .utf8),
                           attributes: [:])
    return contentURL
}

func removeTempoaryFile(at url: URL) {
    try! FileManager.default.removeItem(at: url)
}
