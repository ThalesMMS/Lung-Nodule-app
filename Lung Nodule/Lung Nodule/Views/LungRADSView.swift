import SwiftUI

struct LungRADSView: View {
    @StateObject private var viewModel = LungRADSViewModel()
    @State private var showSModifierConsiderations = false
    @State private var showCTStatusInfo = false
    @State private var showMorphologyInfo = false
    @State private var showCalcificationInfo = false
    @State private var showSizeInfo = false
    @State private var showNoduleStatusInfo = false
    @State private var showSolidComponentInfo = false
    @State private var showSuspiciousFeaturesInfo = false
    
    private let blueAccent = Color(red: 0.0, green: 0.478, blue: 1.0)
    
    var body: some View {
        mainContent
            .onAppear { viewModel.calculate() }
            .modifier(LungRADSChangeObservers(viewModel: viewModel))
            .modifier(LungRADSSheets(
                showSModifierConsiderations: $showSModifierConsiderations,
                showCTStatusInfo: $showCTStatusInfo
            ))
            .modifier(LungRADSAlerts(
                showMorphologyInfo: $showMorphologyInfo,
                showCalcificationInfo: $showCalcificationInfo,
                showSizeInfo: $showSizeInfo,
                showNoduleStatusInfo: $showNoduleStatusInfo,
                showSolidComponentInfo: $showSolidComponentInfo,
                showSuspiciousFeaturesInfo: $showSuspiciousFeaturesInfo
            ))
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                resultCardSection
                inputFieldsSection
                referenceButton
            }
        }
    }
    
    // MARK: - Result Card Section
    @ViewBuilder
    private var resultCardSection: some View {
        if let result = viewModel.result {
            LungRADSResultCard(
                result: result,
                blueAccent: blueAccent,
                onSModifierTap: { showSModifierConsiderations.toggle() }
            )
        }
    }
    
    // MARK: - Input Fields Section
    @ViewBuilder
    private var inputFieldsSection: some View {
        ctStatusRow
        morphologyRow
        benignFeaturesGroup
        sizeRow
        solidComponentRow
        noduleStatusRow
        suspiciousFeaturesRow
    }
    
    // MARK: - CT Status Row
    private var ctStatusRow: some View {
        LungRADSSettingsRow(
            title: "LCS CT Status",
            hasInfo: true,
            accentColor: blueAccent,
            onInfoTap: { showCTStatusInfo = true },
            trailing: {
                LungRADSMenuPicker(
                    selection: viewModel.input.ctStatus.rawValue,
                    accentColor: blueAccent,
                    options: CTStatus.allCases.map { $0.rawValue },
                    onSelect: { value in
                        if let status = CTStatus.allCases.first(where: { $0.rawValue == value }) {
                            viewModel.input.ctStatus = status
                        }
                    }
                )
            }
        )
    }
    
    // MARK: - Morphology Row
    private var morphologyRow: some View {
        LungRADSSettingsRow(
            title: "Nodule Morphology",
            hasInfo: true,
            accentColor: blueAccent,
            onInfoTap: { showMorphologyInfo = true },
            trailing: {
                LungRADSMenuPicker(
                    selection: viewModel.input.noduleType.rawValue,
                    accentColor: blueAccent,
                    options: LungRADSNoduleType.allCases.map { $0.rawValue },
                    onSelect: { value in
                        if let type = LungRADSNoduleType.allCases.first(where: { $0.rawValue == value }) {
                            viewModel.input.noduleType = type
                        }
                    }
                )
            }
        )
    }
    
    // MARK: - Benign Features Group
    private var benignFeaturesGroup: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Benign Calcification Pattern")
                    .foregroundColor(.white)
                Button(action: { showCalcificationInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(blueAccent)
                }
                Spacer()
                Toggle("", isOn: $viewModel.input.hasBenignCalcification)
                    .labelsHidden()
            }
            .padding()
            
            Divider().background(Color(white: 0.3))
            
            HStack {
                Text("Macroscopic Fat in Nodule")
                    .foregroundColor(.white)
                Spacer()
                Toggle("", isOn: $viewModel.input.hasMacroscopicFat)
                    .labelsHidden()
            }
            .padding()
        }
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Size Row
    private var sizeRow: some View {
        LungRADSSettingsRow(
            title: "Nodule Size",
            hasInfo: true,
            accentColor: blueAccent,
            onInfoTap: { showSizeInfo = true },
            trailing: {
                LungRADSMenuPicker(
                    selection: viewModel.input.sizeCategory.rawValue,
                    accentColor: blueAccent,
                    options: LungRADSSize.allCases.map { $0.rawValue },
                    onSelect: { value in
                        if let size = LungRADSSize.allCases.first(where: { $0.rawValue == value }) {
                            viewModel.input.sizeCategory = size
                        }
                    }
                )
            }
        )
    }
    
    // MARK: - Solid Component Row
    @ViewBuilder
    private var solidComponentRow: some View {
        if viewModel.input.noduleType == .partSolid || viewModel.input.noduleType == .atypicalCyst {
            LungRADSSettingsRow(
                title: viewModel.input.noduleType == .atypicalCyst ? "Wall/Nodule Size" : "Solid Component",
                hasInfo: true,
                accentColor: blueAccent,
                onInfoTap: { showSolidComponentInfo = true },
                trailing: {
                    LungRADSMenuPicker(
                        selection: viewModel.input.solidComponentSize.rawValue,
                        accentColor: blueAccent,
                        options: LungRADSSolidComponentSize.allCases.map { $0.rawValue },
                        onSelect: { value in
                            if let size = LungRADSSolidComponentSize.allCases.first(where: { $0.rawValue == value }) {
                                viewModel.input.solidComponentSize = size
                            }
                        }
                    )
                }
            )
        }
    }
    
    // MARK: - Nodule Status Row
    @ViewBuilder
    private var noduleStatusRow: some View {
        if viewModel.input.ctStatus == .followUp {
            LungRADSSettingsRow(
                title: "Nodule Status",
                hasInfo: true,
                accentColor: blueAccent,
                onInfoTap: { showNoduleStatusInfo = true },
                trailing: {
                    LungRADSMenuPicker(
                        selection: viewModel.input.noduleStatus.rawValue,
                        accentColor: blueAccent,
                        options: NoduleStatus.allCases.map { $0.rawValue },
                        onSelect: { value in
                            if let status = NoduleStatus.allCases.first(where: { $0.rawValue == value }) {
                                viewModel.input.noduleStatus = status
                            }
                        }
                    )
                }
            )
        }
    }
    
    // MARK: - Suspicious Features Row
    private var suspiciousFeaturesRow: some View {
        LungRADSSettingsRow(
            title: "Additional Suspicious Features",
            hasInfo: true,
            accentColor: blueAccent,
            onInfoTap: { showSuspiciousFeaturesInfo = true },
            trailing: {
                Toggle("", isOn: $viewModel.input.hasAdditionalSuspiciousFeatures)
                    .labelsHidden()
            }
        )
    }
    
    // MARK: - Reference Button
    private var referenceButton: some View {
        Button(action: {}) {
            Text("Reference")
                .foregroundColor(blueAccent)
        }
        .padding(.top, 8)
    }
}

