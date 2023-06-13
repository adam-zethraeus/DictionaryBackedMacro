public protocol DictionaryBackedType {
  var _storage: [String: Any] { get }
}

#if canImport(Foundation)
import Foundation
extension DictionaryBackedType {
  public func json() throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    let encodable: [String: AnyEncodable] = try _storage
      .mapValues { try ($0 as? any Encodable).unwrapped() }
      .mapValues { AnyEncodable($0) }
    let data = try encoder.encode(encodable)
    let jsonString = String(data: data, encoding: .utf8)
    return try jsonString.unwrapped()
  }
}
#endif

