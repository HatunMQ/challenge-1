import Foundation
import Combine
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Creates 3 drawing ideas for the user's mood.
/// Uses Apple's on-device model (works offline) when available,
/// otherwise uses the written ideas in Models.swift.
@MainActor
final class ScenarioGenerator: ObservableObject {
    @Published private(set) var current: Scenario?
    @Published private(set) var isLoading = false
    @Published private(set) var usesAI = false

    private var queue: [Scenario] = []

    /// Shows the next idea. When all 3 have been shown, it creates 3 new ones.
    func showNext(for mood: Mood?) async {
        if queue.isEmpty {
            await refill(for: mood)
        }
        current = queue.isEmpty ? nil : queue.removeFirst()
    }

    private func refill(for mood: Mood?) async {
        isLoading = true
        defer { isLoading = false }

        if let generated = await generateOnDevice(for: mood) {
            queue = generated
            usesAI = true
        } else {
            let written = mood?.scenarios ?? Mood.allCases.flatMap(\.scenarios)
            queue = Array(written.shuffled().prefix(3))
            usesAI = false
        }
    }

    private func generateOnDevice(for mood: Mood?) async -> [Scenario]? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            guard case .available = SystemLanguageModel.default.availability else { return nil }

            let session = LanguageModelSession(instructions: """
                You write gentle drawing ideas for a calm, stress-relief drawing app on iPad.
                Use warm, simple English. Each idea should be easy to draw in about 10 minutes.
                Never give medical advice.
                """)

            do {
                let response = try await session.respond(
                    to: "\(mood?.aiPrompt ?? Mood.noMoodPrompt) Write 3 different drawing ideas.",
                    generating: GeneratedScenarios.self,
                    options: GenerationOptions(temperature: 0.9)
                )
                return response.content.ideas.map {
                    Scenario(title: $0.title, text: $0.text, colors: $0.colors)
                }
            } catch {
                return nil
            }
        }
        #endif
        return nil
    }
}

extension Mood {
    /// What the on-device model should focus on for each mood.
    var aiPrompt: String {
        switch self {
        case .happy:
            "The user feels happy. Help them celebrate and capture the good feeling."
        case .angry:
            "The user feels angry. Help them release the energy safely, then slowly calm down."
        case .sad:
            "The user feels sad. Offer comfort, a feeling of safety, and a small sign of hope."
        case .confused:
            "The user feels confused. Help them organize their thoughts and find clarity."
        }
    }

    static let noMoodPrompt = "The user didn't share how they feel. Suggest relaxing, open-ended ideas."
}

#if canImport(FoundationModels)
@available(iOS 26.0, *)
@Generable
struct GeneratedScenarios {
    @Guide(description: "Three different drawing ideas", .count(3))
    var ideas: [GeneratedScenario]
}

@available(iOS 26.0, *)
@Generable
struct GeneratedScenario {
    @Guide(description: "A short, calming title of 2 to 5 words")
    var title: String

    @Guide(description: "Two or three short, gentle sentences that describe what to draw")
    var text: String

    @Guide(description: "Four soft colors that suit this idea, as hex codes like F2C29F", .count(4))
    var colors: [String]
}
#endif
