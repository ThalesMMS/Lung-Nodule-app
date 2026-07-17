import Testing
@testable import Lung_Nodule

@MainActor
struct ReferenceTypeTests {
    @Test func everyBundledPDFNameResolvesInTheAppBundle() {
        for reference in ReferenceType.allCases where reference.bundledPDFName != nil {
            #expect(
                reference.resolvedBundleURL() != nil,
                "Missing bundled PDF for \(reference.displayTitle)"
            )
        }
    }
}
