import Testing
@testable import Lung_Nodule
import Foundation

@MainActor
struct LungRADSInputValidationTests {
    @Test func emptyLungRADSFormDoesNotProduceRecommendation() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.calculate()

        #expect(viewModel.result == nil)
    }

    @Test func noNoduleStillCalculatesWithoutMeasurements() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.noduleType = .noNodule
        viewModel.calculate()

        #expect(viewModel.result?.category == .cat1)
    }

    @Test func partSolidRequiresSolidComponentMeasurement() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.noduleType = .partSolid
        viewModel.sizeText = "8.0"
        viewModel.calculate()

        #expect(viewModel.result == nil)
    }

    @Test func partSolidWithInvalidSolidComponentTextDoesNotProduceRecommendation() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.noduleType = .partSolid
        viewModel.sizeText = "8.0"
        viewModel.solidComponentText = "abc"
        viewModel.calculate()

        #expect(viewModel.result == nil)
    }

    // MARK: - Additional Input Validation Tests

    /// Non-numeric size text is rejected and does not produce a recommendation
    @Test func invalidSizeTextDoesNotProduceRecommendation() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.noduleType = .solid
        viewModel.sizeText = "abc"
        viewModel.calculate()

        #expect(viewModel.result == nil)
    }

    /// Valid volume input (solid, baseline) produces a result
    @Test func volumeMeasurementWithValidVolumeProducesResult() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.noduleType = .solid
        viewModel.input.ctStatus = .baseline
        viewModel.useVolumeMeasurements = true
        viewModel.volumeText = "268"
        viewModel.calculate()

        #expect(viewModel.result != nil)
    }

    /// Atypical cyst also requires a solid component measurement before calculating
    @Test func atypicalCystRequiresSolidComponentMeasurement() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.noduleType = .atypicalCyst
        viewModel.sizeText = "20.0"
        viewModel.calculate()

        #expect(viewModel.result == nil)
    }

    /// Atypical cyst with a valid solid component measurement produces a result
    @Test func atypicalCystWithSolidComponentProducesResult() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.noduleType = .atypicalCyst
        viewModel.input.ctStatus = .baseline
        viewModel.sizeText = "20.0"
        viewModel.solidComponentText = "3.0"
        viewModel.calculate()

        #expect(viewModel.result != nil)
    }

    // MARK: - Eligibility Notice Tests

    /// Patient age > 80 triggers an eligibility notice
    @Test func eligibilityNoticeAppearsForAgeOver80() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.ageText = "81"
        #expect(viewModel.eligibilityNotice != nil)
    }

    /// Former smoker who quit more than 15 years ago triggers an eligibility notice
    @Test func eligibilityNoticeAppearsForFormerSmokerQuit16Years() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.isCurrentSmoker = false
        viewModel.yearsSinceQuitText = "16"
        #expect(viewModel.eligibilityNotice != nil)
    }

    /// Eligible patient (age 70, current smoker) has no eligibility notice
    @Test func eligibilityNoticeNilForEligibleCurrentSmoker() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.ageText = "70"
        viewModel.isCurrentSmoker = true
        #expect(viewModel.eligibilityNotice == nil)
    }

    /// Former smoker who quit exactly 15 years ago is still eligible (threshold is > 15 years)
    @Test func eligibilityNoticeNilForQuit15Years() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.isCurrentSmoker = false
        viewModel.yearsSinceQuitText = "15"
        #expect(viewModel.eligibilityNotice == nil)
    }

    // MARK: - Shortcut Categorization Tests

    /// Resolved nodule bypasses size measurement requirement and produces a result
    @Test func resolvedNoduleCalculatesWithoutSizeMeasurement() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.noduleType = .solid
        viewModel.input.ctStatus = .followUp
        viewModel.input.noduleStatus = .resolved
        viewModel.calculate()

        #expect(viewModel.result != nil)
    }

    /// Incomplete CT bypasses size measurement requirement and returns Category 0
    @Test func incompleteCTCalculatesWithoutSizeMeasurement() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.ctStatus = .incomplete
        viewModel.calculate()

        #expect(viewModel.result?.category == .cat0)
    }
}