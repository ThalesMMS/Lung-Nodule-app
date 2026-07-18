import SwiftUI
import Foundation

enum AppMode: CaseIterable {
    case info // Common Issues/Reference
    case calculator // Guideline calculators
    case risk // Brock risk calculator
    case menu // References

    var accessibilityLabel: String {
        switch self {
        case .info: return "Common issues"
        case .calculator: return "Guideline calculator"
        case .risk: return "Brock risk calculator"
        case .menu: return "References"
        }
    }

    var accessibilityHint: String {
        "Shows the \(accessibilityLabel.lowercased()) screen."
    }

    var accessibilityIdentifier: String {
        switch self {
        case .info: return "mode.info"
        case .calculator: return "mode.calculator"
        case .risk: return "mode.brock"
        case .menu: return "mode.references"
        }
    }

    var tabTitle: String {
        switch self {
        case .info: return "Issues"
        case .calculator: return "Calculate"
        case .risk: return "Brock"
        case .menu: return "References"
        }
    }

    var tabIcon: String {
        switch self {
        case .info: return "lightbulb.max"
        case .calculator: return "slider.horizontal.3"
        case .risk: return "percent"
        case .menu: return "books.vertical"
        }
    }
}

enum CalculatorType: String, CaseIterable, Identifiable {
    case fleischner = "Fleischner 2017"
    case lungRADS = "Lung-RADS v2022"

    var id: String { self.rawValue }

    var accessibilityIdentifier: String {
        switch self {
        case .fleischner: return "calculator.fleischner"
        case .lungRADS: return "calculator.lung-rads"
        }
    }

    var color: Color {
        switch self {
        case .fleischner: return .fleischnerAccent
        case .lungRADS: return .lungRADSAccent
        }
    }

    var onColor: Color {
        switch self {
        case .fleischner: return .black.opacity(0.82)
        case .lungRADS: return .white
        }
    }
}

struct ContentView: View {
    @State private var selectedCalculator: CalculatorType = .fleischner
    @State private var startMode: AppMode = .calculator // Default to calculator as per user request for tool
    @StateObject private var brockViewModel = BrockViewModel()
    @State private var brockHandoffError: String?
    @State private var selectedReference: ReferenceType?
    @Namespace private var segmentAnimation
    @Namespace private var tabAnimation

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackdrop()

                VStack(spacing: 0) {
                    header

                    if startMode == .calculator || startMode == .info {
                        calculatorSwitcher
                            .padding(.top, 2)
                            .padding(.bottom, 14)
                    }

                    ScrollView {
                        Group {
                            if startMode == .calculator {
                                if selectedCalculator == .fleischner {
                                    FleischnerView()
                                        .padding(.top)
                                } else {
                                    LungRADSView(onBrockRequest: openBrockPrefilled)
                                        .padding(.top)
                                }
                            } else if startMode == .info {
                                commonIssuesList
                            } else if startMode == .menu {
                                referencesList
                            } else if startMode == .risk {
                                BrockView(viewModel: brockViewModel)
                                    .padding(.top)
                            }
                        }
                        .padding(.bottom, 104)
                    }
                    .scrollIndicators(.hidden)
                }
                .frame(maxWidth: 1100)

                VStack {
                    Spacer()
                    tabBar
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            // Hide default nav bar since we built a custom top bar
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .alert("Brock handoff unavailable", isPresented: brockHandoffAlertPresented) {
            Button("OK", role: .cancel) { brockHandoffError = nil }
        } message: {
            Text(brockHandoffError ?? "")
        }
        .referencePresenter(reference: $selectedReference)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Lung Nodule")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                Text("Fleischner 2017 · Lung-RADS v2022 · Brock")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.45))
            }

            Spacer()

            Image(systemName: "lungs")
                .font(.title3)
                .foregroundColor(selectedCalculator.color.opacity(0.85))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    // MARK: - Floating tab bar

