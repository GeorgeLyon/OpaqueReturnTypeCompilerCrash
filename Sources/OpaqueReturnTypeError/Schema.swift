// MARK: - Namespaces

/// All types are defined in this enum, so that they do not appear in the global namespace
public enum SchemaCoding {

  /// Types which do not need to be part of the public API of `SchemaCodable` types are defined in this namespace.
  /// This allows targets which depend on `SchemaCodable` to typealias just this namespace.
  public enum SchemaCodingSupport {

  }

}

// MARK: - Schema

typealias Schema = SchemaCoding.Schema

extension SchemaCoding {

  public typealias Schema = SchemaCodingSupport.Schema

}

extension SchemaCoding.SchemaCodingSupport {

  public protocol Schema<Value>: Sendable {

    associatedtype Value

  }

}

// MARK: - Schema Codable

extension SchemaCoding {

  public typealias SchemaCodable = SchemaCodingSupport.SchemaCodable

}

extension SchemaCoding.SchemaCodingSupport {

  public protocol SchemaCodable: Schema, Sendable {

    associatedtype Schema: SchemaCoding.Schema
    where Schema.Value == Self
    static var schema: Schema { get }

  }

}

// MARK: - Schema Decoding

extension SchemaCoding.SchemaCodingSupport {

  public enum DecodingResult<Value> {
    case incomplete
    case decoded(Value)
  }

}
