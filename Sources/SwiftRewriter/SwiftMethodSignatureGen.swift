import GrammarModels

/// A helper class that can be used to generate a proper swift method signature
/// from an Objective-C method signature.
public class SwiftMethodSignatureGen {
    private let context: TypeContext
    private let typeMapper: TypeMapper
    
    public init(context: TypeContext, typeMapper: TypeMapper) {
        self.context = context
        self.typeMapper = typeMapper
    }
    
    /// Generates a function definition from an objective-c signature to use as
    /// a class-type function definition.
    public func generateDefinitionSignature(from objcMethod: MethodDefinition) -> MethodGenerationIntention.Signature {
        var sign =
            MethodGenerationIntention
                .Signature(name: "_",
                           returnType: ObjcType.id(protocols: []),
                           parameters: [])
        
        if let sel = objcMethod.methodSelector.selector {
            switch sel {
            case .selector(let s):
                sign.name = s.name
            case .keywords(let kw):
                processKeywords(kw, &sign)
            }
        }
        
        if let type = objcMethod.returnType.type.type {
            sign.returnType = type
        }
        
        return sign
    }
    
    private func processKeywords(_ keywords: [KeywordDeclarator], _ target: inout MethodGenerationIntention.Signature) {
        typealias Parameter = MethodGenerationIntention.Parameter // To shorten up type names within the method
        
        guard keywords.count > 0 else {
            return
        }
        
        // First selector is always the method's name
        target.name = keywords[0].selector?.name ?? "_"
        
        for (i, kw) in keywords.enumerated() {
            var label = kw.selector?.name ?? "_"
            let identifier = kw.identifier?.name ?? "_\(i)"
            let type = kw.type?.type.type ?? ObjcType.id(protocols: [])
            
            // The first label name is always equal to its keyword's identifier.
            // This is because the first label is actually used as the method's name.
            if i == 0 {
                label = identifier
            }
            
            let param = Parameter(label: label, name: identifier, type: type)
            
            target.parameters.append(param)
        }
    }
}
