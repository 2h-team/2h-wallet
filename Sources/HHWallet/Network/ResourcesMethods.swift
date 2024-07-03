// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

extension NetworkService {
    func getConfig(completion: @escaping (Result<Resources.Config, ServiceError>) -> Void){
        client.fetch(data: ConfigRequest()) { result in
            switch result {
            case .success(let data):
                if let data = data {
                    do {
                        debugPrint(String(data: data, encoding: .utf8) ?? "")
                        let object = try self.decoder.decode(Resources.Config.self, from: data)
                        completion(.success(object))
                    } catch {
                        completion(.failure(.error(error)))
                    }

                } else {
                    completion(.failure(ServiceError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(.apiError(error)))
            }
        }
    }

    func getTokens(limit: Int, offset: Int, count: Int = 30, q: String? = nil, blockchains: [Blockchain] = [], completion: @escaping (Result<[Token], ServiceError>) -> Void){
        client.fetch(data: TokensRequest(limit: limit, offset: offset, q: q ?? "", blockchains: blockchains)) { result in
            switch result {
            case .success(let data):
                if let data = data {
                    do {
                        debugPrint(String(data: data, encoding: .utf8) ?? "")
                        let object = try self.decoder.decode([Token].self, from: data)
                        completion(.success(object))
                    } catch {
                        completion(.failure(.error(error)))
                    }

                } else {
                    completion(.failure(ServiceError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(.apiError(error)))
            }
        }
    }

    struct ConfigRequest: Encodable, Requestable {
        let __isEmpty: Bool = true
        var method: APIMethods {
            .config
        }
    }

    struct TokensRequest: Encodable, Requestable {
        let limit: Int
        let offset: Int
        let q: String

        let blockchains: [Blockchain]

        var method: APIMethods {
            .tokens(q: q, offset: offset, limit: limit, coinTypes: blockchains.map { $0.coinType })
        }
    }

}
