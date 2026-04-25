import SwiftUI

struct ReferencePresentation: Identifiable {
    let reference: ReferenceType
    let url: URL

    var id: String { reference.id }
}

struct ReferencePresenter: ViewModifier {
    @Binding var reference: ReferenceType?
    @Environment(\.openURL) private var openURL
    @State private var pdfPresentation: ReferencePresentation?
    @State private var unavailableReference: ReferenceType?

    func body(content: Content) -> some View {
        content
            .onChange(of: reference) { _, nextReference in
                guard let nextReference else { return }
                present(nextReference)
                reference = nil
            }
            .sheet(item: $pdfPresentation) { presentation in
                PDFViewerSheet(reference: presentation.reference, url: presentation.url)
            }
            .alert("Reference unavailable", isPresented: unavailableAlertPresented) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("\(unavailableReference?.displayTitle ?? "This reference") is not available in the app bundle and no external link is configured.")
            }
    }

    private func present(_ reference: ReferenceType) {
        if let bundleURL = reference.resolvedBundleURL() {
            pdfPresentation = ReferencePresentation(reference: reference, url: bundleURL)
        } else if let externalURL = reference.externalURL {
            openURL(externalURL)
        } else {
            unavailableReference = reference
        }
    }

    private var unavailableAlertPresented: Binding<Bool> {
        Binding(
            get: { unavailableReference != nil },
            set: { isPresented in
                if !isPresented {
                    unavailableReference = nil
                }
            }
        )
    }
}

extension View {
    func referencePresenter(reference: Binding<ReferenceType?>) -> some View {
        modifier(ReferencePresenter(reference: reference))
    }
}
