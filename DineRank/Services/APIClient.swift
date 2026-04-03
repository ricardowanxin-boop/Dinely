import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unexpectedStatusCode(Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            L10n.string("接口地址不可用。")
        case .invalidResponse:
            L10n.string("接口返回格式不可识别。")
        case let .unexpectedStatusCode(code):
            L10n.format("接口返回了异常状态码 %d。", code)
        case .decodingFailed:
            L10n.string("接口解码失败，请检查模型定义。")
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct APIRequest<Response: Decodable> {
    let path: String
    var method: HTTPMethod = .get
    var queryItems: [URLQueryItem] = []
    var headers: [String: String] = [:]
    var body: Data?
}

final class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(baseURL: URL = AppConfig.apiBaseURL) {
        self.baseURL = baseURL

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AppConfig.requestTimeout
        configuration.timeoutIntervalForResource = AppConfig.requestTimeout
        session = URLSession(configuration: configuration)
    }

    func send<Response: Decodable>(_ request: APIRequest<Response>) async throws -> Response {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(request.path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        components.queryItems = request.queryItems.isEmpty ? nil : request.queryItems
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        AppConfig.apiDefaultHeaders.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw APIError.unexpectedStatusCode(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
