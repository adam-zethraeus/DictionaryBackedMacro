import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct DictionaryBackedPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
      DictionaryBacked.self,
    ]
}
