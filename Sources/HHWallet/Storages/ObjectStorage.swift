// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

protocol StorageProtocol {
    func get<O: Decodable>(_ type: O.Type, prefix: String) -> O?
    func set<O: Encodable>(_ o: O, prefix: String)
}

#if SKIP
final class KotlinObjectStorage: StorageProtocol {

    static let shared = KotlinObjectStorage()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let settings = UserDefaults.standard

    func get<O: Decodable>(_ type: O.Type, prefix: String = "") -> O? {
        return nil
    }

    func set<O: Encodable>(_ o: O, prefix: String = "") {

    }
}
#else
final class ObjectStorage: StorageProtocol {

    static let shared = ObjectStorage()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let settings = UserDefaults.standard

    func get<O: Decodable>(_ type: O.Type, prefix: String = "") -> O? {
        guard let data = settings.data(forKey: "\(prefix)\(String(describing: type))") else { return nil }
        guard let object = try? decoder.decode(type, from: data) else { return nil }
        return object
    }

    func set<O: Encodable>(_ o: O, prefix: String = "") {
        guard let data = try? encoder.encode(o) else { return }
        settings.set(data, forKey: "\(prefix)\(String(describing: type(of: o)))")
    }
}
#endif

class ObjectStorageWrapper {
    static let shared = ObjectStorageWrapper()

    #if SKIP
    let service: StorageProtocol = KotlinObjectStorage.shared
    #else
    let service: StorageProtocol = ObjectStorage.shared
    #endif
}
