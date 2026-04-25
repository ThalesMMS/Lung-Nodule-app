import SwiftUI
import Foundation

enum AppMode {
    case info // 'i' icon - Common Issues/Reference
    case risk // 'Head' icon - Risk/Patient Info? (Placeholder)
    case calculator // 'Calculator' icon
    case menu // 'Ellipsis' icon - Menu/Settings
}

enum CalculatorType: String, CaseIterable, Identifiable {
    case fleischner = "Fleischner 2017"
    case lungRADS = "Lung-RADS v2022"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .fleischner: return Color.green
        case .lungRADS: return Color.blue
        }
    }
}

struct ContentView: View {
    @State private var selectedCalculator: CalculatorType = .fleischner
    @State private var startMode: AppMode = .calculator // Default to calculator as per user request for tool
    @State private var brockForm = BrockFormState()
    @State private var brockHandoffError: String?
    @State private var selectedReference: ReferenceType?
    
    // Custom Color for Segmented Control Logic
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.darkGray // Fallback
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // Dark background main
                
                VStack(spacing: 0) {
                    // Top Toolbar
                    HStack {
                        Button(action: { startMode = .info }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 22)) // Slightly smaller refined size
                                .foregroundColor(startMode == .info ? .white : .gray)
                        }
                        .padding(.leading, 16)
                        
