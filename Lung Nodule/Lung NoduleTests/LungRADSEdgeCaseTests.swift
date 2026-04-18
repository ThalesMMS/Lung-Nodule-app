import Testing
@testable import Lung_Nodule
import Foundation

@MainActor
struct LungRADSEdgeCaseTests {

    private func makeSolidInput(
        size: LungRADSSize,
        sizeMm: Double? = nil,
        ctStatus: CTStatus = .baseline,
        noduleStatus: NoduleStatus = .baseline
    ) -> LungRADSInput {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.sizeCategory = size
        input.sizeMm = sizeMm
        input.ctStatus = ctStatus
        input.noduleStatus = noduleStatus
        return input
    }

    private func makeGGOInput(
        size: LungRADSSize,
        sizeMm: Double? = nil,
        ctStatus: CTStatus = .baseline,
        noduleStatus: NoduleStatus = .baseline
    ) -> LungRADSInput {
        var input = LungRADSInput()
        input.noduleType = .groundGlass
        input.sizeCategory = size
        input.sizeMm = sizeMm
        input.ctStatus = ctStatus
        input.noduleStatus = noduleStatus
        return input
    }

    private func makePartSolidInput(
        size: LungRADSSize,
        sizeMm: Double? = nil,
        solidSize: LungRADSSolidComponentSize,
        solidMm: Double? = nil,
        ctStatus: CTStatus = .baseline,
        noduleStatus: NoduleStatus = .baseline
    ) -> LungRADSInput {
        var input = LungRADSInput()
        input.noduleType = .partSolid
        input.sizeCategory = size
        input.sizeMm = sizeMm
        input.solidComponentSize = solidSize
        input.solidComponentMm = solidMm
        input.ctStatus = ctStatus
        input.noduleStatus = noduleStatus
        return input
    }

    // MARK: - L001-L003: Category 1 Baseline Tests

    /// L001: Baseline screening with no pulmonary nodules -> Category 1
    @Test func L001_baselineNoNodules() async throws {
        var input = LungRADSInput()
        input.ctStatus = .baseline
        input.noduleType = .noNodule

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat1)
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

    // MARK: - L010-L015: Solid Nodule Baseline Size Thresholds

