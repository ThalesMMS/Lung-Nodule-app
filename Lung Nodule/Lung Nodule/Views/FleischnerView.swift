import SwiftUI

struct FleischnerView: View {
    @StateObject private var viewModel = FleischnerViewModel()
    @State private var showMorphologyInfo = false
    @State private var showSizeInfo = false
    @State private var showRiskInfo = false
    @State private var showMultipleInfo = false
    @State private var showSolidComponentInfo = false
    @FocusState private var focusedField: FocusField?

    private enum FocusField {
        case size
        case solidComponent
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Result Card matching reference Main_Fleischner.PNG
            if let result = viewModel.result {
                VStack(spacing: 12) {
                    // Primary recommendation
                    Text(primaryRecommendation(from: result.recommendation))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    // Primary slider/progress
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(white: 0.3))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.2, green: 0.8, blue: 0.2))
                                .frame(width: progressWidth(for: result.recommendation, in: geo.size.width), height: 8)
                            
                            // Slider knobs
                            Circle()
                                .fill(Color.white)
                                .frame(width: 16, height: 16)
                                .offset(x: knobOffset(for: result.recommendation, in: geo.size.width, isStart: true))
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 16, height: 16)
                                .offset(x: knobOffset(for: result.recommendation, in: geo.size.width, isStart: false))
                        }
                    }
                    .frame(height: 20)
                    .padding(.horizontal, 8)
                    
                    // Secondary recommendation if applicable
                    if hasSecondaryRecommendation(result.recommendation) {
                        Text(secondaryRecommendation(from: result.recommendation))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        
                        // Progress bar with segments
                        HStack(spacing: 2) {
                            ForEach(0..<15, id: \.self) { index in
                                Rectangle()
                                    .fill(Color(red: 0.2, green: 0.8, blue: 0.2))
                                    .frame(height: 12)
                            }
                        }
                        .padding(.horizontal, 8)
                        .overlay(
                            HStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 14, height: 14)
                                Spacer()
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 14, height: 14)
                            }
                            .padding(.horizontal, 4)
                        )
                    }
                    
                    // Gray placeholder bars (4 of them as in reference)
                    VStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(white: 0.35))
                                .frame(height: 20)
                        }
                    }
                    .padding(.top, 12)
                }
                .padding(20)
                .background(Color(white: 0.15))
                .cornerRadius(16)
                .padding(.horizontal, 16)
            }
            
            // Nodule Morphology Row
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
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
                        }
                    }
                }
            )
            
            // Nodule Size Row
            FleischnerSettingsRow(
                title: "Nodule Size",
                hasInfo: true,
                onInfoTap: { showSizeInfo = true },
                trailing: {
                    HStack(spacing: 6) {
                        TextField("mm", text: $viewModel.sizeText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
                            .frame(width: 70)
                            .focused($focusedField, equals: .size)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                }
            )
            
            // High Risk Patient Row
            FleischnerSettingsRow(
                title: "High Risk Patient",
                hasInfo: true,
                onInfoTap: { showRiskInfo = true },
                trailing: {
                    Toggle("", isOn: Binding(
                        get: { viewModel.input.risk == .high },
                        set: { viewModel.input.risk = $0 ? .high : .low }
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
                            TextField("mm", text: $viewModel.solidComponentText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
                                .frame(width: 70)
                                .focused($focusedField, equals: .solidComponent)
                            Text("mm")
                                .foregroundColor(.gray)
                        }
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
            Button(action: {}) {
                Text("Reference")
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .onAppear { viewModel.calculate() }
        .onChange(of: viewModel.input.noduleType) { _, _ in viewModel.calculate() }
        .onChange(of: viewModel.input.sizeCategory) { _, _ in viewModel.calculate() }
        .onChange(of: viewModel.input.risk) { _, _ in viewModel.calculate() }
        .onChange(of: viewModel.input.isMultiple) { _, _ in viewModel.calculate() }
        .onChange(of: viewModel.input.solidComponentSize) { _, _ in viewModel.calculate() }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
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
        .alert("High Risk", isPresented: $showRiskInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Patients at high risk include those with a smoking history, exposure to asbestos/radon/uranium, or having a first degree relative with history of lung cancer")
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

// Reusable settings row component for Fleischner (green accent)
struct FleischnerSettingsRow<Trailing: View>: View {
    let title: String
    var hasInfo: Bool = false
    var onInfoTap: (() -> Void)? = nil
    @ViewBuilder let trailing: () -> Trailing
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            
            if hasInfo {
                Button(action: { onInfoTap?() }) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
                }
            }
            
            Spacer()
            
            trailing()
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FleischnerView()
    }
}
