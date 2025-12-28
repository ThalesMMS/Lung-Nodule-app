import Foundation

enum NoduleType: String, CaseIterable, Identifiable {
    case solid = "Solid"
    case pureGGO = "Pure GGO"
    case partSolid = "Part-Solid"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .solid: return "Entirely soft-tissue attenuation nodule"
        case .pureGGO: return "Ground-glass opacity with no solid component"
        case .partSolid: return "Ground-glass opacity with measurable solid component"
        }
    }
}

enum PatientRisk: String, CaseIterable, Identifiable {
    case low = "Low Risk"
    case high = "High Risk"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .low: return "Minimal or absent history of smoking and other known risk factors."
        case .high: return "History of smoking or other known risk factors."
        }
    }
    
    var detailedFactors: String {
        "• Smoking history (current or former)\n• Asbestos/radon/uranium exposure\n• Family history of lung cancer (first-degree relative)\n• Personal history of lung cancer\n• COPD or pulmonary fibrosis"
    }
}

enum FleischnerSize: String, CaseIterable, Identifiable {
    case lessThanSix = "< 6 mm"
    case sixToEight = "6 - 8 mm"
    case greaterThanEight = "> 8 mm"
    
    var id: String { self.rawValue }
    
    var numericValue: Double {
        switch self {
        case .lessThanSix: return 4.0
        case .sixToEight: return 7.0
        case .greaterThanEight: return 10.0
        }
    }
}

enum FleischnerSolidComponentSize: String, CaseIterable, Identifiable {
    case none = "None/Not Applicable"
    case lessThanSix = "< 6 mm"
    case sixOrMore = "≥ 6 mm"
    
    var id: String { self.rawValue }
}

struct FleischnerInput {
    var noduleType: NoduleType = .solid
    var sizeCategory: FleischnerSize = .lessThanSix
    var solidComponentSize: FleischnerSolidComponentSize = .none
    var risk: PatientRisk = .low
    var isMultiple: Bool = false
}

struct FleischnerRecommendation {
    let recommendation: String
    let followUpInterval: String?
    let additionalNotes: String?
    let reference: String = "Fleischner Society 2017 Guidelines"
    
    init(recommendation: String, followUpInterval: String? = nil, additionalNotes: String? = nil) {
        self.recommendation = recommendation
        self.followUpInterval = followUpInterval
        self.additionalNotes = additionalNotes
    }
}

struct FleischnerCalculator {
    static func calculate(input: FleischnerInput) -> FleischnerRecommendation {
        if input.isMultiple {
            return calculateMultiple(input: input)
        } else {
            return calculateSingle(input: input)
        }
    }
    
    // MARK: - Single Nodule Logic
    
    private static func calculateSingle(input: FleischnerInput) -> FleischnerRecommendation {
        switch input.noduleType {
        case .solid:
            return calculateSingleSolid(size: input.sizeCategory, risk: input.risk)
        case .pureGGO:
            return calculateSinglePureGGO(size: input.sizeCategory)
        case .partSolid:
            return calculateSinglePartSolid(totalSize: input.sizeCategory, solidSize: input.solidComponentSize)
        }
    }
    
    // MARK: Solitary Solid Nodule (Fleischner 2017 Table 1)
    private static func calculateSingleSolid(size: FleischnerSize, risk: PatientRisk) -> FleischnerRecommendation {
        switch size {
        case .lessThanSix:
            if risk == .low {
                return FleischnerRecommendation(
                    recommendation: "No routine follow-up.",
                    followUpInterval: nil,
                    additionalNotes: "Nodules < 6mm in low-risk patients have very low malignancy risk (<1%)."
                )
            } else {
                return FleischnerRecommendation(
                    recommendation: "Optional CT at 12 months.",
                    followUpInterval: "Optional CT at 12 months",
                    additionalNotes: "Optional follow-up may be considered in high-risk patients with suspicious morphology, upper lobe location, or both."
                )
            }
        case .sixToEight:
            if risk == .low {
                return FleischnerRecommendation(
                    recommendation: "CT at 6-12 months, then consider CT at 18-24 months.",
                    followUpInterval: "6-12 months",
                    additionalNotes: "Follow-up at 18-24 months is optional in low-risk patients if unchanged at initial follow-up."
                )
            } else {
                return FleischnerRecommendation(
                    recommendation: "CT at 6-12 months, then CT at 18-24 months.",
                    followUpInterval: "6-12 months",
                    additionalNotes: "Both follow-up exams recommended for high-risk patients."
                )
            }
        case .greaterThanEight:
            return FleischnerRecommendation(
                recommendation: "Consider CT at 3 months; PET/CT or tissue sampling if growth persists.",
                followUpInterval: "3 months or immediate workup",
                additionalNotes: "Management depends on volume, morphology, patient preferences, and comorbidities. PET/CT may help characterize nodules ≥ 8mm."
            )
        }
    }
    
    // MARK: Solitary Pure Ground-Glass Nodule (Fleischner 2017 Table 2)
    private static func calculateSinglePureGGO(size: FleischnerSize) -> FleischnerRecommendation {
        switch size {
        case .lessThanSix:
            return FleischnerRecommendation(
                recommendation: "No routine follow-up.",
                followUpInterval: nil,
                additionalNotes: "Pure ground-glass nodules < 6mm have very low risk. If multiple, see multiple subsolid nodule recommendations."
            )
        case .sixToEight, .greaterThanEight:
            return FleischnerRecommendation(
                recommendation: "CT at 6-12 months to confirm persistence, then CT every 2 years until 5 years.",
                followUpInterval: "6-12 months initially",
                additionalNotes: "Pure GGOs ≥ 6mm may represent adenocarcinoma in situ or minimally invasive adenocarcinoma. Long-term surveillance (5 years) recommended due to slow growth pattern."
            )
        }
    }
    
