import Foundation

enum LungRADSCategory: String, Comparable {
    case cat0 = "0"
    case cat1 = "1"
    case cat2 = "2"
    case cat3 = "3"
    case cat4A = "4A"
    case cat4B = "4B"
    case cat4X = "4X"
    case s = "S"
    
    var riskLevel: Int {
        switch self {
        case .cat0: return 0
        case .cat1: return 1
        case .cat2: return 2
        case .cat3: return 3
        case .cat4A: return 4
        case .cat4B: return 5
        case .cat4X: return 6
        case .s: return -1
        }
    }
    
    var probabilityOfMalignancy: String {
        switch self {
        case .cat0: return "N/A"
        case .cat1: return "< 1%"
        case .cat2: return "< 1%"
        case .cat3: return "1-2%"
        case .cat4A: return "5-15%"
        case .cat4B: return "> 15%"
        case .cat4X: return "> 15%"
        case .s: return "N/A"
        }
    }
    
    var description: String {
        switch self {
        case .cat0: return "Incomplete"
        case .cat1: return "Negative"
        case .cat2: return "Benign Appearance or Behavior"
        case .cat3: return "Probably Benign"
        case .cat4A: return "Suspicious"
        case .cat4B: return "Very Suspicious"
        case .cat4X: return "Highly Suspicious"
        case .s: return "Other Clinically Significant Findings"
        }
    }
    
    static func < (lhs: LungRADSCategory, rhs: LungRADSCategory) -> Bool {
        return lhs.riskLevel < rhs.riskLevel
    }
}

enum LungRADSNoduleType: String, CaseIterable, Identifiable {
    case solid = "Solid"
    case partSolid = "Part-Solid"
    case groundGlass = "Non-Solid (GGO)"
    case juxtapleural = "Juxtapleural Solid"
    case perifissural = "Perifissural"
    case airway = "Endobronchial/Airway"
    case atypicalCyst = "Atypical Pulmonary Cyst"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .solid: return "Entirely soft-tissue attenuation nodule"
        case .partSolid: return "Mixed ground-glass and solid components"
        case .groundGlass: return "Pure ground-glass opacity (non-solid)"
        case .juxtapleural: return "Solid nodule abutting pleural surface"
        case .perifissural: return "Triangular/lentiform nodule attached to fissure"
        case .airway: return "Nodule within or adjacent to airway"
        case .atypicalCyst: return "Cyst with wall thickening or nodularity"
        }
    }
}

enum LungRADSSize: String, CaseIterable, Identifiable {
    case lessThanFour = "< 4 mm"
    case fourToSix = "4-5.9 mm"
    case sixToEight = "6-7.9 mm"
    case eightToFifteen = "8-14.9 mm"
    case fifteenToThirty = "15-29.9 mm"
    case thirtyPlus = "≥ 30 mm"
    
    var id: String { self.rawValue }
    
    var midpoint: Double {
        switch self {
        case .lessThanFour: return 2.5
        case .fourToSix: return 5.0
        case .sixToEight: return 7.0
        case .eightToFifteen: return 11.0
        case .fifteenToThirty: return 22.0
        case .thirtyPlus: return 35.0
        }
    }
    
    var lowerBound: Double {
        switch self {
        case .lessThanFour: return 0
        case .fourToSix: return 4.0
        case .sixToEight: return 6.0
        case .eightToFifteen: return 8.0
        case .fifteenToThirty: return 15.0
        case .thirtyPlus: return 30.0
        }
    }
}

enum LungRADSSolidComponentSize: String, CaseIterable, Identifiable {
    case none = "None"
    case lessThanFour = "< 4 mm"
    case fourToSix = "4-5.9 mm"
    case sixToEight = "6-7.9 mm"
    case eightPlus = "≥ 8 mm"
    
    var id: String { self.rawValue }
    
    var midpoint: Double {
        switch self {
        case .none: return 0
        case .lessThanFour: return 2.0
        case .fourToSix: return 5.0
        case .sixToEight: return 7.0
        case .eightPlus: return 10.0
        }
    }
}

enum CTStatus: String, CaseIterable, Identifiable {
    case baseline = "Baseline CT"
    case followUp = "Follow-Up CT"
    case awaitingComparison = "Awaiting Comparison CT"
    case incomplete = "Incomplete CT"
    
    var id: String { self.rawValue }
}

