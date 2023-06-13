# @DictionaryBacked

`@DictionaryBacked` is a simple swift macro which:
* replaces a struct's stored members with a backing dictionary
* adds a memberwise intializer for its fields
* conforms it to a protocol with some utility extensions

It's based on @DougGregor's [swift-macro-examples](https://github.com/DougGregor/swift-macro-examples) and @HuangRunHua's [@StructInit](https://github.com/HuangRunHua/wwdc23-code-notes/struct-init-macro).

