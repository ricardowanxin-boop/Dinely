import Foundation

final class JSONFileStore {
    private let directoryURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init() {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        directoryURL = baseURL.appendingPathComponent("\(AppConfig.projectName)Cache", isDirectory: true)
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func save<T: Encodable>(_ value: T, as filename: String) throws {
        let url = directoryURL.appendingPathComponent(filename)
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

    func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        let url = directoryURL.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try decoder.decode(type, from: data)
    }
}
