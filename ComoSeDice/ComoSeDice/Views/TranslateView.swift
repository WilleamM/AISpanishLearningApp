import SwiftUI

struct TranslateView: View {
    @StateObject private var viewModel = TranslateViewModel()

    var body: some View {
        // content stack
        VStack(alignment: .leading, spacing: 16) {
            Text("English")
                .font(.headline)
            TextEditor(text: $viewModel.sourceText)
                .frame(minHeight: 120)

            // action row
            HStack {
                Spacer()
                // translate button
                Button(action: {
                    Task { await viewModel.translate() }
                }) {
                    if viewModel.isTranslating {
                        ProgressView()
                    } else {
                        Label("Translate to Spanish", systemImage: "arrow.down.circle")
                    }
                }
                .disabled(viewModel.isTranslating || viewModel.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Text("Spanish")
                .font(.headline)
            // result area
            Group {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding(8)
                } else if viewModel.translatedText.isEmpty {
                    Text("Translation will appear here")
                        .foregroundStyle(.secondary)
                        .padding(8)
                } else {
                    ScrollView {
                        Text(viewModel.translatedText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
    }
}

#Preview {
    TranslateView()
}
