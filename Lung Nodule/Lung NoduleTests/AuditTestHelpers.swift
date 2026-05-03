import Foundation
import Testing
@testable import Lung_Nodule

/// Test-only helpers used by the guideline edge-case audit.
///
/// Keep these intentionally small and local to the test target.
enum AuditTestHelpers {

    // MARK: - Scenario builders

    static func makeLungRADSSolid(
        size: LungRADSSize,
        ctStatus: CTStatus = .baseline,
        noduleStatus: NoduleStatus = .baseline
    ) -> LungRADSInput {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = size
        input.ctStatus = ctStatus
        input.noduleStatus = noduleStatus
        return input
    }

    static func makeLungRADSPartSolid(
        size: LungRADSSize,
        solidSize: LungRADSSolidComponentSize,
        ctStatus: CTStatus = .baseline,
        noduleStatus: NoduleStatus = .baseline,
        solidComponentGrowthDetected: Bool = false
    ) -> LungRADSInput {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = size
        input.solidComponentSize = solidSize
        input.ctStatus = ctStatus
        input.noduleStatus = noduleStatus
        input.solidComponentGrowthDetected = solidComponentGrowthDetected
        return input
    }

    static func makeFleischnerSolid(
        size: FleischnerSize,
        risk: PatientRisk = .low,
        isMultiple: Bool = false
    ) -> FleischnerInput {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = size
        input.risk = risk
        input.isMultiple = isMultiple
        return input
    }

    static func makeFleischnerPureGGO(
        size: FleischnerSize,
        isMultiple: Bool = false
    ) -> FleischnerInput {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = size
        input.isMultiple = isMultiple
        return input
    }

    static func makeFleischnerPartSolid(
        size: FleischnerSize,
        solidSize: FleischnerSolidComponentSize,
        isMultiple: Bool = false
    ) -> FleischnerInput {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = size
        input.solidComponentSize = solidSize
        input.isMultiple = isMultiple
        return input
    }

    // MARK: - Severity ordering assertions

    /// Encodes Lung-RADS ordering: 0 < 1 < 2 < 3 < 4A < 4B < 4X.
    ///
    /// Note: `.s` is a modifier, not a base category; callers should pass the base category.
    static func assertLungRADSSeverityNotBelow(
        actual: LungRADSCategory,
        expectedMinimum: LungRADSCategory
    ) {
        guard expectedMinimum != .s else {
            #expect(Bool(false), "LungRADSCategory.s is a modifier, not a base category")
            return
        }
        guard actual != .s else {
            #expect(Bool(false), "LungRADSCategory.s is a modifier, not a base category")
            return
        }
        #expect(actual.riskLevel >= expectedMinimum.riskLevel)
    }

    /// Minimal ordering guard for Fleischner recommendations based on follow-up intensity.
    ///
    /// This is intentionally conservative: if we cannot confidently rank a recommendation,
    /// unsupported actual text is treated below all recognized recommendations.
    static func assertFleischnerSeverityNotBelow(
        recommendationText actual: String,
        expectedMinimumText expected: String
    ) {
        let actualLevel = fleischnerIntensityLevel(recommendation: actual)
        let expectedLevel = fleischnerIntensityLevel(recommendation: expected)
        guard expectedLevel >= 0 else {
            #expect(Bool(false), "Unsupported Fleischner expected recommendation text: \(expected)")
            return
        }
        #expect(actualLevel >= expectedLevel)
    }

    static func fleischnerIntensityLevelForTesting(recommendation: String) -> Int {
        fleischnerIntensityLevel(recommendation: recommendation)
    }

    private static func fleischnerIntensityLevel(recommendation: String) -> Int {
        let text = recommendation
            .replacingOccurrences(of: "\u{2010}", with: "-")
            .replacingOccurrences(of: "\u{2011}", with: "-")
            .replacingOccurrences(of: "\u{2012}", with: "-")
            .replacingOccurrences(of: "\u{2013}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
            .replacingOccurrences(of: "\u{2212}", with: "-")
            .replacingOccurrences(of: "\u{FE58}", with: "-")
            .replacingOccurrences(of: "\u{FE63}", with: "-")
            .replacingOccurrences(of: "\u{FF0D}", with: "-")
            .lowercased()

        if text.contains("pet/ct") || text.contains("biopsy") || text.contains("tissue sampling") {
            return 4
        }

        // Earliest (most urgent) follow-up wins.
        if text.contains("3 months") || text.contains("3-6 months") || text.contains("3mo") || text.contains("3-6mo") {
            return 3
        }

        if text.contains("6 months") || text.contains("6-12 months") || text.contains("6-12") || text.contains("6mo") || text.contains("6-12mo") {
            return 2
        }

        if text.contains("12 months") || text.contains("12mo") {
            return 1
        }

        if text.contains("no routine follow-up") {
            return 0
        }

        return -1
    }
}
