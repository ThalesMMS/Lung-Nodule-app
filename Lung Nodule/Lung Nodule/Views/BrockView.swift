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
            VStack(spacing: 16) {
                Text(MedicalCopy.brockModelDescription)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .cardStyle(cornerRadius: 12)
                    .padding(.horizontal, 16)

                patientSection
            }

            VStack(spacing: 16) {
                noduleSection
                riskFactorsSection
                resultSection
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
        VStack(alignment: .leading, spacing: 0) {
            Text("PATIENT")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                HStack {
                    Text("Age (>= 18 yrs)")
                        .foregroundColor(.white)
                    Spacer()
                    TextField("", text: $viewModel.form.age)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                        .frame(minWidth: 50, idealWidth: 60, maxWidth: 90)
                        .focused($focusedField, equals: .age)
                    Text("yrs")
                        .foregroundColor(.gray)
                }
                .padding()

                Divider().background(Color.subtleDivider)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Gender")
                        .foregroundColor(.gray)
                        .font(.caption)

                    Picker("Gender", selection: $viewModel.form.gender) {
                        ForEach(BrockGender.allCases) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(blueAccent)
                }
                .padding()
            }
            .cardStyle(cornerRadius: 12)
            .padding(.horizontal)
        }
    }

    private var noduleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("NODULE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                HStack {
                    Text("Size (3-30 mm)")
                        .foregroundColor(.white)
                    Spacer()
                    TextField("", text: $viewModel.form.noduleSize)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                        .frame(minWidth: 50, idealWidth: 60, maxWidth: 90)
                        .focused($focusedField, equals: .size)
                    Text("mm")
                        .foregroundColor(.gray)
                }
                .padding()

                Divider().background(Color.subtleDivider)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Nodule morphology")
                        .foregroundColor(.gray)
                        .font(.caption)

                    Picker("Morphology", selection: $viewModel.form.noduleMorphology) {
                        ForEach(BrockNoduleType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(blueAccent)
                }
                .padding()

                Divider().background(Color.subtleDivider)

                HStack {
                    Text("Upper lobe")
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $viewModel.form.upperLobe)
                        .labelsHidden()
                        .accessibilityLabel("Upper lobe")
                }
                .padding()

                Divider().background(Color.subtleDivider)

                HStack {
                    Text("Nodule count (>= 1), no decimal")
                        .foregroundColor(.white)
                    Spacer()
                    TextField("0", text: $viewModel.form.noduleCount)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                        .frame(minWidth: 44, idealWidth: 50, maxWidth: 70)
                        .focused($focusedField, equals: .count)
                }
                .padding()

                Divider().background(Color.subtleDivider)

                HStack {
                    Text("Spiculation")
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $viewModel.form.spiculation)
                        .labelsHidden()
                        .accessibilityLabel("Spiculation")
                }
                .padding()
            }
            .cardStyle(cornerRadius: 12)
            .padding(.horizontal)
        }
    }

    private var riskFactorsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("OTHER RISK FACTORS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                HStack {
                    Text("Family history of lung cancer")
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $viewModel.form.familyHistory)
                        .labelsHidden()
                        .accessibilityLabel("Family history of lung cancer")
                }
                .padding()

                Divider().background(Color.subtleDivider)

                HStack {
                    Text("Emphysema")
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $viewModel.form.emphysema)
                        .labelsHidden()
                        .accessibilityLabel("Emphysema")
                }
                .padding()
            }
            .cardStyle(cornerRadius: 12)
            .padding(.horizontal)
        }
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("RESULT")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 8) {
                if let result = viewModel.result {
                    Text(String(format: "Estimated malignancy risk: %.1f%%", result.malignancyProbability))
                        .foregroundColor(.white)
                    Text(result.riskCategory.rawValue)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(blueAccent)
                    Text(result.interpretation)
                        .font(.footnote)
                        .foregroundColor(.gray)
                } else if let validationError = viewModel.validationError {
                    Text(validationError)
                        .foregroundColor(.gray)
                } else {
                    Text("Enter all required fields.")
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .cardStyle(cornerRadius: 12)
            .padding(.horizontal)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(resultAccessibilityLabel)
        }
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