    private var tabBar: some View {
        HStack(spacing: 2) {
            ForEach(AppMode.allCases, id: \.self) { targetMode in
                tabButton(for: targetMode)
            }
        }
        .padding(5)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
        .shadow(color: .black.opacity(0.4), radius: 18, x: 0, y: 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
        .frame(maxWidth: 520)
    }

    private func tabButton(for targetMode: AppMode) -> some View {
        let isSelected = startMode == targetMode
        let accent = selectedCalculator.color

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                startMode = targetMode
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: targetMode.tabIcon)
                    .font(.system(size: 17, weight: .semibold))
                Text(targetMode.tabTitle)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(isSelected ? accent : .white.opacity(0.55))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill(accent.opacity(0.16))
                        .matchedGeometryEffect(id: "tab", in: tabAnimation)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(targetMode.accessibilityIdentifier)
        .accessibilityLabel(targetMode.accessibilityLabel)
        .accessibilityHint(targetMode.accessibilityHint)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    // MARK: - Calculator switcher

    private var calculatorSwitcher: some View {
        HStack(spacing: 4) {
            ForEach(CalculatorType.allCases) { type in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                        selectedCalculator = type
                    }
                } label: {
                    Text(type.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selectedCalculator == type ? type.onColor : .white.opacity(0.55))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background {
                            if selectedCalculator == type {
                                Capsule()
                                    .fill(type.color.gradient)
                                    .matchedGeometryEffect(id: "segment", in: segmentAnimation)
                                    .shadow(color: type.color.opacity(0.35), radius: 8, x: 0, y: 3)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(type.accessibilityIdentifier)
                .accessibilityValue(selectedCalculator == type ? "Selected" : "Not selected")
            }
        }
        .padding(4)
        .background(Capsule().fill(Color.white.opacity(0.07)))
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
        .padding(.horizontal, 16)
        .frame(maxWidth: 520)
    }

    // MARK: - Common issues list

    private var commonIssuesList: some View {
        VStack(alignment: .leading, spacing: 18) {
            InfoBanner(
                text: MedicalCopy.decisionSupportDisclaimer,
                tint: selectedCalculator.color
            )

            Text("\(selectedCalculator == .fleischner ? "Fleischner" : "Lung-RADS") Common Issues")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            SettingsSection {
                if selectedCalculator == .fleischner {
                    Group {
                        NavigationLink(destination: FleischnerEligibilityDetailView()) {
                            InfoRow(icon: "checkmark.seal", text: "Eligibility", accentColor: .fleischnerAccent)
                        }
                        NavigationLink(destination: FleischnerMeasuringNodulesDetailView()) {
                            InfoRow(icon: "ruler", text: "Measuring Nodules", accentColor: .fleischnerAccent)
                        }
                        NavigationLink(destination: FleischnerPerifissuralNodulesDetailView()) {
                            InfoRow(icon: "circle.fill", text: "Perifissural Nodules", accentColor: .fleischnerAccent)
                        }
                        NavigationLink(destination: FleischnerNoduleDensityDetailView()) {
                            InfoRow(icon: "circle.bottomhalf.filled", text: "Nodule Density / Types", accentColor: .fleischnerAccent)
                        }
                        NavigationLink(destination: FleischnerCalcificationPatternsDetailView()) {
                            InfoRow(icon: "atom", text: "Nodule Calcification Patterns", accentColor: .fleischnerAccent)
                        }
                        NavigationLink(destination: FleischnerApicalScarringDetailView()) {
                            InfoRow(icon: "arrow.up.right", text: "Apical Scarring", accentColor: .fleischnerAccent)
                        }
                        NavigationLink(destination: FleischnerNeckAbdomenCTsDetailView()) {
                            InfoRow(icon: "person.crop.rectangle", text: "Neck / Abdomen CTs", accentColor: .fleischnerAccent)
                        }
                    }
                } else {
                    Group {
                        NavigationLink(destination: LungRADSEligibilityDetailView()) {
                            InfoRow(icon: "checkmark.seal", text: "Eligibility", accentColor: .lungRADSAccent)
                        }
                        NavigationLink(destination: LungRADSMeasuringNodulesDetailView()) {
                            InfoRow(icon: "ruler", text: "Measuring Nodules", accentColor: .lungRADSAccent)
                        }
                        NavigationLink(destination: LungRADSJuxtapleuralNodulesDetailView()) {
                            InfoRow(icon: "circle.fill", text: "Juxtapleural Nodules", accentColor: .lungRADSAccent)
                        }
                        NavigationLink(destination: LungRADSNoduleDensityDetailView()) {
                            InfoRow(icon: "circle.bottomhalf.filled", text: "Nodule Density / Types", accentColor: .lungRADSAccent)
                        }
                        NavigationLink(destination: LungRADSCalcificationPatternsDetailView()) {
                            InfoRow(icon: "atom", text: "Nodule Calcification Patterns", accentColor: .lungRADSAccent)
                        }
                        NavigationLink(destination: LungRADSSteppedManagementDetailView()) {
                            InfoRow(icon: "slider.horizontal.3", text: "Stepped Management", accentColor: .lungRADSAccent)
                        }
                        NavigationLink(destination: LungRADSIntervalDiagnosticCTDetailView()) {
                            InfoRow(icon: "clock.arrow.circlepath", text: "Interval Diagnostic Chest CT", accentColor: .lungRADSAccent)
                        }
                        NavigationLink(destination: LungRADSInflammatoryFindingsDetailView()) {
                            InfoRow(icon: "allergens", text: "Inflammatory/Infectious Findings", accentColor: .lungRADSAccent)
                        }
                        NavigationLink(destination: LungRADSSModifierDetailView()) {
                            InfoRow(icon: "exclamationmark.circle", text: "S Modifier", accentColor: .lungRADSAccent)
                        }
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .padding(.top, 8)
    }

    // MARK: - References list

    private var referencesList: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("References")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            SettingsSection(title: "Fleischner Society Guidelines") {
                ReferenceLink(text: "Fleischner Society Guidelines Reference", reference: .fleischnerGuideline, onTap: presentReference)
                ReferenceLink(text: "Recommendations for Measuring Pulmonary Nodules at CT: A Statement from the Fleischner Society", reference: .fleischnerGuideline, onTap: presentReference)
            }

            SettingsSection(title: "ACR Lung-RADS v2022") {
                ReferenceLink(text: "ACR Lung-RADS v2022 Reference", reference: .lungRADSGuideline, onTap: presentReference)
                ReferenceLink(text: "ACR Lung-RADS v2022 Summary of Changes and Updates", reference: .lungRADSGuideline, onTap: presentReference)
                ReferenceLink(text: "ACR Lung-RADS v2022: Assessment Categories and Management Recommendations", reference: .lungRADSTable, onTap: presentReference)
                ReferenceLink(text: "ACR Lung Cancer Screening CT Incidental Findings Quick Reference Guide", reference: .lungRADSGuideline, onTap: presentReference)
                ReferenceLink(text: "ACR–STR Practice Parameter for the Performance and Reporting of Lung Cancer Screening Thoracic Computed Tomography (CT)", reference: .lungRADSGuideline, onTap: presentReference)
            }

            Spacer(minLength: 28)
        }
        .padding(.bottom, 32)
    }

    private func presentReference(_ reference: ReferenceType) {
        selectedReference = reference
    }

    private func openBrockPrefilled(from input: LungRADSInput) {
        guard let noduleType = BrockNoduleType.from(lungRADSType: input.noduleType) else {
            brockHandoffError = "Brock malignancy risk is unavailable for \(input.noduleType.rawValue) nodules."
            return
        }

        var nextForm = BrockFormState()

        if let size = input.sizeMm, size > 0 {
            nextForm.noduleSize = formatSize(size)
        }
        nextForm.noduleCount = input.isMultiple ? "2" : "1"
        nextForm.noduleMorphology = noduleType

        brockViewModel.form = nextForm
        startMode = .risk
    }

    private func formatSize(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    private var brockHandoffAlertPresented: Binding<Bool> {
        Binding(
            get: { brockHandoffError != nil },
            set: { isPresented in
                if !isPresented {
                    brockHandoffError = nil
                }
            }
        )
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    var accentColor: Color = .fleischnerAccent

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(accentColor)
                .frame(width: 34, height: 34)
                .background(accentColor.opacity(0.13), in: Circle())
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.92))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.rowFill)
    }
}

struct ReferenceLink: View {
    let text: String
    let reference: ReferenceType
    let onTap: (ReferenceType) -> Void

    var body: some View {
        Button(action: { onTap(reference) }) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.lungRADSAccent)
                    .frame(width: 34, height: 34)
                    .background(Color.lungRADSAccent.opacity(0.13), in: Circle())

                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 6)

                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.35))
                    .padding(.top, 9)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.rowFill)
        }
        .buttonStyle(.plain)
    }
}
