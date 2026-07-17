import SwiftUI

// MARK: - Palette

extension Color {
    /// Primary accent for the Fleischner 2017 calculator.
    static let fleischnerAccent = Color(red: 0.20, green: 0.78, blue: 0.35)
    /// Primary accent for the Lung-RADS v2022 calculator.
    static let lungRADSAccent = Color(red: 0.04, green: 0.52, blue: 1.0)

    /// Shared urgency scale used by both calculators' result cards.
    static let severityMinimal = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let severityModerate = Color(red: 0.97, green: 0.78, blue: 0.18)
    static let severityElevated = Color(red: 0.98, green: 0.56, blue: 0.16)
    static let severityHigh = Color(red: 0.95, green: 0.27, blue: 0.31)
    static let severityNeutral = Color(red: 0.55, green: 0.58, blue: 0.63)

    static let appBackdropTop = Color(red: 0.055, green: 0.063, blue: 0.078)
    static let appBackdropBottom = Color.black
    static let cardFillTop = Color(white: 0.145)
    static let cardFillBottom = Color(white: 0.10)
    static let cardStroke = Color.white.opacity(0.08)
    static let subtleDivider = Color.white.opacity(0.08)
}

// MARK: - App background

struct AppBackdrop: View {
    var body: some View {
        LinearGradient(
            colors: [.appBackdropTop, .appBackdropBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Card surface

struct CardStyle: ViewModifier {
    var cornerRadius: CGFloat = 16
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
                    .strokeBorder(Color.cardStroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(shadow ? 0.30 : 0), radius: 14, x: 0, y: 7)
    }
}

extension View {
    /// Applies the app's standard elevated dark-card surface.
    func cardStyle(cornerRadius: CGFloat = 16, shadow: Bool = true) -> some View {
        modifier(CardStyle(cornerRadius: cornerRadius, shadow: shadow))
    }
}

// MARK: - Value chip (trailing content on settings rows)

struct ValueChip<Content: View>: View {
    var accentColor: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(spacing: 4) {
            content()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(accentColor.opacity(0.12), in: Capsule())
    }
}

// MARK: - Pill button (secondary actions inside result cards)

struct PillButton: View {
    let title: String
    let icon: String
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(accentColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(accentColor.opacity(0.14), in: Capsule())
                .overlay(Capsule().strokeBorder(accentColor.opacity(0.35), lineWidth: 1))
        }
    }
}

// MARK: - Severity indicator bar

struct SeverityBar: View {
    var color: Color
    var height: CGFloat = 5
    var maxWidth: CGFloat = 130

    var body: some View {
        Capsule()
            .fill(color.gradient)
            .frame(height: height)
            .frame(maxWidth: maxWidth)
    }
}

// MARK: - Section header (small caps label used above grouped cards)

struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .tracking(0.4)
            .foregroundColor(.white.opacity(0.5))
            .padding(.horizontal)
            .padding(.bottom, 8)
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
