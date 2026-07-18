import SwiftUI

struct BrockView: View {
    @ObservedObject var viewModel: BrockViewModel
    @FocusState private var focusedField: FocusField?
    private let blueAccent = Color.lungRADSAccent

    private enum FocusField {
        case age
        case size
        case count
    }

    var body: some View {
        AdaptiveCalculatorGrid {
            VStack(spacing: 18) {
                resultSection

                InfoBanner(
                    text: MedicalCopy.brockModelDescription,
                    icon: "waveform.path.ecg",
                    tint: blueAccent
                )
            }

            VStack(spacing: 18) {
                patientSection
                noduleSection
                riskFactorsSection
                referenceButton
            }
        }
        .padding(.horizontal, 8)
        .tint(blueAccent)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
                    .foregroundColor(blueAccent)
            }
        }
    }

    private var patientSection: some View {
        SettingsSection(title: "Patient") {
            SettingsRow(
                title: "Age (>= 18 yrs)",
                accentColor: blueAccent,
                trailing: {
                    ValueChip(accentColor: blueAccent) {
                        TextField("0", text: $viewModel.form.age)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(blueAccent)
                            .frame(minWidth: 50, idealWidth: 60, maxWidth: 90)
                            .focused($focusedField, equals: .age)
                        Text("yrs")
                            .foregroundColor(.gray)
                    }
                }
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Gender")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.92))

                Picker("Gender", selection: $viewModel.form.gender) {
                    ForEach(BrockGender.allCases) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
                .tint(blueAccent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.rowFill)
        }
    }

    private var noduleSection: some View {
        SettingsSection(title: "Nodule") {
            SettingsRow(
                title: "Size (3-30 mm)",
                accentColor: blueAccent,
                trailing: {
                    ValueChip(accentColor: blueAccent) {
                        TextField("0", text: $viewModel.form.noduleSize)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(blueAccent)
                            .frame(minWidth: 50, idealWidth: 60, maxWidth: 90)
                            .focused($focusedField, equals: .size)
                        Text("mm")
                            .foregroundColor(.gray)
                    }
                }
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Nodule morphology")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.92))

                Picker("Morphology", selection: $viewModel.form.noduleMorphology) {
                    ForEach(BrockNoduleType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .tint(blueAccent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.rowFill)

            SettingsRow(
                title: "Upper lobe",
                accentColor: blueAccent,
                trailing: {
                    Toggle("", isOn: $viewModel.form.upperLobe)
                        .labelsHidden()
                        .accessibilityLabel("Upper lobe")
                }
            )

            SettingsRow(
                title: "Nodule count (>= 1), no decimal",
                accentColor: blueAccent,
                trailing: {
                    ValueChip(accentColor: blueAccent) {
                        TextField("0", text: $viewModel.form.noduleCount)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(blueAccent)
                            .frame(minWidth: 44, idealWidth: 50, maxWidth: 70)
                            .focused($focusedField, equals: .count)
                    }
                }
            )

            SettingsRow(
                title: "Spiculation",
                accentColor: blueAccent,
                trailing: {
                    Toggle("", isOn: $viewModel.form.spiculation)
                        .labelsHidden()
                        .accessibilityLabel("Spiculation")
                }
            )
        }
    }

    private var riskFactorsSection: some View {
        SettingsSection(title: "Other Risk Factors") {
            SettingsRow(
                title: "Family history of lung cancer",
                accentColor: blueAccent,
                trailing: {
                    Toggle("", isOn: $viewModel.form.familyHistory)
                        .labelsHidden()
                        .accessibilityLabel("Family history of lung cancer")
                }
            )

            SettingsRow(
                title: "Emphysema",
                accentColor: blueAccent,
                trailing: {
                    Toggle("", isOn: $viewModel.form.emphysema)
                        .labelsHidden()
                        .accessibilityLabel("Emphysema")
                }
            )
        }
    }

    private var resultSection: some View {
        VStack(spacing: 16) {
            Text("Brock Malignancy Risk")
                .font(.caption.weight(.semibold))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.5))

            if let result = viewModel.result {
                let severityColor = result.riskCategory.severityColor

                ZStack {
                    Circle()
                        .fill(severityColor)
                        .frame(width: 110, height: 110)
                        .blur(radius: 55)
                        .opacity(0.30)

                    Text(String(format: "%.1f%%", result.malignancyProbability))
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [severityColor, severityColor.opacity(0.75)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .frame(height: 68)

                Text("\(result.riskCategory.rawValue) risk of malignancy")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                SeverityBar(color: severityColor)

                Text(result.interpretation)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.62))
                    .multilineTextAlignment(.center)
            } else {
                Image(systemName: "percent")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.severityNeutral)
                    .frame(width: 68, height: 68)
                    .background(Color.severityNeutral.opacity(0.13), in: Circle())
                    .overlay(Circle().strokeBorder(Color.severityNeutral.opacity(0.30), lineWidth: 1))

                Text(viewModel.validationError ?? "Enter all required fields.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.62))
                    .multilineTextAlignment(.center)

                SeverityBar(color: .severityNeutral)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .cardStyle()
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(resultAccessibilityLabel)
    }

    private var resultAccessibilityLabel: String {
        if let result = viewModel.result {
            return String(
                format: "Brock result. Estimated malignancy risk: %.1f%%. %@. %@",
                result.malignancyProbability,
                result.riskCategory.rawValue,
                result.interpretation
            )
        }
        if let validationError = viewModel.validationError {
            return "Brock result. \(validationError)"
        }
        return "Brock result. Enter all required fields."
    }

    private var referenceButton: some View {
        ReferenceButton(
            reference: .brockSource,
            accentColor: blueAccent,
            topPadding: 8,
            bottomPadding: 0
        )
    }

}