    // MARK: Solitary Part-Solid Nodule (Fleischner 2017 Table 2)
    private static func calculateSinglePartSolid(totalSize: FleischnerSize, solidSize: FleischnerSolidComponentSize) -> FleischnerRecommendation {
        switch totalSize {
        case .lessThanSix:
            return FleischnerRecommendation(
                recommendation: "No routine follow-up.",
                followUpInterval: nil,
                additionalNotes: "Part-solid nodules < 6mm total size have very low malignancy risk."
            )
        case .sixToEight, .greaterThanEight:
            switch solidSize {
            case .none, .lessThanSix:
                return FleischnerRecommendation(
                    recommendation: "CT at 3-6 months to confirm persistence. If unchanged and solid component remains < 6mm, annual CT for 5 years.",
                    followUpInterval: "3-6 months initially",
                    additionalNotes: "Part-solid nodules with solid component < 6mm are likely preinvasive lesions. Annual surveillance for 5 years monitors for development of invasive component."
                )
            case .sixOrMore:
                return FleischnerRecommendation(
                    recommendation: "CT at 3-6 months to confirm persistence. If growth occurs or solid component is ≥ 6mm, consider PET/CT or tissue sampling.",
                    followUpInterval: "3-6 months initially",
                    additionalNotes: "Part-solid nodules with solid component ≥ 6mm have higher malignancy risk and may warrant PET/CT or tissue sampling. Consider biopsy or surgical resection based on clinical context."
                )
            }
        }
    }
    
    // MARK: - Multiple Nodule Logic
    
    private static func calculateMultiple(input: FleischnerInput) -> FleischnerRecommendation {
        switch input.noduleType {
        case .solid:
            return calculateMultipleSolid(size: input.sizeCategory, risk: input.risk)
        case .pureGGO:
            return calculateMultiplePureGGO(size: input.sizeCategory)
        case .partSolid:
            return calculateMultipleSubsolid()
        }
    }
    
    // MARK: Multiple Solid Nodules (Fleischner 2017 Table 1)
    private static func calculateMultipleSolid(size: FleischnerSize, risk: PatientRisk) -> FleischnerRecommendation {
        switch size {
        case .lessThanSix:
            if risk == .low {
                return FleischnerRecommendation(
                    recommendation: "No routine follow-up.",
                    followUpInterval: nil,
                    additionalNotes: "Multiple solid nodules < 6mm in low-risk patients are typically benign (granulomas, intrapulmonary lymph nodes)."
                )
            } else {
                return FleischnerRecommendation(
                    recommendation: "Optional CT at 12 months.",
                    followUpInterval: "Optional CT at 12 months",
                    additionalNotes: "Optional follow-up at 12 months may be considered in high-risk patients."
                )
            }
        case .sixToEight, .greaterThanEight:
            if risk == .low {
                return FleischnerRecommendation(
                    recommendation: "CT at 3-6 months, then consider CT at 18-24 months.",
                    followUpInterval: "3-6 months",
                    additionalNotes: "Use the most suspicious nodule as a guide. The dominant/most suspicious nodule may not necessarily be the largest. Second follow-up at 18-24 months is optional in low-risk if stable."
                )
            } else {
                return FleischnerRecommendation(
                    recommendation: "CT at 3-6 months, then CT at 18-24 months.",
                    followUpInterval: "3-6 months",
                    additionalNotes: "Use the most suspicious nodule as a guide. The dominant/most suspicious nodule may not necessarily be the largest. Both follow-ups recommended for high-risk patients."
                )
            }
        }
    }
    
    // MARK: Multiple Pure GGO Nodules (Fleischner 2017 Table 2)
    private static func calculateMultiplePureGGO(size: FleischnerSize) -> FleischnerRecommendation {
        switch size {
        case .lessThanSix:
            return FleischnerRecommendation(
                recommendation: "CT at 3-6 months. If stable, consider CT at 2 and 4 years.",
                followUpInterval: "3-6 months initially",
                additionalNotes: "Multiple pure GGOs < 6mm warrant closer initial follow-up than solitary nodules. Extended surveillance at 2 and 4 years monitors for interval change."
            )
        case .sixToEight, .greaterThanEight:
            return FleischnerRecommendation(
                recommendation: "CT at 3-6 months. Subsequent management based on the most suspicious nodule.",
                followUpInterval: "3-6 months initially",
                additionalNotes: "For dominant nodule ≥ 6mm, follow single pure GGO guidelines. Consider multifocal adenocarcinoma spectrum disease."
            )
        }
    }
    
    // MARK: Multiple Subsolid Nodules (including Part-Solid)
    private static func calculateMultipleSubsolid() -> FleischnerRecommendation {
        return FleischnerRecommendation(
            recommendation: "CT at 3-6 months. Subsequent management based on the most suspicious nodule.",
            followUpInterval: "3-6 months initially",
            additionalNotes: "For multiple part-solid nodules, apply single part-solid nodule guidelines to the dominant/most suspicious nodule. If any nodule develops solid component ≥ 6mm, consider PET/CT or tissue sampling."
        )
    }
}
