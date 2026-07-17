import SwiftUI

extension LungRADSView {
    // MARK: - Size Row
    @ViewBuilder
    var sizeRow: some View {
        if viewModel.input.noduleType == .airway {
            airwayLocationRow
        } else if viewModel.useVolumeMeasurements {
            SettingsRow(
                title: "Equivalent Diameter",
                hasInfo: true,
                accentColor: blueAccent,
                onInfoTap: { showSizeInfo = true },
                trailing: {
                    ValueChip(accentColor: blueAccent) {
                        Text(viewModel.volumeEquivalentDisplay)
                            .foregroundColor(blueAccent)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                }
            )
        } else {
            SettingsRow(
                title: "Nodule Size",
                hasInfo: true,
                accentColor: blueAccent,
                onInfoTap: { showSizeInfo = true },
                trailing: {
                    if viewModel.useAxisMeasurements {
                        ValueChip(accentColor: blueAccent) {
                            Text(viewModel.axisMeanDisplay)
                                .foregroundColor(blueAccent)
                            Text("mm")
                                .foregroundColor(.gray)
                        }
                    } else {
                        ValueChip(accentColor: blueAccent) {
                            TextField("0", text: $viewModel.sizeText)
                                .accessibilityLabel("Nodule Size")
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(blueAccent)
                                .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                                .focused($focusedField, equals: .size)
                            Text("mm")
                                .foregroundColor(.gray)
                        }
                    }
                }
            )
        }
    }

    @ViewBuilder
    var volumeMeasurementSection: some View {
        if viewModel.input.noduleType != .airway {
            SettingsRow(
                title: "Use volume (mm3)",
                accentColor: blueAccent,
                trailing: {
                    Toggle("", isOn: $viewModel.useVolumeMeasurements)
                        .labelsHidden()
                        .accessibilityLabel("Use volume measurement")
                }
            )

            if viewModel.useVolumeMeasurements {
                SettingsRow(
                    title: "Volume",
                    accentColor: blueAccent,
                    trailing: {
                        ValueChip(accentColor: blueAccent) {
                            TextField("0", text: $viewModel.volumeText)
                                .accessibilityLabel("Volume")
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(blueAccent)
                                .frame(minWidth: 70, idealWidth: 90, maxWidth: 120)
                                .focused($focusedField, equals: .volume)
                            Text("mm3")
                                .foregroundColor(.gray)
                        }
                    }
                )
            }
        }
    }

    @ViewBuilder
    var axisMeasurementSection: some View {
        if viewModel.input.noduleType != .airway && !viewModel.useVolumeMeasurements {
            SettingsRow(
                title: "Use long/short axes",
                accentColor: blueAccent,
                trailing: {
                    Toggle("", isOn: $viewModel.useAxisMeasurements)
                        .labelsHidden()
                        .accessibilityLabel("Use long and short axes")
                }
            )

            if viewModel.useAxisMeasurements {
                SettingsRow(
                    title: "Long axis",
                    accentColor: blueAccent,
                    trailing: {
                        ValueChip(accentColor: blueAccent) {
                            TextField("0", text: $viewModel.longAxisText)
                                .accessibilityLabel("Long axis")
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(blueAccent)
                                .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                                .focused($focusedField, equals: .longAxis)
                            Text("mm")
                                .foregroundColor(.gray)
                        }
                    }
                )

                SettingsRow(
                    title: "Short axis",
                    accentColor: blueAccent,
                    trailing: {
                        ValueChip(accentColor: blueAccent) {
                            TextField("0", text: $viewModel.shortAxisText)
                                .accessibilityLabel("Short axis")
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(blueAccent)
                                .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                                .focused($focusedField, equals: .shortAxis)
                            Text("mm")
                                .foregroundColor(.gray)
                        }
                    }
                )
            }
        }
    }

    var airwayLocationRow: some View {
        SettingsRow(
            title: "Airway Location",
            hasInfo: false,
            accentColor: blueAccent,
            trailing: {
                SettingsMenuPicker(
                    selection: viewModel.input.airwayLocation.rawValue,
                    accentColor: blueAccent,
                    options: AirwayLocation.allCases.map { $0.rawValue },
                    onSelect: { value in
                        if let location = AirwayLocation.allCases.first(where: { $0.rawValue == value }) {
                            viewModel.input.airwayLocation = location
                        }
                    }
                )
            }
        )
    }

    // MARK: - Solid Component Row
    @ViewBuilder
    var solidComponentRow: some View {
        if viewModel.input.noduleType == .partSolid || viewModel.input.noduleType == .atypicalCyst {
            SettingsRow(
                title: viewModel.input.noduleType == .atypicalCyst ? "Wall/Nodule Size" : "Solid Component",
                hasInfo: true,
                accentColor: blueAccent,
                onInfoTap: { showSolidComponentInfo = true },
                trailing: {
                    ValueChip(accentColor: blueAccent) {
                        TextField("0", text: $viewModel.solidComponentText)
                            .accessibilityLabel(
                                viewModel.input.noduleType == .atypicalCyst
                                    ? "Wall/Nodule Size"
                                    : "Solid Component"
                            )
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(blueAccent)
                            .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                            .focused($focusedField, equals: .solidComponent)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                }
            )
        }
    }

    // MARK: - Nodule Status Row
    @ViewBuilder
    var noduleStatusRow: some View {
        if viewModel.input.ctStatus == .followUp {
            SettingsRow(
                title: "Nodule Status",
                hasInfo: true,
                accentColor: blueAccent,
                onInfoTap: { showNoduleStatusInfo = true },
                trailing: {
                    SettingsMenuPicker(
                        selection: viewModel.input.noduleStatus.rawValue,
                        accentColor: blueAccent,
                        options: NoduleStatus.allCases.map { $0.rawValue },
                        onSelect: { value in
                            if let status = NoduleStatus.allCases.first(where: { $0.rawValue == value }) {
                                viewModel.input.noduleStatus = status
                            }
                        }
                    )
                    .disabled(viewModel.useGrowthCalculator)
                }
            )

            if viewModel.input.noduleType == .partSolid && viewModel.input.noduleStatus == .growing {
                SettingsRow(
                    title: "Solid component grew",
                    accentColor: blueAccent,
                    trailing: {
                        Toggle("", isOn: $viewModel.input.solidComponentGrowthDetected)
                            .labelsHidden()
                            .accessibilityLabel("Solid component grew")
                    }
                )
            }
        }
    }

    @ViewBuilder
    var growthCalculatorSection: some View {
        if viewModel.input.ctStatus == .followUp {
            SettingsRow(
                title: "Use growth calculator",
                accentColor: blueAccent,
                trailing: {
                    Toggle("", isOn: $viewModel.useGrowthCalculator)
                        .labelsHidden()
                        .accessibilityLabel("Use growth calculator")
                }
            )

            if viewModel.useGrowthCalculator {
                SettingsRow(
                    title: "Current size",
                    accentColor: blueAccent,
                    trailing: {
                        ValueChip(accentColor: blueAccent) {
                            Text(viewModel.currentSizeDisplay)
                                .foregroundColor(blueAccent)
                            Text("mm")
                                .foregroundColor(.gray)
                        }
                    }
                )

                SettingsRow(
                    title: "Prior size",
                    accentColor: blueAccent,
                    trailing: {
                        ValueChip(accentColor: blueAccent) {
                            TextField("0", text: $viewModel.priorSizeText)
                                .accessibilityLabel("Prior size")
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(blueAccent)
                                .frame(minWidth: 60, idealWidth: 70, maxWidth: 100)
                                .focused($focusedField, equals: .priorSize)
                            Text("mm")
                                .foregroundColor(.gray)
                        }
                    }
                )

                SettingsRow(
                    title: "Prior date",
                    accentColor: blueAccent,
                    trailing: {
                        DatePicker("", selection: $viewModel.priorDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .accessibilityLabel("Prior date")
                    }
                )

                SettingsRow(
                    title: "Current date",
                    accentColor: blueAccent,
                    trailing: {
                        DatePicker("", selection: $viewModel.currentDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .accessibilityLabel("Current date")
                    }
                )

                if let summary = viewModel.growthSummary {
                    Text(summary)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: - Suspicious Features Row
    var suspiciousFeaturesRow: some View {
        SettingsRow(
            title: "Additional Suspicious Features",
            hasInfo: true,
            accentColor: blueAccent,
            onInfoTap: { showSuspiciousFeaturesInfo = true },
            trailing: {
                Toggle("", isOn: $viewModel.input.hasAdditionalSuspiciousFeatures)
                    .labelsHidden()
                    .accessibilityLabel("Additional Suspicious Features")
            }
        )
    }

    // MARK: - Reference Button
    var referenceButton: some View {
        ReferenceButton(
            reference: .lungRADSGuideline,
            accentColor: blueAccent,
            topPadding: 8,
            bottomPadding: 0
        )
    }
}
