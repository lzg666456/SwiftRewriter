import SwiftAST
import SwiftRewriterLib
import MiniLexer

private typealias SwiftRewriterAttribute = SwiftClassInterfaceParser.SwiftRewriterAttribute

extension IncompleteKnownType {
    
    func toCompoundedKnownType(
        _ typeSystem: TypeSystem = DefaultTypeSystem.defaultTypeSystem) throws -> CompoundedMappingType {
        
        let type = complete(typeSystem: typeSystem)
        
        var nonCanonicalNames: [String] = []
        var transformations: [PostfixTransformation] = []
        
        do {
            nonCanonicalNames = try aliases(in: type)
            
            transformations.append(contentsOf:
                try type.knownConstructors.flatMap {
                    try initTransformations($0, type: type)
                }
            )
            transformations.append(contentsOf:
                try type.knownProperties.flatMap(propertyTransformations)
            )
            transformations.append(contentsOf:
                try type.knownMethods.flatMap {
                    try methodTransformations($0, type: type)
                }
            )
        } catch {
            throw IncompleteTypeError(description:
                "Found error while parsing @\(SwiftRewriterAttribute.name) attribute: \(error)"
            )
        }
        
        return CompoundedMappingType(knownType: type,
                                     transformations: transformations,
                                     semantics: [],
                                     aliases: nonCanonicalNames)
    }
}

struct IncompleteTypeError: Error {
    var description: String
}

private func aliases(in type: KnownType) throws -> [String] {
    var aliases: [String] = []
    
    for attribute in type.knownAttributes {
        guard attribute.name == SwiftRewriterAttribute.name else {
            continue
        }
        
        let attr = try parseAttribute(attribute)
        
        switch attr.content {
        case .renameFrom(let name):
            aliases.append(name)
        default:
            // TODO: Throw diagnostic error for unsupported mappings
            break
        }
    }
    
    return aliases
}

private func initTransformations(_ ctor: KnownConstructor, type: KnownType) throws -> [PostfixTransformation] {
    var transforms: [PostfixTransformation] = []
    
    func _mapStaticMethod(_ identifier: FunctionIdentifier) {
        let transformer = ValueTransformer<PostfixExpression, Expression> { $0 }
            .validate { exp in
                guard let member = exp.asPostfix?.exp.asPostfix?.member?.name else {
                    return false
                }
                
                return
                    exp.asPostfix?
                        .functionCall?
                        .identifierWith(methodName: member) == identifier
            }
            .decompose()
            .transformIndex(index: 0, transformer: ValueTransformer()
                .removingMemberAccess()
                .validate(matcher: ValueMatcher()
                    .isTyped(.metatype(for: .typeName(type.typeName)),
                             ignoringNullability: true)
                )
            )
            .asFunctionCall(labels: ctor.parameters.argumentLabels())
            .typed(.typeName(type.typeName))
        
        transforms.append(.valueTransformer(transformer.anyExpression()))
    }
    
    func _mapFreeFunction(_ identifier: FunctionIdentifier) {
        let transformer = ValueTransformer<PostfixExpression, Expression> { $0 }
            .validate { exp in
                guard let ident = exp.asPostfix?.exp.asIdentifier else {
                    return false
                }
                
                return
                    exp.asPostfix?
                        .functionCall?
                        .identifierWith(methodName: ident.identifier) == identifier
            }
            .decompose()
            .replacing(index: 0, with: Expression.identifier(type.typeName))
            .asFunctionCall(labels: ctor.parameters.argumentLabels())
            .typed(.typeName(type.typeName))
        
        transforms.append(.valueTransformer(transformer.anyExpression()))
    }
    
    for attribute in ctor.knownAttributes {
        guard attribute.name == SwiftRewriterAttribute.name else {
            continue
        }
        
        let attr = try parseAttribute(attribute)
        
        switch attr.content {
        case .mapFrom(let signature):
            if signature.name == "init" {
                transforms.append(
                    .initializer(old: signature.parameters.argumentLabels(),
                                 new: ctor.parameters.argumentLabels()))
            } else {
                _mapStaticMethod(signature.asIdentifier)
            }
            
        case .mapFromIdentifier(let identifier):
            if identifier.name == "init" {
                transforms.append(
                    .initializer(old: identifier.parameterNames,
                                 new: ctor.parameters.argumentLabels()))
            } else {
                _mapStaticMethod(identifier)
            }
            
        case .initFromFunction(let identifier):
            _mapFreeFunction(identifier)
            
        case .renameFrom, .mapToBinaryOperator:
            // TODO: Throw diagnostic error for unsupported mappings
            break
        }
    }
    
    return transforms
}

