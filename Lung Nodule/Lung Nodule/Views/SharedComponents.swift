import SwiftUI

struct AdaptiveCalculatorGrid<Content: View>: View {
    var minimumColumnWidth: CGFloat = 340
    @ViewBuilder let content: () -> Content

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: minimumColumnWidth, maximum: 520),
                    spacing: 16,
                    alignment: .top
                )
            ],
            alignment: .leading,
            spacing: 16
        ) {
            content()
        }
        .frame(maxWidth: 1040)
        .frame(maxWidth: .infinity)
    }
}

/// Groups related rows into a single inset card. Rows are separated by
/// hairlines created by the 1 pt spacing over the section's divider fill.
struct SettingsSection<Content: View>: View {
    var title: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                SectionLabel(title: title)
            }

            VStack(spacing: 1) {
                content()
            }
            .background(Color.subtleDivider)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.cardStroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal, 16)
    }
}

struct SettingsRow<Trailing: View>: View {
    let title: String
    var hasInfo = false
    var accentColor: Color = .fleischnerAccent
    var onInfoTap: (() -> Void)? = nil
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.92))
                .layoutPriority(1)

            if hasInfo {
                Button(action: { onInfoTap?() }) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(accentColor.opacity(0.85))
                }
                .accessibilityLabel("Information about \(title)")
                .accessibilityHint("Shows guidance for this field.")
            }

            Spacer(minLength: 10)
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.rowFill)
    }
}

struct GroupedToggleInfo {
    let accentColor: Color
    let accessibilityLabel: LocalizedStringKey
    let accessibilityHint: LocalizedStringKey
    let action: () -> Void
}

struct GroupedToggleRow: Identifiable {
    let id: String
    let title: LocalizedStringKey
    let isOn: Binding<Bool>
    var accessibilityLabel: LocalizedStringKey? = nil
    var info: GroupedToggleInfo? = nil
}

struct GroupedToggleCard: View {
    let rows: [GroupedToggleRow]

    var body: some View {
        SettingsSection {
            ForEach(rows) { row in
                HStack(spacing: 8) {
                    Text(row.title)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.92))
                        .accessibilityHidden(true)

                    if let info = row.info {
                        Button(action: info.action) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundColor(info.accentColor.opacity(0.85))
                        }
                        .accessibilityLabel(info.accessibilityLabel)
                        .accessibilityHint(info.accessibilityHint)
                    }

                    Spacer(minLength: 10)
                    Toggle("", isOn: row.isOn)
                        .labelsHidden()
                        .accessibilityLabel(row.accessibilityLabel ?? row.title)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.rowFill)
            }
        }
    }
}

struct SettingsMenuPicker: View {
    let selection: String
    let accentColor: Color
    let options: [String]
    let onSelect: (String) -> Void

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { onSelect(option) }
            }
        } label: {
            HStack(spacing: 5) {
                Text(selection)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.weight(.bold))
                    .opacity(0.8)
            }
            .foregroundColor(accentColor)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(accentColor.opacity(0.13), in: Capsule())
            .overlay(Capsule().strokeBorder(accentColor.opacity(0.22), lineWidth: 1))
        }
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
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(accentColor.opacity(0.13), in: Capsule())
        .overlay(Capsule().strokeBorder(accentColor.opacity(0.22), lineWidth: 1))
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
                .background(accentColor.opacity(0.13), in: Capsule())
                .overlay(Capsule().strokeBorder(accentColor.opacity(0.30), lineWidth: 1))
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
            .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 0)
    }
}

// MARK: - Section header (small caps label used above grouped cards)

struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .tracking(1.1)
            .textCase(.uppercase)
            .foregroundColor(.white.opacity(0.42))
            .padding(.horizontal, 4)
    }
}

// MARK: - Tinted informational banner

struct InfoBanner: View {
    let text: String
    var icon = "info.circle.fill"
    var tint: Color = .fleischnerAccent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.15), in: Circle())

            Text(text)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.72))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(tint.opacity(0.18), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Reset button (result-card corner action)

struct ResetButton: View {
    var accentColor: Color = .fleischnerAccent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.counterclockwise")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.65))
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.08), in: Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Reset")
    }
}

struct ReferenceButton: View {
    let reference: ReferenceType
    var accentColor: Color = .lungRADSAccent
    var topPadding: CGFloat = 16
    var bottomPadding: CGFloat = 32
    @State private var selectedReference: ReferenceType?

    var body: some View {
        Button(action: { selectedReference = reference }) {
            Label("Reference", systemImage: "doc.text")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(accentColor)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(accentColor.opacity(0.13), in: Capsule())
                .overlay(Capsule().strokeBorder(accentColor.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .referencePresenter(reference: $selectedReference)
    }
}

extension View {
    func informationAlert(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        message: LocalizedStringKey
    ) -> some View {
        alert(title, isPresented: isPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(message)
        }
    }
}
