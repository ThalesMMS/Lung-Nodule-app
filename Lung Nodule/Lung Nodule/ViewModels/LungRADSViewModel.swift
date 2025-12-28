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

    var axisMeanDisplay: String {
        guard let mean = axisMeanMm else { return "--" }
        return formatSize(mean)
    }
    
    func calculate() {
        result = LungRADSCalculator.calculate(input: input)
    }
    
    func reset() {
        input = LungRADSInput()
        result = nil
        sizeText = ""
        solidComponentText = ""
        useAxisMeasurements = false
        longAxisText = ""
        shortAxisText = ""
        axisMeanMm = nil
    }

    private func parseDouble(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return nil }
        return normalizeMeasurement(value)
    }

    private func updateSizeFromAxes() {
        guard useAxisMeasurements else { return }
        guard let longAxis = parseDouble(longAxisText),
              let shortAxis = parseDouble(shortAxisText),
              longAxis > 0,
              shortAxis > 0 else {
            axisMeanMm = nil
            input.sizeMm = nil
            return
        }
        let mean = (longAxis + shortAxis) / 2.0
        let normalized = normalizeMeasurement(mean)
        axisMeanMm = normalized
        input.sizeMm = normalized
    }

    private func syncSizeTextFromAxisMean() {
        guard let mean = axisMeanMm else { return }
        sizeText = formatSize(mean)
    }

    private func formatSize(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    private func normalizeMeasurement(_ value: Double) -> Double {
        (value * 10).rounded(.toNearestOrAwayFromZero) / 10
    }
}
