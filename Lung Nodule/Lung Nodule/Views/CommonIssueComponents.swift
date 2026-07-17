import SwiftUI

// MARK: - Reusable Components

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(title: title)

            content()
                .cardStyle(cornerRadius: 12)
                .padding(.horizontal)
        }
    }
}

struct DetailItem: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.55))
        }
        .padding()
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
