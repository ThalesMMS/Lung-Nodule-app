import Foundation

enum MedicalCopy {
    static let decisionSupportDisclaimer = String(
        localized: "medical.disclaimer",
        defaultValue: "This application is a decision support tool for healthcare professionals and does not replace clinical judgment. Management should be based on the original guidelines (ACR/Fleischner).",
        comment: "Clinical disclaimer shown above the common issues list."
    )

    static let brockModelDescription = String(
        localized: "medical.brock.description",
        defaultValue: "The Brock full model estimates a CT-detected nodule's 2-4 year malignancy risk.",
        comment: "Description shown at the top of the Brock risk calculator."
    )

    static let fleischnerPurpose = String(
        localized: "medical.fleischner.purpose",
        defaultValue: "Management of incidentally detected pulmonary nodules on CT in routine clinical practice.",
        comment: "Purpose of the Fleischner Society guidelines."
    )

    static let lungRADSMeanDiameter = String(
        localized: "medical.lungrads.mean-diameter",
        defaultValue: "Average of long and short axis measurements on the same axial image.",
        comment: "Definition of mean nodule diameter in Lung-RADS."
    )

    enum Section {
        static let ageCriteria = localized("section.age-criteria", defaultValue: "AGE CRITERIA")
        static let smokingHistoryCriteria = localized("section.smoking-history-criteria", defaultValue: "SMOKING HISTORY CRITERIA")
        static let smokingQuitTimeCriteria = localized("section.smoking-quit-time-criteria", defaultValue: "SMOKING QUIT-TIME CRITERIA")
        static let measuringNodules = localized("section.measuring-nodules", defaultValue: "MEASURING NODULES")
        static let juxtapleuralNodules = localized("section.juxtapleural-nodules", defaultValue: "JUXTAPLEURAL NODULES")
        static let noduleTypes = localized("section.nodule-types", defaultValue: "NODULE TYPES")
        static let steppedManagement = localized("section.stepped-management", defaultValue: "STEPPED MANAGEMENT")
        static let fleischnerGuidelines = localized("section.fleischner-guidelines", defaultValue: "2017 FLEISCHNER SOCIETY GUIDELINES")
        static let exclusions = localized("section.exclusions", defaultValue: "EXCLUSIONS")
        static let general = localized("section.general", defaultValue: "GENERAL")
        static let solidAndNonSolidNodules = localized(
            "section.solid-and-non-solid-nodules",
            defaultValue: "SOLID NODULES AND NON-SOLID (GROUND-GLASS) NODULES"
        )
        static let perifissuralNodules = localized("section.perifissural-nodules", defaultValue: "PERIFISSURAL NODULES")

        private static func localized(_ key: StaticString, defaultValue: String.LocalizationValue) -> String {
            String(localized: key, defaultValue: defaultValue, comment: "Medical information section header.")
        }
    }
}
