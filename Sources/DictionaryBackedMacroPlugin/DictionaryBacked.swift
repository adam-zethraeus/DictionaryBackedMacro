import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct DictionaryBacked { }

extension DictionaryBacked: AccessorMacro {
  public static func expansion<
    Context: MacroExpansionContext,
    Declaration: DeclSyntaxProtocol
  >(
    of node: AttributeSyntax,
    providingAccessorsOf declaration: Declaration,
    in context: Context
  ) throws -> [AccessorDeclSyntax] {
    guard let varDecl = declaration.as(VariableDeclSyntax.self),
      let binding = varDecl.bindings.first,
      let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
      binding.accessor == nil,
      let type = binding.typeAnnotation?.type
    else {
      return []
    }

    // Ignore the generated `_storage` variable.
    if identifier.text == "_storage" {
      return []
    }
    let getAccessor: AccessorDeclSyntax =
      """
      get {
        _storage[\(literal: identifier.text)] as! \(type)
      }
      """
    let setAccessor: AccessorDeclSyntax =
      """
      set {
        _storage[\(literal: identifier.text)] = newValue
      }
      """

    return [
      getAccessor,
      setAccessor
    ]
  }
}

extension DictionaryBacked: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let storage: DeclSyntax = "var _storage: [String: Any] = [:]"

    guard let structDecl = declaration.as(StructDeclSyntax.self) else {
      throw CustomError.message("@DictionaryBacked may only be use on structs.")
    }

    let members = structDecl.memberBlock.members
            let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
            let variablesName = variableDecl.compactMap { $0.bindings.first?.pattern }
            let variablesType = variableDecl.compactMap { $0.bindings.first?.typeAnnotation?.type }

    let initializer = try InitializerDeclSyntax(Self.generateInitialCode(variablesName: variablesName, variablesType: variablesType)) {
      for name in variablesName {
          ExprSyntax("_storage[\"\(name)\"] = \(name)")
      }
    }

    return [
      DeclSyntax(initializer),
      storage.with(\.leadingTrivia, [.newlines(1), .spaces(2)])
    ]
  }

  public static func generateInitialCode(variablesName: [PatternSyntax],
                                          variablesType: [TypeSyntax]) -> PartialSyntaxNodeString {
      var initialCode: String = "public init("
      for (name, type) in zip(variablesName, variablesType) {
          initialCode += "\(name): \(type), "
      }
      initialCode = String(initialCode.dropLast(2))
      initialCode += ")"
      return PartialSyntaxNodeString(stringLiteral: initialCode)
  }

}

extension DictionaryBacked: MemberAttributeMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingAttributesFor member: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AttributeSyntax] {
    guard let property = member.as(VariableDeclSyntax.self),
          property.isStoredProperty
    else {
      return []
    }

    return [
      AttributeSyntax(
        attributeName: SimpleTypeIdentifierSyntax(
          name: .identifier("DictionaryBacked")
        )
      )
      .with(\.leadingTrivia, [.newlines(1), .spaces(2)])
    ]
  }

}

extension DictionaryBacked: ConformanceMacro {
  public static func expansion<Declaration, Context>(
    of node: AttributeSyntax,
    providingConformancesOf declaration: Declaration,
    in context: Context
  ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] where Declaration : DeclGroupSyntax, Context : MacroExpansionContext {
    return [ ("DictionaryBackedType", nil) ]
  }
}


enum CustomError: Error, CustomStringConvertible {
   case message(String)

   var description: String {
     switch self {
     case .message(let text):
       return text
     }
   }
 }

extension VariableDeclSyntax {
  /// Determine whether this variable has the syntax of a stored property.
  ///
  /// This syntactic check cannot account for semantic adjustments due to,
  /// e.g., accessor macros or property wrappers.
  var isStoredProperty: Bool {
    if bindings.count != 1 {
      return false
    }

    let binding = bindings.first!
    switch binding.accessor {
    case .none:
      return true

    case .accessors(let node):
      for accessor in node.accessors {
        switch accessor.accessorKind.tokenKind {
        case .keyword(.willSet), .keyword(.didSet):
          // Observers can occur on a stored property.
          break

        default:
          // Other accessors make it a computed property.
          return false
        }
      }

      return true

    case .getter:
      return false

    @unknown default:
      return false
    }
  }
}

extension DeclGroupSyntax {
  /// Enumerate the stored properties that syntactically occur in this
  /// declaration.
  func storedProperties() -> [VariableDeclSyntax] {
    return memberBlock.members.compactMap { member in
      guard let variable = member.decl.as(VariableDeclSyntax.self),
            variable.isStoredProperty else {
        return nil
      }

      return variable
    }
  }
}

extension DeclModifierSyntax {
  var isPublic: Bool {
    switch self.name.tokenKind {
    case .keyword(.public): return true
    default: return false
    }
  }
  var isPrivate: Bool {
    switch self.name.tokenKind {
    case .keyword(.private): return true
    default: return false
    }
  }
}

extension SyntaxStringInterpolation {
  // It would be nice for SwiftSyntaxBuilder to provide this out-of-the-box.
  mutating func appendInterpolation<Node: SyntaxProtocol>(_ node: Node?) {
    if let node {
      appendInterpolation(node)
    }
  }
}
