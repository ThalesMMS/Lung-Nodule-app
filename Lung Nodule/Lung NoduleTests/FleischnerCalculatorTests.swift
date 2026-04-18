import Testing
@testable import Lung_Nodule
import Foundation

@MainActor
struct FleischnerCalculatorTests {

    private func makeSolidInput(
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

    private func makeGGOInput(
        size: FleischnerSize,
        isMultiple: Bool = false
    ) -> FleischnerInput {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = size
        input.isMultiple = isMultiple
        return input
    }

    private func makePartSolidInput(
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

    // MARK: Single Solid Nodule Tests

    @Test func solidLessThan6mmLowRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .lessThanSix))
        #expect(result.recommendation.contains("No routine follow-up"))
    }

    @Test func solidLessThan6mmHighRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .lessThanSix, risk: .high))
        #expect(result.recommendation.contains("Optional CT at 12 months"))
        #expect(result.followUpInterval?.contains("12 months") == true)
    }

    @Test func solid6To8mmLowRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .sixToEight))
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("consider"))
    }

    @Test func solid6To8mmHighRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .sixToEight, risk: .high))
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("18-24 months"))
    }

    @Test func solidGreaterThan8mm() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .greaterThanEight))
        #expect(result.recommendation.contains("3 months"))
        #expect(result.recommendation.contains("PET/CT"))
    }

    // MARK: Single Pure GGO Tests

    @Test func pureGGOLessThan6mm() async throws {
        let result = FleischnerCalculator.calculate(input: makeGGOInput(size: .lessThanSix))
        #expect(result.recommendation.contains("No routine follow-up"))
    }

    @Test func pureGGO6mmOrMore() async throws {
        let result = FleischnerCalculator.calculate(input: makeGGOInput(size: .sixToEight))
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("5 years"))
    }

    // MARK: Single Part-Solid Tests

    @Test func partSolidLessThan6mm() async throws {
        let result = FleischnerCalculator.calculate(input: makePartSolidInput(size: .lessThanSix, solidSize: .lessThanSix))
        #expect(result.recommendation.contains("No routine follow-up"))
    }

    @Test func partSolid6mmPlusSolidLessThan6mm() async throws {
        let result = FleischnerCalculator.calculate(input: makePartSolidInput(size: .sixToEight, solidSize: .lessThanSix))
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("5 years"))
    }

    @Test func partSolid6mmPlusSolid6mmPlus() async throws {
        let result = FleischnerCalculator.calculate(input: makePartSolidInput(size: .greaterThanEight, solidSize: .sixOrMore))
        // Per Fleischner 2017: solid component ≥6mm requires CT 3-6m first
        // PET/CT/biopsy only for >8mm solid or suspicious morphology/growth
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("growth"))
    }

    // MARK: Multiple Nodule Tests

    @Test func multipleSolidLessThan6mmLowRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .lessThanSix, isMultiple: true))
        // Use the dominant/most suspicious nodule to determine management, not the total count.
        #expect(result.recommendation.contains("No routine follow-up"))
    }

    @Test func multipleSolid6mmPlusHighRisk() async throws {
        let result = FleischnerCalculator.calculate(input: makeSolidInput(size: .sixToEight, risk: .high, isMultiple: true))
        #expect(result.recommendation.contains("3-6 months"))
    }

    @Test func multiplePureGGOLessThan6mm() async throws {
        let result = FleischnerCalculator.calculate(input: makeGGOInput(size: .lessThanSix, isMultiple: true))
        // Use the dominant/most suspicious nodule to determine management, not the total count.
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("2 and 4 years"))
    }
}