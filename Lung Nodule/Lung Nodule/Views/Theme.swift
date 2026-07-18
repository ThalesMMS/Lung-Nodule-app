import SwiftUI

// MARK: - Palette

extension Color {
    /// Primary accent for the Fleischner 2017 calculator.
    static let fleischnerAccent = Color(red: 0.24, green: 0.80, blue: 0.42)
    /// Primary accent for the Lung-RADS v2022 calculator.
    static let lungRADSAccent = Color(red: 0.18, green: 0.56, blue: 1.0)

    /// Shared urgency scale used by both calculators' result cards.
    static let severityMinimal = Color(red: 0.24, green: 0.80, blue: 0.42)
    static let severityModerate = Color(red: 0.97, green: 0.76, blue: 0.22)
    static let severityElevated = Color(red: 0.98, green: 0.55, blue: 0.18)
    static let severityHigh = Color(red: 0.95, green: 0.30, blue: 0.34)
    static let severityNeutral = Color(red: 0.58, green: 0.61, blue: 0.66)

    static let appBackdropTop = Color(red: 0.055, green: 0.070, blue: 0.090)
    static let appBackdropBottom = Color(red: 0.016, green: 0.020, blue: 0.028)
    static let cardFillTop = Color(red: 0.110, green: 0.125, blue: 0.145)
    static let cardFillBottom = Color(red: 0.082, green: 0.092, blue: 0.108)
    static let rowFill = Color(red: 0.100, green: 0.113, blue: 0.132)
    static let cardStroke = Color.white.opacity(0.09)
    static let subtleDivider = Color.white.opacity(0.07)
}

// MARK: - App background

struct AppBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.appBackdropTop, .appBackdropBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [Color.fleischnerAccent.opacity(0.08), .clear],
                center: .init(x: 0.15, y: -0.05),
                startRadius: 0,
                endRadius: 420
            )

            RadialGradient(
                colors: [Color.lungRADSAccent.opacity(0.07), .clear],
                center: .init(x: 1.05, y: 0.35),
                startRadius: 0,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Card surface

struct CardStyle: ViewModifier {
    var cornerRadius: CGFloat = 20
    var shadow: Bool = true

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.cardFillTop, .cardFillBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.13), .white.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(shadow ? 0.35 : 0), radius: 16, x: 0, y: 8)
    }
}

extension View {
    /// Applies the app's standard elevated dark-card surface.
    func cardStyle(cornerRadius: CGFloat = 20, shadow: Bool = true) -> some View {
        modifier(CardStyle(cornerRadius: cornerRadius, shadow: shadow))
    }
}

// MARK: - Severity mapping

extension LungRADSCategory {
    var severityColor: Color {
        switch self {
        case .cat0: return .severityNeutral
        case .cat1, .cat2: return .severityMinimal
        case .cat3: return .severityModerate
        case .cat4A: return .severityElevated
        case .cat4B, .cat4X: return .severityHigh
        case .s: return .severityNeutral
        }
    }

    /// Legible text color for content drawn on top of `severityColor`.
    var onSeverityColor: Color {
        switch self {
        case .cat4B, .cat4X: return .white
        default: return .black.opacity(0.82)
        }
    }
}

extension BrockRiskCategory {
    var severityColor: Color {
        switch self {
        case .low: return .severityMinimal
        case .intermediate: return .severityModerate
        case .high: return .severityHigh
        }
    }
}

enum FleischnerSeverity {
    static func color(for recommendation: String) -> Color {
        if recommendation.contains("No routine") {
            return .severityMinimal
        } else if recommendation.contains("PET/CT") || recommendation.contains("tissue sampling") {
            return .severityHigh
        } else if recommendation.contains("3-6 months") || recommendation.contains("3 months") {
            return .severityElevated
        } else if recommendation.contains("6-12 months") {
            return .severityModerate
        } else if recommendation.contains("Optional CT at 12") {
            return .severityMinimal
        }
        return .severityModerate
    }

    static func icon(for recommendation: String) -> String {
        if recommendation.contains("No routine") {
            return "checkmark.seal.fill"
        } else if recommendation.contains("PET/CT") || recommendation.contains("tissue sampling") {
            return "exclamationmark.triangle.fill"
        }
        return "calendar.badge.clock"
    }
}
