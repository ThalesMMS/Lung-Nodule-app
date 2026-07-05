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
    @State private var selectedReference: ReferenceType?
    @FocusState private var focusedField: FocusField?

    private enum FocusField {
        case size
        case solidComponent
        case longAxis
        case shortAxis
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Result Card matching reference Main_Fleischner.PNG
            resultCard
            morphologyRow
            sizeSection
            
            // High Risk Patient Row
            FleischnerSettingsRow(
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
                }
            )
            
            // Solid Component Size Row (only for Part-Solid)
            if viewModel.input.noduleType == .partSolid {
                FleischnerSettingsRow(
                    title: "Solid Component",
                    hasInfo: true,
                    onInfoTap: { showSolidComponentInfo = true },
                    trailing: {
                        HStack(spacing: 6) {
                            TextField("0", text: $viewModel.solidComponentText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color.fleischnerAccent)
                                .frame(width: 70)
                                .focused($focusedField, equals: .solidComponent)
                            Text("mm")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.fleischnerAccent.opacity(0.12), in: Capsule())
                    }
                )
            }
            
            // Multiple Row
            FleischnerSettingsRow(
                title: "Multiple",
                hasInfo: true,
                onInfoTap: { showMultipleInfo = true },
                trailing: {
                    Toggle("", isOn: $viewModel.input.isMultiple)
                        .labelsHidden()
                }
            )
            
            // Reference link
            Button(action: { selectedReference = .fleischnerGuideline }) {
                Text("Reference")
                    .foregroundColor(Color.fleischnerAccent)
            }
            .padding(.top, 8)
            
            Spacer()
        }
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
        .alert("Nodule Morphology", isPresented: $showMorphologyInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("• Solid: entirely soft-tissue attenuation.\n• Non-Solid (Ground-Glass): no measurable solid component.\n• Part-Solid: both ground-glass and solid components.")
        }
        .alert("Nodule Measurement", isPresented: $showSizeInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("< 3 mm: Do not measure (use \"micronodule\" descriptor).\n\n3–10 mm: Report the average diameter = (long-axis + short-axis) / 2.\n\n≥ 10 mm: Report both long-axis and short-axis measurements.\n\nBoth measurements and averages should be expressed to the nearest whole millimeter.\n\nFor further guidance, tap the \"Common Issues\" (info circle icon) in the top-left corner of the app, then tap \"Measuring Nodules.\"")
        }
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
        .alert("Multiple Nodules", isPresented: $showMultipleInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("If one nodule is larger or more suspicious than the others, management should be based upon guidelines for solitary nodules")
        }
        .alert("Solid Component Size", isPresented: $showSolidComponentInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("For part-solid nodules, measure the solid component on lung windows. The solid component size determines management recommendations.")
        }
        .referencePresenter(reference: $selectedReference)
    }

    private func updateHighRiskFromChecklist() {
        let isHighRisk = highRiskSmokingHistory || highRiskExposure || highRiskFamilyHistory
        viewModel.input.risk = isHighRisk ? .high : .low
    }

    @ViewBuilder
    private var resultCard: some View {
        if let result = viewModel.result {
            let severityColor = FleischnerSeverity.color(for: result.recommendation)

            VStack(spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: FleischnerSeverity.icon(for: result.recommendation))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(severityColor)
                        .frame(width: 44, height: 44)
                        .background(severityColor.opacity(0.15), in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(primaryRecommendation(from: result.recommendation))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)

                        if hasSecondaryRecommendation(result.recommendation) {
                            Text(secondaryRecommendation(from: result.recommendation))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }

                    Spacer(minLength: 0)
                }

                SeverityBar(color: severityColor, maxWidth: .infinity)
            }
            .padding(20)
            .cardStyle()
            .padding(.horizontal, 16)
        }
    }

    private var morphologyRow: some View {
        FleischnerSettingsRow(
            title: "Nodule Morphology",
            hasInfo: true,
            onInfoTap: { showMorphologyInfo = true },
            trailing: {
                Menu {
                    ForEach(NoduleType.allCases) { type in
                        Button(type.rawValue) {
                            viewModel.input.noduleType = type
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.input.noduleType.rawValue)
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundColor(Color.fleischnerAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.fleischnerAccent.opacity(0.12), in: Capsule())
                }
            }
        )
    }

    private var sizeSection: some View {
        VStack(spacing: 16) {
            sizeRow
            axisToggleRow
            axisRows
            roundingNote
        }
    }

    private var sizeRow: some View {
        FleischnerSettingsRow(
            title: "Nodule Size",
            hasInfo: true,
            onInfoTap: { showSizeInfo = true },
            trailing: {
                if viewModel.useAxisMeasurements {
                    HStack(spacing: 6) {
                        Text(viewModel.axisMeanDisplay)
                            .foregroundColor(Color.fleischnerAccent)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.fleischnerAccent.opacity(0.12), in: Capsule())
                } else {
                    HStack(spacing: 6) {
                        TextField("0", text: $viewModel.sizeText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.fleischnerAccent)
                            .frame(width: 70)
                            .focused($focusedField, equals: .size)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.fleischnerAccent.opacity(0.12), in: Capsule())
                }
            }
        )
    }

    private var axisToggleRow: some View {
        FleischnerSettingsRow(
            title: "Use long/short axes",
            trailing: {
                Toggle("", isOn: $viewModel.useAxisMeasurements)
                    .labelsHidden()
            }
        )
    }

    @ViewBuilder
    private var axisRows: some View {
        if viewModel.useAxisMeasurements {
            FleischnerSettingsRow(
                title: "Long axis",
                trailing: {
                    HStack(spacing: 6) {
                        TextField("0", text: $viewModel.longAxisText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.fleischnerAccent)
                            .frame(width: 70)
                            .focused($focusedField, equals: .longAxis)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.fleischnerAccent.opacity(0.12), in: Capsule())
                }
            )

            FleischnerSettingsRow(
                title: "Short axis",
                trailing: {
                    HStack(spacing: 6) {
                        TextField("0", text: $viewModel.shortAxisText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.fleischnerAccent)
                            .frame(width: 70)
                            .focused($focusedField, equals: .shortAxis)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.fleischnerAccent.opacity(0.12), in: Capsule())
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

                VStack(spacing: 0) {
                    toggleRow(
                        title: "Smoking history",
                        isOn: $smokingHistory
                    )

                    Divider().background(Color.subtleDivider)

                    toggleRow(
                        title: "Asbestos/radon/uranium exposure",
                        isOn: $exposureHistory
                    )

                    Divider().background(Color.subtleDivider)

                    toggleRow(
                        title: "First-degree relative with lung cancer",
                        isOn: $familyHistory
                    )
                }
                .cardStyle(cornerRadius: 12)
                .padding(.horizontal, 16)

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

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding()
    }

    private func updateRisk() {
        isHighRisk = smokingHistory || exposureHistory || familyHistory
    }
}

// Reusable settings row component for Fleischner (green accent)
struct FleischnerSettingsRow<Trailing: View>: View {
    let title: String
    var hasInfo: Bool = false
    var onInfoTap: (() -> Void)? = nil
    @ViewBuilder let trailing: () -> Trailing
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .foregroundColor(.white)

            if hasInfo {
                Button(action: { onInfoTap?() }) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(Color.fleischnerAccent)
                }
            }

            Spacer()

            trailing()
        }
        .padding()
        .cardStyle(cornerRadius: 12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FleischnerView()
    }
}
