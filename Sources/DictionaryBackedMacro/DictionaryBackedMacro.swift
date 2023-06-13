/// ``DictionaryBacked`` expands a struct to use internal dictionary storage to
/// back the declared members.
///
/// This macro also conforms the struct type to ``DictionaryBackedType``
/// providing a JSON String dumping method:
///
/// `func json() throws -> String`
@attached(accessor)
@attached(member, names: named(_storage), named(init))
@attached(memberAttribute)
@attached(conformance)
public macro DictionaryBacked() = #externalMacro(module: "DictionaryBackedMacroPlugin", type: "DictionaryBacked")
