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
    @Published var useAxisMeasurements: Bool = false {
        didSet {
            if useAxisMeasurements {
                updateSizeFromAxes()
            } else {
                syncSizeTextFromAxisMean()
            }
        }
    }
    @Published var longAxisText: String = "" {
        didSet { updateSizeFromAxes() }
    }
    @Published var shortAxisText: String = "" {
        didSet { updateSizeFromAxes() }
    }
    @Published private(set) var axisMeanMm: Double? = nil
    @Published private(set) var roundedSizeMm: Int? = nil
    
    func calculate() {
        result = FleischnerCalculator.calculate(input: input)
    }
    
    func reset() {
        input = FleischnerInput()
        result = nil
        sizeText = ""
        solidComponentText = ""
        useAxisMeasurements = false
        longAxisText = ""
        shortAxisText = ""
        axisMeanMm = nil
        roundedSizeMm = nil
    }

    private func updateSizeCategory() {
        guard let rounded = roundedMillimeters(from: sizeText) else {
            roundedSizeMm = nil
            return
        }
        roundedSizeMm = rounded
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
        return roundToNearestMm(value)
    }

    private func parseDouble(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private func updateSizeFromAxes() {
        guard useAxisMeasurements else { return }
        guard let longAxis = parseDouble(longAxisText),
              let shortAxis = parseDouble(shortAxisText),
              longAxis > 0,
              shortAxis > 0 else {
            axisMeanMm = nil
            roundedSizeMm = nil
            return
        }
        let mean = (longAxis + shortAxis) / 2.0
        axisMeanMm = mean
        let rounded = roundToNearestMm(mean)
        roundedSizeMm = rounded
        if rounded < 6 {
            input.sizeCategory = .lessThanSix
        } else if rounded <= 8 {
            input.sizeCategory = .sixToEight
        } else {
            input.sizeCategory = .greaterThanEight
        }
    }

    private func syncSizeTextFromAxisMean() {
        guard let mean = axisMeanMm else { return }
        sizeText = formatSize(mean)
    }

    private func formatSize(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    private func roundToNearestMm(_ value: Double) -> Int {
        Int(value.rounded(.toNearestOrAwayFromZero))
    }

    var axisMeanDisplay: String {
        guard let mean = axisMeanMm else { return "--" }
        return formatSize(mean)
    }

    var roundingMessage: String? {
        let rawValue: Double?
        if useAxisMeasurements {
            rawValue = axisMeanMm
        } else {
            rawValue = parseDouble(sizeText)
        }
        guard let raw = rawValue, let rounded = roundedSizeMm else { return nil }
        let fractional = abs(raw - Double(rounded)) > 0.0001
        guard fractional else { return nil }
        return "Guidelines require rounding to nearest mm. Interpreted as: \(rounded) mm."
    }
}
