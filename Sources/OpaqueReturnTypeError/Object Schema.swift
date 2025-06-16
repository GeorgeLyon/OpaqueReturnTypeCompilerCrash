// MARK: - Public API

extension SchemaCoding {

  public typealias ObjectSchema = SchemaCodingSupport.ObjectSchema

}

extension SchemaCoding.SchemaCodingSupport {

  public static func objectSchema<
    Value,
    each PropertyValueSchema: Schema
  >(
    representing _: Value.Type,
    description: String? = nil,
    properties: (
      repeat SchemaCoding.SchemaCodingSupport.ObjectPropertyDefinition<
        each PropertyValueSchema
      >
    ),
    initializer: @escaping @Sendable (
      (repeat (each PropertyValueSchema).Value)
    ) -> Value
  ) -> some SchemaCoding.ObjectSchema<Value> {
    SimpleObjectSchema(
      properties: repeat each properties,
      initializer: initializer
    )
  }

  public protocol ObjectSchema<Value>: Schema {

    func encodePropertySchemas(to encoder: inout ObjectSchemaEncoder)

    func encodeProperties(to encoder: inout ObjectEncoder)

    func decodeProperties(
      from decoder: inout ObjectDecoder<Self>
    ) throws -> DecodingResult<Value>

  }

  public struct ObjectPropertyDefinition<ValueSchema: Schema>: Sendable {
    public init(
      name: StaticString,
      description: String? = nil,
      schema: ValueSchema
    ) {
      self.init(name: "\(name)", description: description, schema: schema)
    }
    init(
      name: String,
      description: String? = nil,
      schema: ValueSchema
    ) {
      self.name = name
      self.description = description
      self.schema = schema
    }
    let name: String
    let description: String?
    let schema: ValueSchema
  }

  public struct ObjectSchemaEncoder: ~Copyable {
    var requiredPropertyNames: [String]
  }

  public struct ObjectEncoder: ~Copyable {

  }

  public struct ObjectDecoder<Schema: ObjectSchema>: ~Copyable {

  }

}

extension SchemaCoding.SchemaCodingSupport.ObjectSchema {

  public func withAdditionalProperties<AdditionalPropertiesValue, each AdditionalPropertySchema>(
    _ additionalProperties: repeat SchemaCoding.SchemaCodingSupport.ObjectPropertyDefinition<
      each AdditionalPropertySchema
    >,
    initializer: @escaping @Sendable (
      (repeat (each AdditionalPropertySchema).Value)
    ) -> AdditionalPropertiesValue
  ) -> some SchemaCoding.SchemaCodingSupport.ObjectSchema<(Value, AdditionalPropertiesValue)> {
    CompoundObjectSchema(
      firstObjectSchema: self,
      secondObjectSchema: SimpleObjectSchema(
        properties: repeat each additionalProperties,
        initializer: initializer
      ),
      initializer: { first, second in
        (first, second)
      }
    )
  }

}

// MARK: - Concrete Schemas

struct SimpleObjectSchema<Value, each PropertyValueSchema: Schema>: SchemaCoding
    .ObjectSchema
{

  init(
    properties:
      repeat SchemaCoding.SchemaCodingSupport.ObjectPropertyDefinition<each PropertyValueSchema>,
    initializer: @escaping @Sendable ((repeat (each PropertyValueSchema).Value)) -> Value
  ) {
    self.properties = (repeat each properties)
    self.initializer = initializer
  }

  let description: String? = nil
  let properties:
    (
      repeat SchemaCoding.SchemaCodingSupport.ObjectPropertyDefinition<each PropertyValueSchema>
    )
  let initializer: @Sendable ((repeat (each PropertyValueSchema).Value)) -> Value

  func encodePropertySchemas(
    to encoder: inout SchemaCoding.SchemaCodingSupport.ObjectSchemaEncoder
  ) {

  }

  func encodeProperties(
    to encoder: inout SchemaCoding.SchemaCodingSupport.ObjectEncoder
  ) {

  }

  func decodeProperties(
    from decoder: inout SchemaCoding.SchemaCodingSupport.ObjectDecoder<Self>
  ) throws -> SchemaCoding.SchemaCodingSupport.DecodingResult<Value> {
    fatalError()
  }

}

private struct CompoundObjectSchema<
  Value,
  FirstObjectSchema: SchemaCoding.ObjectSchema,
  SecondObjectSchema: SchemaCoding.ObjectSchema
>: SchemaCoding.ObjectSchema {

  let firstObjectSchema: FirstObjectSchema
  let secondObjectSchema: SecondObjectSchema
  let initializer:
    @Sendable (
      FirstObjectSchema.Value,
      SecondObjectSchema.Value
    ) -> Value

  func encodePropertySchemas(
    to encoder: inout SchemaCoding.SchemaCodingSupport.ObjectSchemaEncoder
  ) {
    firstObjectSchema.encodePropertySchemas(to: &encoder)
    secondObjectSchema.encodePropertySchemas(to: &encoder)
  }

  func encodeProperties(
    to encoder: inout SchemaCoding.SchemaCodingSupport.ObjectEncoder
  ) {
    firstObjectSchema.encodeProperties(to: &encoder)
    secondObjectSchema.encodeProperties(to: &encoder)
  }

  func decodeProperties(
    from decoder: inout SchemaCoding.SchemaCodingSupport.ObjectDecoder<Self>
  ) throws -> SchemaCoding.SchemaCodingSupport.DecodingResult<Value> {
    fatalError()
  }

}