enum NoduleStatus: String, CaseIterable, Identifiable {
    case baseline = "Baseline (no prior)"
    case stable = "Stable"
    case newNodule = "New"
    case growing = "Growing (≥1.5mm increase)"
    case slowGrowing = "Slow Growing (GGO)"
    case resolved = "Resolved"
    
    var id: String { self.rawValue }
}

struct LungRADSInput {
    var noduleType: LungRADSNoduleType = .solid
    var sizeCategory: LungRADSSize = .lessThanFour
    var solidComponentSize: LungRADSSolidComponentSize = .none
    var ctStatus: CTStatus = .baseline
    var noduleStatus: NoduleStatus = .baseline
    var hasBenignCalcification: Bool = false
    var hasMacroscopicFat: Bool = false
    var hasInflammatoryFindings: Bool = false
    var hasAdditionalSuspiciousFeatures: Bool = false
    var hasSModifierFindings: Bool = false
    var isMultiple: Bool = false
    
    var isBaseline: Bool {
        return ctStatus == .baseline
    }
    
    var isNew: Bool {
        return noduleStatus == .newNodule
    }
    
    var isGrowing: Bool {
        return noduleStatus == .growing
    }
    
    var isStable: Bool {
        return noduleStatus == .stable || noduleStatus == .slowGrowing
    }
}

struct LungRADSResult {
    let category: LungRADSCategory
    let baseCategory: LungRADSCategory?
    let management: String
    let probabilityOfMalignancy: String
    let additionalNotes: String?
    let isReclassified: Bool
    
    init(category: LungRADSCategory,
         baseCategory: LungRADSCategory? = nil,
         management: String,
         probabilityOfMalignancy: String? = nil,
         additionalNotes: String? = nil,
         isReclassified: Bool = false) {
        self.category = category
        self.baseCategory = baseCategory
        self.management = management
        self.probabilityOfMalignancy = probabilityOfMalignancy ?? category.probabilityOfMalignancy
        self.additionalNotes = additionalNotes
        self.isReclassified = isReclassified
    }
}

struct LungRADSCalculator {
    
    // MARK: - Main Calculator Entry Point
    
    static func calculate(input: LungRADSInput) -> LungRADSResult {
        var result: LungRADSResult

        // Category 0: Incomplete
        if input.ctStatus == .incomplete {
            result = LungRADSResult(
                category: .cat0,
                management: "Additional imaging or comparison required. Prior chest CT needed for comparison OR recall for complete exam.",
                additionalNotes: "Category 0 assigned when exam is technically inadequate or prior CT needed for comparison."
            )
        } else if input.ctStatus == .awaitingComparison {
            // Category 0: Awaiting Comparison
            result = LungRADSResult(
                category: .cat0,
                management: "Comparison CT required. Obtain prior exam for comparison before final categorization.",
                additionalNotes: "Category 0 pending prior CT review."
            )
        } else if input.hasInflammatoryFindings {
            // Category 0: Suspected infection/inflammation
            result = LungRADSResult(
                category: .cat0,
                management: "Short-term follow-up LDCT in 1-3 months to confirm resolution.",
                additionalNotes: "Findings suggest infection or inflammation. Short-term follow-up recommended."
            )
        } else if input.hasBenignCalcification {
            // Category 1: Benign calcification or fat (hamartoma)
            result = LungRADSResult(
                category: .cat1,
                management: "Continue annual screening with LDCT in 12 months.",
                additionalNotes: "Benign calcification pattern (complete, central, popcorn, or concentric rings) indicates benign nodule."
            )
        } else if input.hasMacroscopicFat {
            result = LungRADSResult(
                category: .cat1,
                management: "Continue annual screening with LDCT in 12 months.",
                additionalNotes: "Macroscopic fat within nodule indicates hamartoma (benign)."
            )
        } else if input.noduleStatus == .resolved {
            // Category 2: Resolved nodule
            result = LungRADSResult(
                category: .cat2,
                management: "Continue annual screening with LDCT in 12 months.",
                additionalNotes: "Resolution of previously seen nodule indicates benign etiology."
            )
        } else {
            // Route to specific nodule type calculator
            switch input.noduleType {
            case .solid:
                result = calculateSolid(input: input)
            case .partSolid:
                result = calculatePartSolid(input: input)
            case .groundGlass:
                result = calculateGGO(input: input)
            case .perifissural, .juxtapleural:
                // Per Lung-RADS v2022: Both perifissural and juxtapleural with benign criteria use same logic
                result = calculatePerifissural(input: input)
            case .airway:
                result = calculateAirway(input: input)
            case .atypicalCyst:
                result = calculateAtypicalCyst(input: input)
            }

            // Apply 4X upgrade if additional suspicious features present
            // Per Lung-RADS v2022: Category 3, 4A, or 4B + suspicious features = 4X
            if input.hasAdditionalSuspiciousFeatures && (result.category == .cat3 || result.category == .cat4A || result.category == .cat4B) {
                result = upgrade4X(from: result)
            }
        }

        if input.isMultiple {
            result = applyMultipleNodulesNote(to: result)
        }
        
        return result
    }
    
