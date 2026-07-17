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

struct SettingsRow<Trailing: View>: View {
    let title: String
    var hasInfo = false
    var accentColor: Color = .fleischnerAccent
    var onInfoTap: (() -> Void)? = nil
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .layoutPriority(1)

            if hasInfo {
                Button(action: { onInfoTap?() }) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(accentColor)
                }
                .accessibilityLabel("Information about \(title)")
                .accessibilityHint("Shows guidance for this field.")
            }

            Spacer()
            trailing()
        }
        .padding()
        .cardStyle(cornerRadius: 12)
        .padding(.horizontal, 16)
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
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                HStack {
                    Text(row.title)
                        .foregroundColor(.white)
                        .accessibilityHidden(true)

                    if let info = row.info {
                        Button(action: info.action) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundColor(info.accentColor)
                        }
                        .accessibilityLabel(info.accessibilityLabel)
                        .accessibilityHint(info.accessibilityHint)
                    }

                    Spacer()
                    Toggle("", isOn: row.isOn)
                        .labelsHidden()
                        .accessibilityLabel(row.accessibilityLabel ?? row.title)
                }
                .padding()

                if index < rows.count - 1 {
                    Divider().background(Color.subtleDivider)
                }
            }
        }
        .cardStyle(cornerRadius: 12)
        .padding(.horizontal, 16)
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
            HStack(spacing: 4) {
                Text(selection)
                    .font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.weight(.bold))
            }
            .foregroundColor(accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(accentColor.opacity(0.12), in: Capsule())
        }
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
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(accentColor.opacity(0.14), in: Capsule())
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
