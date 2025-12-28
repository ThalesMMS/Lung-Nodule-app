import SwiftUI
import Combine

class FleischnerViewModel: ObservableObject {
    @Published var input = FleischnerInput()
    @Published var result: FleischnerRecommendation?
    @Published var sizeText: String = "" {
        didSet { updateSizeCategory() }
    }
    @Published var solidComponentText: String = "" {
        didSet { updateSolidComponentCategory() }
    }
    
    func calculate() {
        result = FleischnerCalculator.calculate(input: input)
    }
    
    func reset() {
        input = FleischnerInput()
        result = nil
        sizeText = ""
        solidComponentText = ""
    }

    private func updateSizeCategory() {
        guard let rounded = roundedMillimeters(from: sizeText) else { return }
        if rounded < 6 {
            input.sizeCategory = .lessThanSix
        } else if rounded <= 8 {
            input.sizeCategory = .sixToEight
        } else {
            input.sizeCategory = .greaterThanEight
        }
    }

    private func updateSolidComponentCategory() {
        guard let rounded = roundedMillimeters(from: solidComponentText) else {
            input.solidComponentSize = .none
            return
        }
        if rounded <= 0 {
            input.solidComponentSize = .none
        } else if rounded < 6 {
            input.solidComponentSize = .lessThanSix
        } else {
            input.solidComponentSize = .sixOrMore
        }
    }

    private func roundedMillimeters(from text: String) -> Int? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return nil }
        return Int(value.rounded())
    }
}