    // MARK: - Solid Nodule (Lung-RADS v2022)
    
    private static func calculateSolid(input: LungRADSInput) -> LungRADSResult {
        let size = input.sizeCategory.lowerBound
        
        // Baseline CT scenarios
        if input.isBaseline {
            return calculateSolidBaseline(size: size, input: input)
        }
        
        // Follow-up CT scenarios
        return calculateSolidFollowUp(size: size, input: input)
    }
    
    private static func calculateSolidBaseline(size: Double, input: LungRADSInput) -> LungRADSResult {
        if size < 6 {
            // < 6mm at baseline = Category 2
            return LungRADSResult(
                category: .cat2,
                management: "Continue annual screening with LDCT in 12 months.",
                additionalNotes: "Solid nodule < 6mm at baseline. Very low malignancy probability."
            )
        } else if size >= 6 && size < 8 {
            // 6-7.9mm at baseline = Category 3
            return LungRADSResult(
                category: .cat3,
                management: "6-month LDCT.",
                additionalNotes: "Solid nodule 6-7.9mm at baseline. Short-term follow-up recommended."
            )
        } else if size >= 8 && size < 15 {
            // 8-14.9mm at baseline = Category 4A
            return LungRADSResult(
                category: .cat4A,
                management: "3-month LDCT; PET/CT may be used when solid component is ≥ 8mm.",
                additionalNotes: "Solid nodule 8-14.9mm at baseline. Suspicious. Consider PET/CT if ≥ 8mm solid component."
            )
        } else {
            // ≥ 15mm at baseline = Category 4B
            return LungRADSResult(
                category: .cat4B,
                management: "Chest CT with or without contrast, PET/CT and/or tissue sampling depending on probability of malignancy and comorbidities.",
                additionalNotes: "Solid nodule ≥ 15mm at baseline. Very suspicious. Further workup warranted."
            )
        }
    }

    private static func calculateSolidFollowUp(size: Double, input: LungRADSInput) -> LungRADSResult {
        // Slow-growing solid nodules on follow-up remain suspicious
        if input.noduleStatus == .slowGrowing {
            return LungRADSResult(
                category: .cat4B,
                management: "Chest CT with or without contrast, PET/CT and/or tissue sampling.",
                additionalNotes: "Slow-growing solid nodule on follow-up. Suspicious despite sub-threshold growth."
            )
        }

        // NEW solid nodules on follow-up
        if input.isNew {
            if size < 4 {
                // New < 4mm = Category 2
                return LungRADSResult(
                    category: .cat2,
                    management: "Continue annual screening with LDCT in 12 months.",
                    additionalNotes: "New solid nodule < 4mm. Continue routine screening."
                )
            } else if size >= 4 && size < 6 {
                // New 4-5.9mm = Category 3
                return LungRADSResult(
                    category: .cat3,
                    management: "6-month LDCT.",
                    additionalNotes: "New solid nodule 4-5.9mm. Short-term follow-up to assess stability."
                )
            } else if size >= 6 && size < 8 {
                // New 6-7.9mm = Category 4A
                return LungRADSResult(
                    category: .cat4A,
                    management: "3-month LDCT; PET/CT may be used.",
                    additionalNotes: "New solid nodule 6-7.9mm. Suspicious. Short-term follow-up or PET/CT."
                )
            } else {
                // New ≥ 8mm = Category 4B
                return LungRADSResult(
                    category: .cat4B,
                    management: "Chest CT with or without contrast, PET/CT and/or tissue sampling.",
                    additionalNotes: "New solid nodule ≥ 8mm. Very suspicious. Further workup warranted."
                )
            }
        }
        
        // GROWING solid nodules
        if input.isGrowing {
            if size < 8 {
                // Growing < 8mm = Category 4A
                return LungRADSResult(
                    category: .cat4A,
                    management: "3-month LDCT; PET/CT may be used if ≥ 8mm.",
                    additionalNotes: "Growing solid nodule < 8mm. Growth defined as ≥ 1.5mm increase. Suspicious."
                )
            } else {
                // Growing ≥ 8mm = Category 4B
                return LungRADSResult(
                    category: .cat4B,
                    management: "Chest CT with or without contrast, PET/CT and/or tissue sampling.",
                    additionalNotes: "Growing solid nodule ≥ 8mm. Very suspicious. Further workup warranted."
                )
            }
        }
        
        // STABLE solid nodules - potential downgrade
        if input.isStable {
            // Stable at 3-month follow-up: 4A → 3
            // Stable at 6-month follow-up: 3 → 2
            if size >= 6 && size < 8 {
                return LungRADSResult(
                    category: .cat2,
                    baseCategory: .cat3,
                    management: "Continue annual screening with LDCT in 12 months.",
                    additionalNotes: "Category 3 → 2: Solid nodule 6-7.9mm stable on follow-up.",
                    isReclassified: true
                )
            } else if size >= 8 && size < 15 {
                return LungRADSResult(
                    category: .cat3,
                    baseCategory: .cat4A,
                    management: "6-month LDCT.",
                    additionalNotes: "Category 4A → 3: Solid nodule 8-14.9mm stable at 3-month follow-up. Continue 6-month surveillance.",
                    isReclassified: true
                )
            }
        }
        
        // Default: unchanged nodule on follow-up, use baseline thresholds
        return calculateSolidBaseline(size: size, input: input)
    }
    
