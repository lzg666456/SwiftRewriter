public class IfStatement: Statement {
    public var exp: Expression {
        didSet { oldValue.parent = nil; exp.parent = self }
    }
    public var body: CompoundStatement {
        didSet { oldValue.parent = nil; body.parent = self }
    }
    public var elseBody: CompoundStatement? {
        didSet { oldValue?.parent = nil; elseBody?.parent = self }
    }
    
    /// If non-nil, the expression of this if statement must be resolved to a
    /// pattern match over a given pattern.
    ///
    /// This is used to create if-let statements.
    public var pattern: Pattern?
    
    public var isIfLet: Bool {
        return pattern != nil
    }
    
    public override var children: [SyntaxNode] {
        if let elseBody = elseBody {
            return [exp, body, elseBody]
        }
        return [exp, body]
    }
    
    public init(exp: Expression, body: CompoundStatement, elseBody: CompoundStatement?, pattern: Pattern?) {
        self.exp = exp
        self.body = body
        self.elseBody = elseBody
        self.pattern = pattern
        
        super.init()
        
        exp.parent = self
        body.parent = self
        elseBody?.parent = self
        pattern?.setParent(self)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try self.init(
            exp: container.decodeExpression(forKey: .exp),
            body: container.decodeStatement(CompoundStatement.self, forKey: .body),
            elseBody: container.decodeStatementIfPresent(CompoundStatement.self, forKey: .elseBody),
            pattern: container.decodeIfPresent(Pattern.self, forKey: .pattern))
    }
    
    public override func copy() -> IfStatement {
        let copy =
            IfStatement(exp: exp.copy(),
                        body: body.copy(),
                        elseBody: elseBody?.copy(),
                        pattern: pattern?.copy())
                .copyMetadata(from: self)
        
        copy.pattern = pattern?.copy()
        
        return copy
    }
    
    public override func accept<V: StatementVisitor>(_ visitor: V) -> V.StmtResult {
        return visitor.visitIf(self)
    }
    
    public override func isEqual(to other: Statement) -> Bool {
        switch other {
        case let rhs as IfStatement:
            return exp == rhs.exp && pattern == rhs.pattern && body == rhs.body && elseBody == rhs.elseBody
        default:
            return false
        }
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(pattern, forKey: .pattern)
        try container.encodeExpression(exp, forKey: .exp)
        try container.encodeStatement(body, forKey: .body)
        try container.encodeStatementIfPresent(elseBody, forKey: .elseBody)
        
        try super.encode(to: container.superEncoder())
    }
    
    public enum CodingKeys: String, CodingKey {
        case pattern
        case exp
        case body
        case elseBody
    }
}
public extension Statement {
    public var asIf: IfStatement? {
        return cast()
    }
}
