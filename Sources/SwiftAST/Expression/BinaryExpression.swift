
public class BinaryExpression: Expression {
    public var lhs: Expression {
        didSet { oldValue.parent = nil; lhs.parent = self; }
    }
    public var op: SwiftOperator
    public var rhs: Expression {
        didSet { oldValue.parent = nil; rhs.parent = self; }
    }
    
    public override var subExpressions: [Expression] {
        return [lhs, rhs]
    }
    
    public override var isLiteralExpression: Bool {
        return lhs.isLiteralExpression && rhs.isLiteralExpression
    }
    
    public override var requiresParens: Bool {
        return true
    }
    
    public override var description: String {
        // With spacing
        if op.requiresSpacing {
            return "\(lhs.description) \(op) \(rhs.description)"
        }
        
        // No spacing
        return "\(lhs.description)\(op)\(rhs.description)"
    }
    
    public init(lhs: Expression, op: SwiftOperator, rhs: Expression) {
        self.lhs = lhs
        self.op = op
        self.rhs = rhs
        
        super.init()
        
        self.lhs.parent = self
        self.rhs.parent = self
    }
    
    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let lhs = try container.decodeExpression(forKey: .lhs)
        let op = try container.decode(SwiftOperator.self, forKey: .op)
        let rhs = try container.decodeExpression(forKey: .rhs)
        
        self.init(lhs: lhs, op: op, rhs: rhs)
    }
    
    public override func copy() -> BinaryExpression {
        return
            BinaryExpression(
                lhs: lhs.copy(),
                op: op,
                rhs: rhs.copy()
            ).copyTypeAndMetadata(from: self)
    }
    
    public override func accept<V: ExpressionVisitor>(_ visitor: V) -> V.ExprResult {
        return visitor.visitBinary(self)
    }
    
    public override func isEqual(to other: Expression) -> Bool {
        switch other {
        case let rhs as BinaryExpression:
            return self == rhs
        default:
            return false
        }
    }
    
    public static func == (lhs: BinaryExpression, rhs: BinaryExpression) -> Bool {
        return lhs.lhs == rhs.lhs && lhs.op == rhs.op && lhs.rhs == rhs.rhs
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeExpression(lhs, forKey: .lhs)
        try container.encode(op, forKey: .op)
        try container.encodeExpression(rhs, forKey: .rhs)
        
        try super.encode(to: container.superEncoder())
    }
    
    public enum CodingKeys: String, CodingKey {
        case lhs
        case op
        case rhs
    }
}
extension Expression {
    public var asBinary: BinaryExpression? {
        return cast()
    }
}
