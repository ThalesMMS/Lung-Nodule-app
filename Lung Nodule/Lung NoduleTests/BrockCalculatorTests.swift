import Testing
@testable import Lung_Nodule
import Foundation

@MainActor
struct BrockCalculatorTests {

    private func makeBrockInput(
        age: Int = 65,
        isFemale: Bool = false,
        noduleSizeMm: Double = 10,
        noduleType: BrockNoduleType = .solid,
        upperLobe: Bool = false,
        noduleCount: Int = 1,
        spiculation: Bool = false,
        familyHistory: Bool = false,
        emphysema: Bool = false
    ) -> BrockInput {
        BrockInput(
            age: age,
            isFemale: isFemale,
            noduleSizeMm: noduleSizeMm,
            noduleType: noduleType,
            upperLobe: upperLobe,
            noduleCount: noduleCount,
            spiculation: spiculation,
            familyHistory: familyHistory,
            emphysema: emphysema
        )
    }

    // MARK: - Risk Levels

    @Test func representativeLowIntermediateAndHighRiskCases() async throws {
        let low = try #require(BrockCalculator.calculate(input: makeBrockInput(
            age: 55,
            noduleSizeMm: 4,
            noduleCount: 4
        )))
        #expect(abs(low.malignancyProbability - 0.092011) < 0.0001)
        #expect(low.malignancyProbability < 5)
        #expect(low.riskCategory == .low)

        let intermediate = try #require(BrockCalculator.calculate(input: makeBrockInput(
            age: 68,
            isFemale: true,
            noduleSizeMm: 10,
            noduleType: .solid,
            upperLobe: true,
            noduleCount: 2,
            familyHistory: true
        )))
        #expect(abs(intermediate.malignancyProbability - 14.588653) < 0.0001)
        #expect(intermediate.malignancyProbability >= 5)
        #expect(intermediate.malignancyProbability < 65)
        #expect(intermediate.riskCategory == .intermediate)

        let high = try #require(BrockCalculator.calculate(input: makeBrockInput(
            age: 80,
            isFemale: true,
            noduleSizeMm: 30,
            noduleType: .partSolid,
            upperLobe: true,
            noduleCount: 1,
            spiculation: true,
            familyHistory: true,
            emphysema: true
        )))
        #expect(abs(high.malignancyProbability - 91.535942) < 0.0001)
        #expect(high.malignancyProbability >= 65)
        #expect(high.riskCategory == .high)
    }

    // MARK: - Boundaries

    @Test func acceptsInputBoundaries() async throws {
        let lowerBoundary = makeBrockInput(age: 18, noduleSizeMm: 3, noduleCount: 1)
        #expect(BrockCalculator.validate(input: lowerBoundary) == nil)
        #expect(BrockCalculator.calculate(input: lowerBoundary) != nil)

        let upperBoundary = makeBrockInput(age: 90, noduleSizeMm: 30, noduleCount: 10)
        #expect(BrockCalculator.validate(input: upperBoundary) == nil)
        #expect(BrockCalculator.calculate(input: upperBoundary) != nil)
    }

    @Test func edgeSizeAndAgeProduceFiniteProbabilities() async throws {
        // Smallest allowed size should still yield a sensible, finite probability.
        let minSize = try #require(BrockCalculator.calculate(input: makeBrockInput(noduleSizeMm: 3)))
        #expect(minSize.malignancyProbability.isFinite)
        #expect(minSize.malignancyProbability >= 0)
        #expect(minSize.malignancyProbability <= 100)

        // Largest allowed size with high-risk covariates should remain finite and within range.
        let maxSize = try #require(BrockCalculator.calculate(input: makeBrockInput(
            age: 90,
            isFemale: true,
            noduleSizeMm: 30,
            noduleType: .partSolid,
            upperLobe: true,
            noduleCount: 1,
            spiculation: true,
            familyHistory: true,
            emphysema: true
        )))
        #expect(maxSize.malignancyProbability.isFinite)
        #expect(maxSize.malignancyProbability >= 0)
        #expect(maxSize.malignancyProbability <= 100)
    }

    @Test func noduleCountVariationChangesRiskMonotonically() async throws {
        let countOne = try #require(BrockCalculator.calculate(input: makeBrockInput(noduleCount: 1)))
        let countFive = try #require(BrockCalculator.calculate(input: makeBrockInput(noduleCount: 5)))
        let countTen = try #require(BrockCalculator.calculate(input: makeBrockInput(noduleCount: 10)))

        #expect(countOne.malignancyProbability > countFive.malignancyProbability)
        #expect(countFive.malignancyProbability > countTen.malignancyProbability)
    }

    @Test func rejectsOutOfRangeInputs() async throws {
        #expect(BrockCalculator.validate(input: makeBrockInput(age: 17)) == .ageBelowMinimum)
        #expect(BrockCalculator.validate(input: makeBrockInput(noduleSizeMm: 2.9)) == .noduleSizeOutOfRange)
        #expect(BrockCalculator.validate(input: makeBrockInput(noduleSizeMm: 30.1)) == .noduleSizeOutOfRange)
        #expect(BrockCalculator.validate(input: makeBrockInput(noduleCount: 0)) == .noduleCountBelowMinimum)
        #expect(BrockCalculator.calculate(input: makeBrockInput(noduleCount: 0)) == nil)
    }

    // MARK: - Morphology

    @Test func morphologyCoefficientsRemainStable() async throws {
        let nonsolid = try #require(BrockCalculator.calculate(input: makeBrockInput(noduleType: .nonsolid)))
        let solid = try #require(BrockCalculator.calculate(input: makeBrockInput(noduleType: .solid)))
        let partSolid = try #require(BrockCalculator.calculate(input: makeBrockInput(noduleType: .partSolid)))

        #expect(abs(nonsolid.malignancyProbability - 3.065470) < 0.0001)
        #expect(abs(solid.malignancyProbability - 3.468206) < 0.0001)
        #expect(abs(partSolid.malignancyProbability - 4.977268) < 0.0001)
        #expect(nonsolid.malignancyProbability < solid.malignancyProbability)
        #expect(solid.malignancyProbability < partSolid.malignancyProbability)
    }

    // MARK: - Formula Stability

    @Test func publishedFormulaRegressionExampleRemainsStable() async throws {
        let input = makeBrockInput(
            age: 70,
            isFemale: true,
            noduleSizeMm: 4,
            noduleType: .solid,
            upperLobe: true
        )

        let result = try #require(BrockCalculator.calculate(input: input))
        #expect(abs(result.malignancyProbability - 0.634830) < 0.0001)
        #expect(result.reference.contains("McWilliams"))
    }

    @Test func missingOptionalCovariatesDefaultToFalse() async throws {
        // These covariates are user-provided toggles in the UI. Ensure the default baseline
        // (all optional covariates false) remains deterministic.
        let baseline = try #require(BrockCalculator.calculate(input: makeBrockInput(
            age: 65,
            isFemale: false,
            noduleSizeMm: 10,
            noduleType: .solid,
            upperLobe: false,
            noduleCount: 1,
            spiculation: false,
            familyHistory: false,
            emphysema: false
        )))
        #expect(abs(baseline.malignancyProbability - 3.468206) < 0.0001)
        #expect(baseline.riskCategory == .low)

        // Flipping each optional covariate individually should not decrease risk.
        let spic = try #require(BrockCalculator.calculate(input: makeBrockInput(spiculation: true)))
        let fam = try #require(BrockCalculator.calculate(input: makeBrockInput(familyHistory: true)))
        let emph = try #require(BrockCalculator.calculate(input: makeBrockInput(emphysema: true)))

        #expect(spic.malignancyProbability > baseline.malignancyProbability)
        #expect(fam.malignancyProbability > baseline.malignancyProbability)
        #expect(emph.malignancyProbability > baseline.malignancyProbability)
    }

    // MARK: - View Model

    @Test func viewModelUsesTypedGenderAndMorphology() async throws {
        let viewModel = BrockViewModel()
        viewModel.form.age = "68"
        viewModel.form.gender = .female
        viewModel.form.noduleSize = "10"
        viewModel.form.noduleMorphology = .partSolid
        viewModel.form.noduleCount = "2"

        let result = try #require(viewModel.result)
        let expected = try #require(BrockCalculator.calculate(input: makeBrockInput(
            age: 68,
            isFemale: true,
            noduleSizeMm: 10,
            noduleType: .partSolid,
            noduleCount: 2
        )))

        #expect(abs(result.malignancyProbability - expected.malignancyProbability) < 0.0001)
    }

    @Test func viewModelSurfacesDomainValidationAndRejectsUnparseableFields() async throws {
        let viewModel = BrockViewModel()
        viewModel.form.age = "17"
        viewModel.form.noduleSize = "10"
        viewModel.form.noduleCount = "1"

        #expect(viewModel.result == nil)
        #expect(viewModel.validationError == BrockValidationError.ageBelowMinimum.message)

        viewModel.form.age = "not an age"
        #expect(viewModel.result == nil)
        #expect(viewModel.validationError == nil)
    }

    // MARK: - Morphology Mapping

    @Test func lungRADSHandoffMorphologyMapping() async throws {
        let expected: [LungRADSNoduleType: BrockNoduleType] = [
            .solid: .solid,
            .partSolid: .partSolid,
            .groundGlass: .nonsolid,
            .juxtapleural: .solid,
            .perifissural: .solid
        ]
        let unsupported: [LungRADSNoduleType] = [.noNodule, .airway, .atypicalCyst]

        #expect(expected.count + unsupported.count == LungRADSNoduleType.allCases.count)

        for lungRADSType in expected.keys {
            #expect(BrockNoduleType.from(lungRADSType: lungRADSType) == expected[lungRADSType])
        }

        for lungRADSType in unsupported {
            #expect(BrockNoduleType.from(lungRADSType: lungRADSType) == nil)
        }
    }
}
