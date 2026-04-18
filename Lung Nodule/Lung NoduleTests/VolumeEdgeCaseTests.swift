import Testing
@testable import Lung_Nodule
import Foundation

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

    // MARK: - Volume Category Boundary Tests

    /// Volume of 100mm³ ≈ 5.8mm equivalent diameter → solid baseline <6mm → Category 2
    @Test func lungRadsBaselineVolumeSmallReturnsCategory2() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.ctStatus = .baseline
        input.useVolume = true
        input.volumeMm3 = 100.0

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat2)
    }

    /// Volume of 180mm³ ≈ 7.0mm equivalent diameter → solid baseline 6-<8mm → Category 3
    @Test func lungRadsBaselineVolume180ReturnsCategory3() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.ctStatus = .baseline
        input.useVolume = true
        input.volumeMm3 = 180.0

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat3)
    }

    /// Volume of 1770mm³ ≈ 15.0mm equivalent diameter → solid baseline ≥15mm → Category 4B
    @Test func lungRadsBaselineVolume1770ReturnsCategory4B() async throws {
        var input = LungRADSInput()
        input.noduleType = .solid
        input.ctStatus = .baseline
        input.useVolume = true
        input.volumeMm3 = 1770.0

        let result = LungRADSCalculator.calculate(input: input)
        #expect(result.category == .cat4B)
    }

    // MARK: - Volume Converter Tests

    /// Volume of 268mm³ converts to approximately 8mm diameter (sphere formula)
    @Test func volumeConverterEquivalentDiameterFor268mm3() async throws {
        let diameter = LungRADSVolumeConverter.equivalentDiameter(268.0)
        #expect(abs(diameter - 8.0) < 0.1)
    }

    /// Volume converter normalizeDiameter rounds to 0.1mm precision
    @Test func volumeConverterNormalizesDiameterToOneDecimal() async throws {
        let normalized = LungRADSVolumeConverter.normalizeDiameter(7.94)
        #expect(abs(normalized - 7.9) < 0.0001)
    }

    // MARK: - Volume-Based Input via ViewModel

    /// Volume input via ViewModel: 268mm³ (solid, baseline) → Category 4A
    @Test func lungRadsViewModelVolumeMeasurementProducesCategory4A() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.noduleType = .solid
        viewModel.input.ctStatus = .baseline
        viewModel.useVolumeMeasurements = true
        viewModel.volumeText = "268"
        viewModel.calculate()

        #expect(viewModel.result?.category == .cat4A)
    }

    /// Volume input via ViewModel: small volume (solid, baseline) → Category 2
    @Test func lungRadsViewModelSmallVolumeProducesCategory2() async throws {
        let viewModel = LungRADSViewModel()
        viewModel.input.noduleType = .solid
        viewModel.input.ctStatus = .baseline
        viewModel.useVolumeMeasurements = true
        viewModel.volumeText = "100"
        viewModel.calculate()

        #expect(viewModel.result?.category == .cat2)
    }
}