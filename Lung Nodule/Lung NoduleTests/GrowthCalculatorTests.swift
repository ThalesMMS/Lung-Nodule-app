import Testing
@testable import Lung_Nodule
import Foundation

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

    // MARK: - Growth Threshold Boundary Tests

    /// Exact 1.5mm delta is NOT growing (threshold requires > 1.5mm)
    @Test func growthCalculatorExactThresholdNotGrowing() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.ctStatus = .followUp
        viewModel.useGrowthCalculator = true
        viewModel.sizeText = "7.0"
        viewModel.priorSizeText = "5.5"  // delta = 1.5mm exactly
        viewModel.priorDate = Date(timeIntervalSince1970: 0)
        viewModel.currentDate = Date(timeIntervalSince1970: 60 * 60 * 24 * 180)
        viewModel.calculate()
        #expect(viewModel.input.noduleStatus == .stable)
    }

    /// Delta of 1.6mm within 12 months IS growing (> 1.5mm threshold)
    @Test func growthCalculatorJustAboveThresholdGrowing() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.ctStatus = .followUp
        viewModel.useGrowthCalculator = true
        viewModel.sizeText = "7.1"
        viewModel.priorSizeText = "5.5"  // delta = 1.6mm
        viewModel.priorDate = Date(timeIntervalSince1970: 0)
        viewModel.currentDate = Date(timeIntervalSince1970: 60 * 60 * 24 * 180)
        viewModel.calculate()
        #expect(viewModel.input.noduleStatus == .growing)
    }

    /// Interval beyond 12 months (366 days): status not updated to growing even with large delta
    @Test func growthCalculatorOutsideTwelveMonthsDoesNotSetGrowing() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.ctStatus = .followUp
        viewModel.priorDate = Date(timeIntervalSince1970: 0)
        viewModel.currentDate = Date(timeIntervalSince1970: 60 * 60 * 24 * 366)
        viewModel.sizeText = "10.0"
        viewModel.priorSizeText = "5.0"  // delta = 5mm but interval > 12 months
        viewModel.useGrowthCalculator = true
        viewModel.calculate()
        // Status should NOT be .growing; growth logic doesn't apply for > 12 months
        #expect(viewModel.input.noduleStatus != .growing)
    }

    /// Growth summary contains manual review prompt when interval exceeds 12 months
    @Test func growthCalculatorSummaryContainsManualReviewWhenOver12Months() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.ctStatus = .followUp
        viewModel.useGrowthCalculator = true
        viewModel.sizeText = "9.0"
        viewModel.priorSizeText = "6.0"
        viewModel.priorDate = Date(timeIntervalSince1970: 0)
        viewModel.currentDate = Date(timeIntervalSince1970: 60 * 60 * 24 * 400)
        viewModel.calculate()
        let summary = viewModel.growthSummary ?? ""
        #expect(summary.contains("12 months"))
    }

    /// Growth summary is nil when growth calculator is disabled
    @Test func growthCalculatorSummaryIsNilWhenDisabled() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.ctStatus = .followUp
        viewModel.useGrowthCalculator = false
        viewModel.sizeText = "7.2"
        viewModel.priorSizeText = "5.4"
        viewModel.priorDate = Date(timeIntervalSince1970: 0)
        viewModel.currentDate = Date(timeIntervalSince1970: 60 * 60 * 24 * 200)
        viewModel.calculate()
        #expect(viewModel.growthSummary == nil)
    }

    /// Growth calculator requires prior size text; missing prior size shows prompt
    @Test func growthCalculatorMissingPriorSizeShowsPrompt() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.ctStatus = .followUp
        viewModel.useGrowthCalculator = true
        viewModel.sizeText = "7.2"
        // priorSizeText intentionally left empty
        viewModel.priorDate = Date(timeIntervalSince1970: 0)
        viewModel.currentDate = Date(timeIntervalSince1970: 60 * 60 * 24 * 200)
        viewModel.calculate()
        let summary = viewModel.growthSummary ?? ""
        #expect(!summary.isEmpty)
    }

    /// Exactly 365-day interval is within 12 months: growth rules apply
    @Test func growthCalculatorExactly365DaysIsWithinTwelveMonths() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.ctStatus = .followUp
        viewModel.useGrowthCalculator = true
        viewModel.sizeText = "7.2"
        viewModel.priorSizeText = "5.4"  // delta = 1.8mm > 1.5mm threshold
        viewModel.priorDate = Date(timeIntervalSince1970: 0)
        viewModel.currentDate = Date(timeIntervalSince1970: 60 * 60 * 24 * 365)
        viewModel.calculate()
        #expect(viewModel.input.noduleStatus == .growing)
    }
}
