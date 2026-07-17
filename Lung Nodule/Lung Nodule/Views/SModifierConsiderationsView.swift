import SwiftUI

struct SModifierFindings {
    var thyroidNodule = false
    var fibroticILD = false
    var bronchiectasis = false
    var emphysema = false
    var newPleuralDisease = false
    var ascendingAorta = false
    var pericardialEffusion = false
    var aorticValveCalcification = false
    var coronaryCalcifications = false
    var pulmonaryArtery = false
    var lymphNodes = false
    var mediastinalMass = false
    var hiatalHernia = false
    var esophagealWallThickening = false
    var osteopenia = false
    var osteoporosis = false
    var breastNodule = false
    var liverLesion = false
    var fattyLiver = false
    var adrenalLesion = false
    var kidneyLesion = false
    var pancreasCyst = false
    var otherFindings = false

    var hasAny: Bool {
        thyroidNodule || fibroticILD || bronchiectasis || emphysema || newPleuralDisease ||
        ascendingAorta || pericardialEffusion || aorticValveCalcification ||
        coronaryCalcifications || pulmonaryArtery || lymphNodes || mediastinalMass ||
        hiatalHernia || esophagealWallThickening || osteopenia || osteoporosis ||
        breastNodule || liverLesion || fattyLiver || adrenalLesion || kidneyLesion ||
        pancreasCyst || otherFindings
    }

