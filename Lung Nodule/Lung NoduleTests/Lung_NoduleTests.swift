//
//  Lung_NoduleTests.swift
//  Lung NoduleTests
//
//  Created by Thales Matheus Mendonça Santos on 27/12/25.
//

import Testing
@testable import Lung_Nodule
import Foundation

// MARK: - Fleischner Calculator Tests

@MainActor
struct FleischnerCalculatorTests {
    
    // MARK: Single Solid Nodule Tests
    
    @Test func solidLessThan6mmLowRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .lessThanSix
        input.risk = .low
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("No routine follow-up"))
    }
    
    @Test func solidLessThan6mmHighRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .lessThanSix
        input.risk = .high
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("Optional CT at 12 months"))
        #expect(result.followUpInterval?.contains("12 months") == true)
    }
    
    @Test func solid6To8mmLowRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.risk = .low
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("consider"))
    }
    
    @Test func solid6To8mmHighRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.risk = .high
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("18-24 months"))
    }
    
    @Test func solidGreaterThan8mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .greaterThanEight
        input.risk = .low
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3 months"))
        #expect(result.recommendation.contains("PET/CT"))
    }
    
    // MARK: Single Pure GGO Tests
    
    @Test func pureGGOLessThan6mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = .lessThanSix
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("No routine follow-up"))
    }
    
    @Test func pureGGO6mmOrMore() async throws {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = .sixToEight
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("5 years"))
    }
    
    // MARK: Single Part-Solid Tests
    
    @Test func partSolidLessThan6mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = .lessThanSix
        input.solidComponentSize = .lessThanSix
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("No routine follow-up"))
    }
    
    @Test func partSolid6mmPlusSolidLessThan6mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = .sixToEight
        input.solidComponentSize = .lessThanSix
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("5 years"))
    }
    
    @Test func partSolid6mmPlusSolid6mmPlus() async throws {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = .greaterThanEight
        input.solidComponentSize = .sixOrMore
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        // Per Fleischner 2017: solid component ≥6mm requires CT 3-6m first
        // PET/CT/biopsy only for >8mm solid or suspicious morphology/growth
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("growth"))
    }
    
    // MARK: Multiple Nodule Tests
    
    @Test func multipleSolidLessThan6mmLowRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .lessThanSix
        input.risk = .low
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        // Use the dominant/most suspicious nodule to determine management, not the total count.
        #expect(result.recommendation.contains("No routine follow-up"))
    }
    
    @Test func multipleSolid6mmPlusHighRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.risk = .high
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
    }
    
    @Test func multiplePureGGOLessThan6mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = .lessThanSix
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        // Use the dominant/most suspicious nodule to determine management, not the total count.
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("2 and 4 years"))
    }
}

// MARK: - Fleischner Edge Cases (from nodule_edge_cases CSV)

@MainActor
struct FleischnerEdgeCaseTests {
    
    // MARK: - F001-F005: Solid Nodule Rounding Threshold Tests
    