    // MARK: - Part-Solid Nodule (Lung-RADS v2022)
    
    private static func calculatePartSolid(input: LungRADSInput) -> LungRADSResult {
        let totalSize = input.sizeCategory.lowerBound
        let solidSize = input.solidComponentSize.midpoint
        
        // Solid component resolved = Category 2
        if input.solidComponentSize == .none && !input.isBaseline {
            return LungRADSResult(
                category: .cat2,
                management: "Continue annual screening with LDCT in 12 months.",
                additionalNotes: "Solid component resolved. Now pure GGO. Benign behavior."
            )
        }
        
        // NEW part-solid nodule (Lung-RADS 2022)
        if input.isNew {
            // New part-solid <6mm = Category 3
            if totalSize < 6 {
                return LungRADSResult(
                    category: .cat3,
                    management: "6-month LDCT.",
                    additionalNotes: "New part-solid nodule < 6mm total. Short-term follow-up recommended."
                )
            }
            // New part-solid with solid < 4mm = Category 4A
            if solidSize < 4 {
                return LungRADSResult(
                    category: .cat4A,
                    management: "3-month LDCT.",
                    additionalNotes: "New part-solid nodule with solid component < 4mm. Suspicious."
                )
            } else {
                // New part-solid with solid ≥ 4mm = Category 4B
                return LungRADSResult(
                    category: .cat4B,
                    management: "Chest CT with or without contrast, PET/CT and/or tissue sampling.",
                    additionalNotes: "New part-solid nodule with solid component ≥ 4mm. Very suspicious."
                )
            }
        }

        // Slow-growing part-solid nodules on follow-up remain suspicious
        if !input.isBaseline && input.noduleStatus == .slowGrowing {
            return LungRADSResult(
                category: .cat4B,
                management: "Chest CT with or without contrast, PET/CT and/or tissue sampling.",
                additionalNotes: "Slow-growing part-solid nodule on follow-up. Suspicious despite sub-threshold growth."
            )
        }

        // Total size < 6mm at baseline = Category 2
        if totalSize < 6 {
            return LungRADSResult(
                category: .cat2,
                management: "Continue annual screening with LDCT in 12 months.",
                additionalNotes: "Part-solid nodule < 6mm total size. Very low malignancy probability."
            )
        }

        // Baseline or growing part-solid by solid component size
        if solidSize < 6 {
            // Solid < 6mm = Category 3
            return LungRADSResult(
                category: .cat3,
                management: "6-month LDCT.",
                additionalNotes: "Part-solid nodule ≥ 6mm with solid component < 6mm. Short-term follow-up."
            )
        } else if solidSize >= 6 && solidSize < 8 {
            // Solid 6-7.9mm = Category 4A
            if input.isGrowing {
                return LungRADSResult(
                    category: .cat4A,
                    management: "3-month LDCT; PET/CT may be used.",
                    additionalNotes: "Growing part-solid with solid component 6-7.9mm. Suspicious."
                )
            }
            return LungRADSResult(
                category: .cat4A,
                management: "3-month LDCT; PET/CT may be used.",
                additionalNotes: "Part-solid nodule with solid component 6-7.9mm. Suspicious."
            )
        } else {
            // Solid ≥ 8mm = Category 4B
            return LungRADSResult(
                category: .cat4B,
                management: "Chest CT with or without contrast, PET/CT and/or tissue sampling.",
                additionalNotes: "Part-solid nodule with solid component ≥ 8mm. Very suspicious."
            )
        }
    }
    
