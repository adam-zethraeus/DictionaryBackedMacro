extension Encodable {
  fileprivate func encode(to container: inout SingleValueEncodingContainer) throws {
    try container.encode(self)
  }
}

/// A wrapper allowing Encodable types to be encoded — even
/// when only references as an existential `any Encodable`.
///
/// source: https://forums.swift.org/t/how-to-encode-objects-of-unknown-type/12253/5
/// author: https://forums.swift.org/u/hamishknight/summary
public struct AnyEncodable: Encodable {
  var value: any Encodable
  public init(_ value: any Encodable) {
    self.value = value
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try value.encode(to: &container)
  }
}
