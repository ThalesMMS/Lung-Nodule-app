import Testing
@testable import Lung_Nodule

@MainActor
struct LungRADSSModifierStateBindingTests {

    @Test func S001_sModifierAppliesToComputedBaseCategory() async throws {
        var input = LungRADSInput()
        input.ctStatus = .baseline
        input.noduleType = .solid
        input.sizeMm = 8.0
        input.hasSModifierFindings = true

        let result = LungRADSCalculator.calculate(input: input)

        #expect(result.category == .cat4A)
        #expect(result.hasSModifier == true)
        #expect(result.baseCategory == nil)
        #expect(result.additionalNotes?.contains("Modifier 'S' applied") == true)
    }

    @Test func S002_sModifierDoesNotPersistAcrossEditsOrScenarios() async throws {
        var input = LungRADSInput()
        input.ctStatus = .baseline
        input.noduleType = .solid
        input.sizeMm = 8.0
        input.hasSModifierFindings = true

        let withS = LungRADSCalculator.calculate(input: input)
        #expect(withS.hasSModifier == true)

        input.hasSModifierFindings = false
        let withoutS = LungRADSCalculator.calculate(input: input)
        #expect(withoutS.category == .cat4A)
        #expect(withoutS.hasSModifier == false)
        #expect(withoutS.additionalNotes?.contains("Modifier 'S' applied") != true)

        input.hasSModifierFindings = true
        let reapplied = LungRADSCalculator.calculate(input: input)
        #expect(reapplied.hasSModifier == true)
    }

    @Test func S003_sModifierDoesNotOverride4XUpgrade() async throws {
        var input = LungRADSInput()
        input.ctStatus = .baseline
        input.noduleType = .solid
        input.sizeMm = 8.0
        input.hasAdditionalSuspiciousFeatures = true
        input.hasSModifierFindings = true

        let result = LungRADSCalculator.calculate(input: input)

        #expect(result.category == .cat4X)
        #expect(result.baseCategory == .cat4A)
        #expect(result.hasSModifier == true)
    }

    @Test func solidComponentGrowthFlagClearsWhenPartSolidGrowingNoLongerApplies() async throws {
        let viewModel = LungRADSViewModel(calculationScheduler: { action in action() })
        viewModel.input.ctStatus = .followUp
        viewModel.input.noduleType = .partSolid
        viewModel.input.noduleStatus = .growing
        viewModel.input.solidComponentGrowthDetected = true

        #expect(viewModel.input.solidComponentGrowthDetected == true)

        viewModel.input.noduleStatus = .stable
        #expect(viewModel.input.solidComponentGrowthDetected == false)

        viewModel.input.noduleStatus = .growing
        viewModel.input.solidComponentGrowthDetected = true
        viewModel.input.noduleType = .solid
        #expect(viewModel.input.solidComponentGrowthDetected == false)
    }
}
