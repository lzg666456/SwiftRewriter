#if !canImport(ObjectiveC)
import XCTest

extension StringDiffTestingTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__StringDiffTestingTests = [
        ("testDiffEmptyStrings", testDiffEmptyStrings),
        ("testDiffEqualStrings", testDiffEqualStrings),
        ("testDiffLargerExpectedString", testDiffLargerExpectedString),
        ("testDiffLargerExpectedStringWithChangeAtFirstLine", testDiffLargerExpectedStringWithChangeAtFirstLine),
        ("testDiffLargerExpectedStringWithMismatchInMiddle", testDiffLargerExpectedStringWithMismatchInMiddle),
        ("testDiffLargerResultString", testDiffLargerResultString),
        ("testDiffSimpleString", testDiffSimpleString),
        ("testDiffWhitespaceString", testDiffWhitespaceString),
    ]
}

extension VirtualFileDiskTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__VirtualFileDiskTests = [
        ("testContentsOfDirectory", testContentsOfDirectory),
        ("testContentsOfFile", testContentsOfFile),
        ("testCreateDirectory", testCreateDirectory),
        ("testCreateFile", testCreateFile),
        ("testCreateFileFullPath", testCreateFileFullPath),
        ("testCreateFileSubfolder", testCreateFileSubfolder),
        ("testCreateFileWithData", testCreateFileWithData),
        ("testDeleteDirectory", testDeleteDirectory),
        ("testDeleteFile", testDeleteFile),
        ("testFilesInDirectory", testFilesInDirectory),
        ("testInit", testInit),
        ("testWriteContentsOfFile", testWriteContentsOfFile),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StringDiffTestingTests.__allTests__StringDiffTestingTests),
        testCase(VirtualFileDiskTests.__allTests__VirtualFileDiskTests),
    ]
}
#endif