    /// F001: 4.9mm rounds to 5mm (<6mm), low risk -> No routine follow-up
    @Test func F001_solidMean4_9mmLowRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .lessThanSix  // 4.9 rounds to 5 -> <6mm
        input.risk = .low
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("No routine follow-up"))
    }
    
    /// F003: 5.5mm rounds to 6mm (6-8mm threshold), low risk -> CT at 6-12 months
    @Test func F003_solidMean5_5mmRoundsTo6LowRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight  // 5.5 rounds to 6 -> 6-8mm
        input.risk = .low
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("6-12 months"))
    }
    
    /// F004: 5.5mm rounds to 6mm (6-8mm threshold), high risk -> CT at 6-12m then 18-24m
    @Test func F004_solidMean5_5mmRoundsTo6HighRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.risk = .high
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("18-24 months"))
    }
    
    /// F005: 5.0mm exact, high risk -> Optional CT at 12 months
    @Test func F005_solid5mmHighRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .lessThanSix
        input.risk = .high
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("Optional CT at 12 months"))
        #expect(result.followUpInterval?.contains("12 months") == true)
    }
    
    // MARK: - F009-F012: 8mm Threshold Tests
    
    /// F009: 8.4mm rounds to 8mm (still 6-8mm range), low risk
    @Test func F009_solidMean8_4mmRoundsTo8LowRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight  // 8.4 rounds to 8 -> 6-8mm
        input.risk = .low
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("6-12 months"))
    }
    
    /// F010: 8.5mm rounds to 9mm (>8mm range), low risk -> Consider CT 3m, PET/CT
    @Test func F010_solidMean8_5mmRoundsTo9LowRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .greaterThanEight  // 8.5 rounds to 9 -> >8mm
        input.risk = .low
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3 months"))
        #expect(result.recommendation.contains("PET/CT"))
    }
    
    /// F011: 8.5mm rounds to 9mm (>8mm), high risk -> Consider CT 3m, PET/CT, tissue sampling
    @Test func F011_solidMean8_5mmRoundsTo9HighRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .greaterThanEight
        input.risk = .high
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3 months"))
        #expect(result.recommendation.contains("PET/CT"))
    }
    
    /// F012: Solid 12mm, high risk, spiculated -> Consider CT 3m, PET/CT, tissue sampling
    @Test func F012_solid12mmHighRiskSpiculated() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .greaterThanEight
        input.risk = .high
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3 months"))
        #expect(result.recommendation.contains("PET/CT"))
    }
    
    // MARK: - F013-F019: Multiple Solid Nodule Tests
    
    /// F013: Multiple solid <6mm, low risk -> No routine follow-up
    @Test func F013_multipleSolidLessThan6mmLowRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .lessThanSix
        input.risk = .low
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("No routine follow-up"))
    }
    
    /// F014: Multiple solid <6mm, high risk -> Optional CT at 12 months
    @Test func F014_multipleSolidLessThan6mmHighRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .lessThanSix
        input.risk = .high
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("Optional CT at 12 months"))
        #expect(result.followUpInterval?.contains("12 months") == true)
    }
    
    /// F015: Multiple solid 6-8mm (dominant 6.2mm rounds to 6), low risk -> CT at 3-6m
    @Test func F015_multipleSolid6mmLowRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.risk = .low
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
    }
    
    /// F016: Multiple solid 6-8mm, high risk -> CT at 3-6m then 18-24m
    @Test func F016_multipleSolid6To8mmHighRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.risk = .high
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("18-24 months"))
    }
    
    /// F017: Multiple solid >8mm (dominant 8.6mm), high risk -> CT at 3-6m
    @Test func F017_multipleSolidGreaterThan8mmHighRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .greaterThanEight
        input.risk = .high
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
    }
    
    /// F018: Multiple solid >8mm (dominant 10mm), low risk -> CT at 3-6m
    @Test func F018_multipleSolid10mmLowRisk() async throws {
        var input = FleischnerInput()
        input.noduleType = .solid
        input.sizeCategory = .greaterThanEight
        input.risk = .low
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
    }
    
    // MARK: - F026-F030: Pure GGO Tests
    
    /// F026: GGN 4.8mm (rounds to 5, <6mm) -> No routine follow-up
    @Test func F026_pureGGO4_8mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = .lessThanSix
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("No routine follow-up"))
    }
    
    /// F027: GGN 5.5mm (rounds to 6, ≥6mm) -> CT at 6-12m, then every 2y until 5y
    @Test func F027_pureGGO5_5mmRoundsTo6() async throws {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = .sixToEight  // 5.5 rounds to 6
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("5 years"))
    }
    
    /// F029: GGN 10mm -> CT at 6-12m, then every 2y until 5y
    @Test func F029_pureGGO10mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = .greaterThanEight
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("6-12 months"))
        #expect(result.recommendation.contains("5 years"))
    }
    
    // MARK: - F031-F036: Part-Solid Nodule Tests
    
    /// F031: Part-solid <6mm total -> No routine follow-up (treat as small GGN)
    @Test func F031_partSolidLessThan6mmTotal() async throws {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = .lessThanSix
        input.solidComponentSize = .lessThanSix
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("No routine follow-up"))
    }
    
    /// F032: Part-solid 6mm total, solid 3mm -> CT at 3-6m, then annual for 5y
    @Test func F032_partSolid6mmSolid3mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = .sixToEight
        input.solidComponentSize = .lessThanSix
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("5 years"))
    }
    
    /// F033: Part-solid 5.5mm (rounds to 6) with discrete solid -> CT at 3-6m
    @Test func F033_partSolid5_5mmRoundsTo6() async throws {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = .sixToEight
        input.solidComponentSize = .lessThanSix
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
    }
    
    /// F034: Part-solid 10mm total, solid 5mm -> CT at 3-6m, annual for 5y
    @Test func F034_partSolid10mmSolid5mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = .greaterThanEight
        input.solidComponentSize = .lessThanSix
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
    }
    
    /// F035: Part-solid 10mm total, solid 6mm (threshold) -> CT at 3-6m
    /// Note: PET/CT/biopsy only for solid >8mm or suspicious morphology per Fleischner 2017
    @Test func F035_partSolid10mmSolid6mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = .greaterThanEight
        input.solidComponentSize = .sixOrMore
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
    }
    
    /// F036: Part-solid 15mm total, solid 9mm -> CT at 3-6m, consider PET/CT/biopsy/resection
    @Test func F036_partSolid15mmSolid9mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = .greaterThanEight
        input.solidComponentSize = .sixOrMore
        input.isMultiple = false
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("PET/CT") || result.recommendation.contains("tissue sampling"))
    }
    
    // MARK: - F037-F040: Multiple Subsolid Nodule Tests
    
    /// F037: Multiple GGNs all <6mm -> CT at 3-6m, then 2 and 4 years
    @Test func F037_multipleGGNsLessThan6mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = .lessThanSix
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
        #expect(result.recommendation.contains("2 and 4 years"))
    }
    
    /// F039: Multiple subsolids with one GGN ≥6mm (8mm) -> CT at 3-6m
    @Test func F039_multipleSubsolidsOneGGN8mm() async throws {
        var input = FleischnerInput()
        input.noduleType = .pureGGO
        input.sizeCategory = .greaterThanEight
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
    }
    
    /// F040: Multiple subsolids with part-solid dominant (7mm, solid 4mm) -> CT at 3-6m
    @Test func F040_multipleSubsolidsPartSolidDominant() async throws {
        var input = FleischnerInput()
        input.noduleType = .partSolid
        input.sizeCategory = .sixToEight
        input.solidComponentSize = .lessThanSix
        input.isMultiple = true
        
        let result = FleischnerCalculator.calculate(input: input)
        #expect(result.recommendation.contains("3-6 months"))
    }
}

