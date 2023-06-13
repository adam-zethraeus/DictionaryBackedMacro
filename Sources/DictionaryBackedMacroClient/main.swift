import DictionaryBackedMacro

/// ``MyStruct`` is conformed to ``DictionaryBackedType`` and expanded as follows: 
/// ```swift
/// struct MyStruct {
///   var x: Int {
///       get {
///         _storage["x"] as! Int
///       }
///       set {
///         _storage["x"] = newValue
///       }
///   }
///   var y: Bool {
///       get {
///         _storage["y"] as! Bool
///       }
///       set {
///         _storage["y"] = newValue
///       }
///   }
///   var z: String {
///       get {
///         _storage["z"] as! String
///       }
///       set {
///         _storage["z"] = newValue
///       }
///   }
///   init(x: Int, y: Bool, z: String) {
///       _storage["x"] = x
///       _storage["y"] = y
///       _storage["z"] = z
///   }
///   var _storage: [String: Any] = [:]
/// }
/// ```
@DictionaryBacked
struct MyStruct {
  var x: Int
  var y: Bool
  var z: String
}

let test = MyStruct(x: 123, y: false, z: "456")
print(try! test.json())