// MARK: - Result Card Subview
struct LungRADSResultCard: View {
    let result: LungRADSResult
    let blueAccent: Color
    let onSModifierTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(managementText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            progressBar
            
            Text(result.category.rawValue)
                .font(.system(size: 120, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
                .padding(.vertical, 8)
            
            Text(result.category.description)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.2))
            
            Button(action: onSModifierTap) {
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundColor(blueAccent)
                    Text("S Modifier Considerations")
                        .foregroundColor(blueAccent)
                }
            }
            .padding(.top, 12)
        }
        .padding(20)
        .background(Color(white: 0.15))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(white: 0.3))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.2, green: 0.8, blue: 0.2))
                    .frame(width: geo.size.width, height: 8)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .offset(x: -8)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .offset(x: geo.size.width - 8)
            }
        }
        .frame(height: 20)
        .padding(.horizontal, 8)
    }
    
    private var managementText: String {
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
}

// MARK: - Menu Picker Helper
struct LungRADSMenuPicker: View {
    let selection: String
    let accentColor: Color
    let options: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    onSelect(option)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selection)
                    .foregroundColor(accentColor)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundColor(accentColor)
            }
        }
    }
}

// Reusable settings row component for Lung-RADS (blue accent)
struct LungRADSSettingsRow<Trailing: View>: View {
    let title: String
    var hasInfo: Bool = false
    var accentColor: Color = .blue
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
                        .foregroundColor(accentColor)
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

// CT Status Info View - detailed explanation sheet
struct CTStatusInfoView: View {
    @Environment(\.dismiss) private var dismiss
    private let blueAccent = Color(red: 0.0, green: 0.478, blue: 1.0)
    
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
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                    
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
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select **Awaiting Comparison CT** if a prior CT exists but has not been reviewed yet")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select **Incomplete CT** if current LDCT is technically limited (e.g., respiratory motion, partially imaged lung apices or bases)")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color.black)
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
    }
}

