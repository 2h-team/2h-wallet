// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

extension NetworkService {
    func getBalance(_ params: BalanceRequest, completion: @escaping (Result<Balance, ServiceError>) -> Void){
        client.fetch(data: params) { result in
            switch result {
            case .success(let data):
                if let data = data {
                    do {
                        debugPrint(String(data: data, encoding: .utf8) ?? "")
                        let object = try self.decoder.decode(Balance.self, from: data)
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


    struct BalanceRequest: Encodable, Requestable {
        struct Token: Encodable {
            var id: String?
            var symbol: String?
            var address: String?
            var account: String
            var coinType: UInt32?
        }

        let tokens: [Token]
        let currency: String

        var method: APIMethods {
            .balance
        }
    }
}