                        Button(action: { startMode = .calculator }) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 22))
                                .foregroundColor(startMode == .calculator ? .white : .gray)
                        }
                        .padding(.leading, 16)
                        
                        Button(action: { startMode = .risk }) {
                            Image(systemName: "plusminus.circle")
                                .font(.system(size: 22))
                                .foregroundColor(startMode == .risk ? .white : .gray)
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        Button(action: { startMode = .menu }) {
                           Image(systemName: "ellipsis.circle")
                                .font(.system(size: 22))
                                .foregroundColor(startMode == .menu ? .white : .gray)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                    
                    // Custom Segmented Control
                    VStack(spacing: 0) {
                        // Background Container for Buttons
                        ZStack {
                            RoundedRectangle(cornerRadius: 8.91) // Exact corner radius approximation from typical iOS look
                                .fill(Color(UIColor.darkGray)) // Background for the whole control or just buttons? 
                                // Actually, screenshots (Button Calc) often show a segmented control look where the background is continuous.
                                // Let's use a container background.
                            
                            HStack(spacing: 0) {
                                // Fleischner Button - only changes calculator type, does NOT change mode
                                Button(action: { selectedCalculator = .fleischner }) {
                                    Text(CalculatorType.fleischner.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.clear)
                                }
                                
                                // Lung-RADS Button - only changes calculator type, does NOT change mode
                                Button(action: { selectedCalculator = .lungRADS }) {
                                    Text(CalculatorType.lungRADS.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.clear)
                                }
                            }
                        }
                        .frame(height: 36) // Fixed height for control
                        .padding(.horizontal, 16)
                        
                        // Indicators (Below the rounded container)
                        HStack(spacing: 0) {
                            // Fleischner Indicator
                            if selectedCalculator == .fleischner {
                                Rectangle()
                                    .fill(Color(red: 0.2, green: 0.8, blue: 0.2)) // Brighter Green matching screenshot
                                    .frame(height: 2)
                                    .transition(.opacity)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                            
                            // Lung-RADS Indicator
                            if selectedCalculator == .lungRADS {
                                Rectangle()
                                    .fill(Color(red: 0.0, green: 0.478, blue: 1.0)) // System Blue
                                    .frame(height: 2)
                                    .transition(.opacity)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .frame(height: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 0) // Flush with bottom of control? Or slightly overlapping? 
                        // Screenshot IMG_0032 seems to show the line is part of the button "active state" bottom border.
                        // Let's keep it just below for clarity or verify "Button Calc".
                        // Assuming "Button Calc" shows the specific active underline style.
                    }
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
                                Text("This application is a decision support tool for healthcare professionals and does not replace clinical judgment. Management should be based on the original guidelines (ACR/Fleischner).")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(white: 0.15))
                                    .cornerRadius(12)
                                    .padding(.horizontal)

                                Text("\(selectedCalculator == .fleischner ? "Fleischner" : "Lung-RADS") Common Issues")
                                    .font(.title2).bold()
                                    .foregroundColor(.white)
                                    .padding()
                                
                                VStack(spacing: 12) {
                                    if selectedCalculator == .fleischner {
                                        // Fleischner Common Issues - 7 items matching reference
                                        Group {
                                            NavigationLink(destination: FleischnerEligibilityDetailView()) {
                                                InfoRow(icon: "checkmark.seal", text: "Eligibility", accentColor: .green)
                                            }
                                            NavigationLink(destination: FleischnerMeasuringNodulesDetailView()) {
                                                InfoRow(icon: "ruler", text: "Measuring Nodules", accentColor: .green)
                                            }
                                            NavigationLink(destination: FleischnerPerifissuralNodulesDetailView()) {
                                                InfoRow(icon: "circle.fill", text: "Perifissural Nodules", accentColor: .green)
                                            }
                                            NavigationLink(destination: FleischnerNoduleDensityDetailView()) {
                                                InfoRow(icon: "circle.bottomhalf.filled", text: "Nodule Density / Types", accentColor: .green)
                                            }
                                            NavigationLink(destination: FleischnerCalcificationPatternsDetailView()) {
                                                InfoRow(icon: "atom", text: "Nodule Calcification Patterns", accentColor: .green)
                                            }
                                            NavigationLink(destination: FleischnerApicalScarringDetailView()) {
                                                InfoRow(icon: "arrow.up.right", text: "Apical Scarring", accentColor: .green)
                                            }
                                            NavigationLink(destination: FleischnerNeckAbdomenCTsDetailView()) {
                                                InfoRow(icon: "person.crop.rectangle", text: "Neck / Abdomen CTs", accentColor: .green)
                                            }
                                        }
                                    } else {
                                        // Lung-RADS Common Issues - 9 items matching reference
                                        Group {
                                            NavigationLink(destination: LungRADSEligibilityDetailView()) {
                                                InfoRow(icon: "checkmark.seal", text: "Eligibility", accentColor: .blue)
                                            }
                                            NavigationLink(destination: LungRADSMeasuringNodulesDetailView()) {
                                                InfoRow(icon: "ruler", text: "Measuring Nodules", accentColor: .blue)
                                            }
                                            NavigationLink(destination: LungRADSJuxtapleuralNodulesDetailView()) {
                                                InfoRow(icon: "circle.fill", text: "Juxtapleural Nodules", accentColor: .blue)
                                            }
                                            NavigationLink(destination: LungRADSNoduleDensityDetailView()) {
                                                InfoRow(icon: "circle.bottomhalf.filled", text: "Nodule Density / Types", accentColor: .blue)
                                            }
                                            NavigationLink(destination: LungRADSCalcificationPatternsDetailView()) {
                                                InfoRow(icon: "atom", text: "Nodule Calcification Patterns", accentColor: .blue)
                                            }
                                            NavigationLink(destination: LungRADSSteppedManagementDetailView()) {
                                                InfoRow(icon: "slider.horizontal.3", text: "Stepped Management", accentColor: .blue)
                                            }
                                            NavigationLink(destination: LungRADSIntervalDiagnosticCTDetailView()) {
                                                InfoRow(icon: "clock.arrow.circlepath", text: "Interval Diagnostic Chest CT", accentColor: .blue)
                                            }
                                            NavigationLink(destination: LungRADSInflammatoryFindingsDetailView()) {
                                                InfoRow(icon: "allergens", text: "Inflammatory/Infectious Findings", accentColor: .blue)
                                            }
                                            NavigationLink(destination: LungRADSSModifierDetailView()) {
                                                InfoRow(icon: "exclamationmark.circle", text: "S Modifier", accentColor: .blue)
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
                                    .font(.largeTitle).bold()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 40)
                                
                                // Fleischner Society Guidelines Section
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("FLEISCHNER SOCIETY GUIDELINES")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                        .padding(.bottom, 8)
                                    
                                    VStack(spacing: 0) {
                                        ReferenceLink(text: "Fleischner Society Guidelines Reference", reference: .fleischnerGuideline, onTap: presentReference)
                                        Divider().background(Color(white: 0.3))
                                        ReferenceLink(text: "Recommendations for Measuring Pulmonary Nodules at CT: A Statement from the Fleischner Society", reference: .fleischnerGuideline, onTap: presentReference)
                                    }
                                    .background(Color(white: 0.15))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                
                                // ACR Lung-RADS Section
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("ACR LUNG-RADS V2022")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                        .padding(.bottom, 8)
                                    
                                    VStack(spacing: 0) {
                                        ReferenceLink(text: "ACR Lung-RADS v2022 Reference", reference: .lungRADSGuideline, onTap: presentReference)
                                        Divider().background(Color(white: 0.3))
                                        ReferenceLink(text: "ACR Lung-RADS v2022 Summary of Changes and Updates", reference: .lungRADSGuideline, onTap: presentReference)
                                        Divider().background(Color(white: 0.3))
                                        ReferenceLink(text: "ACR Lung-RADS v2022: Assessment Categories and Management Recommendations", reference: .lungRADSTable, onTap: presentReference)
                                        Divider().background(Color(white: 0.3))
                                        ReferenceLink(text: "ACR Lung Cancer Screening CT Incidental Findings Quick Reference Guide", reference: .lungRADSGuideline, onTap: presentReference)
                                        Divider().background(Color(white: 0.3))
                                        ReferenceLink(text: "ACR–STR Practice Parameter for the Performance and Reporting of Lung Cancer Screening Thoracic Computed Tomography (CT)", reference: .lungRADSGuideline, onTap: presentReference)
                                    }
                                    .background(Color(white: 0.15))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                
                                Spacer()
                            }
                            .padding(.bottom, 40)
                        } else if startMode == .risk {
                            // Brock Full Model Calculator
                            BrockView(form: $brockForm)
                                .padding(.top)
                        } else {
                            Text("Other Mode")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
            }
            // Hide default nav bar since we built a custom top bar
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark) // Force dark mode
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

        let defaultMorphologyIndex = BrockNoduleType.allCases.firstIndex(of: .solid) ?? 0
        var nextForm = BrockFormState()

        if let size = input.sizeMm, size > 0 {
            nextForm.noduleSize = formatSize(size)
        }
        nextForm.noduleCount = input.isMultiple ? "2" : "1"
        nextForm.noduleMorphology = BrockNoduleType.allCases.firstIndex(of: noduleType) ?? defaultMorphologyIndex

        brockForm = nextForm
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
    var accentColor: Color = .green
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .frame(width: 30)
            Text(text)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct ReferenceLink: View {
    let text: String
    let reference: ReferenceType
    let onTap: (ReferenceType) -> Void
    
    var body: some View {
        Button(action: { onTap(reference) }) {
            Text(text)
                .foregroundColor(Color(red: 0.0, green: 0.478, blue: 1.0))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}
