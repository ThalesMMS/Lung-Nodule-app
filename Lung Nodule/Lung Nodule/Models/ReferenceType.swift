import Foundation

enum ReferenceType: Equatable, Identifiable {
    case fleischnerGuideline
    case lungRADSGuideline
    case lungRADSTable
    case brockSource

    var id: String {
        switch self {
        case .fleischnerGuideline:
            return "fleischnerGuideline"
        case .lungRADSGuideline:
            return "lungRADSGuideline"
        case .lungRADSTable:
            return "lungRADSTable"
        case .brockSource:
            return "brockSource"
        }
    }

    var bundledPDFName: String? {
        switch self {
        case .fleischnerGuideline:
            return "Fleischner 2017"
        case .lungRADSGuideline:
            return "ACR-Lung-RADS"
        case .lungRADSTable:
            return "Lung-RADS-2022 Table"
        case .brockSource:
            return nil
        }
    }

    var externalURL: URL? {
        switch self {
        case .fleischnerGuideline:
            return nil
        case .lungRADSGuideline, .lungRADSTable:
            return URL(string: "https://www.acr.org/Clinical-Resources/Reporting-and-Data-Systems/Lung-Rads")
        case .brockSource:
            return URL(string: "https://www.nejm.org/doi/full/10.1056/NEJMoa1214726")
        }
    }

    var displayTitle: String {
        switch self {
        case .fleischnerGuideline:
            return "Fleischner 2017"
        case .lungRADSGuideline:
            return "ACR Lung-RADS v2022"
        case .lungRADSTable:
            return "Lung-RADS v2022 Table"
        case .brockSource:
            return "Brock Full Model"
        }
    }

    func resolvedBundleURL() -> URL? {
        guard let bundledPDFName else { return nil }
        return Bundle.main.url(forResource: bundledPDFName, withExtension: "pdf")
    }
}
