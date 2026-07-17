import SwiftUI
import Foundation

enum AppMode {
    case info // 'i' icon - Common Issues/Reference
    case risk // 'Head' icon - Risk/Patient Info? (Placeholder)
    case calculator // 'Calculator' icon
    case menu // 'Ellipsis' icon - Menu/Settings

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
}

struct ContentView: View {
    @State private var selectedCalculator: CalculatorType = .fleischner
    @State private var startMode: AppMode = .calculator // Default to calculator as per user request for tool
    @StateObject private var brockViewModel = BrockViewModel()
    @State private var brockHandoffError: String?
    @State private var selectedReference: ReferenceType?
    @Namespace private var segmentAnimation

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackdrop()

                VStack(spacing: 0) {
                    // Top Toolbar
                    HStack(spacing: 10) {
                        topBarButton(systemName: "info.circle", mode: .info)
                        topBarButton(systemName: "brain.head.profile", mode: .calculator)
                        topBarButton(systemName: "plusminus.circle", mode: .risk)

                        Spacer()

                        topBarButton(systemName: "ellipsis", mode: .menu)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 14)

                    // Calculator Switcher
                    calculatorSwitcher
                        .padding(.bottom, 16)

                    // Main Content Area
                    ScrollView {
                        // Content matching logic... 
                        if startMode == .calculator {
                            if selectedCalculator == .fleischner {
                                FleischnerView()
                                    .padding(.top)
                            } else {
                                LungRADSView(onBrockRequest: openBrockPrefilled)
                                    .padding(.top)
                            }
                        } else if startMode == .info {
                            // "Common Issues" List
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.white.opacity(0.5))
                                    Text(MedicalCopy.decisionSupportDisclaimer)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.65))
                                        .multilineTextAlignment(.leading)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cardStyle()
                                .padding(.horizontal)

                                Text("\(selectedCalculator == .fleischner ? "Fleischner" : "Lung-RADS") Common Issues")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding()

                                VStack(spacing: 12) {
                                    if selectedCalculator == .fleischner {
                                        // Fleischner Common Issues - 7 items matching reference
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
                                        // Lung-RADS Common Issues - 9 items matching reference
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
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 40)
                        } else if startMode == .menu {
                            // References Screen - matching Button Menu.PNG
                            VStack(alignment: .leading, spacing: 24) {
                                Text("References")
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 40)

                                // Fleischner Society Guidelines Section
                                VStack(alignment: .leading, spacing: 0) {
                                    SectionLabel(title: "FLEISCHNER SOCIETY GUIDELINES")

                                    VStack(spacing: 0) {
                                        ReferenceLink(text: "Fleischner Society Guidelines Reference", reference: .fleischnerGuideline, onTap: presentReference)
                                        Divider().background(Color.subtleDivider)
                                        ReferenceLink(text: "Recommendations for Measuring Pulmonary Nodules at CT: A Statement from the Fleischner Society", reference: .fleischnerGuideline, onTap: presentReference)
                                    }
                                    .cardStyle()
                                    .padding(.horizontal)
                                }

                                // ACR Lung-RADS Section
                                VStack(alignment: .leading, spacing: 0) {
                                    SectionLabel(title: "ACR LUNG-RADS V2022")

                                    VStack(spacing: 0) {
                                        ReferenceLink(text: "ACR Lung-RADS v2022 Reference", reference: .lungRADSGuideline, onTap: presentReference)
                                        Divider().background(Color.subtleDivider)
                                        ReferenceLink(text: "ACR Lung-RADS v2022 Summary of Changes and Updates", reference: .lungRADSGuideline, onTap: presentReference)
                                        Divider().background(Color.subtleDivider)
                                        ReferenceLink(text: "ACR Lung-RADS v2022: Assessment Categories and Management Recommendations", reference: .lungRADSTable, onTap: presentReference)
                                        Divider().background(Color.subtleDivider)
                                        ReferenceLink(text: "ACR Lung Cancer Screening CT Incidental Findings Quick Reference Guide", reference: .lungRADSGuideline, onTap: presentReference)
                                        Divider().background(Color.subtleDivider)
                                        ReferenceLink(text: "ACR–STR Practice Parameter for the Performance and Reporting of Lung Cancer Screening Thoracic Computed Tomography (CT)", reference: .lungRADSGuideline, onTap: presentReference)
                                    }
                                    .cardStyle()
                                    .padding(.horizontal)
                                }

                                Spacer()
                            }
                            .padding(.bottom, 40)
                        } else if startMode == .risk {
                            // Brock Full Model Calculator
                            BrockView(viewModel: brockViewModel)
                                .padding(.top)
                        } else {
                            Text("Other Mode")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
                .frame(maxWidth: 1100)
            }
            // Hide default nav bar since we built a custom top bar
            .toolbar(.hidden, for: .navigationBar)
        }
        .alert("Brock handoff unavailable", isPresented: brockHandoffAlertPresented) {
            Button("OK", role: .cancel) { brockHandoffError = nil }
        } message: {
            Text(brockHandoffError ?? "")
        }
        .referencePresenter(reference: $selectedReference)
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

    private func topBarButton(systemName: String, mode: AppMode) -> some View {
        let isSelected = startMode == mode
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                startMode = mode
            }
        } label: {
            Image(systemName: systemName)
                .font(.headline)
                .foregroundColor(isSelected ? .black : .white.opacity(0.7))
                .frame(width: 38, height: 38)
                .background {
                    Circle()
                        .fill(isSelected ? selectedCalculator.color : Color.white.opacity(0.07))
                }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(mode.accessibilityIdentifier)
        .accessibilityLabel(mode.accessibilityLabel)
        .accessibilityHint(mode.accessibilityHint)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

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
                        .foregroundColor(selectedCalculator == type ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background {
                            if selectedCalculator == type {
                                Capsule()
                                    .fill(type.color)
                                    .matchedGeometryEffect(id: "segment", in: segmentAnimation)
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
        .padding(.horizontal, 16)
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
                .frame(width: 32, height: 32)
                .background(accentColor.opacity(0.14), in: Circle())
            Text(text)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding()
        .cardStyle(cornerRadius: 12)
    }
}

struct ReferenceLink: View {
    let text: String
    let reference: ReferenceType
    let onTap: (ReferenceType) -> Void

    var body: some View {
        Button(action: { onTap(reference) }) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "doc.text")
                    .foregroundColor(.lungRADSAccent)
                    .font(.subheadline)
                    .padding(.top, 2)
                Text(text)
                    .foregroundColor(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
}
