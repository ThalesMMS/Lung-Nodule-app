import SwiftUI

struct FleischnerView: View {
    @StateObject private var viewModel = FleischnerViewModel()
    @State private var showMorphologyInfo = false
    @State private var showSizeInfo = false
    @State private var showRiskInfo = false
    @State private var showMultipleInfo = false
    @State private var showSolidComponentInfo = false
    @State private var highRiskSmokingHistory = false
    @State private var highRiskExposure = false
    @State private var highRiskFamilyHistory = false
    @FocusState private var focusedField: FocusField?

    private enum FocusField {
        case size
        case solidComponent
        case longAxis
        case shortAxis
    }
    
    var body: some View {
        AdaptiveCalculatorGrid {
            resultCard

            VStack(spacing: 18) {
                SettingsSection(title: "Nodule") {
                    morphologyRow
                    sizeSection

                    if viewModel.input.noduleType == .partSolid {
                        SettingsRow(
                            title: "Solid Component",
                            hasInfo: true,
                            onInfoTap: { showSolidComponentInfo = true },
                            trailing: {
                                ValueChip(accentColor: .fleischnerAccent) {
                                    TextField("0", text: $viewModel.solidComponentText)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(Color.fleischnerAccent)
                                        .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                                        .focused($focusedField, equals: .solidComponent)
                                    Text("mm")
                                        .foregroundColor(.gray)
                                }
                            }
                        )
                    }
                }

                roundingNote

                SettingsSection(title: "Patient & Context") {
                    SettingsRow(
                        title: "High Risk Patient",
                        hasInfo: true,
                        onInfoTap: { showRiskInfo = true },
                        trailing: {
                            Toggle("", isOn: Binding(
                                get: { viewModel.input.risk == .high },
                                set: { isHighRisk in
                                    viewModel.input.risk = isHighRisk ? .high : .low
                                    if !isHighRisk {
                                        highRiskSmokingHistory = false
                                        highRiskExposure = false
                                        highRiskFamilyHistory = false
                                    }
                                }
                            ))
                            .labelsHidden()
                            .accessibilityLabel("High Risk Patient")
                        }
                    )

                    SettingsRow(
                        title: "Multiple",
                        hasInfo: true,
                        onInfoTap: { showMultipleInfo = true },
                        trailing: {
                            Toggle("", isOn: $viewModel.input.isMultiple)
                                .labelsHidden()
                                .accessibilityLabel("Multiple Nodules")
                        }
                    )
                }

                ReferenceButton(
                    reference: .fleischnerGuideline,
                    accentColor: .fleischnerAccent,
                    topPadding: 8,
                    bottomPadding: 0
                )
            }
        }
        .padding(.horizontal, 8)
        .tint(Color.fleischnerAccent)
        .onAppear { viewModel.calculate() }
        .onChange(of: viewModel.input.noduleType) { _, _ in viewModel.calculate() }
        .onChange(of: viewModel.input.sizeCategory) { _, _ in viewModel.calculate() }
        .onChange(of: viewModel.input.risk) { _, _ in viewModel.calculate() }
        .onChange(of: viewModel.input.isMultiple) { _, _ in viewModel.calculate() }
        .onChange(of: viewModel.input.solidComponentSize) { _, _ in viewModel.calculate() }
        .onChange(of: highRiskSmokingHistory) { _, _ in updateHighRiskFromChecklist() }
        .onChange(of: highRiskExposure) { _, _ in updateHighRiskFromChecklist() }
        .onChange(of: highRiskFamilyHistory) { _, _ in updateHighRiskFromChecklist() }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
                    .foregroundColor(Color.fleischnerAccent)
            }
        }
        .informationAlert(
            "Nodule Morphology",
            isPresented: $showMorphologyInfo,
            message: "• Solid: entirely soft-tissue attenuation.\n• Non-Solid (Ground-Glass): no measurable solid component.\n• Part-Solid: both ground-glass and solid components."
        )
        .informationAlert(
            "Nodule Measurement",
            isPresented: $showSizeInfo,
            message: "< 3 mm: Do not measure (use \"micronodule\" descriptor).\n\n3–10 mm: Report the average diameter = (long-axis + short-axis) / 2.\n\n≥ 10 mm: Report both long-axis and short-axis measurements.\n\nBoth measurements and averages should be expressed to the nearest whole millimeter.\n\nFor further guidance, tap the \"Common Issues\" (info circle icon) in the top-left corner of the app, then tap \"Measuring Nodules.\""
        )
        .sheet(isPresented: $showRiskInfo) {
            FleischnerHighRiskChecklistView(
                isHighRisk: Binding(
                    get: { viewModel.input.risk == .high },
                    set: { viewModel.input.risk = $0 ? .high : .low }
                ),
                smokingHistory: $highRiskSmokingHistory,
                exposureHistory: $highRiskExposure,
                familyHistory: $highRiskFamilyHistory
            )
        }
        .informationAlert(
            "Multiple Nodules",
            isPresented: $showMultipleInfo,
            message: "If one nodule is larger or more suspicious than the others, management should be based upon guidelines for solitary nodules"
        )
        .informationAlert(
            "Solid Component Size",
            isPresented: $showSolidComponentInfo,
            message: "For part-solid nodules, measure the solid component on lung windows. The solid component size determines management recommendations."
        )
    }

    private func updateHighRiskFromChecklist() {
        let isHighRisk = highRiskSmokingHistory || highRiskExposure || highRiskFamilyHistory
        viewModel.input.risk = isHighRisk ? .high : .low
    }

    @ViewBuilder
    private var resultCard: some View {
        if let result = viewModel.result {
            let severityColor = FleischnerSeverity.color(for: result.recommendation)

            VStack(spacing: 16) {
                Text("Fleischner 2017")
                    .font(.caption.weight(.semibold))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundColor(.white.opacity(0.5))

                ZStack {
                    Circle()
                        .fill(severityColor)
                        .frame(width: 90, height: 90)
                        .blur(radius: 45)
                        .opacity(0.28)

                    Image(systemName: FleischnerSeverity.icon(for: result.recommendation))
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(severityColor)
                        .frame(width: 68, height: 68)
                        .background(severityColor.opacity(0.13), in: Circle())
                        .overlay(Circle().strokeBorder(severityColor.opacity(0.30), lineWidth: 1))
                }

                VStack(spacing: 5) {
                    Text(primaryRecommendation(from: result.recommendation))
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    if hasSecondaryRecommendation(result.recommendation) {
                        Text(secondaryRecommendation(from: result.recommendation))
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.62))
                            .multilineTextAlignment(.center)
                    }
                }

                SeverityBar(color: severityColor, maxWidth: .infinity)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topTrailing) {
                ResetButton(accentColor: .fleischnerAccent) {
                    highRiskSmokingHistory = false
                    highRiskExposure = false
                    highRiskFamilyHistory = false
                    viewModel.reset()
                    viewModel.calculate()
                }
                .padding(12)
            }
            .cardStyle()
            .padding(.horizontal, 16)
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier("fleischner.result")
            .accessibilityLabel("Fleischner result")
            .accessibilityValue(result.recommendation)
        }
    }

    private var morphologyRow: some View {
        SettingsRow(
            title: "Nodule Morphology",
            hasInfo: true,
            onInfoTap: { showMorphologyInfo = true },
            trailing: {
                SettingsMenuPicker(
                    selection: viewModel.input.noduleType.rawValue,
                    accentColor: .fleischnerAccent,
                    options: NoduleType.allCases.map(\.rawValue),
                    onSelect: { value in
                        if let type = NoduleType.allCases.first(where: { $0.rawValue == value }) {
                            viewModel.input.noduleType = type
                        }
                    }
                )
            }
        )
    }

    @ViewBuilder
    private var sizeSection: some View {
        sizeRow
        axisToggleRow
        axisRows
    }

    private var sizeRow: some View {
        SettingsRow(
            title: "Nodule Size",
            hasInfo: true,
            onInfoTap: { showSizeInfo = true },
            trailing: {
                if viewModel.useAxisMeasurements {
                    ValueChip(accentColor: .fleischnerAccent) {
                        Text(viewModel.axisMeanDisplay)
                            .foregroundColor(Color.fleischnerAccent)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                } else {
                    ValueChip(accentColor: .fleischnerAccent) {
                        TextField("0", text: $viewModel.sizeText)
                            .accessibilityIdentifier("fleischner.size")
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.fleischnerAccent)
                            .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                            .focused($focusedField, equals: .size)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                }
            }
        )
    }

    private var axisToggleRow: some View {
        SettingsRow(
            title: "Use long/short axes",
            trailing: {
                Toggle("", isOn: $viewModel.useAxisMeasurements)
                    .labelsHidden()
                    .accessibilityLabel("Use long and short axes")
            }
        )
    }

    @ViewBuilder
    private var axisRows: some View {
        if viewModel.useAxisMeasurements {
            SettingsRow(
                title: "Long axis",
                trailing: {
                    ValueChip(accentColor: .fleischnerAccent) {
                        TextField("0", text: $viewModel.longAxisText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.fleischnerAccent)
                            .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                            .focused($focusedField, equals: .longAxis)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                }
            )

            SettingsRow(
                title: "Short axis",
                trailing: {
                    ValueChip(accentColor: .fleischnerAccent) {
                        TextField("0", text: $viewModel.shortAxisText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.fleischnerAccent)
                            .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                            .focused($focusedField, equals: .shortAxis)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                }
            )
        }
    }

    @ViewBuilder
    private var roundingNote: some View {
        if let roundingMessage = viewModel.roundingMessage {
            Text(roundingMessage)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
        }
    }
    
    // Helper functions for recommendation parsing
    private func primaryRecommendation(from text: String) -> String {
        if text.contains(",") {
            return String(text.split(separator: ",").first ?? Substring(text)).trimmingCharacters(in: .whitespaces)
        }
        return text
    }
    
    private func hasSecondaryRecommendation(_ text: String) -> Bool {
        return text.contains(",") || text.contains("then")
    }
    
    private func secondaryRecommendation(from text: String) -> String {
        if let range = text.range(of: ", then ") {
            return "then " + String(text[range.upperBound...])
        } else if let range = text.range(of: ",") {
            return String(text[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        }
        return ""
    }
    
    private func progressWidth(for recommendation: String, in totalWidth: CGFloat) -> CGFloat {
        // Return progress based on recommendation urgency
        if recommendation.contains("No routine") {
            return totalWidth * 0.1
        } else if recommendation.contains("12 months") || recommendation.contains("6-12") {
            return totalWidth * 0.6
        } else if recommendation.contains("3 months") || recommendation.contains("3-6") {
            return totalWidth * 0.8
        }
        return totalWidth * 0.5
    }
    
    private func knobOffset(for recommendation: String, in totalWidth: CGFloat, isStart: Bool) -> CGFloat {
        let progress = progressWidth(for: recommendation, in: totalWidth)
        if isStart {
            return progress * 0.3 - 8
        } else {
            return progress - 8
        }
    }
    
}

struct FleischnerHighRiskChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isHighRisk: Bool
    @Binding var smokingHistory: Bool
    @Binding var exposureHistory: Bool
    @Binding var familyHistory: Bool

    private let greenAccent = Color.fleischnerAccent

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Select any risk factor that applies. The High Risk toggle will update automatically.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                GroupedToggleCard(rows: [
                    GroupedToggleRow(
                        id: "risk.smoking-history",
                        title: "Smoking history",
                        isOn: $smokingHistory
                    ),
                    GroupedToggleRow(
                        id: "risk.exposure-history",
                        title: "Asbestos/radon/uranium exposure",
                        isOn: $exposureHistory
                    ),
                    GroupedToggleRow(
                        id: "risk.family-history",
                        title: "First-degree relative with lung cancer",
                        isOn: $familyHistory
                    )
                ])

                Spacer()
            }
            .padding(.top, 16)
            .background(AppBackdrop())
            .navigationTitle("High Risk Checklist")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(greenAccent)
                }
            }
            .onAppear { updateRisk() }
            .onChange(of: smokingHistory) { _, _ in updateRisk() }
            .onChange(of: exposureHistory) { _, _ in updateRisk() }
            .onChange(of: familyHistory) { _, _ in updateRisk() }
        }
        .tint(greenAccent)
    }

    private func updateRisk() {
        isHighRisk = smokingHistory || exposureHistory || familyHistory
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FleischnerView()
    }
}
