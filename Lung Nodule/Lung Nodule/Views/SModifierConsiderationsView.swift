import SwiftUI

struct SModifierConsiderationsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Thyroid
    @State private var thyroidNodule = false
    
    // Lung/Pleura
    @State private var fibroticILD = false
    @State private var bronchiectasis = false
    @State private var emphysema = false
    @State private var newPleuralDisease = false
    
    // Cardiovascular
    @State private var ascendingAorta = false
    @State private var pericardialEffusion = false
    @State private var aorticValveCalcification = false
    @State private var coronaryCalcifications = false
    @State private var pulmonaryArtery = false
    
    // Mediastinum
    @State private var lymphNodes = false
    @State private var mediastinalMass = false
    
    // Esophagus
    @State private var hiatalHernia = false
    @State private var esophagealWallThickening = false
    
    // Musculoskeletal
    @State private var osteopenia = false
    @State private var osteoporosis = false
    
    // Breast
    @State private var breastNodule = false
    
    // Liver
    @State private var liverLesion = false
    @State private var fattyLiver = false
    
    // Adrenal Gland
    @State private var adrenalLesion = false
    
    // Kidney
    @State private var kidneyLesion = false
    
    // Pancreas
    @State private var pancreasCyst = false
    
    // Other
    @State private var otherFindings = false
    
    private let blueAccent = Color(red: 0.0, green: 0.478, blue: 1.0)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // THYROID Section
                    SModifierSection(title: "THYROID", icon: "brain.head.profile") {
                        SModifierToggleItem(
                            title: "Nodule ≥ 15 mm or with suspicious features",
                            recommendation: "Recommend Thyroid Ultrasound and clinical evaluation.",
                            isOn: $thyroidNodule
                        )
                    }
                    
                    // LUNG/PLEURA Section
                    SModifierSection(title: "LUNG/PLEURA", icon: "lungs") {
                        SModifierToggleItem(
                            title: "Fibrotic interstitial lung disease (ILD)",
                            recommendation: "Recommend pulmonary consultation.",
                            isOn: $fibroticILD
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "Bronchiectasis / Ground-glass opacity / Cystic lung disease / Diffuse nodular disease",
                            recommendation: "Recommend PCP evaluation; consider pulmonary consultation.",
                            isOn: $bronchiectasis
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "Emphysema/Bronchial wall thickening (Expected findings)",
                            recommendation: "Consider PCP evaluation; may benefit from pulmonary consultation.",
                            isOn: $emphysema
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "New pleural disease – effusion, thickening, mass",
                            recommendation: "Recommend PCP evaluation; consider pulmonary consultation.",
                            isOn: $newPleuralDisease
                        )
                    }
                    
                    // CARDIOVASCULAR Section
                    SModifierSection(title: "CARDIOVASCULAR", icon: "heart") {
                        SModifierToggleItem(
                            title: "Ascending aorta ≥ 42 mm",
                            recommendation: "Recommend PCP surveillance or cardiology consult for aneurysm surveillance.",
                            isOn: $ascendingAorta
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "Moderate or large pericardial effusion",
                            recommendation: "Discuss findings with PCP.",
                            isOn: $pericardialEffusion
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "Other abnormalities (e.g., moderate or greater aortic valve calcification)",
                            recommendation: "Recommend PCP evaluation.",
                            isOn: $aorticValveCalcification
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "Coronary artery calcifications present",
                            recommendation: "Recommend PCP evaluation for ASCVD risk assessment.",
                            isOn: $coronaryCalcifications
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "Main pulmonary artery measurement ≥ 31 mm",
                            recommendation: "Recommend PCP evaluation; consider cardiology or pulmonary consult.",
                            isOn: $pulmonaryArtery
                        )
                    }
                    
                    // MEDIASTINUM Section
                    SModifierSection(title: "MEDIASTINUM", icon: "rectangle.portrait.on.rectangle.portrait") {
                        SModifierToggleItem(
                            title: "Lymph nodes ≥ 15 mm (short axis measurement) & no explainable cause",
                            recommendation: "Recommend PCP evaluation; consider pulmonary consultation. Consider follow-up contrast-enhanced Chest CT in 3–6 months.",
                            isOn: $lymphNodes
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "Mass (soft tissue or mixed density)",
                            recommendation: "Recommend contrast-enhanced Chest MRI or CT.",
                            isOn: $mediastinalMass
                        )
                    }
                    
                    // ESOPHAGUS Section
                    SModifierSection(title: "ESOPHAGUS", icon: "arrow.down.to.line") {
                        SModifierToggleItem(
                            title: "Large hiatal hernia or dilated esophagus",
                            recommendation: "Recommend PCP evaluation.",
                            isOn: $hiatalHernia
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "Focal wall thickening or mass",
                            recommendation: "Recommend PCP evaluation; consider gastroenterology consult.",
                            isOn: $esophagealWallThickening
                        )
                    }
                    
                    // MUSCULOSKELETAL Section
                    SModifierSection(title: "MUSCULOSKELETAL", icon: "figure.stand") {
                        SModifierToggleItem(
                            title: "100 – 130 HU at L1 (Osteopenia)",
                            recommendation: "Consider PCP evaluation.",
                            isOn: $osteopenia
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "< 100 HU at L1 (Osteoporosis)",
                            recommendation: "Recommend PCP evaluation and consider DEXA scan.",
                            isOn: $osteoporosis
                        )
                    }
                    
                    // BREAST Section
                    SModifierSection(title: "BREAST", icon: "person.bust") {
                        SModifierToggleItem(
                            title: "Any nodule/mass or asymmetric density",
                            recommendation: "Recommend Diagnostic Mammogram +/- Breast Ultrasound.",
                            isOn: $breastNodule
                        )
                    }
                    
                    // LIVER Section
                    SModifierSection(title: "LIVER", icon: "drop") {
                        SModifierComplexItem(
                            title: "Any liver lesion that:",
                            bullets: [
                                "Does NOT clearly appear benign (examples of benign characteristics include uniformly low attenuation ≤20 HU and sharp, well-defined margins)",
                                "Shows concerning or suspicious features, such as:\n  ▸ Heterogeneous (uneven) attenuation\n  ▸ Ill-defined or blurry margins\n  ▸ Mural (wall) thickening or internal nodularity\n  ▸ Thick septa (internal dividing walls)",
                                "Is <1 cm in a patient who is considered high-risk (e.g., cirrhosis, hepatitis, nonalcoholic steatohepatitis, alcoholism, other hepatic risk factors)"
                            ],
                            recommendation: "Recommend MRI (preferred) or CT of the liver without and with IV contrast.",
                            isOn: $liverLesion
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        SModifierToggleItem(
                            title: "Fatty liver/hepatic steatosis or cirrhosis",
                            recommendation: "Recommend PCP evaluation.",
                            isOn: $fattyLiver
                        )
                    }
                    
                    // ADRENAL GLAND Section
                    SModifierSection(title: "ADRENAL GLAND", icon: "triangle") {
                        SModifierComplexItem(
                            title: "Any adrenal lesion that:",
                            bullets: [
                                "Measures ≥1 cm in size and has an attenuation >10 HU",
                                "Does NOT show clearly benign characteristics (examples of benign characteristics include simple cysts, myelolipomas with visible fat, or stable size with no growth over 1 year)",
                                "Demonstrates worrisome changes, such as:\n  ▸ Enlargement over time\n  ▸ Other suspicious visual features"
                            ],
                            recommendation: "Recommend CT or MRI of the adrenal glands without and with IV contrast.",
                            isOn: $adrenalLesion
                        )
                    }
                    
                    // KIDNEY Section
                    SModifierSection(title: "KIDNEY", icon: "leaf") {
                        SModifierComplexItem(
                            title: "Any kidney lesion that:",
                            bullets: [
                                "Does NOT clearly appear benign (examples of benign characteristics include visible fat or uniform low attenuation ≤20 HU)",
                                "Does not have a thin, smooth wall",
                                "Does not show very slow growth (slow growth is defined as ≤0.3 cm per year over at least 5 years)",
                                "Displays suspicious changes, such as:\n  ▸ Shape changes\n  ▸ Attenuation between 21-69 HU\n  ▸ Thick or irregular walls\n  ▸ Nodules inside the lesion\n  ▸ Internal septa\n  ▸ Calcifications"
                            ],
                            recommendation: "Recommend MRI (preferred) or CT of the kidneys without and with IV contrast.",
                            isOn: $kidneyLesion
                        )
                    }
                    
                    // PANCREAS Section
                    SModifierSection(title: "PANCREAS", icon: "waveform.path") {
                        SModifierToggleItem(
                            title: "Cyst/mass",
                            recommendation: "Recommend Contrast-Enhanced Abdomen CT or MRI.",
                            isOn: $pancreasCyst
                        )
                    }
                    
                    // OTHER Section
                    SModifierSection(title: "OTHER", icon: "ellipsis.circle") {
                        SModifierToggleItem(
                            title: "Other imaging finding(s) (not listed above) that require(s) an S modifier",
                            recommendation: nil,
                            isOn: $otherFindings
                        )
                    }
                    
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(Color.black)
            .navigationTitle("Select Incidental Finding(s)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        resetAll()
                    }
                    .foregroundColor(blueAccent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(blueAccent)
                }
            }
        }
    }
    
    private func resetAll() {
        thyroidNodule = false
        fibroticILD = false
        bronchiectasis = false
        emphysema = false
        newPleuralDisease = false
        ascendingAorta = false
        pericardialEffusion = false
        aorticValveCalcification = false
        coronaryCalcifications = false
        pulmonaryArtery = false
        lymphNodes = false
        mediastinalMass = false
        hiatalHernia = false
        esophagealWallThickening = false
        osteopenia = false
        osteoporosis = false
        breastNodule = false
        liverLesion = false
        fattyLiver = false
        adrenalLesion = false
        kidneyLesion = false
        pancreasCyst = false
        otherFindings = false
    }
}

// MARK: - Supporting Views

struct SModifierSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content
    
    private let blueAccent = Color(red: 0.0, green: 0.478, blue: 1.0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(blueAccent)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(white: 0.1))
            
            // Section Content
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .background(Color(white: 0.15))
        }
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SModifierToggleItem: View {
    let title: String
    let recommendation: String?
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    if let recommendation = recommendation {
                        Text(recommendation)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        }
        .padding()
    }
}

struct SModifierComplexItem: View {
    let title: String
    let bullets: [String]
    let recommendation: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    ForEach(bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 8) {
                            Text("●")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(bullet)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(recommendation)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        }
        .padding()
    }
}

#Preview {
    SModifierConsiderationsView()
}
