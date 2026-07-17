import SwiftUI

// MARK: - Result Card Subview
struct LungRADSResultCard: View {
    let result: LungRADSResult
    let blueAccent: Color
    let onSModifierTap: () -> Void
    let onBrockTap: (() -> Void)?
    @ScaledMetric(relativeTo: .largeTitle) var categoryFontSize = 84

    var severityColor: Color { result.category.severityColor }

    var body: some View {
        VStack(spacing: 14) {
            Text(managementText)
                .font(.caption.weight(.semibold))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.55))

            Text(categoryDisplay)
                .font(.system(size: categoryFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(severityColor)
                .lineLimit(1)
                .minimumScaleFactor(0.4)

            Text(result.category.description)
                .font(.headline)
                .foregroundColor(severityColor)
                .multilineTextAlignment(.center)

            SeverityBar(color: severityColor)

            if let notes = result.additionalNotes, !notes.isEmpty {
                Text(notes)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            VStack(spacing: 10) {
                if let onBrockTap {
                    PillButton(
                        title: "Calculate Malignancy Risk (Brock)",
                        icon: "waveform.path.ecg",
                        accentColor: blueAccent,
                        action: onBrockTap
                    )
                }

                PillButton(
                    title: "S Modifier Considerations",
                    icon: "plus.circle",
                    accentColor: blueAccent,
                    action: onSModifierTap
                )
            }
            .padding(.top, 8)
        }
        .padding(20)
        .cardStyle()
        .padding(.horizontal, 16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Lung-RADS result, category \(categoryDisplay)")
    }

    var managementText: String {
        if result.management.contains("12 months") || result.management.contains("annual") {
            return "12mo LDCT"
        } else if result.management.contains("6-month") || result.management.contains("6 months") {
            return "6mo LDCT"
        } else if result.management.contains("3-month") || result.management.contains("3 months") {
            return "3mo LDCT"
        } else if result.management.contains("PET/CT") || result.management.contains("tissue sampling") {
            return "Further Workup"
        } else if result.management.contains("Comparison") || result.management.contains("Additional imaging") {
            return "Prior CT Needed"
        }
        return "LDCT"
    }

    var categoryDisplay: String {
        result.category.rawValue + (result.hasSModifier ? "-S" : "")
    }
}

// CT Status Info View - detailed explanation sheet
struct CTStatusInfoView: View {
    @Environment(\.dismiss) var dismiss
    let blueAccent = Color.lungRADSAccent

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select **Baseline CT** if current CT is:")
                            .foregroundColor(.white)
                        Text("• Baseline LCS CT with **no** prior chest CT (screening or diagnostic) available for comparison")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle(cornerRadius: 12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select **Follow-Up CT** if current CT is:")
                            .foregroundColor(.white)
                        Text("• Baseline LCS CT that **does** have a comparison diagnostic chest CT")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Text("• Annual LCS CT")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Text("• 1-, 3-, or 6-month follow-up LCS CT")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Text("• Diagnostic chest CT that has a comparison LCS CT")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle(cornerRadius: 12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select **Awaiting Comparison CT** if a prior CT exists but has not been reviewed yet")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle(cornerRadius: 12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select **Incomplete CT** if current LDCT is technically limited (e.g., respiratory motion, partially imaged lung apices or bases)")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle(cornerRadius: 12)
                }
                .padding()
            }
            .background(AppBackdrop())
            .navigationTitle("LCS CT Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(blueAccent)
                }
            }
        }
        .tint(blueAccent)
    }
}

struct LungRADSSheets: ViewModifier {
    @ObservedObject var viewModel: LungRADSViewModel
    @Binding var showSModifierConsiderations: Bool
    @Binding var showCTStatusInfo: Bool

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSModifierConsiderations) {
                SModifierConsiderationsView(hasSModifierFindings: $viewModel.input.hasSModifierFindings)
            }
            .sheet(isPresented: $showCTStatusInfo) { CTStatusInfoView() }
    }
}

struct LungRADSAlerts: ViewModifier {
    @Binding var showMorphologyInfo: Bool
    @Binding var showCalcificationInfo: Bool
    @Binding var showSizeInfo: Bool
    @Binding var showNoduleStatusInfo: Bool
    @Binding var showSolidComponentInfo: Bool
    @Binding var showSuspiciousFeaturesInfo: Bool

    func body(content: Content) -> some View {
        content
            .informationAlert(
                "Nodule Morphology",
                isPresented: $showMorphologyInfo,
                message: "No lung nodule = Lung-RADS 1\nJuxtapleural includes costal, perimediastinal, and peridiaphragmatic locations."
            )
            .informationAlert(
                "Benign Calcification Pattern",
                isPresented: $showCalcificationInfo,
                message: "Complete, Central, Popcorn, Concentric Ring"
            )
            .informationAlert(
                "Nodule Size",
                isPresented: $showSizeInfo,
                message: "Select the mean diameter of the nodule. Mean diameter = (long axis + short axis) / 2, measured on the same axial image."
            )
            .informationAlert(
                "Nodule Status",
                isPresented: $showNoduleStatusInfo,
                message: "• Stable: No significant change from prior\n• New: Not present on prior CT\n• Growing: > 1.5 mm increase in mean diameter within 12 months\n• Slow Growing: GGO with gradual increase\n• Resolved: Previously seen nodule no longer present\n\nFor shorter intervals, smaller changes may be clinically significant; volumetric assessment is encouraged."
            )
            .informationAlert(
                "Solid Component",
                isPresented: $showSolidComponentInfo,
                message: "For part-solid nodules, measure the solid component on lung windows. For atypical cysts, measure the wall thickening or associated nodule."
            )
            .informationAlert(
                "Additional Suspicious Features",
                isPresented: $showSuspiciousFeaturesInfo,
                message: "Features that may upgrade Category 4A/4B to 4X:\n• Spiculation\n• Lymphadenopathy\n• Chest wall invasion\n• Cystic/cavitary features\n• Upper lobe location with emphysema"
            )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        LungRADSView()
    }
}
