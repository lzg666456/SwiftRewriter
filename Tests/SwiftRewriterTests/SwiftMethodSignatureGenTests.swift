import XCTest
import SwiftRewriter
import ObjcParser
import GrammarModels

class SwiftMethodSignatureGenTests: XCTestCase {
    func testSimpleVoidDefinition() throws {
        let sign = genSignature("""
            - (void)abc;
            """)
        
        XCTAssertEqual(sign.name, "abc")
        XCTAssertEqual(sign.returnType, .void)
        XCTAssertEqual(sign.parameters.count, 0)
    }
    
    func testSimpleSingleArgument() throws {
        let sign = genSignature("""
            - (void)setInteger:(NSInteger)int;
            """)
        
        XCTAssertEqual(sign.name, "setInteger")
        XCTAssertEqual(sign.returnType, .void)
        XCTAssertEqual(sign.parameters.count, 1)
        
        XCTAssertEqual(sign.parameters[0].label, "int")
        XCTAssertEqual(sign.parameters[0].type, .struct("NSInteger"))
        XCTAssertEqual(sign.parameters[0].name, "int")
    }
    
    func testSimpleMultiArguments() throws {
        let sign = genSignature("""
            - (void)intAndString:(NSInteger)a b:(NSString*)b;
            """)
        
        XCTAssertEqual(sign.name, "intAndString")
        XCTAssertEqual(sign.returnType, .void)
        XCTAssertEqual(sign.parameters.count, 2)
        
        XCTAssertEqual(sign.parameters[0].label, "a")
        XCTAssertEqual(sign.parameters[0].type, .struct("NSInteger"))
        XCTAssertEqual(sign.parameters[0].name, "a")
        
        XCTAssertEqual(sign.parameters[1].label, "b")
        XCTAssertEqual(sign.parameters[1].type, .pointer(.struct("NSString")))
        XCTAssertEqual(sign.parameters[1].name, "b")
    }
    
    func testLabellessArgument() {
        let sign = genSignature("""
            - (void)intAndString:(NSInteger)a :(NSString*)b;
            """)
        
        XCTAssertEqual(sign.name, "intAndString")
        XCTAssertEqual(sign.returnType, .void)
        XCTAssertEqual(sign.parameters.count, 2)
        
        XCTAssertEqual(sign.parameters[0].label, "a")
        XCTAssertEqual(sign.parameters[0].type, .struct("NSInteger"))
        XCTAssertEqual(sign.parameters[0].name, "a")
        
        XCTAssertEqual(sign.parameters[1].label, "_")
        XCTAssertEqual(sign.parameters[1].type, .pointer(.struct("NSString")))
        XCTAssertEqual(sign.parameters[1].name, "b")
    }
    
    private func genSignature(_ objc: String) -> MethodGenerationIntention.Signature {
        let node = parseMethodSign(objc)
        let gen = createSwiftMethodSignatureGen()
        
        return gen.generateDefinitionSignature(from: node)
    }
    
    private func createSwiftMethodSignatureGen() -> SwiftMethodSignatureGen {
        let ctx = TypeContext()
        let mapper = TypeMapper(context: ctx)
        
        return SwiftMethodSignatureGen(context: ctx, typeMapper: mapper)
    }
    
    private func parseMethodSign(_ source: String, file: String = #file, line: Int = #line) -> MethodDefinition {
        let parser = ObjcParser(string: source)
        
        do {
            let root: GlobalContextNode =
                try parser.withTemporaryContext {
                    try parser.parseMethodDeclaration()
            }
            
            let result: MethodDefinition! = root.childrenMatching().first
            
            return result
        } catch {
            recordFailure(withDescription: "Failed to parse test '\(source)': \(error)", inFile: #file, atLine: line, expected: false)
            fatalError()
        }
    }
}
