import XCTest
import SwiftRewriterLib
import SwiftAST
import IntentionPasses
import TestCommons

class PropertyMergeIntentionPassTests: XCTestCase {
    func testMergeGetterAndSetter() {
        let intentions =
            IntentionCollectionBuilder()
                .createFileWithClass(named: "A") { builder in
                    builder
                        .createProperty(named: "a", type: .int)
                        .createMethod(named: "setA", parameters: [
                            ParameterSignature(label: "_", name: "a", type: .int)
                        ])
                        .createMethod(named: "a", returnType: .int)
                }.build()
        let cls = intentions.classIntentions()[0]
        let sut = PropertyMergeIntentionPass()
        
        sut.apply(on: intentions, context: makeContext(intentions: intentions))
        
        XCTAssertEqual(cls.methods.count, 0)
        XCTAssertEqual(cls.properties.count, 1)
        switch cls.properties[0].mode {
        case .property:
            // Success
            break
        default:
            XCTFail("Unexpected property mode \(cls.properties[0].mode)")
        }
    }
    
    // When merging a property with a setter (w/ no getter found), merge, but
    // produce a backing field to allow properly overriding the setter on the
    // type, and produce a default getter returning the backing field, as well.
    func testMergeSetterOverrideProducesBackingField() {
        let intentions =
            IntentionCollectionBuilder()
                .createFileWithClass(named: "A") { builder in
                    builder
                        .createProperty(named: "a", type: .int)
                        .createMethod(named: "setA", parameters: [
                            ParameterSignature(label: "_", name: "a", type: .int)
                            ])
                }.build()
        let cls = intentions.classIntentions()[0]
        let sut = PropertyMergeIntentionPass()
        
        sut.apply(on: intentions, context: makeContext(intentions: intentions))
        
        XCTAssertEqual(cls.methods.count, 0)
        XCTAssertEqual(cls.properties.count, 1)
        XCTAssertEqual(cls.instanceVariables.count, 1)
        XCTAssertEqual(cls.instanceVariables[0].name, "_a")
        XCTAssertEqual(cls.instanceVariables[0].type, .int)
        switch cls.properties[0].mode {
        case let .property(getter, _):
            XCTAssertEqual(getter.body, [.return(.identifier("_a"))])
            
        default:
            XCTFail("Unexpected property mode \(cls.properties[0].mode)")
        }
    }
    
    func testMergeReadonlyWithGetter() {
        let intentions =
            IntentionCollectionBuilder()
                .createFileWithClass(named: "A") { builder in
                    builder
                        .createProperty(named: "a", type: .int,
                                        attributes: [.attribute("readonly")])
                        .createMethod(named: "a", returnType: .int)
                }.build()
        let cls = intentions.classIntentions()[0]
        let sut = PropertyMergeIntentionPass()
        
        sut.apply(on: intentions, context: makeContext(intentions: intentions))
        
        XCTAssertEqual(cls.methods.count, 0)
        XCTAssertEqual(cls.properties.count, 1)
        switch cls.properties[0].mode {
        case .computed:
            // Success
            break
        default:
            XCTFail("Unexpected property mode \(cls.properties[0].mode)")
        }
    }
    
    func testMergeCategories() {
        let intentions =
            IntentionCollectionBuilder()
                .createFile(named: "A") { file in
                    file.createExtension(forClassNamed: "A") { builder in
                        builder
                            .createProperty(named: "a", type: .int, attributes: [.attribute("readonly")])
                            .createMethod(named: "a", returnType: .int)
                    }
                }.build()
        let cls = intentions.extensionIntentions()[0]
        let sut = PropertyMergeIntentionPass()
        
        sut.apply(on: intentions, context: makeContext(intentions: intentions))
        
        XCTAssertEqual(cls.methods.count, 0)
        XCTAssertEqual(cls.properties.count, 1)
        switch cls.properties[0].mode {
        case .computed:
            // Success
            break
        default:
            XCTFail("Unexpected property mode \(cls.properties[0].mode)")
        }
    }
    
    // Checks if PropertyMergeIntentionPass properly records history entries on
    // the merged properties and the types the properties are contained within.
    func testHistoryTrackingMergingGetterSetterMethods() {
        let intentions =
            IntentionCollectionBuilder()
                .createFileWithClass(named: "A") { (builder) in
                    builder
                        .createProperty(named: "a", type: .int)
                        .createMethod(named: "a", returnType: .int)
                        .createMethod(named: "setA", parameters: [
                            ParameterSignature(label: "_", name: "a", type: .int)
                            ])
                }.build()
        let cls = intentions.classIntentions()[0]
        let sut = PropertyMergeIntentionPass()
        
        sut.apply(on: intentions, context: makeContext(intentions: intentions))
        
        XCTAssertEqual(
            cls.history.summary,
            "[PropertyMergeIntentionPass] Merging getter method A.a() -> Int and setter method A.setA(_ a: Int) into a computed property A.a: Int"
        )
        XCTAssertEqual(
            cls.properties[0].history.summary,
            "[PropertyMergeIntentionPass] Merging getter method A.a() -> Int and setter method A.setA(_ a: Int) into a computed property A.a: Int"
        )
    }
}

extension PropertyMergeIntentionPassTests {
    func makeContext(intentions: IntentionCollection) -> IntentionPassContext {
        let system = IntentionCollectionTypeSystem(intentions: intentions)
        let resolver = ExpressionTypeResolver(typeSystem: system)
        let invoker = DefaultTypeResolverInvoker(typeResolver: resolver)
        
        return IntentionPassContext(typeSystem: system, typeResolverInvoker: invoker)
    }
}
