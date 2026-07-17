import SwiftUI

// MARK: - Supporting Views

struct SModifierSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    private let blueAccent = Color.lungRADSAccent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(blueAccent)
                    .frame(width: 32, height: 32)
                    .background(blueAccent.opacity(0.15), in: Circle())
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer(minLength: 0)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider().background(Color.subtleDivider)

            // Section Content
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
        }
        .cardStyle(cornerRadius: 12)
        .padding(.horizontal)
    }
}

struct SModifierToggleItem: View {
    let title: String
    var bullets: [String] = []
    let recommendation: String?
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: bullets.isEmpty ? 4 : 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: bullets.isEmpty ? 4 : 8) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white)

                    ForEach(bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 8) {
                            Text("●")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(bullet)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    if let recommendation {
                        Text(recommendation)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, bullets.isEmpty ? 0 : 4)
                    }
                }
                .accessibilityHidden(true)

                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .accessibilityLabel(title)
                    .accessibilityHint(accessibilityHint)
            }
            .accessibilityElement(children: .contain)
        }
        .padding()
    }

    private var accessibilityHint: String {
        let details = bullets + [recommendation].compactMap { $0 }
        if !details.isEmpty {
            return details.joined(separator: ". ")
        }
        return String(
            localized: "accessibility.s-modifier.toggle-hint",
            defaultValue: "Marks this finding for the S modifier.",
            comment: "Fallback hint for an S modifier finding toggle without a recommendation."
        )
    }
}

#Preview {
    SModifierConsiderationsView(hasSModifierFindings: .constant(false))
}
