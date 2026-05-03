import Testing
@testable import Lung_Nodule

@MainActor
struct AuditTestHelpersTests {

    @Test func lungRADSSeverityOrderingGuardWorks() async throws {
        // 4B should never be considered below 4A.
        AuditTestHelpers.assertLungRADSSeverityNotBelow(actual: .cat4B, expectedMinimum: .cat4A)

        // 2 should be below 3.
        #expect((LungRADSCategory.cat2) < .cat3)
    }

    @Test func fleischnerIntensityOrderingGuardWorks() async throws {
        // PET/CT is considered more severe than 3-month CT.
        AuditTestHelpers.assertFleischnerSeverityNotBelow(
            recommendationText: "Consider PET/CT and/or tissue sampling",
            expectedMinimumText: "CT at 3 months"
        )

        // No follow-up should be considered less intense than 12 month CT.
        AuditTestHelpers.assertFleischnerSeverityNotBelow(
            recommendationText: "Optional CT at 12 months",
            expectedMinimumText: "No routine follow-up"
        )

        AuditTestHelpers.assertFleischnerSeverityNotBelow(
            recommendationText: "CT at 3-6mo",
            expectedMinimumText: "CT at 3 months"
        )

        AuditTestHelpers.assertFleischnerSeverityNotBelow(
            recommendationText: "CT at 6-12mo, then consider CT at 18-24mo",
            expectedMinimumText: "CT at 6-12 months"
        )

        AuditTestHelpers.assertFleischnerSeverityNotBelow(
            recommendationText: "CT at 3\u{2013}6mo, then consider CT at 18\u{2014}24mo",
            expectedMinimumText: "CT at 3-6 months"
        )

        AuditTestHelpers.assertFleischnerSeverityNotBelow(
            recommendationText: "Optional CT at 12mo",
            expectedMinimumText: "Optional CT at 12 months"
        )

        AuditTestHelpers.assertFleischnerSeverityNotBelow(
            recommendationText: "CT at 6mo",
            expectedMinimumText: "Optional CT at 12 months"
        )

        let twelveMonthOnlyRecommendation = "Optional CT at 12mo"
        let sixMonthMinimum = "CT at 6mo"
        let twelveMonthLevel = AuditTestHelpers.fleischnerIntensityLevelForTesting(
            recommendation: twelveMonthOnlyRecommendation
        )
        let sixMonthLevel = AuditTestHelpers.fleischnerIntensityLevelForTesting(
            recommendation: sixMonthMinimum
        )
        #expect(twelveMonthLevel < sixMonthLevel)

        let noRoutineLevel = AuditTestHelpers.fleischnerIntensityLevelForTesting(
            recommendation: "No routine follow-up"
        )
        #expect(noRoutineLevel < twelveMonthLevel)

        let unsupportedLevel = AuditTestHelpers.fleischnerIntensityLevelForTesting(
            recommendation: "typo follow-up interval"
        )
        #expect(unsupportedLevel < noRoutineLevel)
    }
}