// MARK: - Lung-RADS Calculator Tests

@MainActor
struct LungRADSCalculatorTests {
    
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
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .lessThanFour
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    @Test func solidLessThan4mmNewReturnsCategory2() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .lessThanFour
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// Per Lung-RADS v2022: Resolved nodules may be reclassified to Category 1 or 2
    @Test func resolvedNoduleReturnsCategory1Or2() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .resolved
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat1 || result.category == .cat2)
    }
    
    // MARK: Category 3 Tests
    
    @Test func solid6To8mmBaselineReturnsCategory3() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    @Test func solid4To6mmNewReturnsCategory3() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .fourToSix
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    @Test func partSolidSolidLessThan6mmReturnsCategory3() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .eightToFifteen
        input.solidComponentSize = .fourToSix
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    @Test func ggo30mmPlusBaselineReturnsCategory3() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .thirtyPlus
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    // MARK: Category 4A Tests
    
    @Test func solid8To15mmBaselineReturnsCategory4A() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    @Test func solid6To8mmNewReturnsCategory4A() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    @Test func growingSolidLessThan8mmReturnsCategory4A() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .growing
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    @Test func partSolidSolid6To8mmReturnsCategory4A() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .eightToFifteen
        input.solidComponentSize = .sixToEight
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    // MARK: Category 4B Tests
    
    @Test func solid15mmPlusBaselineReturnsCategory4B() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .fifteenToThirty
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }
    
    @Test func solid8mmPlusNewReturnsCategory4B() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }
    
    @Test func growingSolid8mmPlusReturnsCategory4B() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .followUp
        input.noduleStatus = .growing
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }
    
    @Test func partSolidSolid8mmPlusReturnsCategory4B() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .fifteenToThirty
        input.solidComponentSize = .eightPlus
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
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
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .baseline
        input.hasAdditionalSuspiciousFeatures = true
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4X)
    }
    
    @Test func category4BWithSuspiciousFeaturesReturnsCategory4X() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .fifteenToThirty
        input.ctStatus = .baseline
        input.hasAdditionalSuspiciousFeatures = true
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4X)
    }
    
    // MARK: Reclassification Tests
    
    @Test func stableSolid6To8mmDowngradesTo2() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .stable
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
        #expect(result.isReclassified == true)
    }
    
    @Test func stableSolid8To15mmDowngradesTo3() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .followUp
        input.noduleStatus = .stable
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
        #expect(result.isReclassified == true)
    }
    
    // MARK: GGO Tests
    
    @Test func ggoLessThan30mmReturnsCategory2() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .fifteenToThirty
        input.ctStatus = .baseline

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }

    @Test func multipleGGOLessThan6mmReturnsCategory2WithNote() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .fourToSix
        input.ctStatus = .baseline
        input.isMultiple = true

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
        #expect(result.additionalNotes?.contains("Multiple nodules") == true)
    }

    @Test func stableGGO30mmPlusReturnsCategory2() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .thirtyPlus
        input.ctStatus = .followUp
        input.noduleStatus = .stable

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }

    @Test func slowGrowingGGNReturnsCategory2() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .fifteenToThirty
        input.ctStatus = .followUp
        input.noduleStatus = .slowGrowing

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
}

