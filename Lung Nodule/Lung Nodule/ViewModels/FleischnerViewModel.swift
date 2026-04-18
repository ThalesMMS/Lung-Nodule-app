import SwiftUI
import Combine

class FleischnerViewModel: ObservableObject {
    @Published var input = FleischnerInput()
    @Published var result: FleischnerRecommendation?
    @Published var sizeText: String = "" {
        didSet { updateSizeMeasurement() }
    }
    @Published var solidComponentText: String = "" {
        didSet { updateSolidComponentMeasurement() }
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

    private func updateSizeMeasurement() {
        guard let value = parseMeasurement(sizeText), value > 0 else {
            input.sizeMm = nil
            input.sizeCategory = .lessThanSix
            roundedSizeMm = nil
            return
        }
        input.sizeMm = value
        guard let rounded = roundToNearestMm(value) else { return }
        roundedSizeMm = rounded
        input = input.resolvingMeasurements()
    }

    private func updateSolidComponentMeasurement() {
        guard let value = parseMeasurement(solidComponentText), value >= 0 else {
            input.solidComponentMm = 0
            input.solidComponentSize = .none
            input = input.resolvingMeasurements()
            return
        }
        input.solidComponentMm = value
        input = input.resolvingMeasurements()
    }

    private func parseMeasurement(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return nil }
        guard value.isFinite, roundToNearestMm(value) != nil else { return nil }
        return value
    }

    private func updateSizeFromAxes() {
        guard useAxisMeasurements else { return }
        guard let longAxis = parseMeasurement(longAxisText),
              let shortAxis = parseMeasurement(shortAxisText),
              longAxis > 0,
              shortAxis > 0 else {
            axisMeanMm = nil
            roundedSizeMm = nil
            input.sizeMm = nil
            input.sizeCategory = .lessThanSix
            return
        }
        let mean = (longAxis + shortAxis) / 2.0
        guard let rounded = roundToNearestMm(mean) else {
            axisMeanMm = nil
            roundedSizeMm = nil
            input.sizeMm = nil
            input.sizeCategory = .lessThanSix
            return
        }
        axisMeanMm = mean
        roundedSizeMm = rounded
        input.sizeMm = mean
        input = input.resolvingMeasurements()
    }

    private func syncSizeTextFromAxisMean() {
        guard let mean = axisMeanMm else { return }
        sizeText = formatSize(mean)
    }

    private func formatSize(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    private func roundToNearestMm(_ value: Double) -> Int? {
        guard value.isFinite else { return nil }
        return Int(exactly: value.rounded(.toNearestOrAwayFromZero))
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
            rawValue = parseMeasurement(sizeText)
        }
        guard let raw = rawValue, let rounded = roundedSizeMm else { return nil }
        let fractional = abs(raw - Double(rounded)) > 0.0001
        guard fractional else { return nil }
        return "Guidelines require rounding to nearest mm. Interpreted as: \(rounded) mm."
    }
}
