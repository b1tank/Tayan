
# 📘 Apple FoundationModels API — [Code Examples](https://developer.apple.com/videos/play/wwdc2025/286/)

## Basic usage
```swift
import FoundationModels
let session = LanguageModelSession()
let response = try await session.respond(to: "What's a good name for a trip to Japan?")
```

## Creating a Generable struct
```swift
@Generable
struct SearchSuggestions {
    @Guide(description: "Suggested search terms", .count(4))
    var searchTerms: [String]
}
```

##  Responding with Generable types
```swift
let response = try await session.respond(
    to: "Generate search suggestions for landmarks",
    generating: SearchSuggestions.self
)
```

## Composing nested Generable types
```swift
@Generable struct Itinerary {
    var destination: String
    var days: Int
    var budget: Float
    var rating: Double
    var requiresVisa: Bool
    var activities: [String]
    var emergencyContact: Person
    var relatedItineraries: [Itinerary]
}
```

## PartiallyGenerated types
```swift
@Generable struct Itinerary {
    var name: String
    var days: [Day]
}
```

## Streaming partial generations
```swift
let stream = session.streamResponse(
    to: "Craft a 3-day itinerary to Mt. Fuji",
    generating: Itinerary.self
)

for try await partial in stream {
    print(partial)
}
```

## Streaming in SwiftUI
```swift
struct ItineraryView: View {
    let session: LanguageModelSession
    let dayCount: Int
    let landmarkName: String
  
    @State
    private var itinerary: Itinerary.PartiallyGenerated?
  
    var body: some View {
        //...
        Button("Start") {
            Task {
                do {
                    let prompt = """
                        Generate a \(dayCount) itinerary \
                        to \(landmarkName).
                        """
                  
                    let stream = session.streamResponse(
                        to: prompt,
                        generating: Itinerary.self
                    )
                  
                    for try await partial in stream {
                        self.itinerary = partial
                    }
                } catch {
                    print(error)  
                }
            }
        }
    }
}
```

## Property order matters
```swift
@Generable struct Itinerary {
    @Guide(description: "Plans per day") var days: [DayPlan]
    @Guide(description: "Summary") var summary: String
}
```

## Define a tool
```swift
// Defining a tool
import WeatherKit
import CoreLocation
import FoundationModels

struct GetWeatherTool: Tool {
    let name = "getWeather"
    let description = "Retrieve the latest weather information for a city"

    @Generable
    struct Arguments {
        @Guide(description: "The city to fetch the weather for")
        var city: String
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        let places = try await CLGeocoder().geocodeAddressString(arguments.city)
        let weather = try await WeatherService.shared.weather(for: places.first!.location!)
        let temperature = weather.currentWeather.temperature.value

        let content = GeneratedContent(properties: ["temperature": temperature])
        let output = ToolOutput(content)

        // Or if your tool’s output is natural language:
        // let output = ToolOutput("\(arguments.city)'s temperature is \(temperature) degrees.")

        return output
    }
}
```

## Attach tool to a session
```swift
let session = LanguageModelSession(
    tools: [GetWeatherTool()],
    instructions: "Help with weather forecasts."
)
```

## Custom instructions
```swift
let session = LanguageModelSession(
    instructions: "Always respond in rhyme."
)
```

## Multi-turn conversations
```swift
let first = try await session.respond(to: "Write a haiku about fishing")
let second = try await session.respond(to: "Now one about golf")
print(session.transcript)
```

## Gate on `isResponding`
```swift
struct HaikuView: View {
    @State
    private var session = LanguageModelSession()
    @State
    private var haiku: String?
    var body: some View {
        if let haiku {
            Text(haiku)
        }
        Button("Go!") {
            Task {
                haiku = try await session.respond(
                    to: "Write a haiku about something you haven't yet"
                ).content
            }
        }
        // Gate on `isResponding`
        .disabled(session.isResponding)
    }
}
```

## Built-in use case
```swift
let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging)
)
```

## Content tagging use case - 1
```swift
@Generable
struct Result {
    let topics: [String]
}
let session = LanguageModelSession(model: SystemLanguageModel(useCase: .contentTagging))
let response = try await session.respond(to: ..., generating: Result.self)
```

## Content tagging use case - 2
```swift
@Generable
struct Top3ActionEmotionResult {
    @Guide(.maximumCount(3))
    let actions: [String]
    @Guide(.maximumCount(3))
    let emotions: [String]
}
let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging),
    instructions: "Tag the 3 most important actions and emotions in the given input text."
)
let response = try await session.respond(to: ..., generating: Top3ActionEmotionResult.self)
```

## Model availability
```swift
struct AvailabilityExample: View {
    private let model = SystemLanguageModel.default
    var body: some View {
        switch model.availability {
        case .available:
            Text("Model is available").foregroundStyle(.green)
        case .unavailable(let reason):
            Text("Model is unavailable").foregroundStyle(.red)
            Text("Reason: \(reason)")
        }
    }
}
```