// MARK: - Lung-RADS Edge Cases (from nodule_edge_cases CSV)

@MainActor
struct LungRADSEdgeCaseTests {
    
    // MARK: - L001-L009: Category 0/1 Baseline Tests
    
    /// L001: Baseline screening with no pulmonary nodules -> Category 1
    @Test func L001_baselineNoNodules() async throws {
        var input = LungRADSInput()
        input.ctStatus = .baseline
        input.noduleType = .solid
        input.sizeCategory = .lessThanFour
        input.hasBenignCalcification = false
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2 || result.category == .cat1)
    }
    
    /// L002: Baseline with benign calcification (popcorn) -> Category 1
    @Test func L002_baselineBenignCalcification() async throws {
        var input = LungRADSInput()
        input.ctStatus = .baseline
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.hasBenignCalcification = true
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat1)
    }
    
    /// L003: Baseline with intralesional fat (hamartoma) -> Category 1
    @Test func L003_baselineMacroscopicFat() async throws {
        var input = LungRADSInput()
        input.ctStatus = .baseline
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.hasMacroscopicFat = true
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat1)
    }
    
    /// L004: Awaiting prior CT comparison -> Category 0
    @Test func L004_awaitingComparison() async throws {
        var input = LungRADSInput()
        input.ctStatus = .awaitingComparison
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat0)
    }
    
    /// L005: Part of lung not evaluable -> Category 0
    @Test func L005_incompleteCT() async throws {
        var input = LungRADSInput()
        input.ctStatus = .incomplete
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat0)
    }
    
    // MARK: - L010-L015: Solid Nodule Baseline Size Thresholds
    
    /// L010: Baseline solid 5.9mm (<6) -> Category 2
    @Test func L010_baselineSolid5_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .fourToSix  // 5.9mm is in 4-5.9 range
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// L011: Baseline solid 6.0mm (threshold for ≥6) -> Category 3
    @Test func L011_baselineSolid6_0mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    /// L012: Baseline solid 7.9mm -> Category 3
    @Test func L012_baselineSolid7_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    /// L013: Baseline solid 8.0mm (threshold for 4A) -> Category 4A
    @Test func L013_baselineSolid8_0mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    /// L014: Baseline solid 14.9mm (still 4A) -> Category 4A
    @Test func L014_baselineSolid14_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    /// L015: Baseline solid 15.0mm (threshold for 4B) -> Category 4B
    @Test func L015_baselineSolid15_0mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .fifteenToThirty
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }
    
    // MARK: - L016-L021: New Solid Nodule Tests
    
    /// L016: New solid 3.9mm (<4) -> Category 2
    @Test func L016_newSolid3_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .lessThanFour
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// L017: New solid 4.0mm (threshold for category 3) -> Category 3
    @Test func L017_newSolid4_0mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .fourToSix
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    /// L018: New solid 5.9mm -> Category 3
    @Test func L018_newSolid5_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .fourToSix
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    /// L019: New solid 6.0mm (new 6 to <8) -> Category 4A
    @Test func L019_newSolid6_0mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    /// L020: New solid 7.9mm -> Category 4A
    @Test func L020_newSolid7_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    /// L021: New solid 8.0mm (new ≥8) -> Category 4B
    @Test func L021_newSolid8_0mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }
    
    // MARK: - L022-L031: Growing/Stable/Threshold Solid Nodule Tests
    
    /// L022: Growing solid 6→7.7mm (+1.7mm growth, still <8) -> Category 4A
    @Test func L022_growingSolid6To7_7mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .growing
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    /// L023: Solid 6→7.4mm (+1.4mm, NOT growth criteria) -> Category 3
    @Test func L023_solidNoGrowth6To7_4mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .baseline  // No growth criteria met
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    /// L024: Category 3 (solid 7mm) stable at 6-month follow-up -> Category 2
    @Test func L024_stableSolid7mmAt6MonthFU() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .stable
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
        #expect(result.isReclassified == true)
    }
    
    /// L025: Category 4A (solid 9mm) stable at 3-month follow-up -> Category 3
    @Test func L025_stableSolid9mmAt3MonthFU() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .followUp
        input.noduleStatus = .stable
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
        #expect(result.isReclassified == true)
    }
    
    /// L026: Category 4A resolved at 3-month follow-up -> Category 1 or 2
    @Test func L026_resolvedSolid9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .followUp
        input.noduleStatus = .resolved
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat1 || result.category == .cat2)
    }
    
    /// L028: Solid crosses threshold to ≥8 (no growth criteria) -> Category 4A
    @Test func L028_solidCrossesThresholdTo8mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    /// L029: Solid 6→7.5mm (+1.5 EXACT, not >1.5) -> Category 3 (no growth)
    @Test func L029_solidExact1_5mmIncrease() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        // +1.5mm exactly is NOT growth (needs >1.5mm)
        input.noduleStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    // MARK: - L030-L031: Slow-Growing Solid/Part-Solid Tests

    /// L030: Slow-growing solid 7mm on follow-up -> Category 4B
    @Test func L030_slowGrowingSolid7mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .slowGrowing

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }

    /// L031: Slow-growing part-solid 12mm with solid 6mm -> Category 4B
    @Test func L031_slowGrowingPartSolid12mmSolid6mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .eightToFifteen
        input.solidComponentSize = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .slowGrowing

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }

    // MARK: - L032-L043: Part-Solid Nodule Tests
    
    /// L032: Baseline part-solid 5.9mm (<6) -> Category 2
    @Test func L032_baselinePartSolid5_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .fourToSix
        input.solidComponentSize = .lessThanFour
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// L033: Baseline part-solid 6mm with solid 5.9mm (<6) -> Category 3
    @Test func L033_baselinePartSolid6mmSolid5_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .sixToEight
        input.solidComponentSize = .fourToSix
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    /// L034: Baseline part-solid 10mm with solid 3mm -> Category 3
    @Test func L034_baselinePartSolid10mmSolid3mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .eightToFifteen
        input.solidComponentSize = .lessThanFour
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    /// L035: New part-solid 5mm (<6) -> Category 3
    @Test func L035_newPartSolid5mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .fourToSix
        input.solidComponentSize = .lessThanFour
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    /// L036: Baseline part-solid 12mm with solid 6.5mm (6-<8) -> Category 4A
    @Test func L036_baselinePartSolid12mmSolid6_5mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .eightToFifteen
        input.solidComponentSize = .sixToEight
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    /// L037: New part-solid 8mm with solid 3mm (new solid <4) -> Category 4A
    @Test func L037_newPartSolid8mmSolid3mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .eightToFifteen
        input.solidComponentSize = .lessThanFour
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    /// L039: Baseline part-solid 20mm with solid 8mm (≥8) -> Category 4B
    @Test func L039_baselinePartSolid20mmSolid8mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .fifteenToThirty
        input.solidComponentSize = .eightPlus
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }
    
    /// L040: New part-solid 10mm with solid 4mm (new ≥4) -> Category 4B
    @Test func L040_newPartSolid10mmSolid4mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .eightToFifteen
        input.solidComponentSize = .fourToSix
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }
    
    // MARK: - L044-L052: GGO (Non-Solid) Nodule Tests
    
    /// L044: Baseline GGN 10mm (<30) -> Category 2
    @Test func L044_baselineGGN10mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// L045: Baseline GGN 29.9mm (still <30) -> Category 2
    @Test func L045_baselineGGN29_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .fifteenToThirty
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// L046: Baseline GGN 30mm (threshold for category 3) -> Category 3
    @Test func L046_baselineGGN30mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .thirtyPlus
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    /// L047: New GGN 25mm (<30) -> Category 2
    @Test func L047_newGGN25mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .fifteenToThirty
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// L048: New GGN 30mm (≥30) -> Category 3
    @Test func L048_newGGN30mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .thirtyPlus
        input.ctStatus = .followUp
        input.noduleStatus = .newNodule
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }
    
    /// L050: Stable GGN 35mm at 6-month follow-up -> Category 2
    @Test func L050_stableGGN35mmAt6MonthFU() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .thirtyPlus
        input.ctStatus = .followUp
        input.noduleStatus = .stable
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// L051: Slow-growing GGN <30mm -> Category 2
    @Test func L051_slowGrowingGGNLessThan30mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .fifteenToThirty
        input.ctStatus = .followUp
        input.noduleStatus = .slowGrowing
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// L052: GGN doubles in 1 year (suspicious additional feature) -> Category 4X
    @Test func L052_ggnDoublesInOneYear() async throws {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = .fifteenToThirty
        input.ctStatus = .followUp
        input.noduleStatus = .growing
        input.hasAdditionalSuspiciousFeatures = true
        
        let result = LungRADSCalculator.calculate(input: input)
        // GGN with suspicious features should be elevated
        #expect(result.category == .cat2 || result.category == .cat4X)
    }
    
    // MARK: - L053-L056: Juxtapleural Nodule Tests
    
    /// L053: Baseline juxtapleural triangular 9.9mm (<10) -> Category 2
    /// Per Lung-RADS v2022: Juxtapleural with benign criteria <10mm = Category 2
    @Test func L053_baselineJuxtapleural9_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .juxtapleural
        input.hasBenignJuxtapleuralMorphology = true
        input.sizeCategory = .sixToEight  // Maps to <10mm for juxtapleural
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// L054: Baseline juxtapleural 10mm (not <10) -> Category 4A (treat as solid)
    @Test func L054_baselineJuxtapleural10mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .juxtapleural
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    // MARK: - L057-L060: Airway Nodule Tests
    
    /// L057: Baseline subsegmental airway nodule -> Category 2
    /// Per Lung-RADS v2022: Subsegmental airway findings tend to Category 2
    @Test func L057_baselineAirwaySubsegmental() async throws {
        var input = LungRADSInput()
        input.noduleType = .airway
        input.sizeCategory = .lessThanFour
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// L058: Baseline segmental airway nodule -> Category 4A
    /// Per Lung-RADS v2022: Baseline segmental/proximal = 4A (4B only for persistent in follow-up)
    @Test func L058_baselineAirwaySegmental() async throws {
        var input = LungRADSInput()
        input.noduleType = .airway
        input.airwayLocation = .segmentalOrProximal
        input.sizeCategory = .fourToSix
        input.ctStatus = .baseline

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    // MARK: - L062-L066: Atypical Cyst Tests
    
    /// L062: Baseline thick-walled cyst (≥2mm) -> Category 4A
    /// Per Lung-RADS v2022: Baseline thick-walled cyst = 4A
    @Test func L062_baselineThickWalledCyst() async throws {
        var input = LungRADSInput()
        input.noduleType = .atypicalCyst
        input.sizeCategory = .fifteenToThirty
        input.solidComponentSize = .lessThanFour
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    /// L063: Baseline multilocular cyst -> Category 4A
    /// Per Lung-RADS v2022: Baseline multilocular cyst = 4A
    @Test func L063_baselineMultilocularCyst() async throws {
        var input = LungRADSInput()
        input.noduleType = .atypicalCyst
        input.sizeCategory = .fifteenToThirty
        input.solidComponentSize = .lessThanFour
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
    
    /// L065: Growing wall thickness/nodularity -> Category 4B
    /// Per Lung-RADS v2022: Growing wall thickness/nodularity = 4B
    @Test func L065_growingWallThickness() async throws {
        var input = LungRADSInput()
        input.noduleType = .atypicalCyst
        input.sizeCategory = .fifteenToThirty
        input.solidComponentSize = .fourToSix
        input.ctStatus = .followUp
        input.noduleStatus = .growing
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }
    
    // MARK: - L070-L073: 4X Modifier Tests
    
    /// L071: Solid 7mm (category 3) with marked spiculations -> Category 4X
    /// Per Lung-RADS v2022: Category 3 + suspicious features = 4X
    @Test func L071_solid7mmWithSpiculations() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .baseline
        input.hasAdditionalSuspiciousFeatures = true
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4X)
    }
    
    /// L072: Solid 9mm (4A) + suspicious lymphadenopathy -> Category 4X
    @Test func L072_solid9mmWithLymphadenopathy() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .baseline
        input.hasAdditionalSuspiciousFeatures = true
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4X)
    }
    
    /// L073: Part-solid 12mm with solid 6.5mm (4A) + pleural retraction -> Category 4X
    @Test func L073_partSolidWithPleuralRetraction() async throws {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = .eightToFifteen
        input.solidComponentSize = .sixToEight
        input.ctStatus = .baseline
        input.hasAdditionalSuspiciousFeatures = true
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4X)
    }
    
    // MARK: - Perifissural Nodule Tests
    
    /// Perifissural nodule <10mm at baseline -> Category 2 (benign appearance)
    /// Per Lung-RADS v2022: Perifissural with benign criteria <10mm = Category 2
    @Test func perifissuralLessThan10mmBaseline() async throws {
        var input = LungRADSInput()
        input.noduleType = .perifissural
        input.sizeCategory = .sixToEight
        input.ctStatus = .baseline
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    /// Perifissural nodule stable -> Category 2
    /// Per Lung-RADS v2022: Perifissural with benign criteria = Category 2
    @Test func perifissuralStable() async throws {
        var input = LungRADSInput()
        input.noduleType = .perifissural
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .stable
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }
    
    // MARK: - Stepped Management Tests
    
    /// L082: Category 3 stable at 6-month follow-up -> Category 2
    @Test func L082_steppedManagement3To2() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .sixToEight
        input.ctStatus = .followUp
        input.noduleStatus = .stable
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
        #expect(result.isReclassified == true)
    }
    
    /// L083: Category 4A stable at 3-month -> 3, then stable at 6-month -> 2
    @Test func L083_steppedManagement4ATo3To2() async throws {
        // First step: 4A stable at 3-month -> 3
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = .eightToFifteen
        input.ctStatus = .followUp
        input.noduleStatus = .stable
        
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
        #expect(result.isReclassified == true)
    }
}

