import SwiftUI
import Combine

class LungRADSViewModel: ObservableObject {
    @Published var input = LungRADSInput()
    @Published var result: LungRADSResult?
    @Published var sizeText: String = "" {
        didSet {
            guard !useVolumeMeasurements else { return }
            input.sizeMm = parseDouble(sizeText)
            updateGrowthStatus()
        }
    }
    @Published var solidComponentText: String = "" {
        didSet { input.solidComponentMm = parseDouble(solidComponentText) }
    }
    @Published var useAxisMeasurements: Bool = false {
        didSet {
            if useAxisMeasurements {
                useVolumeMeasurements = false
            }
            if useAxisMeasurements {
                updateSizeFromAxes()
            } else {
                syncSizeTextFromAxisMean()
            }
        }
    }
    @Published var useVolumeMeasurements: Bool = false {
        didSet {
            input.useVolume = useVolumeMeasurements
            if useVolumeMeasurements {
                useAxisMeasurements = false
                updateSizeFromVolume()
            } else {
                input.volumeMm3 = nil
                volumeEquivalentMm = nil
                if let sizeMm = input.sizeMm, sizeMm > 0 {
                    sizeText = formatSize(sizeMm)
                }
            }
        }
    }
    @Published var longAxisText: String = "" {
        didSet { updateSizeFromAxes() }
    }
    @Published var shortAxisText: String = "" {
        didSet { updateSizeFromAxes() }
    }
    @Published var volumeText: String = "" {
        didSet { updateSizeFromVolume() }
    }
    @Published var useGrowthCalculator: Bool = false {
        didSet { updateGrowthStatus() }
    }
    @Published var priorSizeText: String = "" {
        didSet { updateGrowthStatus() }
    }
    @Published var priorDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date() {
        didSet { updateGrowthStatus() }
    }
    @Published var currentDate: Date = Date() {
        didSet { updateGrowthStatus() }
    }
    @Published var ageText: String = ""
    @Published var isCurrentSmoker: Bool = true {
        didSet {
            if isCurrentSmoker {
                yearsSinceQuitText = ""
            }
        }
    }
    @Published var yearsSinceQuitText: String = ""
    @Published private(set) var axisMeanMm: Double? = nil
    @Published private(set) var volumeEquivalentMm: Double? = nil
    @Published private(set) var growthSummary: String? = nil

    var axisMeanDisplay: String {
        guard let mean = axisMeanMm else { return "--" }
        return formatSize(mean)
    }

    var volumeEquivalentDisplay: String {
        guard let value = volumeEquivalentMm else { return "--" }
        return formatSize(value)
    }

    var currentSizeDisplay: String {
        guard let size = input.sizeMm, size > 0 else { return "--" }
        return formatSize(size)
    }

    var eligibilityNotice: String? {
        let ageValue = parseInt(ageText)
        let quitYears = parseInt(yearsSinceQuitText)
        var reasons: [String] = []
        if let ageValue, ageValue > 80 {
            reasons.append("age > 80")
        }
        if !isCurrentSmoker, let quitYears, quitYears > 15 {
            reasons.append("quit > 15 years")
        }
        guard !reasons.isEmpty else { return nil }
        let reasonText = reasons.joined(separator: ", ")
        return "Patient may be ineligible for screening (\(reasonText)). Suggested note: \"Patient no longer meets screening eligibility; management depends on continued eligibility.\""
    }
    
    func calculate() {
        updateGrowthStatus()
        result = LungRADSCalculator.calculate(input: input)
    }
    
    func reset() {
        input = LungRADSInput()
        result = nil
        sizeText = ""
        solidComponentText = ""
        useAxisMeasurements = false
        useVolumeMeasurements = false
        longAxisText = ""
        shortAxisText = ""
        volumeText = ""
        useGrowthCalculator = false
        priorSizeText = ""
        priorDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        currentDate = Date()
        ageText = ""
        isCurrentSmoker = true
        yearsSinceQuitText = ""
        axisMeanMm = nil
        volumeEquivalentMm = nil
        growthSummary = nil
    }

    private func parseDouble(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return nil }
        return normalizeMeasurement(value)
    }

    private func updateSizeFromAxes() {
        guard useAxisMeasurements, !useVolumeMeasurements else { return }
        guard let longAxis = parseDouble(longAxisText),
              let shortAxis = parseDouble(shortAxisText),
              longAxis > 0,
              shortAxis > 0 else {
            axisMeanMm = nil
            if !useVolumeMeasurements {
                input.sizeMm = nil
            }
            return
        }
        let mean = (longAxis + shortAxis) / 2.0
        let normalized = normalizeMeasurement(mean)
        axisMeanMm = normalized
        input.sizeMm = normalized
        updateGrowthStatus()
    }

    private func updateSizeFromVolume() {
        guard useVolumeMeasurements else { return }
        guard let volumeValue = parseRawDouble(volumeText),
              volumeValue > 0 else {
            input.volumeMm3 = nil
            volumeEquivalentMm = nil
            return
        }
        let diameter = LungRADSVolumeConverter.equivalentDiameter(volumeValue)
        let normalized = normalizeMeasurement(diameter)
        input.volumeMm3 = volumeValue
        input.useVolume = true
        volumeEquivalentMm = normalized
        input.sizeMm = normalized
        updateGrowthStatus()
    }

    private func syncSizeTextFromAxisMean() {
        if let mean = axisMeanMm, useAxisMeasurements {
            sizeText = formatSize(mean)
            return
        }
        if let mean = volumeEquivalentMm, useVolumeMeasurements {
            sizeText = formatSize(mean)
            return
        }
    }

    private func formatSize(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    private func normalizeMeasurement(_ value: Double) -> Double {
        (value * 10).rounded(.toNearestOrAwayFromZero) / 10
    }

    private func parseRawDouble(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private func parseInt(_ text: String) -> Int? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(normalized)
    }

    private func updateGrowthStatus() {
        guard useGrowthCalculator, input.ctStatus == .followUp else {
            growthSummary = nil
            return
        }
        guard let currentSize = input.sizeMm, currentSize > 0,
              let priorSize = parseDouble(priorSizeText), priorSize > 0 else {
            growthSummary = "Enter prior and current sizes to calculate growth."
            return
        }
        guard currentDate > priorDate else {
            growthSummary = "Enter a valid date interval."
            return
        }
        let dayCount = Calendar.current.dateComponents([.day], from: priorDate, to: currentDate).day ?? 0
        let days = max(0, dayCount)
        let months = Double(days) / 30.44
        let delta = currentSize - priorSize
        let withinTwelveMonths = days <= 365
        let isGrowing = withinTwelveMonths && delta > 1.5
        if withinTwelveMonths {
            let newStatus: NoduleStatus = isGrowing ? .growing : .stable
            if input.noduleStatus != newStatus {
                input.noduleStatus = newStatus
            }
        }
        let deltaText = String(format: "%+.1f", delta)
        let monthsText = String(format: "%.1f", months)
        if withinTwelveMonths {
            let statusText = isGrowing ? "Growing" : "Stable"
            growthSummary = "Delta \(deltaText) mm in \(monthsText) months -> \(statusText)"
        } else {
            growthSummary = "Delta \(deltaText) mm in \(monthsText) months -> Interval > 12 months. Review manually."
        }
    }
}
