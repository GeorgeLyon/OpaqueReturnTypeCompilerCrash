// MARK: - Case Definition

extension SchemaCoding.SchemaCodingSupport {

  public struct EnumSchemaCaseDefinition<
    Value,
    AssociatedValuesSchema: Schema
  >: Sendable {
    public init(
      name: StaticString,
      description: String?,
      schema: AssociatedValuesSchema,
      initializer: @escaping @Sendable (AssociatedValuesSchema.Value) -> Value
    ) {
      self.name = name
      self.description = description
      self.schema = schema
      self.initializer = initializer
    }

    fileprivate let name: StaticString
    fileprivate let description: String?
    fileprivate let schema: AssociatedValuesSchema
    fileprivate let initializer: @Sendable (AssociatedValuesSchema.Value) -> Value
  }

}

extension SchemaCoding.SchemaCodingSupport {

  static func enumSchemaCaseDefinition<
    Value,
    AssociatedValueSchema
  >(
    name: StaticString,
    description: String? = nil,
    associatedValues associatedValue: SchemaCoding.SchemaCodingSupport
      .EnumSchemaNamedAssociatedValueDefinition<
        AssociatedValueSchema
      >,
    initializer: @escaping @Sendable (AssociatedValueSchema.Value) -> Value
  ) -> EnumSchemaCaseDefinition<
    Value,
    some Schema<AssociatedValueSchema.Value>
  > {
    let schema: some ObjectSchema<AssociatedValueSchema.Value> = objectSchema(
      representing: AssociatedValueSchema.Value.self,
      description: nil,
      properties: (ObjectPropertyDefinition(
        name: associatedValue.name,
        description: nil,
        schema: associatedValue.schema
      )),
      initializer: { (value: AssociatedValueSchema.Value) in
        value
      }
    )
    let initializer = { @Sendable (value: AssociatedValueSchema.Value) -> Value in
      initializer(value)
    }
    let def: EnumSchemaCaseDefinition<Value, some Schema<AssociatedValueSchema.Value>> = EnumSchemaCaseDefinition(
       name: name,
       description: description,
       schema: schema,
       initializer: initializer
     )
    /// Uncommenting this crashes the compiler
//     return def
  }
  
}

// MARK: - Associated Value Definition

extension SchemaCoding.SchemaCodingSupport {

  public protocol EnumSchemaAssociatedValueDefinition: Sendable {
    associatedtype Schema: SchemaCoding.SchemaCodingSupport.Schema
    var schema: Schema { get }
    var description: String? { get }
  }

  public struct EnumSchemaNamedAssociatedValueDefinition<Schema: SchemaCoding.Schema>:
    EnumSchemaAssociatedValueDefinition
  {
    public init(name: StaticString, schema: Schema) {
      self.name = "\(name)"
      self.schema = schema
    }
    public let schema: Schema
    public var description: String? {
      name
    }

    fileprivate let name: String
  }

  public struct EnumSchemaUnnamedAssociatedValueDefinition<Schema: SchemaCoding.Schema>:
    EnumSchemaAssociatedValueDefinition
  {
    public init(schema: Schema) {
      self.schema = schema
    }
    public let schema: Schema
    public var description: String? { nil }
  }

}
