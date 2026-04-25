import PDFKit
import SwiftUI

struct PDFViewerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var loadFailed = false

    let reference: ReferenceType
    let url: URL

    var body: some View {
        NavigationStack {
            ZStack {
                PDFKitView(url: url, onLoadFailure: { loadFailed = true })

                if loadFailed {
                    VStack(spacing: 8) {
                        Text("Reference unavailable")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("The PDF could not be loaded.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                }
            }
            .background(Color.black)
            .navigationTitle(reference.displayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct PDFKitView: UIViewRepresentable {
    let url: URL
    let onLoadFailure: (() -> Void)?

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        } else {
            DispatchQueue.main.async {
                onLoadFailure?()
            }
        }
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
    }
}