private func methodTransformations(_ method: KnownMethod, type: KnownType) throws -> [PostfixTransformation] {
    func makeTransformation(identifier: FunctionIdentifier) -> PostfixTransformation {
        
        // Free function to method conversion
        if identifier.parameterNames.first == "self" {
            
            let transformer = FunctionInvocationTransformer(
                objcFunctionName: identifier.name,
                toSwiftFunction: method.signature.name,
                firstArgumentBecomesInstance: true,
                arguments: method.signature.parameters.map { arg in
                    arg.label.flatMap { .labeled($0, .asIs) } ?? .asIs
                }
            )
            
            return .function(transformer)
        }
        
        let builder =
            MethodInvocationRewriterBuilder(mappingTo: method.signature)
        
        let transformer =
            MethodInvocationTransformerMatcher(
                identifier: identifier,
                isStatic: method.isStatic,
                transformer: builder.build())
        
        return .method(transformer)
    }
    func makeTransformation(signature: FunctionSignature) -> PostfixTransformation {
        return makeTransformation(identifier: signature.asIdentifier)
    }
    
    var transforms: [PostfixTransformation] = []
    
    for attribute in method.knownAttributes {
        guard attribute.name == SwiftRewriterAttribute.name else {
            continue
        }
        
        let attr = try parseAttribute(attribute)
        
        switch attr.content {
        case .renameFrom(let ident):
            let builder =
                MethodInvocationRewriterBuilder(mappingTo: method.signature)
            
            let ident =
                FunctionIdentifier(
                    name: ident,
                    parameterNames: method.signature.asIdentifier.parameterNames)
            
            let transformer =
                MethodInvocationTransformerMatcher(
                    identifier: ident,
                    isStatic: method.isStatic,
                    transformer: builder.build())
            
            transforms.append(.method(transformer))
            
        case .mapFrom(let signature):
            let transformer = makeTransformation(signature: signature)
            
            transforms.append(transformer)
            
        case .mapFromIdentifier(let ident):
            let transformer = makeTransformation(identifier: ident)
            
            transforms.append(transformer)
            
        case .mapToBinaryOperator(let op):
            let signature = method.signature
            
            assert(signature.parameters.count == 1, """
                Trying to create a binary operator mapping with a function call \
                that does not have exactly one parameter?
                Binary operation mapping requires two parameters (the base type \
                and first argument type)
                """)
            
            let transformer = ValueTransformer<PostfixExpression, Expression> { $0 }
                // Flatten expressions (breaks postfix expressions into sub-expressions)
                .decompose()
                .validate { $0.count == 2 }
                // Verify first expression is a member access to the type we expect
                .transformIndex(
                    index: 0,
                    transformer: ValueTransformer()
                        .validate(matcher: ValueMatcher()
                            .keyPath(\.asPostfix, .isMemberAccess(forMember: signature.name))
                            .keyPath(\.resolvedType, equals: signature.swiftClosureType)
                        )
                        .removingMemberAccess()
                        .validate(matcher: ValueMatcher()
                            .isTyped(.typeName(type.typeName), ignoringNullability: true)
                    )
                )
                // Re-shape it into a binary expression
                .asBinaryExpression(operator: op)
            
            transforms.append(.valueTransformer(transformer.anyExpression()))
            
        case .initFromFunction:
            // TODO: Throw diagnostic error for unsupported mappings
            break
        }
    }
    
    return transforms
}

private func propertyTransformations(_ prop: KnownProperty) throws -> [PostfixTransformation] {
    var transforms: [PostfixTransformation] = []
    
    var isFreeFunction = false
    
    var getter: String?
    var setter: String?
    
    func analyze(_ identifier: FunctionIdentifier) {
        let params = identifier.parameterNames
        
        if params.isEmpty {
            getter = identifier.name
            return
        }
        
        if params[0] == "self" {
            if params.count == 1 {
                getter = identifier.name
                isFreeFunction = true
            } else if params.count == 2 {
                setter = identifier.name
                isFreeFunction = true
            }
        } else if params.count == 1 {
            setter = identifier.name
        }
    }
    
    for attribute in prop.knownAttributes {
        guard attribute.name == SwiftRewriterAttribute.name else {
            continue
        }
        
        let attr = try parseAttribute(attribute)
        
        switch attr.content {
        case .renameFrom(let old):
            transforms.append(.property(old: old, new: prop.name))
            
        case .mapFrom(let signature):
            analyze(signature.asIdentifier)
            
        case .mapFromIdentifier(let ident):
            analyze(ident)
            
        case .mapToBinaryOperator, .initFromFunction:
            // TODO: Throw diagnostic error for unsupported mappings
            break
        }
    }
    
    if let getter = getter {
        
        let mapper: PostfixTransformation
        
        if isFreeFunction {
            mapper = .propertyFromFreeFunctions(
                property: prop.name,
                getterName: getter,
                setterName: setter
            )
        } else {
            mapper = .propertyFromMethods(
                property: prop.name,
                getterName: getter,
                setterName: setter,
                resultType: prop.memberType,
                isStatic: prop.isStatic
            )
        }
        
        transforms.append(mapper)
    }
    
    return transforms
}

private func parseAttribute(_ attribute: KnownAttribute) throws -> SwiftClassInterfaceParser.SwiftRewriterAttribute {
    let lexer = Lexer(input: attribute.attributeString)
    let attribute =
        try SwiftClassInterfaceParser
            .parseSwiftRewriterAttribute(from: lexer)
    
    return attribute
}