// MARK: - Rounding Edge Case Tests

@MainActor
struct RoundingEdgeCaseTests {
    @Test func fleischnerRoundsPointFiveUp() async throws {
        let viewModel = FleischnerViewModel()
        viewModel.sizeText = "8.5"
        #expect(viewModel.roundedSizeMm == 9)
        #expect(viewModel.input.sizeCategory == .greaterThanEight)
    }

    @Test func lungRadsRoundsToOneDecimal() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.sizeText = "5.96"
        let normalized = viewModel.input.sizeMm ?? 0
        #expect(abs(normalized - 6.0) < 0.0001)
    }
}

@MainActor
struct VolumeEdgeCaseTests {
    @Test func lungRadsBaselineVolume268ReturnsCategory4A() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.ctStatus = .baseline
        input.useVolume = true
        input.volumeMm3 = 268.0

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4A)
    }
}

@MainActor
struct GrowthCalculatorTests {
    @Test func growthCalculatorSetsGrowingWithinTwelveMonths() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.ctStatus = .followUp
        viewModel.useGrowthCalculator = true
        viewModel.sizeText = "7.2"
        viewModel.priorSizeText = "5.4"
        viewModel.priorDate = Date(timeIntervalSince1970: 0)
        viewModel.currentDate = Date(timeIntervalSince1970: 60 * 60 * 24 * 200)
        viewModel.calculate()
        #expect(viewModel.input.noduleStatus == .growing)
    }

    @Test func growthCalculatorSetsStableWhenBelowThreshold() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.ctStatus = .followUp
        viewModel.useGrowthCalculator = true
        viewModel.sizeText = "6.0"
        viewModel.priorSizeText = "5.2"
        viewModel.priorDate = Date(timeIntervalSince1970: 0)
        viewModel.currentDate = Date(timeIntervalSince1970: 60 * 60 * 24 * 180)
        viewModel.calculate()
        #expect(viewModel.input.noduleStatus == .stable)
    }
}
