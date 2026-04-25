import SwiftUI

struct BrockFormState {
    var age: String = ""
    var gender: Int = 0
    var noduleSize: String = ""
    var noduleMorphology: Int = 0
    var upperLobe: Bool = false
    var noduleCount: String = ""
    var spiculation: Bool = false
    var familyHistory: Bool = false
    var emphysema: Bool = false
}

struct BrockView: View {
    @Binding var form: BrockFormState
    @State private var selectedReference: ReferenceType?
    @FocusState private var focusedField: FocusField?
    private let blueAccent = Color(red: 0.0, green: 0.478, blue: 1.0)

    private enum FocusField {
        case age
        case size
        case count
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("The Brock full model estimates a CT-detected nodule's 2-4 year malignancy risk.")
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(white: 0.15))
                .cornerRadius(12)
                .padding(.horizontal, 16)

            patientSection
            noduleSection
            riskFactorsSection
            resultSection
            referenceButton

            Spacer()
        }
        .referencePresenter(reference: $selectedReference)
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
                    TextField("", text: $form.age)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                        .frame(width: 60)
                        .focused($focusedField, equals: .age)
                    Text("yrs")
                        .foregroundColor(.gray)
                }
                .padding()

                Divider().background(Color(white: 0.3))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Gender")
                        .foregroundColor(.gray)
                        .font(.caption)

                    Picker("Gender", selection: $form.gender) {
                        Text("Male").tag(0)
                        Text("Female").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
            }
            .background(Color(white: 0.15))
            .cornerRadius(12)
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
                    TextField("", text: $form.noduleSize)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                        .frame(width: 60)
                        .focused($focusedField, equals: .size)
                    Text("mm")
                        .foregroundColor(.gray)
                }
                .padding()

                Divider().background(Color(white: 0.3))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Nodule morphology")
                        .foregroundColor(.gray)
                        .font(.caption)

                    Picker("Morphology", selection: $form.noduleMorphology) {
                        ForEach(Array(BrockNoduleType.allCases.enumerated()), id: \.element.id) { index, type in
                            Text(type.rawValue).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()

                Divider().background(Color(white: 0.3))

                HStack {
                    Text("Upper lobe")
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $form.upperLobe)
                        .labelsHidden()
                }
                .padding()

                Divider().background(Color(white: 0.3))

                HStack {
                    Text("Nodule count (>= 1), no decimal")
                        .foregroundColor(.white)
                    Spacer()
                    TextField("#", text: $form.noduleCount)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                        .frame(width: 40)
                        .focused($focusedField, equals: .count)
                }
                .padding()

                Divider().background(Color(white: 0.3))

                HStack {
                    Text("Spiculation")
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $form.spiculation)
                        .labelsHidden()
                }
                .padding()
            }
            .background(Color(white: 0.15))
            .cornerRadius(12)
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
                    Toggle("", isOn: $form.familyHistory)
                        .labelsHidden()
                }
                .padding()

                Divider().background(Color(white: 0.3))

                HStack {
                    Text("Emphysema")
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $form.emphysema)
                        .labelsHidden()
                }
                .padding()
            }
            .background(Color(white: 0.15))
            .cornerRadius(12)
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
                if let result = brockResult {
                    Text(String(format: "Estimated malignancy risk: %.1f%%", result.malignancyProbability))
                        .foregroundColor(.white)
                    Text(result.riskCategory.rawValue)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(blueAccent)
                    Text(result.interpretation)
                        .font(.footnote)
                        .foregroundColor(.gray)
                } else if let validationError = brockValidationError {
                    Text(validationError)
                        .foregroundColor(.gray)
                } else {
                    Text("Enter all required fields.")
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(white: 0.15))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    private var referenceButton: some View {
        Button(action: { selectedReference = .brockSource }) {
            Text("Reference")
                .foregroundColor(blueAccent)
        }
        .padding(.top, 8)
    }

    private var brockResult: BrockResult? {
        guard let input = brockInput else { return nil }
        return BrockCalculator.calculate(input: input)
    }

    private var brockValidationError: String? {
        guard let input = brockInput else { return nil }
        return BrockCalculator.validate(input: input)?.message
    }

    private var brockInput: BrockInput? {
        guard let ageValue = parseInt(form.age) else { return nil }
        guard let sizeValue = parseDouble(form.noduleSize) else { return nil }
        guard let countValue = parseInt(form.noduleCount) else { return nil }

        return BrockInput(
            age: ageValue,
            isFemale: form.gender == 1,
            noduleSizeMm: sizeValue,
            noduleType: noduleType,
            upperLobe: form.upperLobe,
            noduleCount: countValue,
            spiculation: form.spiculation,
            familyHistory: form.familyHistory,
            emphysema: form.emphysema
        )
    }

    private var noduleType: BrockNoduleType {
        let types = BrockNoduleType.allCases
        guard types.indices.contains(form.noduleMorphology) else { return .solid }
        return types[form.noduleMorphology]
    }

    private func parseDouble(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private func parseInt(_ text: String) -> Int? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(normalized)
    }
}
