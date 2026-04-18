import Testing
@testable import Lung_Nodule
import Foundation

@MainActor
struct FleischnerEdgeCaseTests {

    private func makeSolidInput(
        size: FleischnerSize,
        sizeMm: Double? = nil,
        risk: PatientRisk = .low,
        isMultiple: Bool = false
    ) -> FleischnerInput {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = size
        input.sizeMm = sizeMm
        input.risk = risk
        input.isMultiple = isMultiple
        return input
    }

    private func makeGGOInput(
        size: FleischnerSize,
        sizeMm: Double? = nil,
        isMultiple: Bool = false
    ) -> FleischnerInput {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = size
        input.sizeMm = sizeMm
        input.isMultiple = isMultiple
        return input
    }

    private func makePartSolidInput(
        size: FleischnerSize,
        sizeMm: Double? = nil,
        solidSize: FleischnerSolidComponentSize,
        solidSizeMm: Double? = nil,
        isMultiple: Bool = false
    ) -> FleischnerInput {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = size
        input.sizeMm = sizeMm
        input.solidComponentSize = solidSize
        input.solidComponentMm = solidSizeMm
        input.isMultiple = isMultiple
        return input
    }

    // MARK: - F001-F005: Solid Nodule Rounding Threshold Tests

    /// F001: 4.9mm rounds to 5mm (<6mm), low risk -> No routine follow-up
    @Test func F001_solidMean4_9mmLowRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .lessThanSix, sizeMm: 4.9))
        #expect(result.recommendation.contains("No routine follow-up"))
    }

    /// F003: 5.5mm rounds to 6mm (6-8mm threshold), low risk -> CT at 6-12 months
    @Test func F003_solidMean5_5mmRoundsTo6LowRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .lessThanSix, sizeMm: 5.5))
        #expect(result.recommendation.contains("6-12 months"))
    }

    /// F004: 5.5mm rounds to 6mm (6-8mm threshold), high risk -> CT at 6-12m then 18-24m
    @Test func F004_solidMean5_5mmRoundsTo6HighRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .lessThanSix, sizeMm: 5.5, risk: .high))
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("18-24 months"))
    }

    /// F005: 5.0mm exact, high risk -> Optional CT at 12 months
    @Test func F005_solid5mmHighRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 5.0, risk: .high))
        #expect(result.recommendation.contains("Optional CT at 12 months"))
        #expect(result.followUpInterval?.contains("12 months") == true)
    }
    
    // MARK: - F009-F012: 8mm Threshold Tests
    
    /// F009: 8.4mm rounds to 8mm (still 6-8mm range), low risk
    @Test func F009_solidMean8_4mmRoundsTo8LowRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .greaterThanEight, sizeMm: 8.4))
        #expect(result.recommendation.contains("6-12 months"))
    }

    /// F010: 8.5mm rounds to 9mm (>8mm range), low risk -> Consider CT 3m, PET/CT
    @Test func F010_solidMean8_5mmRoundsTo9LowRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 8.5))
        #expect(result.recommendation.contains("3 months"))
        #expect(result.recommendation.contains("PET/CT"))
    }

    /// F011: 8.5mm rounds to 9mm (>8mm), high risk -> Consider CT 3m, PET/CT, tissue sampling
    @Test func F011_solidMean8_5mmRoundsTo9HighRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 8.5, risk: .high))
        #expect(result.recommendation.contains("3 months"))
        #expect(result.recommendation.contains("PET/CT"))
    }

    /// F012: Solid 12mm, high risk, spiculated -> Consider CT 3m, PET/CT, tissue sampling
    @Test func F012_solid12mmHighRiskSpiculated() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 12.0, risk: .high))
        #expect(result.recommendation.contains("3 months"))
        #expect(result.recommendation.contains("PET/CT"))
    }

    // MARK: - F013-F019: Multiple Solid Nodule Tests

    /// F013: Multiple solid <6mm, low risk -> No routine follow-up
    @Test func F013_multipleSolidLessThan6mmLowRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .lessThanSix, isMultiple: true))
        #expect(result.recommendation.contains("No routine follow-up"))
    }

    /// F014: Multiple solid <6mm, high risk -> Optional CT at 12 months
    @Test func F014_multipleSolidLessThan6mmHighRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .lessThanSix, risk: .high, isMultiple: true))
        #expect(result.recommendation.contains("Optional CT at 12 months"))
        #expect(result.followUpInterval?.contains("12 months") == true)
    }

    /// F015: Multiple solid 6-8mm (dominant 6.2mm rounds to 6), low risk -> CT at 3-6m
    @Test func F015_multipleSolid6mmLowRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .lessThanSix, sizeMm: 6.2, isMultiple: true))
        #expect(result.recommendation.contains("3-6 months"))
    }

    /// F016: Multiple solid 6-8mm, high risk -> CT at 3-6m then 18-24m
    @Test func F016_multipleSolid6To8mmHighRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .sixToEight, risk: .high, isMultiple: true))
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("18-24 months"))
    }

    /// F017: Multiple solid >8mm (dominant 8.6mm), high risk -> CT at 3-6m
    @Test func F017_multipleSolidGreaterThan8mmHighRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 8.6, risk: .high, isMultiple: true))
        #expect(result.recommendation.contains("3-6 months"))
    }

    /// F018: Multiple solid >8mm (dominant 10mm), low risk -> CT at 3-6m
    @Test func F018_multipleSolid10mmLowRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 10.0, isMultiple: true))
        #expect(result.recommendation.contains("3-6 months"))
    }
    
    // MARK: - F026-F030: Pure GGO Tests

    /// F026: GGN 4.8mm (rounds to 5, <6mm) -> No routine follow-up
    @Test func F026_pureGGO4_8mm() async throws {
        let result = FleischnerCalculator.calculate(input: makeGGOInput(size: .sixToEight, sizeMm: 4.8))
        #expect(result.recommendation.contains("No routine follow-up"))
    }

    /// F027: GGN 5.5mm (rounds to 6, ≥6mm) -> CT at 6-12m, then every 2y until 5y
    @Test func F027_pureGGO5_5mmRoundsTo6() async throws {
        let result = FleischnerCalculator.calculate(input: makeGGOInput(size: .lessThanSix, sizeMm: 5.5))
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("5 years"))
    }

    /// F029: GGN 10mm -> CT at 6-12m, then every 2y until 5y
    @Test func F029_pureGGO10mm() async throws {
        let result = FleischnerCalculator.calculate(input: makeGGOInput(size: .sixToEight, sizeMm: 10.0))
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("5 years"))
    }
    
    // MARK: - F031-F036: Part-Solid Nodule Tests
    
    /// F031: Part-solid <6mm total -> No routine follow-up (treat as small GGN)
    @Test func F031_partSolidLessThan6mmTotal() async throws {
        let result = FleischnerCalculator.calculate(input: makePartSolidInput(size: .lessThanSix, solidSize: .lessThanSix))
        #expect(result.recommendation.contains("No routine follow-up"))
    }

    /// F032: Part-solid 6mm total, solid 3mm -> CT at 3-6m, then annual for 5y
    @Test func F032_partSolid6mmSolid3mm() async throws {
        let result = FleischnerCalculator.calculate(input: makePartSolidInput(size: .lessThanSix, sizeMm: 6.0, solidSize: .sixOrMore, solidSizeMm: 3.0))
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("5 years"))
    }

    /// F033: Part-solid 5.5mm rounds to 6mm, solid 3mm -> CT at 3-6m
    @Test func F033_partSolid5_5mmRoundsTo6() async throws {
        let result = FleischnerCalculator.calculate(input: makePartSolidInput(size: .lessThanSix, sizeMm: 5.5, solidSize: .sixOrMore, solidSizeMm: 3.0))
        #expect(result.recommendation.contains("3-6 months"))
    }

    /// F034: Part-solid 10mm total, solid 5mm -> CT at 3-6m, annual for 5y
    @Test func F034_partSolid10mmSolid5mm() async throws {
        let result = FleischnerCalculator.calculate(input: makePartSolidInput(size: .sixToEight, sizeMm: 10.0, solidSize: .sixOrMore, solidSizeMm: 5.0))
        #expect(result.recommendation.contains("3-6 months"))
    }

    /// F035: Part-solid 10mm total, solid 6mm (threshold) -> CT at 3-6m and consider PET/CT
    @Test func F035_partSolid10mmSolid6mm() async throws {
        let result = FleischnerCalculator.calculate(input: makePartSolidInput(size: .sixToEight, sizeMm: 10.0, solidSize: .lessThanSix, solidSizeMm: 6.0))
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("PET/CT"))
    }

    /// F036: Part-solid 15mm total, solid 9mm -> CT at 3-6m, consider PET/CT/biopsy/resection
    @Test func F036_partSolid15mmSolid9mm() async throws {
        let result = FleischnerCalculator.calculate(input: makePartSolidInput(size: .sixToEight, sizeMm: 15.0, solidSize: .lessThanSix, solidSizeMm: 9.0))
        #expect(result.recommendation.contains("PET/CT") || result.recommendation.contains("tissue sampling"))
    }
    
    // MARK: - F037-F040: Multiple Subsolid Nodule Tests

    /// F037: Multiple GGNs all <6mm -> CT at 3-6m; if stable, consider CT at 2 and 4y
    @Test func F037_multipleGGNsLessThan6mm() async throws {
        let result = FleischnerCalculator.calculate(input: makeGGOInput(size: .lessThanSix, isMultiple: true))
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("2 and 4 years"))
    }

    /// F039: Multiple subsolids with one GGN ≥6mm (8mm) -> CT at 3-6m
    @Test func F039_multipleSubsolidsOneGGN8mm() async throws {
        let result = FleischnerCalculator.calculate(input: makeGGOInput(size: .lessThanSix, sizeMm: 8.0, isMultiple: true))
        #expect(result.recommendation.contains("3-6 months"))
    }

    /// F040: Multiple subsolids with part-solid dominant (7mm, solid 4mm) -> CT at 3-6m
    @Test func F040_multipleSubsolidsPartSolidDominant() async throws {
        let result = FleischnerCalculator.calculate(input: makePartSolidInput(size: .lessThanSix, sizeMm: 7.0, solidSize: .sixOrMore, solidSizeMm: 4.0, isMultiple: true))
        #expect(result.recommendation.contains("3-6 months"))
    }
}
