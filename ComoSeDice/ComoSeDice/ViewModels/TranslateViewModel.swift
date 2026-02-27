// imports
import Foundation
import SwiftUI
import Combine

// view model
@MainActor
final class TranslateViewModel: ObservableObject {
    @Published var sourceText: String = ""
    @Published var translatedText: String = ""
    @Published var isTranslating: Bool = false
    @Published var errorMessage: String?

    // translator dependency
    private let translator: GPTTranslator

    // inject dependency
    init(translator: GPTTranslator) {
        self.translator = translator
    }
    // called on main actor
    convenience init() {
        self.init(translator: GPTTranslator())
    }

    // translate flow
    func translate() async {
        let text = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else { return }
        isTranslating = true
        errorMessage = nil
        do {
            let result = try await translator.translateToSpanish(text)
            translatedText = result
        }
        catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isTranslating = false
    }
}

