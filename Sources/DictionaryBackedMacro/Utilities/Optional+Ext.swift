extension Optional {
  func unwrapped() throws -> Wrapped {
    try unwrappingResult().get()
  }
  func unwrappingResult() -> Result<Wrapped, OptionalUnwrappingError<Wrapped>> {
    switch self {
    case .none:
      return .failure(OptionalUnwrappingError(Wrapped.self))
    case .some(let wrapped):
      return .success(wrapped)
    }
  }
}

// MARK: - OptionalUnwrappingError

public struct OptionalUnwrappingError<T>: Error {
  public init(_: T.Type) { }
  public let description = "Could not unwrap \(T.self)?"
}
