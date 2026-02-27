import Foundation

// code sourced from github for chat gpt integration

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double?
}

struct ChatChoice: Codable {
    struct Message: Codable {
        let role: String
        let content: String
    }
    let index: Int
    let message: Message
}

struct ChatResponse: Codable {
    let id: String
    let choices: [ChatChoice]
}

enum GPTTranslatorError: Error, LocalizedError {
    case missingAPIKey
    case invalidResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing OpenAI API key. Add OPENAI_API_KEY to Info.plist."
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let code):
            return "Server returned HTTP status code: \(code)"
        }
    }
}

final class GPTTranslator {
    private let session: URLSession
    private let model: String

    init(session: URLSession = .shared, model: String = "gpt-4o-mini") {
        self.session = session
        self.model = model
    }

    private func apiKey() -> String? {
        Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String
    }

    func translateToSpanish(_ english: String) async throws -> String {
        guard let key = apiKey(), key.isEmpty == false else {
            throw GPTTranslatorError.missingAPIKey
        }

        let systemPrompt = "You are a professional translator. Translate the user's English text to natural sounding Spanish. Only return the translated Spanish text without additional commentary or saying anything else."

        let request = ChatRequest(
            model: model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: english)
            ],
            temperature: 0.2
        )

        var urlRequest = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else { throw GPTTranslatorError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw GPTTranslatorError.httpError(http.statusCode) }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines), content.isEmpty == false else {
            throw GPTTranslatorError.invalidResponse
        }
        return content
    }
}
