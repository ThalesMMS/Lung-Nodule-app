import SwiftUI

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
                                LungRADSView()
                                    .padding(.top)
                            }
                        } else if startMode == .info {
                            // "Common Issues" List
                            VStack(alignment: .leading, spacing: 10) {
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
                                        ReferenceLink(text: "Fleischner Society Guidelines Reference")
                                        Divider().background(Color(white: 0.3))
                                        ReferenceLink(text: "Recommendations for Measuring Pulmonary Nodules at CT: A Statement from the Fleischner Society")
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
                                        ReferenceLink(text: "ACR Lung-RADS v2022 Reference")
                                        Divider().background(Color(white: 0.3))
                                        ReferenceLink(text: "ACR Lung-RADS v2022 Summary of Changes and Updates")
                                        Divider().background(Color(white: 0.3))
                                        ReferenceLink(text: "ACR Lung-RADS v2022: Assessment Categories and Management Recommendations")
                                        Divider().background(Color(white: 0.3))
                                        ReferenceLink(text: "ACR Lung Cancer Screening CT Incidental Findings Quick Reference Guide")
                                        Divider().background(Color(white: 0.3))
                                        ReferenceLink(text: "ACR–STR Practice Parameter for the Performance and Reporting of Lung Cancer Screening Thoracic Computed Tomography (CT)")
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
                            BrockModelView()
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
    
    var body: some View {
        Button(action: {}) {
            Text(text)
                .foregroundColor(Color(red: 0.0, green: 0.478, blue: 1.0))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}

// Brock Full Model View matching reference Brock Full Model 1.PNG / 2.PNG
struct BrockModelView: View {
    @State private var age: String = ""
    @State private var gender: Int = 0 // 0 = Male, 1 = Female
    @State private var noduleSize: String = ""
    @State private var noduleMorphology: Int = 0 // 0 = Non-solid, 1 = Part-solid, 2 = Solid
    @State private var upperLobe: Bool = false
    @State private var noduleCount: String = ""
    @State private var spiculation: Bool = false
    @State private var familyHistory: Bool = false
    @State private var emphysema: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Description card
            Text("The Brock full model estimates a CT-detected nodule's 2–4 year malignancy risk.")
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(white: 0.15))
                .cornerRadius(12)
                .padding(.horizontal, 16)
            
            // PATIENT Section
            VStack(alignment: .leading, spacing: 0) {
                Text("PATIENT")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    // Age
                    HStack {
                        Text("Age (≥ 18 yrs)")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("", text: $age)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                            .frame(width: 60)
                        Text("yrs")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    Divider().background(Color(white: 0.3))
                    
                    // Gender
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gender")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Picker("Gender", selection: $gender) {
                            Text("Male").tag(0)
                            Text("Female").tag(1)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                }
                .background(Color(white: 0.15))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // NODULE Section
            VStack(alignment: .leading, spacing: 0) {
                Text("NODULE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    // Size
                    HStack {
                        Text("Size (3–30 mm)")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("", text: $noduleSize)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                            .frame(width: 60)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    Divider().background(Color(white: 0.3))
                    
                    // Nodule morphology
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nodule morphology")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Picker("Morphology", selection: $noduleMorphology) {
                            Text("Non-solid (GG)").tag(0)
                            Text("Part-solid").tag(1)
                            Text("Solid").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    
                    Divider().background(Color(white: 0.3))
                    
                    // Upper lobe
                    HStack {
                        Text("Upper lobe")
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $upperLobe)
                            .labelsHidden()
                    }
                    .padding()
                    
                    Divider().background(Color(white: 0.3))
                    
                    // Nodule count
                    HStack {
                        Text("Nodule count (≥ 1), no decimal")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("#", text: $noduleCount)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                            .frame(width: 40)
                    }
                    .padding()
                    
                    Divider().background(Color(white: 0.3))
                    
                    // Spiculation
                    HStack {
                        Text("Spiculation")
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $spiculation)
                            .labelsHidden()
                    }
                    .padding()
                }
                .background(Color(white: 0.15))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // OTHER RISK FACTORS Section
            VStack(alignment: .leading, spacing: 0) {
                Text("OTHER RISK FACTORS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Family history of lung cancer")
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $familyHistory)
                            .labelsHidden()
                    }
                    .padding()
                    
                    Divider().background(Color(white: 0.3))
                    
                    HStack {
                        Text("Emphysema")
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $emphysema)
                            .labelsHidden()
                    }
                    .padding()
                }
                .background(Color(white: 0.15))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // RESULT Section
            VStack(alignment: .leading, spacing: 0) {
                Text("RESULT")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    Text("Enter all required fields.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color(white: 0.15))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // Reference link
            Button(action: {}) {
                Text("Reference")
                    .foregroundColor(Color(red: 0.0, green: 0.478, blue: 1.0))
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
}
