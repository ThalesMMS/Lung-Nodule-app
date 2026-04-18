import Testing
@testable import Lung_Nodule
import Foundation

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

    // MARK: - Fleischner Axis Measurement Rounding

    /// Axis mean of 8.5mm (longAxis=9, shortAxis=8) rounds up to 9 → greaterThanEight
    @Test func fleischnerAxisMeanRoundsUpAt8_5() async throws {
        let viewModel = FleischnerViewModel()
        viewModel.useAxisMeasurements = true
        viewModel.longAxisText = "9"
        viewModel.shortAxisText = "8"
        #expect(viewModel.roundedSizeMm == 9)
        #expect(viewModel.axisMeanMm == 8.5)
        #expect(viewModel.input.sizeCategory == .greaterThanEight)
    }

    /// Axis mean of 7.5mm (longAxis=8, shortAxis=7) rounds up to 8 → remains sixToEight
    @Test func fleischnerAxisMeanAt7_5RoundsUpTo8() async throws {
        let viewModel = FleischnerViewModel()
        viewModel.useAxisMeasurements = true
        viewModel.longAxisText = "8"
        viewModel.shortAxisText = "7"
        #expect(viewModel.roundedSizeMm == 8)
        #expect(viewModel.input.sizeCategory == .sixToEight)
    }

    /// Comma as decimal separator is treated the same as a period
    @Test func fleischnerCommaAsDecimalSeparator() async throws {
        let viewModel = FleischnerViewModel()
        viewModel.sizeText = "5,5"
        #expect(viewModel.roundedSizeMm == 6)
        #expect(viewModel.input.sizeCategory == .sixToEight)
    }

    @Test func fleischnerInvalidSizeClearsDerivedCategory() async throws {
        let viewModel = FleischnerViewModel()
        viewModel.sizeText = "8.5"
        viewModel.sizeText = "invalid"
        #expect(viewModel.input.sizeMm == nil)
        #expect(viewModel.roundedSizeMm == nil)
        #expect(viewModel.input.sizeCategory == .lessThanSix)
    }

    @Test func fleischnerInvalidSolidComponentClearsDerivedCategory() async throws {
        let viewModel = FleischnerViewModel()
        viewModel.solidComponentText = "6"
        viewModel.solidComponentText = "invalid"
        #expect(viewModel.input.solidComponentMm == 0)
        #expect(viewModel.input.solidComponentSize == .none)
    }

    @Test func fleischnerNegativeSolidComponentClampsToNone() async throws {
        let viewModel = FleischnerViewModel()
        viewModel.solidComponentText = "-3"
        #expect(viewModel.input.solidComponentMm == 0)
        #expect(viewModel.input.solidComponentSize == .none)
    }

    /// Rounding message appears when raw value is not an integer
    @Test func fleischnerRoundingMessageAppearsWhenNotExact() async throws {
        let viewModel = FleischnerViewModel()
        viewModel.sizeText = "5.5"
        #expect(viewModel.roundingMessage != nil)
    }

    /// No rounding message when the entered value is already an integer
    @Test func fleischnerRoundingMessageNilWhenExact() async throws {
        let viewModel = FleischnerViewModel()
        viewModel.sizeText = "6.0"
        #expect(viewModel.roundingMessage == nil)
    }

    // MARK: - Lung-RADS Normalization

    /// Value 7.94 normalizes to 7.9mm (truncates at one decimal)
    @Test func lungRadsNormalizesValuesBelowBoundary() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.sizeText = "7.94"
        let normalized = viewModel.input.sizeMm ?? 0
        #expect(abs(normalized - 7.9) < 0.0001)
    }

    /// Value 3.95 normalizes to 4.0mm (rounds up at one decimal)
    @Test func lungRadsRoundsUpAtHalfDecimal() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.sizeText = "3.95"
        let normalized = viewModel.input.sizeMm ?? 0
        #expect(abs(normalized - 4.0) < 0.0001)
    }
}
