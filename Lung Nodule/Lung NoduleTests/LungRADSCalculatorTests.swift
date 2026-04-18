import Testing
@testable import Lung_Nodule
import Foundation

@MainActor
struct LungRADSCalculatorTests {

    private func makeSolidInput(
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

    private func makeGGOInput(
        size: LungRADSSize,
        ctStatus: CTStatus = .baseline,
        noduleStatus: NoduleStatus = .baseline,
        isMultiple: Bool = false
    ) -> LungRADSInput {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = size
        input.ctStatus = ctStatus
        input.noduleStatus = noduleStatus
        input.isMultiple = isMultiple
        return input
    }

    private func makePartSolidInput(
        size: LungRADSSize,
        solidSize: LungRADSSolidComponentSize,
        ctStatus: CTStatus = .baseline,
        noduleStatus: NoduleStatus = .baseline
    ) -> LungRADSInput {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = size
        input.solidComponentSize = solidSize
        input.ctStatus = ctStatus
        input.noduleStatus = noduleStatus
        return input
    }

    // MARK: Category 0 Tests

    @Test func incompleteCTReturnsCategory0() async throws {
        var input = LungRADSInput()
        input.ctStatus = .incomplete
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat0)
    }

    @Test func awaitingComparisonReturnsCategory0() async throws {
        var input = LungRADSInput()
        input.ctStatus = .awaitingComparison
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat0)
    }

    @Test func inflammatoryFindingsReturnCategory0() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .fifteenToThirty
        input.ctStatus = .baseline
        input.hasInflammatoryFindings = true
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat0)
        #expect(result.management.contains("1-3 months"))
    }

    // MARK: Category 1 Tests

    @Test func benignCalcificationReturnsCategory1() async throws {
        var input = LungRADSInput()
        input.hasBenignCalcification = true
        input.sizeCategory = .eightToFifteen
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat1)
    }

    @Test func macroscopicFatReturnsCategory1() async throws {
        var input = LungRADSInput()
        input.hasMacroscopicFat = true
        input.sizeCategory = .fifteenToThirty
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat1)
    }

    /// Per Lung-RADS v2022: Perifissural/juxtapleural nodule with benign criteria <10mm = Category 2
    @Test func perifissuralLessThan10mmBaselineReturnsCategory2() async throws {
        var input = LungRADSInput()
        input.noduleType = .perifissural
        input.sizeCategory = .sixToEight
        input.ctStatus = .baseline
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }

    // MARK: Category 2 Tests - Solid Nodule Baseline

    @Test func solidLessThan6mmBaselineReturnsCategory2() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .lessThanFour))
        #expect(result.category == .cat2)
    }

    @Test func solidLessThan4mmNewReturnsCategory2() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .lessThanFour, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat2)
    }

    /// Per current calculator behavior: resolved nodules return Category 2
    @Test func resolvedNoduleReturnsCategory2() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, ctStatus: .followUp, noduleStatus: .resolved))
        #expect(result.category == .cat2)
    }

    // MARK: Category 3 Tests

    @Test func solid6To8mmBaselineReturnsCategory3() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight))
        #expect(result.category == .cat3)
    }

    @Test func solid4To6mmNewReturnsCategory3() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .fourToSix, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat3)
    }

    @Test func partSolidSolidLessThan6mmReturnsCategory3() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .eightToFifteen, solidSize: .fourToSix))
        #expect(result.category == .cat3)
    }

    @Test func ggo30mmPlusBaselineReturnsCategory3() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .thirtyPlus))
        #expect(result.category == .cat3)
    }

    // MARK: Category 4A Tests

    @Test func solid8To15mmBaselineReturnsCategory4A() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .eightToFifteen))
        #expect(result.category == .cat4A)
    }

    @Test func solid6To8mmNewReturnsCategory4A() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat4A)
    }

    @Test func growingSolidLessThan8mmReturnsCategory4A() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, ctStatus: .followUp, noduleStatus: .growing))
        #expect(result.category == .cat4A)
    }

    @Test func partSolidSolid6To8mmReturnsCategory4A() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .eightToFifteen, solidSize: .sixToEight))
        #expect(result.category == .cat4A)
    }

    // MARK: Category 4B Tests

    @Test func solid15mmPlusBaselineReturnsCategory4B() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .fifteenToThirty))
        #expect(result.category == .cat4B)
    }

    @Test func solid8mmPlusNewReturnsCategory4B() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .eightToFifteen, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat4B)
    }

    @Test func growingSolid8mmPlusReturnsCategory4B() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .eightToFifteen, ctStatus: .followUp, noduleStatus: .growing))
        #expect(result.category == .cat4B)
    }

    @Test func partSolidSolid8mmPlusReturnsCategory4B() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .fifteenToThirty, solidSize: .eightPlus))
        #expect(result.category == .cat4B)
    }

    /// Per Lung-RADS v2022: Baseline segmental/proximal airway nodule = 4A (4B only for persistent in follow-up)
    @Test func airwayNoduleSegmentalBaselineReturnsCategory4A() async throws {
        var input = LungRADSInput()
        input.noduleType = .airway
        input.airwayLocation = .segmentalOrProximal
        input.sizeCategory = .fourToSix
        input.ctStatus = .baseline
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }

    @Test func airwayNoduleWithAtelectasis() async throws {
        var input = LungRADSInput()
        input.noduleType = .airway
        input.sizeCategory = .lessThanFour
        input.ctStatus = .baseline
        input.hasAtelectasis = true
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
        let notes = result.additionalNotes?.lowercased() ?? ""
        #expect(notes.contains("atelectasis"))
    }

    /// Per Lung-RADS v2022: Persistent segmental/proximal airway nodules at follow-up = 4B
    @Test func airwayNoduleSegmentalStableFollowUpReturnsCategory4B() async throws {
        var input = LungRADSInput()
        input.noduleType = .airway
        input.airwayLocation = .segmentalOrProximal
        input.sizeCategory = .fourToSix
        input.ctStatus = .followUp
        input.noduleStatus = .stable
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }

    /// Per Lung-RADS v2022: Growing segmental/proximal airway nodules at follow-up = 4B
    @Test func airwayNoduleSegmentalGrowingFollowUpReturnsCategory4B() async throws {
        var input = LungRADSInput()
        input.noduleType = .airway
        input.airwayLocation = .segmentalOrProximal
        input.sizeCategory = .fourToSix
        input.ctStatus = .followUp
        input.noduleStatus = .growing
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }

    /// Per Lung-RADS v2022: Baseline thick-walled/multilocular cyst = 4A (4B only for evolution/growth)
    @Test func atypicalCystBaselineReturnsCategory4A() async throws {
        var input = LungRADSInput()
        input.noduleType = .atypicalCyst
        input.sizeCategory = .eightToFifteen
        input.solidComponentSize = .fourToSix
        input.ctStatus = .baseline
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }

    @Test func atypicalPulmonaryCystWithThickWall() async throws {
        var input = LungRADSInput()
        input.noduleType = .atypicalCyst
        input.sizeCategory = .fifteenToThirty
        input.solidComponentSize = .fourToSix
        input.ctStatus = .baseline
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }

    // MARK: Category 4X Tests

    @Test func category4AWithSuspiciousFeaturesReturnsCategory4X() async throws {
        var input = makeSolidInput(size: .eightToFifteen)
        input.hasAdditionalSuspiciousFeatures = true
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4X)
    }

    @Test func category4BWithSuspiciousFeaturesReturnsCategory4X() async throws {
        var input = makeSolidInput(size: .fifteenToThirty)
        input.hasAdditionalSuspiciousFeatures = true
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4X)
    }

    // MARK: GGO Tests

    @Test func ggoLessThan30mmReturnsCategory2() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .fifteenToThirty))
        #expect(result.category == .cat2)
    }

    @Test func multipleGGOLessThan6mmReturnsCategory2WithNote() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .fourToSix, isMultiple: true))
        #expect(result.category == .cat2)
        #expect(result.additionalNotes?.contains("Multiple nodules") == true)
    }

    @Test func stableGGO30mmPlusReturnsCategory2() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .thirtyPlus, ctStatus: .followUp, noduleStatus: .stable))
        #expect(result.category == .cat2)
    }

    @Test func slowGrowingGGNReturnsCategory2() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .fifteenToThirty, ctStatus: .followUp, noduleStatus: .slowGrowing))
        #expect(result.category == .cat2)
    }
}