    // MARK: - Non-Solid / GGO Nodule (Lung-RADS v2022)
    
    private static func calculateGGO(input: LungRADSInput) -> LungRADSResult {
        let size = input.sizeCategory.lowerBound
        
        // GGO < 30mm
        if size < 30 {
            if input.isNew {
                // New GGO < 30mm = Category 2 (may warrant short-term follow-up)
                return LungRADSResult(
                    category: .cat2,
                    management: "Continue annual screening with LDCT in 12 months.",
                    additionalNotes: "New non-solid (GGO) nodule < 30mm. Pure GGOs are typically slow-growing and indolent."
                )
            }
            
            // Baseline or stable GGO < 30mm = Category 2
            return LungRADSResult(
                category: .cat2,
                management: "Continue annual screening with LDCT in 12 months.",
                additionalNotes: "Non-solid (GGO) nodule < 30mm. Continue routine annual screening."
            )
        }
        
        // GGO ≥ 30mm
        if input.isBaseline || input.isNew {
            // New or baseline GGO ≥ 30mm = Category 3
            return LungRADSResult(
                category: .cat3,
                management: "6-month LDCT.",
                additionalNotes: "Non-solid (GGO) nodule ≥ 30mm. Large GGO warrants short-term follow-up. May represent AIS or MIA."
            )
        }
        
        // Stable/slow-growing ≥ 30mm GGO = Category 2
        if input.isStable || input.noduleStatus == .slowGrowing {
            return LungRADSResult(
                category: .cat2,
                management: "Continue annual screening with LDCT in 12 months.",
                additionalNotes: "Large GGO (≥ 30mm) with stable or slow growth. Pure GGOs are typically indolent even when large."
            )
        }
        
        // Default for ≥ 30mm
        return LungRADSResult(
            category: .cat3,
            management: "6-month LDCT.",
            additionalNotes: "Non-solid (GGO) nodule ≥ 30mm. Short-term follow-up recommended."
        )
    }
    
    // MARK: - Perifissural Nodule (Lung-RADS v2022)
    
    private static func calculatePerifissural(input: LungRADSInput) -> LungRADSResult {
        // Per Lung-RADS v2022: Perifissural/juxtapleural nodule with benign criteria <10mm = Category 2
        // (triangular/lentiform/ovoid, smooth margins, attached to fissure or pleural surface)
        
        // Size categories entirely <10mm: lessThanFour, fourToSix, sixToEight
        // Categories that include ≥10mm: eightToFifteen, fifteenToThirty, thirtyPlus
        let isLessThan10mm = input.sizeCategory == .lessThanFour || 
                             input.sizeCategory == .fourToSix || 
                             input.sizeCategory == .sixToEight
        
        if isLessThan10mm {
            // < 10mm with benign morphology = Category 2
            return LungRADSResult(
                category: .cat2,
                management: "Continue annual screening with LDCT in 12 months.",
                additionalNotes: "Perifissural nodule < 10mm with benign morphology. Likely intrapulmonary lymph node."
            )
        }
        
        // Atypical or ≥ 10mm: manage as solid nodule
        return calculateSolid(input: LungRADSInput(
            noduleType: .solid,
            sizeCategory: input.sizeCategory,
            solidComponentSize: input.solidComponentSize,
            ctStatus: input.ctStatus,
            noduleStatus: input.noduleStatus,
            hasBenignCalcification: input.hasBenignCalcification,
            hasMacroscopicFat: input.hasMacroscopicFat,
            hasInflammatoryFindings: input.hasInflammatoryFindings,
            hasAdditionalSuspiciousFeatures: input.hasAdditionalSuspiciousFeatures,
            hasSModifierFindings: input.hasSModifierFindings,
            isMultiple: input.isMultiple
        ))
    }
    
