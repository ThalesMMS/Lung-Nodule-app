import SwiftUI

// MARK: - Fleischner Common Issues Detail Views

struct FleischnerEligibilityDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 2017 Fleischner Society Guidelines Section
                DetailSection(title: MedicalCopy.Section.fleischnerGuidelines) {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Purpose",
                            description: MedicalCopy.fleischnerPurpose
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Age Requirement",
                            description: "Applicable to patients 35 years of age and older."
                        )
                    }
                }

                // Exclusions Section
                DetailSection(title: MedicalCopy.Section.exclusions) {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Known or Suspected Cancer",
                            description: "These guidelines do not apply to patients with a diagnosed or highly suspected malignancy."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Immunocompromised Patients",
                            description: "These guidelines do not apply to patients with weakened immune systems."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Lung Cancer Screening",
                            description: "These guidelines do not apply to patients in a dedicated lung cancer screening program."
                        )
                    }
                }

                ReferenceButton(reference: .fleischnerGuideline, accentColor: .fleischnerAccent)
            }
            .padding(.top, 16)
        }
        .accessibilityIdentifier("fleischner.eligibility.detail")
        .background(AppBackdrop())
        .navigationTitle("Eligibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FleischnerMeasuringNodulesDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // General Section
                DetailSection(title: MedicalCopy.Section.general) {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Nearest Whole Millimeter",
                            description: "Both measurements and averages should be expressed to the nearest whole millimeter."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "≥2 mm Threshold for Change in Size",
                            description: "A size change can be reported when average diameter has increased or decreased by at least 2 mm (rounded to the nearest millimeter)."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Orthogonal ≤1.5 mm Sections",
                            description: "Use ≤1.5 mm sections in axial orientation, unless maximal dimension is in coronal or sagittal plane. Avoid off-axis oblique reformations."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "Lung Windows and Sharp Filters",
                            description: "Measure on lung windows using a sharp filter."
                        )
                    }
                }

                // Solid and Non-Solid Section
                DetailSection(title: MedicalCopy.Section.solidAndNonSolidNodules) {
                    VStack(alignment: .leading, spacing: 0) {
                        DetailItem(
                            title: "Do Not Measure Micronodules",
                            description: "<3 mm nodules should not be measured. \"Micronodule\" descriptor preferred."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "3-9 mm: Report Average Diameter",
                            description: "Express dimensions as average of maximal long-axis and perpendicular maximal short-axis in same plane."
                        )
                    }
                }

                ReferenceButton(reference: .fleischnerGuideline, accentColor: .fleischnerAccent)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
        .navigationTitle("Measuring Nodules")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FleischnerPerifissuralNodulesDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DetailSection(title: MedicalCopy.Section.perifissuralNodules) {
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

                        Divider().background(Color.subtleDivider)

                        DetailItem(
                            title: "No Followup for Most Characteristic Intrapulmonary Lymph Nodes",
                            description: "Small nodules with location and shape in keeping with intrapulmonary lymph node (even if >6 mm) require no followup."
                        )

                        Divider().background(Color.subtleDivider)

                        DetailItem(
                            title: "6–12 Month Followup if Cancer History or Suspicious Appearance",
                            description: "A 6–12 month followup CT should be considered in patients with a cancer history, or perifissural nodule with spiculated margin or displacement of adjacent fissure."
                        )
                    }
                }

                ReferenceButton(reference: .fleischnerGuideline, accentColor: .fleischnerAccent)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
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

                ReferenceButton(reference: .fleischnerGuideline, accentColor: .fleischnerAccent)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
        .navigationTitle("Nodule Density")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FleischnerCalcificationPatternsDetailView: View {
    var reference: ReferenceType = .fleischnerGuideline
    var accentColor: Color = .fleischnerAccent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Benign Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("BENIGN")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.severityMinimal)
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
                    .cardStyle(cornerRadius: 12)
                    .padding(.horizontal)
                }

                // Indeterminate Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("INDETERMINATE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.severityModerate)
                        .padding(.horizontal)

                    HStack(spacing: 24) {
                        CalcificationPatternItem(title: "ECCENTRIC")
                        CalcificationPatternItem(title: "STIPPLED")
                    }
                    .padding()
                    .cardStyle(cornerRadius: 12)
                    .padding(.horizontal)
                }

                ReferenceButton(reference: reference, accentColor: accentColor)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
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
                        Divider().background(Color.subtleDivider)
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

                ReferenceButton(reference: .fleischnerGuideline, accentColor: .fleischnerAccent)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
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
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: "6–8 mm",
                            description: "If stability cannot be confirmed by retrospective review of an older study, obtain followup chest CT at interval appropriate for nodule of this size."
                        )
                        Divider().background(Color.subtleDivider)
                        DetailItem(
                            title: ">8 mm",
                            description: "Obtain complete chest CT."
                        )
                    }
                }

                ReferenceButton(reference: .fleischnerGuideline, accentColor: .fleischnerAccent)
            }
            .padding(.top, 16)
        }
        .background(AppBackdrop())
        .navigationTitle("Neck/Abdomen CTs")
        .navigationBarTitleDisplayMode(.inline)
    }
}
