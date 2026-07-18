import SwiftUI

// MARK: - Reusable Components

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(title: title)

            content()
                .background(Color.rowFill)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.cardStroke, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal)
    }
}

struct DetailItem: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
            Text(description)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.60))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews

#Preview("Fleischner Eligibility") {
    NavigationStack {
        FleischnerEligibilityDetailView()
    }
}

#Preview("Lung-RADS Eligibility") {
    NavigationStack {
        LungRADSEligibilityDetailView()
    }
}