    mutating func reset() {
        self = SModifierFindings()
    }
}
struct SModifierConsiderationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hasSModifierFindings: Bool
    
    @State private var findings = SModifierFindings()
    
    private let blueAccent = Color.lungRADSAccent
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // THYROID Section
                    SModifierSection(title: "THYROID", icon: "brain.head.profile") {
                        SModifierToggleItem(
                            title: "Nodule ≥ 15 mm or with suspicious features",
                            recommendation: "Recommend Thyroid Ultrasound and clinical evaluation.",
                            isOn: $findings.thyroidNodule
                        )
                    }
                    
                    // LUNG/PLEURA Section
                    SModifierSection(title: "LUNG/PLEURA", icon: "lungs") {
                        SModifierToggleItem(
                            title: "Fibrotic interstitial lung disease (ILD)",
                            recommendation: "Recommend pulmonary consultation.",
                            isOn: $findings.fibroticILD
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "Bronchiectasis / Ground-glass opacity / Cystic lung disease / Diffuse nodular disease",
                            recommendation: "Recommend PCP evaluation; consider pulmonary consultation.",
                            isOn: $findings.bronchiectasis
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "Emphysema/Bronchial wall thickening (Expected findings)",
                            recommendation: "Consider PCP evaluation; may benefit from pulmonary consultation.",
                            isOn: $findings.emphysema
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "New pleural disease – effusion, thickening, mass",
                            recommendation: "Recommend PCP evaluation; consider pulmonary consultation.",
                            isOn: $findings.newPleuralDisease
                        )
                    }
                    
                    // CARDIOVASCULAR Section
                    SModifierSection(title: "CARDIOVASCULAR", icon: "heart") {
                        SModifierToggleItem(
                            title: "Ascending aorta ≥ 42 mm",
                            recommendation: "Recommend PCP surveillance or cardiology consult for aneurysm surveillance.",
                            isOn: $findings.ascendingAorta
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "Moderate or large pericardial effusion",
                            recommendation: "Discuss findings with PCP.",
                            isOn: $findings.pericardialEffusion
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "Other abnormalities (e.g., moderate or greater aortic valve calcification)",
                            recommendation: "Recommend PCP evaluation.",
                            isOn: $findings.aorticValveCalcification
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "Coronary artery calcifications present",
                            recommendation: "Recommend PCP evaluation for ASCVD risk assessment.",
                            isOn: $findings.coronaryCalcifications
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "Main pulmonary artery measurement ≥ 31 mm",
                            recommendation: "Recommend PCP evaluation; consider cardiology or pulmonary consult.",
                            isOn: $findings.pulmonaryArtery
                        )
                    }
                    
                    // MEDIASTINUM Section
                    SModifierSection(title: "MEDIASTINUM", icon: "rectangle.portrait.on.rectangle.portrait") {
                        SModifierToggleItem(
                            title: "Lymph nodes ≥ 15 mm (short axis measurement) & no explainable cause",
                            recommendation: "Recommend PCP evaluation; consider pulmonary consultation. Consider follow-up contrast-enhanced Chest CT in 3–6 months.",
                            isOn: $findings.lymphNodes
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "Mass (soft tissue or mixed density)",
                            recommendation: "Recommend contrast-enhanced Chest MRI or CT.",
                            isOn: $findings.mediastinalMass
                        )
                    }
                    
                    // ESOPHAGUS Section
                    SModifierSection(title: "ESOPHAGUS", icon: "arrow.down.to.line") {
                        SModifierToggleItem(
                            title: "Large hiatal hernia or dilated esophagus",
                            recommendation: "Recommend PCP evaluation.",
                            isOn: $findings.hiatalHernia
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "Focal wall thickening or mass",
                            recommendation: "Recommend PCP evaluation; consider gastroenterology consult.",
                            isOn: $findings.esophagealWallThickening
                        )
                    }
                    
                    // MUSCULOSKELETAL Section
                    SModifierSection(title: "MUSCULOSKELETAL", icon: "figure.stand") {
                        SModifierToggleItem(
                            title: "100 – 130 HU at L1 (Osteopenia)",
                            recommendation: "Consider PCP evaluation.",
                            isOn: $findings.osteopenia
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "< 100 HU at L1 (Osteoporosis)",
                            recommendation: "Recommend PCP evaluation and consider DEXA scan.",
                            isOn: $findings.osteoporosis
                        )
                    }
                    
                    // BREAST Section
                    SModifierSection(title: "BREAST", icon: "person.bust") {
                        SModifierToggleItem(
                            title: "Any nodule/mass or asymmetric density",
                            recommendation: "Recommend Diagnostic Mammogram +/- Breast Ultrasound.",
                            isOn: $findings.breastNodule
                        )
                    }
                    
                    // LIVER Section
                    SModifierSection(title: "LIVER", icon: "drop") {
                        SModifierToggleItem(
                            title: "Any liver lesion that:",
                            bullets: [
                                "Does NOT clearly appear benign (examples of benign characteristics include uniformly low attenuation ≤20 HU and sharp, well-defined margins)",
                                "Shows concerning or suspicious features, such as:\n  ▸ Heterogeneous (uneven) attenuation\n  ▸ Ill-defined or blurry margins\n  ▸ Mural (wall) thickening or internal nodularity\n  ▸ Thick septa (internal dividing walls)",
                                "Is <1 cm in a patient who is considered high-risk (e.g., cirrhosis, hepatitis, nonalcoholic steatohepatitis, alcoholism, other hepatic risk factors)"
                            ],
                            recommendation: "Recommend MRI (preferred) or CT of the liver without and with IV contrast.",
                            isOn: $findings.liverLesion
                        )
                        
                        Divider().background(Color.subtleDivider)
                        
                        SModifierToggleItem(
                            title: "Fatty liver/hepatic steatosis or cirrhosis",
                            recommendation: "Recommend PCP evaluation.",
                            isOn: $findings.fattyLiver
                        )
                    }
                    
                    // ADRENAL GLAND Section
                    SModifierSection(title: "ADRENAL GLAND", icon: "triangle") {
                        SModifierToggleItem(
                            title: "Any adrenal lesion that:",
                            bullets: [
                                "Measures ≥1 cm in size and has an attenuation >10 HU",
                                "Does NOT show clearly benign characteristics (examples of benign characteristics include simple cysts, myelolipomas with visible fat, or stable size with no growth over 1 year)",
                                "Demonstrates worrisome changes, such as:\n  ▸ Enlargement over time\n  ▸ Other suspicious visual features"
                            ],
                            recommendation: "Recommend CT or MRI of the adrenal glands without and with IV contrast.",
                            isOn: $findings.adrenalLesion
                        )
                    }
                    
                    // KIDNEY Section
                    SModifierSection(title: "KIDNEY", icon: "leaf") {
                        SModifierToggleItem(
                            title: "Any kidney lesion that:",
                            bullets: [
                                "Does NOT clearly appear benign (examples of benign characteristics include visible fat or uniform low attenuation ≤20 HU)",
                                "Does not have a thin, smooth wall",
                                "Does not show very slow growth (slow growth is defined as ≤0.3 cm per year over at least 5 years)",
                                "Displays suspicious changes, such as:\n  ▸ Shape changes\n  ▸ Attenuation between 21-69 HU\n  ▸ Thick or irregular walls\n  ▸ Nodules inside the lesion\n  ▸ Internal septa\n  ▸ Calcifications"
                            ],
                            recommendation: "Recommend MRI (preferred) or CT of the kidneys without and with IV contrast.",
                            isOn: $findings.kidneyLesion
                        )
                    }
                    
                    // PANCREAS Section
                    SModifierSection(title: "PANCREAS", icon: "waveform.path") {
                        SModifierToggleItem(
                            title: "Cyst/mass",
                            recommendation: "Recommend Contrast-Enhanced Abdomen CT or MRI.",
                            isOn: $findings.pancreasCyst
                        )
                    }
                    
                    // OTHER Section
                    SModifierSection(title: "OTHER", icon: "ellipsis.circle") {
                        SModifierToggleItem(
                            title: "Other imaging finding(s) (not listed above) that require(s) an S modifier",
                            recommendation: nil,
                            isOn: $findings.otherFindings
                        )
                    }
                    
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(AppBackdrop())
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
                        updateHasSModifierFindings()
                        dismiss()
                    }
                    .foregroundColor(blueAccent)
                }
            }
        }
        .tint(blueAccent)
        .onDisappear {
            updateHasSModifierFindings()
        }
    }
    
    private func resetAll() {
        findings.reset()
        updateHasSModifierFindings()
    }

    private var hasAnyFindings: Bool {
        findings.hasAny
    }

    private func updateHasSModifierFindings() {
        hasSModifierFindings = hasAnyFindings
    }
}
