import SwiftUI
import Combine

@MainActor
class LungRADSViewModel: ObservableObject {
    typealias CalculationScheduler = (@escaping @MainActor () -> Void) -> Void

    @Published var input = LungRADSInput() {
        didSet { scheduleCalculation() }
    }
    @Published var result: LungRADSResult?
    @Published var sizeText: String = "" {
        didSet {
            guard !useVolumeMeasurements else { return }
            input.sizeMm = parseDouble(sizeText)
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
        didSet { scheduleCalculation() }
    }
    @Published var priorSizeText: String = "" {
        didSet { scheduleCalculation() }
    }
    @Published var priorDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date() {
        didSet { scheduleCalculation() }
    }
    @Published var currentDate: Date = Date() {
        didSet { scheduleCalculation() }
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

    private var isCalculationScheduled = false
    private var isCalculating = false
    private let calculationScheduler: CalculationScheduler

    init(calculationScheduler: CalculationScheduler? = nil) {
        self.calculationScheduler = calculationScheduler ?? Self.defaultCalculationScheduler
    }

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
        isCalculationScheduled = false
        performScheduledCalculation()
    }

    private func scheduleCalculation() {
        guard !isCalculationScheduled, !isCalculating else { return }
        isCalculationScheduled = true

        calculationScheduler { [weak self] in
            self?.performCalculationIfScheduled()
        }
    }

    private func performCalculationIfScheduled() {
        guard isCalculationScheduled else { return }
        performScheduledCalculation()
    }

    private func performScheduledCalculation() {
        isCalculating = true
        defer {
            isCalculating = false
            isCalculationScheduled = false
        }

        let growthStatus = LungRADSGrowthStatusCalculator.calculate(
            input: input,
            isEnabled: useGrowthCalculator,
            priorSizeMm: parseDouble(priorSizeText),
            priorDate: priorDate,
            currentDate: currentDate
        )
        growthSummary = growthStatus.summary
        if let noduleStatus = growthStatus.noduleStatus, input.noduleStatus != noduleStatus {
            input.noduleStatus = noduleStatus
        }

        guard hasRequiredInputsForCalculation else {
            result = nil
            return
        }
        result = LungRADSCalculator.calculate(input: input)
    }

    private static let defaultCalculationScheduler: CalculationScheduler = { action in
        Task { @MainActor in
            action()
        }
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
    }

    private func updateSizeFromVolume() {
        guard useVolumeMeasurements else { return }
        guard let volumeValue = parseRawDouble(volumeText),
              volumeValue > 0 else {
            input.volumeMm3 = nil
            input.sizeMm = nil
            volumeEquivalentMm = nil
            return
        }
        let diameter = LungRADSVolumeConverter.equivalentDiameter(volumeValue)
        let normalized = normalizeMeasurement(diameter)
        input.volumeMm3 = volumeValue
        input.useVolume = true
        volumeEquivalentMm = normalized
        input.sizeMm = normalized
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

    private var hasRequiredInputsForCalculation: Bool {
        if hasShortcutCategorization {
            return true
        }

        guard hasPrimaryMeasurement else {
            return false
        }

        switch input.noduleType {
        case .partSolid, .atypicalCyst:
            return hasSolidComponentMeasurement
        default:
            return true
        }
    }

    private var hasShortcutCategorization: Bool {
        input.ctStatus == .incomplete ||
        input.ctStatus == .awaitingComparison ||
        input.noduleType == .noNodule ||
        input.hasInflammatoryFindings ||
        input.hasBenignCalcification ||
        input.hasMacroscopicFat ||
        input.noduleType == .airway ||
        input.noduleStatus == .resolved
    }

    private var hasPrimaryMeasurement: Bool {
        if useVolumeMeasurements {
            return input.volumeMm3 != nil
        }
        if useAxisMeasurements {
            return axisMeanMm != nil
        }
        return input.sizeMm != nil
    }

    private var hasSolidComponentMeasurement: Bool {
        let normalized = solidComponentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return false }
        return input.solidComponentMm != nil
    }
}
