import SwiftUI

struct LungRADSView: View {
    @StateObject var viewModel = LungRADSViewModel()
    @State var showSModifierConsiderations = false
    @State var showCTStatusInfo = false
    @State var showMorphologyInfo = false
    @State var showCalcificationInfo = false
    @State var showSizeInfo = false
    @State var showNoduleStatusInfo = false
    @State var showSolidComponentInfo = false
    @State var showSuspiciousFeaturesInfo = false
    @FocusState var focusedField: FocusField?

    let blueAccent = Color.lungRADSAccent

    enum FocusField {
        case size
        case solidComponent
        case longAxis
        case shortAxis
        case volume
        case priorSize
        case age
        case quitYears
    }

    var onBrockRequest: ((LungRADSInput) -> Void)? = nil
    
    var body: some View {
        mainContent
            .onAppear { viewModel.calculate() }
            .modifier(LungRADSSheets(
                viewModel: viewModel,
                showSModifierConsiderations: $showSModifierConsiderations,
                showCTStatusInfo: $showCTStatusInfo
            ))
            .modifier(LungRADSAlerts(
                showMorphologyInfo: $showMorphologyInfo,
                showCalcificationInfo: $showCalcificationInfo,
                showSizeInfo: $showSizeInfo,
                showNoduleStatusInfo: $showNoduleStatusInfo,
                showSolidComponentInfo: $showSolidComponentInfo,
                showSuspiciousFeaturesInfo: $showSuspiciousFeaturesInfo
            ))
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                        .foregroundColor(blueAccent)
                }
            }
    }
    
    var mainContent: some View {
        AdaptiveCalculatorGrid {
            resultCardSection

            VStack(spacing: 18) {
                inputFieldsSection
                referenceButton
            }
        }
        .padding(.horizontal, 8)
        .tint(blueAccent)
    }

    // MARK: - Result Card Section
    @ViewBuilder
    var resultCardSection: some View {
        if let result = viewModel.result {
            let brockAction: (() -> Void)? = (result.category == .cat4B
                && onBrockRequest != nil
                && BrockNoduleType.from(lungRADSType: viewModel.input.noduleType) != nil)
                ? { onBrockRequest?(viewModel.input) }
                : nil
            LungRADSResultCard(
                result: result,
                blueAccent: blueAccent,
                onSModifierTap: { showSModifierConsiderations.toggle() },
                onBrockTap: brockAction,
                onReset: {
                    viewModel.reset()
                    viewModel.calculate()
                }
            )
        }
    }

    // MARK: - Input Fields Section
    @ViewBuilder
    var inputFieldsSection: some View {
        SettingsSection(title: "Patient") {
            eligibilitySection
        }

        eligibilityNotice

        SettingsSection(title: "Exam") {
            ctStatusRow
        }

        SettingsSection(title: "Nodule") {
            morphologyRow
            juxtapleuralMorphologyRow
            benignFeaturesGroup
            multipleNodulesRow
            inflammatoryFindingsRow
            atelectasisRow
        }

        SettingsSection(title: "Measurements") {
            sizeRow
            volumeMeasurementSection
            axisMeasurementSection
            solidComponentRow
        }

        if viewModel.input.ctStatus == .followUp {
            SettingsSection(title: "Comparison with Prior") {
                noduleStatusRow
                growthCalculatorSection
            }

            growthSummaryNote
        }

        SettingsSection(title: "Risk Features") {
            suspiciousFeaturesRow
        }
    }

}