    // MARK: - Airway/Endobronchial Nodule (Lung-RADS v2022)
    
    private static func calculateAirway(input: LungRADSInput) -> LungRADSResult {
        let size = input.sizeCategory.lowerBound
        
        // Per Lung-RADS v2022:
        // - Subsegmental airway nodule tends to Category 2
        // - Segmental/proximal baseline = Category 4A
        // - Persistent at 3-month follow-up = Category 4B
        
        // Segmental or more proximal airway nodule (size ≥ 4mm as proxy)
        if size >= 4 {
            // Check if this is a follow-up with persistence (4B)
            if !input.isBaseline && (input.isStable || input.isGrowing || input.noduleStatus == .baseline) {
                // Persistent at follow-up = Category 4B
                return LungRADSResult(
                    category: .cat4B,
                    management: "Chest CT with or without contrast, PET/CT and/or tissue sampling. Consider bronchoscopy.",
                    additionalNotes: "Persistent endobronchial/airway nodule at follow-up. High suspicion. Bronchoscopy indicated."
                )
            }
            
            // Baseline segmental/proximal = Category 4A
            return LungRADSResult(
                category: .cat4A,
                management: "3-month LDCT. Consider bronchoscopy.",
                additionalNotes: "Endobronchial/airway nodule (segmental or more proximal). Short-term follow-up to assess persistence."
            )
        }
        
        // Subsegmental (< 4mm) = Category 2
        return LungRADSResult(
            category: .cat2,
            management: "Continue annual screening with LDCT in 12 months.",
            additionalNotes: "Subsegmental airway nodule < 4mm. May represent mucus or secretion. Continue routine screening."
        )
    }
    
    // MARK: - Atypical Pulmonary Cyst (Lung-RADS v2022)
    
    private static func calculateAtypicalCyst(input: LungRADSInput) -> LungRADSResult {
        let wallThickness = input.solidComponentSize.midpoint
        
        // Per Lung-RADS v2022:
        // - Baseline thick-walled (≥2mm) or multilocular cyst = Category 4A
        // - Growing wall thickness/nodularity = Category 4B
        // - New or increased opacity = Category 4B
        
        // Growing wall thickness/nodularity = Category 4B
        if input.isGrowing {
            return LungRADSResult(
                category: .cat4B,
                management: "Chest CT with or without contrast, PET/CT and/or tissue sampling.",
                additionalNotes: "Atypical pulmonary cyst with growing wall thickness or nodularity. Suspicious for cystic lung cancer."
            )
        }
        
        // Baseline thick-walled or multilocular cyst = Category 4A
        // (Using wallThickness as proxy - any atypical cyst at baseline gets 4A)
        if input.isBaseline || input.isNew {
            return LungRADSResult(
                category: .cat4A,
                management: "3-month LDCT.",
                additionalNotes: "Atypical pulmonary cyst (thick-walled or multilocular). Short-term follow-up to assess evolution."
            )
        }
        
        // Stable atypical cyst at follow-up
        return LungRADSResult(
            category: .cat4A,
            management: "3-month LDCT.",
            additionalNotes: "Atypical pulmonary cyst. Continue monitoring for evolution."
        )
    }

    // MARK: - Category 4X Upgrade
    
    private static func upgrade4X(from result: LungRADSResult) -> LungRADSResult {
        return LungRADSResult(
            category: .cat4X,
            baseCategory: result.category,
            management: result.management + " Additional features increase suspicion for malignancy.",
            additionalNotes: "Upgraded to 4X due to additional suspicious features (spiculation, lymphadenopathy, chest wall involvement, etc.)."
        )
    }

    private static func applyMultipleNodulesNote(to result: LungRADSResult) -> LungRADSResult {
        let note = "Multiple nodules present. Assign category based on the most suspicious nodule."
        let combinedNotes: String
        if let existingNotes = result.additionalNotes, !existingNotes.isEmpty {
            combinedNotes = existingNotes + " " + note
        } else {
            combinedNotes = note
        }
        return LungRADSResult(
            category: result.category,
            baseCategory: result.baseCategory,
            management: result.management,
            probabilityOfMalignancy: result.probabilityOfMalignancy,
            additionalNotes: combinedNotes,
            isReclassified: result.isReclassified
        )
    }
}
