import Foundation
import Combine

struct BrockFormState {
    var age: String = ""
    var gender: BrockGender = .male
    var noduleSize: String = ""
    var noduleMorphology: BrockNoduleType = .nonsolid
    var upperLobe: Bool = false
    var noduleCount: String = ""
    var spiculation: Bool = false
    var familyHistory: Bool = false
    var emphysema: Bool = false
}

@MainActor
final class BrockViewModel: ObservableObject {
    @Published var form = BrockFormState()

    var result: BrockResult? {
        guard let input else { return nil }
        return BrockCalculator.calculate(input: input)
    }

    var validationError: String? {
        guard let input else { return nil }
        return BrockCalculator.validate(input: input)?.message
    }

    private var input: BrockInput? {
        guard let ageValue = NumericInputParser.parseInt(form.age) else { return nil }
        guard let sizeValue = NumericInputParser.parseDouble(form.noduleSize) else { return nil }
        guard let countValue = NumericInputParser.parseInt(form.noduleCount) else { return nil }

        return BrockInput(
            age: ageValue,
            isFemale: form.gender == .female,
            noduleSizeMm: sizeValue,
            noduleType: form.noduleMorphology,
            upperLobe: form.upperLobe,
            noduleCount: countValue,
            spiculation: form.spiculation,
            familyHistory: form.familyHistory,
            emphysema: form.emphysema
        )
    }

}
