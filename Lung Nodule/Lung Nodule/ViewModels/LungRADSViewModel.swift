import SwiftUI
import Combine

class LungRADSViewModel: ObservableObject {
    @Published var input = LungRADSInput()
    @Published var result: LungRADSResult?
    @Published var sizeText: String = "" {
        didSet { input.sizeMm = parseDouble(sizeText) }
    }
    @Published var solidComponentText: String = "" {
        didSet { input.solidComponentMm = parseDouble(solidComponentText) }
    }
    
    func calculate() {
        result = LungRADSCalculator.calculate(input: input)
    }
    
    func reset() {
        input = LungRADSInput()
        result = nil
        sizeText = ""
        solidComponentText = ""
    }

    private func parseDouble(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
}