// MARK: - View Modifiers for Type-Checking

struct LungRADSChangeObservers: ViewModifier {
    @ObservedObject var viewModel: LungRADSViewModel
    
    func body(content: Content) -> some View {
        content
            .onChange(of: viewModel.input.noduleType) { _, _ in viewModel.calculate() }
            .onChange(of: viewModel.input.sizeCategory) { _, _ in viewModel.calculate() }
            .onChange(of: viewModel.input.solidComponentSize) { _, _ in viewModel.calculate() }
            .onChange(of: viewModel.input.ctStatus) { _, _ in viewModel.calculate() }
            .onChange(of: viewModel.input.noduleStatus) { _, _ in viewModel.calculate() }
            .onChange(of: viewModel.input.hasBenignCalcification) { _, _ in viewModel.calculate() }
            .onChange(of: viewModel.input.hasMacroscopicFat) { _, _ in viewModel.calculate() }
            .onChange(of: viewModel.input.hasAdditionalSuspiciousFeatures) { _, _ in viewModel.calculate() }
            .onChange(of: viewModel.input.hasInflammatoryFindings) { _, _ in viewModel.calculate() }
    }
}

struct LungRADSSheets: ViewModifier {
    @Binding var showSModifierConsiderations: Bool
    @Binding var showCTStatusInfo: Bool
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSModifierConsiderations) { SModifierConsiderationsView() }
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
            .alert("Nodule Morphology", isPresented: $showMorphologyInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("No lung nodule = Lung-RADS 1")
            }
            .alert("Benign Calcification Pattern", isPresented: $showCalcificationInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Complete, Central, Popcorn, Concentric Ring")
            }
            .alert("Nodule Size", isPresented: $showSizeInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Select the mean diameter of the nodule. Mean diameter = (long axis + short axis) / 2, measured on the same axial image.")
            }
            .alert("Nodule Status", isPresented: $showNoduleStatusInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("• Stable: No significant change from prior\n• New: Not present on prior CT\n• Growing: ≥1.5mm increase in mean diameter\n• Slow Growing: GGO with gradual increase\n• Resolved: Previously seen nodule no longer present")
            }
            .alert("Solid Component", isPresented: $showSolidComponentInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("For part-solid nodules, measure the solid component on lung windows. For atypical cysts, measure the wall thickening or associated nodule.")
            }
            .alert("Additional Suspicious Features", isPresented: $showSuspiciousFeaturesInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Features that may upgrade Category 4A/4B to 4X:\n• Spiculation\n• Lymphadenopathy\n• Chest wall invasion\n• Cystic/cavitary features\n• Upper lobe location with emphysema")
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        LungRADSView()
    }
}
