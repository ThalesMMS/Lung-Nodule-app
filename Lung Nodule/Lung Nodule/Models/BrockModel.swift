import Foundation

enum BrockNoduleType: String, CaseIterable, Identifiable {
    case nonsolid = "Non-solid (GG)"
    case partSolid = "Part-solid"
    case solid = "Solid"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .nonsolid:
            return "Pure ground-glass / non-solid nodule"
        case .partSolid:
            return "Mixed ground-glass and solid components"
        case .solid:
            return "Entirely soft-tissue attenuation nodule"
        }
    }

    static func from(lungRADSType: LungRADSNoduleType) -> BrockNoduleType? {
        switch lungRADSType {
        case .solid, .juxtapleural, .perifissural:
            return .solid
        case .groundGlass:
            return .nonsolid
        case .partSolid:
            return .partSolid
        case .noNodule, .airway, .atypicalCyst:
            return nil
        }
    }
}

enum BrockRiskCategory: String {
    case low = "Low"
    case intermediate = "Intermediate"
    case high = "High"
}

struct BrockInput {
    let age: Int
    let isFemale: Bool
    let noduleSizeMm: Double
    let noduleType: BrockNoduleType
    let upperLobe: Bool
    let noduleCount: Int
    let spiculation: Bool
    let familyHistory: Bool
    let emphysema: Bool
}

struct BrockResult {
    let malignancyProbability: Double
    let riskCategory: BrockRiskCategory
    let interpretation: String
    let reference: String
}

enum BrockValidationError: Equatable {
    case ageBelowMinimum
    case noduleSizeOutOfRange
    case noduleCountBelowMinimum

    var message: String {
        switch self {
        case .ageBelowMinimum:
            return "Age must be 18 years or older."
        case .noduleSizeOutOfRange:
            return "Nodule size must be between 3 and 30 mm."
        case .noduleCountBelowMinimum:
            return "Nodule count must be at least 1."
        }
    }
}

struct BrockCalculator {
    static let referenceText = "McWilliams et al. Probability of cancer in pulmonary nodules detected on first screening CT. N Engl J Med. 2013;369:910-919."

    static func validate(input: BrockInput) -> BrockValidationError? {
        guard input.age >= 18 else { return .ageBelowMinimum }
        guard input.noduleSizeMm >= 3, input.noduleSizeMm <= 30 else { return .noduleSizeOutOfRange }
        guard input.noduleCount >= 1 else { return .noduleCountBelowMinimum }
        return nil
    }

    static func calculate(input: BrockInput) -> BrockResult? {
        calculateProbability(input: input)
    }

    static func calculateProbability(input: BrockInput) -> BrockResult? {
        guard validate(input: input) == nil else { return nil }

        let probability = rawProbability(input: input)
        let riskCategory = riskCategory(for: probability)
        return BrockResult(
            malignancyProbability: probability,
            riskCategory: riskCategory,
            interpretation: interpretation(for: riskCategory),
            reference: referenceText
        )
    }

    private static func rawProbability(input: BrockInput) -> Double {
        let ageTerm = 0.0287 * (Double(input.age) - 62.0)
        let sexTerm = input.isFemale ? 0.6011 : 0.0
        let familyHistoryTerm = input.familyHistory ? 0.2961 : 0.0
        let emphysemaTerm = input.emphysema ? 0.2953 : 0.0
        let spiculationTerm = input.spiculation ? 0.7729 : 0.0
        let upperLobeTerm = input.upperLobe ? 0.6581 : 0.0
        let noduleTypeTerm: Double
        switch input.noduleType {
        case .nonsolid:
            noduleTypeTerm = -0.1276
        case .partSolid:
            noduleTypeTerm = 0.377
        case .solid:
            noduleTypeTerm = 0.0
        }

        let sizeTerm = -5.3854 * (pow(input.noduleSizeMm / 10.0, -0.5) - 1.58113883)
        let countTerm = -0.0824 * (Double(input.noduleCount) - 4.0)
        let logOdds = -6.7892
            + ageTerm
            + sexTerm
            + familyHistoryTerm
            + emphysemaTerm
            + sizeTerm
            + noduleTypeTerm
            + upperLobeTerm
            + countTerm
            + spiculationTerm

        let odds = exp(logOdds)
        return (odds / (1.0 + odds)) * 100.0
    }

    private static func riskCategory(for probability: Double) -> BrockRiskCategory {
        if probability < 5.0 {
            return .low
        }
        if probability < 65.0 {
            return .intermediate
        }
        return .high
    }

    private static func interpretation(for riskCategory: BrockRiskCategory) -> String {
        switch riskCategory {
        case .low:
            return "Low estimated malignancy probability by the Brock full model."
        case .intermediate:
            return "Intermediate estimated malignancy probability by the Brock full model."
        case .high:
            return "High estimated malignancy probability by the Brock full model."
        }
    }
}
