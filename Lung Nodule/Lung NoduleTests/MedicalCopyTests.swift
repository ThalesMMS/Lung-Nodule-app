import Testing
@testable import Lung_Nodule

struct MedicalCopyTests {
    @Test func englishDefaultsRemainAvailable() {
        #expect(MedicalCopy.decisionSupportDisclaimer.contains("decision support tool"))
        #expect(MedicalCopy.brockModelDescription.contains("malignancy risk"))
        #expect(MedicalCopy.fleischnerPurpose.contains("pulmonary nodules"))
        #expect(MedicalCopy.lungRADSMeanDiameter.contains("long and short axis"))
        #expect(MedicalCopy.Section.fleischnerGuidelines == "2017 FLEISCHNER SOCIETY GUIDELINES")
        #expect(MedicalCopy.Section.steppedManagement == "STEPPED MANAGEMENT")
    }
}