    /// L010: Baseline solid 5.9mm (<6) -> Category 2
    @Test func L010_baselineSolid5_9mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .fourToSix, sizeMm: 5.9))
        #expect(result.category == .cat2)
    }

    /// L011: Baseline solid 6.0mm (threshold for ≥6) -> Category 3
    @Test func L011_baselineSolid6_0mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 6.0))
        #expect(result.category == .cat3)
    }

    /// L012: Baseline solid 7.9mm -> Category 3
    @Test func L012_baselineSolid7_9mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 7.9))
        #expect(result.category == .cat3)
    }

    /// L013: Baseline solid 8.0mm (threshold for 4A) -> Category 4A
    @Test func L013_baselineSolid8_0mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .eightToFifteen, sizeMm: 8.0))
        #expect(result.category == .cat4A)
    }

    /// L014: Baseline solid 14.9mm (still 4A) -> Category 4A
    @Test func L014_baselineSolid14_9mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .eightToFifteen, sizeMm: 14.9))
        #expect(result.category == .cat4A)
    }

    /// L015: Baseline solid 15.0mm (threshold for 4B) -> Category 4B
    @Test func L015_baselineSolid15_0mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .fifteenToThirty, sizeMm: 15.0))
        #expect(result.category == .cat4B)
    }
    
    // MARK: - L016-L021: New Solid Nodule Tests

    /// L016: New solid 3.9mm (<4) -> Category 2
    @Test func L016_newSolid3_9mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .lessThanFour, sizeMm: 3.9, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat2)
    }

    /// L017: New solid 4.0mm (threshold for category 3) -> Category 3
    @Test func L017_newSolid4_0mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .fourToSix, sizeMm: 4.0, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat3)
    }

    /// L018: New solid 5.9mm -> Category 3
    @Test func L018_newSolid5_9mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .fourToSix, sizeMm: 5.9, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat3)
    }

    /// L019: New solid 6.0mm (new 6 to <8) -> Category 4A
    @Test func L019_newSolid6_0mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 6.0, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat4A)
    }

    /// L020: New solid 7.9mm -> Category 4A
    @Test func L020_newSolid7_9mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 7.9, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat4A)
    }

    /// L021: New solid 8.0mm (new ≥8) -> Category 4B
    @Test func L021_newSolid8_0mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .eightToFifteen, sizeMm: 8.0, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat4B)
    }

    // MARK: - L022-L029: Growing/Stable/Threshold Solid Nodule Tests

    /// L022: Growing solid 6→7.7mm (+1.7mm growth, still <8) -> Category 4A
    @Test func L022_growingSolid6To7_7mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 7.7, ctStatus: .followUp, noduleStatus: .growing))
        #expect(result.category == .cat4A)
    }

    /// L023: Solid 6→7.4mm (+1.4mm, NOT growth criteria) -> Category 3
    @Test func L023_solidNoGrowth6To7_4mm() async throws {
        // noduleStatus .baseline means no growth criteria met
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 7.4, ctStatus: .followUp))
        #expect(result.category == .cat3)
    }

    /// L024: Category 3 (solid 7mm) stable at 6-month follow-up -> Category 2
    @Test func L024_stableSolid7mmAt6MonthFU() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 7.0, ctStatus: .followUp, noduleStatus: .stable))
        #expect(result.category == .cat2)
        #expect(result.isReclassified == true)
    }

    /// L025: Category 4A (solid 9mm) stable at 3-month follow-up -> Category 3
    @Test func L025_stableSolid9mmAt3MonthFU() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .eightToFifteen, sizeMm: 9.0, ctStatus: .followUp, noduleStatus: .stable))
        #expect(result.category == .cat3)
        #expect(result.isReclassified == true)
    }

    /// L026: Category 4A resolved at 3-month follow-up -> Category 2
    @Test func L026_resolvedSolid9mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .eightToFifteen, sizeMm: 9.0, ctStatus: .followUp, noduleStatus: .resolved))
        #expect(result.category == .cat2)
    }

    /// L029: Solid 6→7.5mm (+1.5 EXACT, not >1.5) -> Category 3 (no growth)
    @Test func L029_solidExact1_5mmIncrease() async throws {
        // +1.5mm exactly is NOT growth (needs >1.5mm); noduleStatus .baseline means no growth criteria
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 7.5, ctStatus: .followUp))
        #expect(result.category == .cat3)
    }
    
    // MARK: - L030-L031: Slow-Growing Solid/Part-Solid Tests

    /// L030: Slow-growing solid 7mm on follow-up -> Category 4B
    @Test func L030_slowGrowingSolid7mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeSolidInput(size: .sixToEight, sizeMm: 7.0, ctStatus: .followUp, noduleStatus: .slowGrowing))
        #expect(result.category == .cat4B)
    }

    /// L031: Slow-growing part-solid 12mm with solid 6mm -> Category 4B
    @Test func L031_slowGrowingPartSolid12mmSolid6mm() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .eightToFifteen, sizeMm: 12.0, solidSize: .sixToEight, solidMm: 6.0, ctStatus: .followUp, noduleStatus: .slowGrowing))
        #expect(result.category == .cat4B)
    }

    // MARK: - L032-L043: Part-Solid Nodule Tests

    /// L032: Baseline part-solid 5.9mm (<6) -> Category 2
    @Test func L032_baselinePartSolid5_9mm() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .fourToSix, sizeMm: 5.9, solidSize: .lessThanFour))
        #expect(result.category == .cat2)
    }

    /// L033: Baseline part-solid 6mm with solid 5.9mm (<6) -> Category 3
    @Test func L033_baselinePartSolid6mmSolid5_9mm() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .sixToEight, sizeMm: 6.0, solidSize: .fourToSix, solidMm: 5.9))
        #expect(result.category == .cat3)
    }

    /// L034: Baseline part-solid 10mm with solid 3mm -> Category 3
    @Test func L034_baselinePartSolid10mmSolid3mm() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .eightToFifteen, sizeMm: 10.0, solidSize: .lessThanFour, solidMm: 3.0))
        #expect(result.category == .cat3)
    }

    /// L035: New part-solid 5mm (<6) -> Category 3
    @Test func L035_newPartSolid5mm() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .fourToSix, sizeMm: 5.0, solidSize: .lessThanFour, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat3)
    }

    /// L036: Baseline part-solid 12mm with solid 6.5mm (6-<8) -> Category 4A
    @Test func L036_baselinePartSolid12mmSolid6_5mm() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .eightToFifteen, sizeMm: 12.0, solidSize: .sixToEight, solidMm: 6.5))
        #expect(result.category == .cat4A)
    }

    /// L037: New part-solid 8mm with solid 3mm (new solid <4) -> Category 4A
    @Test func L037_newPartSolid8mmSolid3mm() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .eightToFifteen, sizeMm: 8.0, solidSize: .lessThanFour, solidMm: 3.0, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat4A)
    }

    /// L039: Baseline part-solid 20mm with solid 8mm (≥8) -> Category 4B
    @Test func L039_baselinePartSolid20mmSolid8mm() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .fifteenToThirty, sizeMm: 20.0, solidSize: .eightPlus, solidMm: 8.0))
        #expect(result.category == .cat4B)
    }

    /// L040: New part-solid 10mm with solid 4mm (new ≥4) -> Category 4B
    @Test func L040_newPartSolid10mmSolid4mm() async throws {
        let result = LungRADSCalculator.calculate(input: makePartSolidInput(size: .eightToFifteen, sizeMm: 10.0, solidSize: .fourToSix, solidMm: 4.0, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat4B)
    }

    // MARK: - L044-L052: GGO (Non-Solid) Nodule Tests

    /// L044: Baseline GGN 10mm (<30) -> Category 2
    @Test func L044_baselineGGN10mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .eightToFifteen, sizeMm: 10.0))
        #expect(result.category == .cat2)
    }

    /// L045: Baseline GGN 29.9mm (still <30) -> Category 2
    @Test func L045_baselineGGN29_9mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .fifteenToThirty, sizeMm: 29.9))
        #expect(result.category == .cat2)
    }

    /// L046: Baseline GGN 30mm (threshold for category 3) -> Category 3
    @Test func L046_baselineGGN30mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .thirtyPlus, sizeMm: 30.0))
        #expect(result.category == .cat3)
    }
    
    /// L047: New GGN 25mm (<30) -> Category 2
    @Test func L047_newGGN25mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .fifteenToThirty, sizeMm: 25.0, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat2)
    }

    /// L048: New GGN 30mm (≥30) -> Category 3
    @Test func L048_newGGN30mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .thirtyPlus, sizeMm: 30.0, ctStatus: .followUp, noduleStatus: .newNodule))
        #expect(result.category == .cat3)
    }

    /// L050: Stable GGN 35mm at 6-month follow-up -> Category 2
    @Test func L050_stableGGN35mmAt6MonthFU() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .thirtyPlus, sizeMm: 35.0, ctStatus: .followUp, noduleStatus: .stable))
        #expect(result.category == .cat2)
    }

    /// L051: Slow-growing GGN <30mm -> Category 2
    @Test func L051_slowGrowingGGNLessThan30mm() async throws {
        let result = LungRADSCalculator.calculate(input: makeGGOInput(size: .fifteenToThirty, ctStatus: .followUp, noduleStatus: .slowGrowing))
        #expect(result.category == .cat2)
    }

    /// L052: GGN doubles in 1 year (suspicious additional feature) -> Category 2
    @Test func L052_ggnDoublesInOneYear() async throws {
        var input = makeGGOInput(size: .fifteenToThirty, ctStatus: .followUp, noduleStatus: .growing)
        input.hasAdditionalSuspiciousFeatures = true
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }

    // MARK: - L053-L056: Juxtapleural Nodule Tests

    /// L053: Baseline juxtapleural triangular 9.9mm (<10) -> Category 2
    /// Per Lung-RADS v2022: Juxtapleural with benign criteria <10mm = Category 2
    @Test func L053_baselineJuxtapleural9_9mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .juxtapleural
        input.hasBenignJuxtapleuralMorphology = true
        input.sizeCategory = .sixToEight  // Maps to <10mm for juxtapleural
        input.sizeMm = 9.9
        input.ctStatus = .baseline
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }

    /// L054: Baseline juxtapleural 10mm (not <10) -> Category 4A (treat as solid)
    @Test func L054_baselineJuxtapleural10mm() async throws {
        var input = LungRADSInput()
        input.noduleType = .juxtapleural
        input.sizeCategory = .eightToFifteen
        input.sizeMm = 10.0
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
        var input = makeSolidInput(size: .sixToEight, sizeMm: 7.0)
        input.hasAdditionalSuspiciousFeatures = true
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4X)
    }

    /// L072: Solid 9mm (4A) + suspicious lymphadenopathy -> Category 4X
    @Test func L072_solid9mmWithLymphadenopathy() async throws {
        var input = makeSolidInput(size: .eightToFifteen, sizeMm: 9.0)
        input.hasAdditionalSuspiciousFeatures = true
        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4X)
    }

    /// L073: Part-solid 12mm with solid 6.5mm (4A) + pleural retraction -> Category 4X
    @Test func L073_partSolidWithPleuralRetraction() async throws {
        var input = makePartSolidInput(size: .eightToFifteen, sizeMm: 12.0, solidSize: .sixToEight, solidMm: 6.5)
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
}
