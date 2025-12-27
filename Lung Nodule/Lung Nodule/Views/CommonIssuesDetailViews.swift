import SwiftUI

// MARK: - Fleischner Common Issues Detail Views

struct FleischnerEligibilityDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 2017 Fleischner Society Guidelines Section
                DetailSection(title: "2017 FLEISCHNER SOCIETY GUIDELINES") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Purpose",
                            description: "Management of incidentally detected pulmonary nodules on CT in routine clinical practice."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Age Requirement",
                            description: "Applicable to patients 35 years of age and older."
                        )
                    }
                }
                
                // Exclusions Section
                DetailSection(title: "EXCLUSIONS") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Known or Suspected Cancer",
                            description: "These guidelines do not apply to patients with a diagnosed or highly suspected malignancy."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Immunocompromised Patients",
                            description: "These guidelines do not apply to patients with weakened immune systems."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Lung Cancer Screening",
                            description: "These guidelines do not apply to patients in a dedicated lung cancer screening program."
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Eligibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FleischnerMeasuringNodulesDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // General Section
                DetailSection(title: "GENERAL") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Nearest Whole Millimeter",
                            description: "Both measurements and averages should be expressed to the nearest whole millimeter."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "≥2 mm Threshold for Change in Size",
                            description: "A size change can be reported when average diameter has increased or decreased by at least 2 mm (rounded to the nearest millimeter)."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Orthogonal ≤1.5 mm Sections",
                            description: "Use ≤1.5 mm sections in axial orientation, unless maximal dimension is in coronal or sagittal plane. Avoid off-axis oblique reformations."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Lung Windows and Sharp Filters",
                            description: "Measure on lung windows using a sharp filter."
                        )
                    }
                }
                
                // Solid and Non-Solid Section
                DetailSection(title: "SOLID NODULES AND NON-SOLID (GROUND-GLASS) NODULES") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Do Not Measure Micronodules",
                            description: "<3 mm nodules should not be measured. \"Micronodule\" descriptor preferred."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "3-9 mm: Report Average Diameter",
                            description: "Express dimensions as average of maximal long-axis and perpendicular maximal short-axis in same plane."
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Measuring Nodules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FleischnerPerifissuralNodulesDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: "PERIFISSURAL NODULES") {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Characteristic Features of Intrapulmonary Lymph Nodes")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("• Triangular")
                                .foregroundColor(.gray)
                            Text("• Flat")
                                .foregroundColor(.gray)
                            Text("• Lentiform")
                                .foregroundColor(.gray)
                            Text("• Fine linear septal extension to pleura")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        
                        Divider().background(Color(white: 0.3))
                        
                        DetailItem(
                            title: "No Followup for Most Characteristic Intrapulmonary Lymph Nodes",
                            description: "Small nodules with location and shape in keeping with intrapulmonary lymph node (even if >6 mm) require no followup."
                        )
                        
                        Divider().background(Color(white: 0.3))
                        
                        DetailItem(
                            title: "6–12 Month Followup if Cancer History or Suspicious Appearance",
                            description: "A 6–12 month followup CT should be considered in patients with a cancer history, or perifissural nodule with spiculated margin or displacement of adjacent fissure."
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Perifissural Nodules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FleischnerNoduleDensityDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Solid Section
                DetailSection(title: "SOLID") {
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(white: 0.3))
                            .frame(width: 100, height: 80)
                            .overlay(Text("CT Image").foregroundColor(.gray).font(.caption))
                        Text("Solid")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                }
                
                // Part-Solid Section
                DetailSection(title: "PART-SOLID") {
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(white: 0.3))
                            .frame(width: 100, height: 80)
                            .overlay(Text("CT Image").foregroundColor(.gray).font(.caption))
                        Text("Part-Solid")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                }
                
                // Non-Solid Section
                DetailSection(title: "NON-SOLID (GROUND-GLASS)") {
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(white: 0.3))
                            .frame(width: 100, height: 80)
                            .overlay(Text("CT Image").foregroundColor(.gray).font(.caption))
                        Text("Non-Solid (Ground-glass)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Nodule Density")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FleischnerCalcificationPatternsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Benign Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("BENIGN")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.2))
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            CalcificationPatternItem(title: "DIFFUSE")
                            CalcificationPatternItem(title: "CENTRAL")
                        }
                        HStack(spacing: 24) {
                            CalcificationPatternItem(title: "CONCENTRIC")
                            CalcificationPatternItem(title: "POPCORN")
                        }
                    }
                    .padding()
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Indeterminate Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("INDETERMINATE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.6, green: 0.5, blue: 0.2))
                        .padding(.horizontal)
                    
                    HStack(spacing: 24) {
                        CalcificationPatternItem(title: "ECCENTRIC")
                        CalcificationPatternItem(title: "STIPPLED")
                    }
                    .padding()
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Calcification Patterns")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CalcificationPatternItem: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.25))
                .frame(width: 80, height: 60)
                .overlay(Text("Image").foregroundColor(.gray).font(.caption2))
        }
        .frame(maxWidth: .infinity)
    }
}

