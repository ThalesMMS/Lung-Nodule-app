import SwiftUI

extension LungRADSView {
    // MARK: - Eligibility Section
    @ViewBuilder
    var eligibilitySection: some View {
        SettingsRow(
            title: "Patient Age",
            accentColor: blueAccent,
            trailing: {
                HStack(spacing: 6) {
                    TextField("0", text: $viewModel.ageText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(blueAccent)
                        .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                        .focused($focusedField, equals: .age)
                    Text("yrs")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(blueAccent.opacity(0.12), in: Capsule())
            }
        )

        SettingsRow(
            title: "Current Smoker",
            accentColor: blueAccent,
            trailing: {
                Toggle("", isOn: $viewModel.isCurrentSmoker)
                    .labelsHidden()
                    .accessibilityLabel("Current Smoker")
            }
        )

        if !viewModel.isCurrentSmoker {
            SettingsRow(
                title: "Years Since Quit",
                accentColor: blueAccent,
                trailing: {
                    HStack(spacing: 6) {
                        TextField("0", text: $viewModel.yearsSinceQuitText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(blueAccent)
                            .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                            .focused($focusedField, equals: .quitYears)
                        Text("yrs")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(blueAccent.opacity(0.12), in: Capsule())
                }
            )
        }
    }

    @ViewBuilder
    var eligibilityNotice: some View {
        if let notice = viewModel.eligibilityNotice {
            InfoBanner(
                text: notice,
                icon: "exclamationmark.triangle.fill",
                tint: .orange
            )
        }
    }

    // MARK: - CT Status Row
    var ctStatusRow: some View {
        SettingsRow(
            title: "LCS CT Status",
            hasInfo: true,
            accentColor: blueAccent,
            onInfoTap: { showCTStatusInfo = true },
            trailing: {
                SettingsMenuPicker(
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
    var morphologyRow: some View {
        SettingsRow(
            title: "Nodule Morphology",
            hasInfo: true,
            accentColor: blueAccent,
            onInfoTap: { showMorphologyInfo = true },
            trailing: {
                SettingsMenuPicker(
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

    @ViewBuilder
    var juxtapleuralMorphologyRow: some View {
        if viewModel.input.noduleType == .juxtapleural {
            SettingsRow(
                title: "Has benign morphology (smooth, oval/lentiform/triangular)?",
                accentColor: blueAccent,
                trailing: {
                    Toggle("", isOn: $viewModel.input.hasBenignJuxtapleuralMorphology)
                        .labelsHidden()
                        .accessibilityLabel("Has benign juxtapleural morphology")
                }
            )
        }
    }

    // MARK: - Benign Features Group
    @ViewBuilder
    var benignFeaturesGroup: some View {
        SettingsRow(
            title: "Benign Calcification Pattern",
            hasInfo: true,
            accentColor: blueAccent,
            onInfoTap: { showCalcificationInfo = true },
            trailing: {
                Toggle("", isOn: $viewModel.input.hasBenignCalcification)
                    .labelsHidden()
                    .accessibilityLabel("Benign Calcification Pattern")
            }
        )

        SettingsRow(
            title: "Macroscopic Fat in Nodule",
            accentColor: blueAccent,
            trailing: {
                Toggle("", isOn: $viewModel.input.hasMacroscopicFat)
                    .labelsHidden()
                    .accessibilityLabel("Macroscopic Fat in Nodule")
            }
        )
    }

    // MARK: - Multiple Nodules Row
    var multipleNodulesRow: some View {
        SettingsRow(
            title: "Multiple Nodules",
            accentColor: blueAccent,
            trailing: {
                Toggle("", isOn: $viewModel.input.isMultiple)
                    .labelsHidden()
                    .accessibilityLabel("Multiple Nodules")
            }
        )
    }

    // MARK: - Inflammatory Findings Row
    var inflammatoryFindingsRow: some View {
        SettingsRow(
            title: "Inflammatory/Infectious Findings",
            accentColor: blueAccent,
            trailing: {
                Toggle("", isOn: $viewModel.input.hasInflammatoryFindings)
                    .labelsHidden()
                    .accessibilityLabel("Inflammatory or Infectious Findings")
            }
        )
    }

    // MARK: - Atelectasis Row
    var atelectasisRow: some View {
        SettingsRow(
            title: "Atelectasis due to mucus plugging (no underlying mass)",
            accentColor: blueAccent,
            trailing: {
                Toggle("", isOn: $viewModel.input.hasAtelectasis)
                    .labelsHidden()
                    .accessibilityLabel("Atelectasis due to mucus plugging")
            }
        )
    }

}
