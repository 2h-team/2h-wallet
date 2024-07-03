// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

fileprivate let ENDPOINT = URL(string: "http://localhost:8087")!

fileprivate struct JSON {
    static let encoder = JSONEncoder()
}

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case patch = "PATCH"
    case post = "POST"
    case delete = "DELETE"
}

enum APIMethods {
    case balance
    case config
    case tokens(q: String, offset: Int, limit: Int, coinTypes: [Int])

    var url: URL {
        switch self {
        case .balance:
            return ENDPOINT.appendingPathComponent("account/balance")
        case .config:
            return ENDPOINT.appendingPathComponent("resources/config")
        case .tokens(let q, let offset, let limit, let coinTypes):

            return ENDPOINT.appendPathString("resources/tokens?limit=\(limit)&offset=\(offset)&q=\(q.urlEncoded() ?? "")&\(coinTypes.map { "coinTypes[]=\($0)" }.joined(separator: "&"))")
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .balance:
            return .post
        case .config:
            return .get
        case .tokens:
            return .get
        }
    }

    var headers: [String: String] {
        switch self {
        case .balance:
            [:]
        case .config:
            [:]
        case .tokens:
            [:]
        }
    }
}

extension Encodable {
    // SKIP NOWARN
    var asDictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSON.encoder.encode(self))) as? [String: Any] ?? [:]
    }
}

struct ServerError: Decodable {
    let statusCode: Int
    let error: String
    let message: String?
}

protocol Requestable: Encodable {
    var method: APIMethods { get }
    var __isEmpty: Bool { get }
}

extension Requestable {
    var __isEmpty: Bool {
        false
    }
}

enum APIClientError: Error, LocalizedError {
    case serverError(ServerError)
    case commonError(statusCode: Int)
    case someError(Error?)

    var errorDescription: String? {
        switch self {
        case .serverError(let error):
            return error.message ?? error.error
        case .commonError(let status):
            return "Error with status \(status)"
        case .someError(let error):
            return error?.localizedDescription ?? "Unknown error, try again."
        }
    }
}

public class APIClient {

    static let shared = APIClient()
    private let decoder = JSONDecoder()

    private init() {}

    func fetch(data: Requestable, completion: @escaping (Result<Data?, APIClientError>) -> Void) {
        do {
            let task = URLSession.shared.dataTask(with: try data.asURLRequest()) { data, response, error in
                if let error = error {
                    completion(.failure(.someError(error)))
                    return
                }

                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    completion(.failure(APIClientError.someError(nil)))
                    return
                }
                if self.acceptableStatusCodes.contains(statusCode) {
                    completion(.success(data))
                } else {

                    debugPrint(String(data: data ?? Data(), encoding: .utf8) ?? "")
                    if let error = try? self.decoder.decode(ServerError.self, from: data ?? Data()) {
                        completion(.failure(APIClientError.serverError(error)))
                    } else {
                        completion(.failure(APIClientError.commonError(statusCode: statusCode)))
                    }
                }
            }
            task.resume()
        } catch {
            completion(.failure(.someError(error)))
        }
    }

    private var acceptableStatusCodes: Range<Int> { return 200..<300 }
}

extension Requestable {
    func asURLRequest() throws -> URLRequest {
        var urlRequest: URLRequest = URLRequest(url: method.url)
        let parameters: [String: Any]
        if self.__isEmpty {
            parameters = [:]
        } else {
            parameters = self.asDictionary
        }
        urlRequest.httpMethod = method.httpMethod.rawValue
        method.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        if method.httpMethod == .get {
            // TODO: - Need added parse
        } else {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            urlRequest.httpBody = data
        }

        return urlRequest
    }
}
