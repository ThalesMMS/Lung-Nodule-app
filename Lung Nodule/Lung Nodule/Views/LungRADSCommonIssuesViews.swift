import SwiftUI

// MARK: - Lung-RADS Common Issues Detail Views

struct LungRADSEligibilityDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Age Criteria
                DetailSection(title: MedicalCopy.Section.ageCriteria) {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "50–80 years",
                            description: "USPSTF (2021), ACS (2023)"
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "50–77 years",
                            description: "CMS (2022)"
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "≥ 50 years (no upper age limit)",
                            description: "NCCN v1.2025"
                        )
                    }
                }

                // Smoking History Criteria
                DetailSection(title: MedicalCopy.Section.smokingHistoryCriteria) {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "≥ 20 pack-years",
                            description: "USPSTF (2021), CMS (2022), ACS (2023), NCCN v1.2025"
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "≥ 20 years of smoking",
                            description: "NCCN v1.2025 – captures additional high-risk individuals"
                        )
                    }
                }

                // Smoking Quit-Time Criteria
                DetailSection(title: MedicalCopy.Section.smokingQuitTimeCriteria) {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Current smoker or quit ≤ 15 years",
                            description: "USPSTF (2021), CMS (2022)"
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "None (quit time does not matter)",
                            description: "ACS (2023), NCCN v1.2025"
                        )
                    }
                }

                ReferenceButton(reference: .lungRADSGuideline)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
        .navigationTitle("Screening Eligibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSMeasuringNodulesDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: MedicalCopy.Section.measuringNodules) {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Mean Diameter",
                            description: MedicalCopy.lungRADSMeanDiameter
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Measure to 0.1 mm",
                            description: "Report measurements to one decimal place for precision."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Use Lung Windows",
                            description: "Measure nodules using lung window settings."
                        )
                    }
                }

                ReferenceButton(reference: .lungRADSGuideline)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
        .navigationTitle("Measuring Nodules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSJuxtapleuralNodulesDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: MedicalCopy.Section.juxtapleuralNodules) {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Definition")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Juxtapleural nodules are nodules adjacent to the pleura.")
                                .foregroundColor(.gray)
                                .padding(.bottom, 8)
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

                        Divider().background(Color.subtleDivider)

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

                ReferenceButton(reference: .lungRADSGuideline)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
        .navigationTitle("Juxtapleural Nodules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSNoduleDensityDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: MedicalCopy.Section.noduleTypes) {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Solid",
                            description: "Completely obscures the lung parenchyma."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Part-Solid",
                            description: "Contains both solid and ground-glass components."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Non-Solid (Ground-Glass)",
                            description: "Hazy increased attenuation that does not obscure underlying structures."
                        )
                    }
                }

                ReferenceButton(reference: .lungRADSGuideline)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
        .navigationTitle("Nodule Density / Types")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LungRADSCalcificationPatternsDetailView: View {
    var body: some View {
        FleischnerCalcificationPatternsDetailView(
            reference: .lungRADSGuideline,
            accentColor: .lungRADSAccent
        )
    }
}

struct LungRADSSteppedManagementDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: MedicalCopy.Section.steppedManagement) {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "All Categories → Follow-up Timing",
                            description: "Follow-up timing dictated by the Lung-RADS category is from the date of the exam being interpreted."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Lung-RADS 3 → Stable/Decreased on 6-Month Follow-up CT",
                            description: "Reclassify to Lung-RADS 2; schedule LDCT 12 months from this exam."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Lung-RADS 4A → Stable/Decreased on 3-Month Follow-up CT",
                            description: "Reclassify to Lung-RADS 3; schedule LDCT 6 months from this exam.\n\nIf still stable/decreased at that 6 month scan, reclassify to Lung-RADS 2; schedule LDCT 12 months from the 6 month follow-up."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Lung-RADS 3 or 4A → Resolved on Follow-up CT",
                            description: "No stepped management; reclassify based on most worrisome nodule and follow-up from this exam."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Lung-RADS 4B → Benign After Workup or Resolved on Follow-up CT",
                            description: "No stepped management; reclassify based on most worrisome nodule and follow-up from this exam."
                        )
                    }
                }

                ReferenceButton(reference: .lungRADSGuideline)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
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
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Purpose",
                            description: "Helps clarify uncertain findings, evaluate symptoms, or follow up on specific concerns between regular screening intervals."
                        )
                    }
                }

                ReferenceButton(reference: .lungRADSGuideline)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
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
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Short-Interval Follow-up",
                            description: "Short-interval follow-up may be appropriate to document resolution."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Category Assignment",
                            description: "Category should be assigned based on the appearance at the time of interpretation."
                        )
                    }
                }

                ReferenceButton(reference: .lungRADSGuideline)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
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

                ReferenceButton(reference: .lungRADSGuideline)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
        .navigationTitle("S Modifier")
        .navigationBarTitleDisplayMode(.inline)
    }
}
