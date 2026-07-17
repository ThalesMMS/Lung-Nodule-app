import Testing
@testable import Lung_Nodule

@MainActor
struct SModifierFindingsTests {
    @Test func tracksAndResetsAnyFinding() {
        var findings = SModifierFindings()
        #expect(!findings.hasAny)

        findings.coronaryCalcifications = true
        #expect(findings.hasAny)

        findings.reset()
        #expect(!findings.hasAny)
    }
}