struct FleischnerApicalScarringDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: "APICAL SCARRING") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Coronal & Sagittal Images May Help",
                            description: "Review of coronal and sagittal reconstructions can often help increase confidence."
                        )
                        Divider().background(Color(white: 0.3))
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Features Suggestive of Scar")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("• Pleural-based configuration")
                                .foregroundColor(.gray)
                            Text("• Elongated shape")
                                .foregroundColor(.gray)
                            Text("• Straight or concave margins")
                                .foregroundColor(.gray)
                            Text("• Presence of similar adjacent opacities")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Apical Scarring")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FleischnerNeckAbdomenCTsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: "INCIDENTALLY DETECTED LUNG NODULES ON NECK OR ABDOMINAL CT") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "1–5 mm",
                            description: "No further investigation recommended."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "6–8 mm",
                            description: "If stability cannot be confirmed by retrospective review of an older study, obtain followup chest CT at interval appropriate for nodule of this size."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: ">8 mm",
                            description: "Obtain complete chest CT."
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Neck/Abdomen CTs")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Lung-RADS Common Issues Detail Views

struct LungRADSEligibilityDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Age Criteria
                DetailSection(title: "AGE CRITERIA") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "50–80 years",
                            description: "USPSTF (2021), ACS (2023)"
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "50–77 years",
                            description: "CMS (2022)"
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "≥ 50 years (no upper age limit)",
                            description: "NCCN v1.2025"
                        )
                    }
                }
                
                // Smoking History Criteria
                DetailSection(title: "SMOKING HISTORY CRITERIA") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "≥ 20 pack-years",
                            description: "USPSTF (2021), CMS (2022), ACS (2023), NCCN v1.2025"
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "≥ 20 years of smoking",
                            description: "NCCN v1.2025 – captures additional high-risk individuals"
                        )
                    }
                }
                
                // Smoking Quit-Time Criteria
                DetailSection(title: "SMOKING QUIT-TIME CRITERIA") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Current smoker or quit ≤ 15 years",
                            description: "USPSTF (2021), CMS (2022)"
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "None (quit time does not matter)",
                            description: "ACS (2023), NCCN v1.2025"
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Screening Eligibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSMeasuringNodulesDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: "MEASURING NODULES") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Mean Diameter",
                            description: "Average of long and short axis measurements on the same axial image."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Measure to 0.1 mm",
                            description: "Report measurements to one decimal place for precision."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Use Lung Windows",
                            description: "Measure nodules using lung window settings."
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Measuring Nodules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSJuxtapleuralNodulesDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: "JUXTAPLEURAL NODULES") {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Definition")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Juxtapleural nodules are nodules adjacent to the pleura.")
                                .foregroundColor(.gray)
                            Text("")
                                .font(.caption)
                            Text("Typical locations include:")
                                .foregroundColor(.gray)
                            Text("• Perifissural: along the lung fissures")
                                .foregroundColor(.gray)
                            Text("• Costal pleural: adjacent to the ribs")
                                .foregroundColor(.gray)
                            Text("• Perimediastinal: abutting the mediastinal pleura")
                                .foregroundColor(.gray)
                            Text("• Peridiaphragmatic: near the diaphragmatic pleura")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        
                        Divider().background(Color(white: 0.3))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Features & Classification")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Classified as Lung-RADS 2 if all of the below criteria are met:")
                                .foregroundColor(.gray)
                            Text("• Mean diameter ≤ 10 mm")
                                .foregroundColor(.gray)
                            Text("• Solid")
                                .foregroundColor(.gray)
                            Text("• Smooth margins")
                                .foregroundColor(.gray)
                            Text("• Triangular, lentiform, or oval shape")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Juxtapleural Nodules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSNoduleDensityDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: "NODULE TYPES") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Solid",
                            description: "Completely obscures the lung parenchyma."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Part-Solid",
                            description: "Contains both solid and ground-glass components."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Non-Solid (Ground-Glass)",
                            description: "Hazy increased attenuation that does not obscure underlying structures."
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Nodule Density / Types")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSCalcificationPatternsDetailView: View {
    var body: some View {
        FleischnerCalcificationPatternsDetailView()
    }
}

struct LungRADSSteppedManagementDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: "STEPPED MANAGEMENT") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "All Categories → Follow-up Timing",
                            description: "Follow-up timing dictated by the Lung-RADS category is from the date of the exam being interpreted."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Lung-RADS 3 → Stable/Decreased on 6-Month Follow-up CT",
                            description: "Reclassify to Lung-RADS 2; schedule LDCT 12 months from this exam."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Lung-RADS 4A → Stable/Decreased on 3-Month Follow-up CT",
                            description: "Reclassify to Lung-RADS 3; schedule LDCT 6 months from this exam.\n\nIf still stable/decreased at that 6 month scan, reclassify to Lung-RADS 2; schedule LDCT 12 months from the 6 month follow-up."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Lung-RADS 3 or 4A → Resolved on Follow-up CT",
                            description: "No stepped management; reclassify based on most worrisome nodule and follow-up from this exam."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Lung-RADS 4B → Benign After Workup or Resolved on Follow-up CT",
                            description: "No stepped management; reclassify based on most worrisome nodule and follow-up from this exam."
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Stepped Management")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSIntervalDiagnosticCTDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: "INTERVAL DIAGNOSTIC CHEST CT") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "When to Consider",
                            description: "Consider interval diagnostic chest CT when additional imaging or clinical evaluation is needed before the next scheduled LDCT."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Purpose",
                            description: "Helps clarify uncertain findings, evaluate symptoms, or follow up on specific concerns between regular screening intervals."
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Interval Diagnostic Chest CT")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSInflammatoryFindingsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: "INFLAMMATORY/INFECTIOUS FINDINGS") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Recognition",
                            description: "Findings suggestive of an inflammatory or infectious process should be recognized and documented."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Short-Interval Follow-up",
                            description: "Short-interval follow-up may be appropriate to document resolution."
                        )
                        Divider().background(Color(white: 0.3))
                        DetailItem(
                            title: "Category Assignment",
                            description: "Category should be assigned based on the appearance at the time of interpretation."
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Inflammatory/Infectious Findings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSSModifierDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: "S MODIFIER") {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "When S Modifier Not Required",
                            description: "An S modifier is unnecessary for significant or potentially significant findings that are already known, treated, or in the process of clinical evaluation."
                        )
                    }
                }
                
                ReferenceButton()
            }
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("S Modifier")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable Components

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            content()
                .background(Color(white: 0.15))
                .cornerRadius(12)
                .padding(.horizontal)
        }
    }
}

struct DetailItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct ReferenceButton: View {
    var body: some View {
        Button(action: {}) {
            Text("Reference")
                .foregroundColor(Color(red: 0.0, green: 0.478, blue: 1.0))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
}

// MARK: - Previews

#Preview("Fleischner Eligibility") {
    NavigationStack {
        FleischnerEligibilityDetailView()
    }
}

#Preview("Lung-RADS Eligibility") {
    NavigationStack {
        LungRADSEligibilityDetailView()
    }
}
