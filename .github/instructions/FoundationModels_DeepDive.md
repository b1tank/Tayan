# 🚀 Apple FoundationModels API — [Advanced Examples](https://developer.apple.com/videos/play/wwdc2025/301/)

## [Error Handling](https://developer.apple.com/forums/thread/792076?answerId=848076022#848076022)
```swift
	do {
	    let response = try await session.respond(to: prompt)
	} catch let error {
	    handleGeneratedError(error as! LanguageModelSession.GenerationError)
	}
	 
	private func handleGeneratedError(_ error: LanguageModelSession.GenerationError) {
	    switch error {
	    case .exceededContextWindowSize(let context):
	        presentGeneratedError(error, context: context)
	        
	    case .assetsUnavailable(let context):
	        presentGeneratedError(error, context: context)
	 
	    case .guardrailViolation(let context):
	        presentGeneratedError(error, context: context)
	 
	    case .unsupportedGuide(let context):
	        presentGeneratedError(error, context: context)
	 
	    case .unsupportedLanguageOrLocale(let context) :
	        presentGeneratedError(error, context: context)
	        
	    case .decodingFailure(let context) :
	        presentGeneratedError(error, context: context)
	        
	    case .rateLimited(let context) :
	        presentGeneratedError(error, context: context)
	        
	    default:
	        print("Failed to respond: \(error.localizedDescription)")
	    }
	}
	 
	private func presentGeneratedError(_ error: LanguageModelSession.GenerationError,
	                                   context: LanguageModelSession.GenerationError.Context) {
	    print("""
	        Failed to respond: \(error.localizedDescription).
	        Failure reason: \(String(describing: error.failureReason)).
	        Recovery suggestion: \(String(describing: error.recoverySuggestion)).
	        """)
	    print("Failed to respond: \(context)")
	}
```

## Custom instructions with sessions
```swift
import FoundationModels

func respond(userInput: String) async throws -> String {
    let session = LanguageModelSession(instructions: """
        You are a friendly barista in a world full of pixels.
        Respond to the player's question.
        """
    )
    let response = try await session.respond(to: userInput)
    return response.content
}
```

## Handle context window errors
```swift
var session = LanguageModelSession()

do {
    let answer = try await session.respond(to: prompt)
    print(answer.content)
} catch LanguageModelSession.GenerationError.exceededContextWindowSize {
    // Create new session without history
    session = LanguageModelSession()
}
```

## Context window management with history
```swift
var session = LanguageModelSession()

do {
    let answer = try await session.respond(to: prompt)
    print(answer.content)
} catch LanguageModelSession.GenerationError.exceededContextWindowSize {
    // Create new session with condensed history
    session = newSession(previousSession: session)
}

private func newSession(previousSession: LanguageModelSession) -> LanguageModelSession {
    let allEntries = previousSession.transcript.entries
    var condensedEntries = [Transcript.Entry]()
    if let firstEntry = allEntries.first {
        condensedEntries.append(firstEntry)
        if allEntries.count > 1, let lastEntry = allEntries.last {
            condensedEntries.append(lastEntry)
        }
    }
    let condensedTranscript = Transcript(entries: condensedEntries)
    return LanguageModelSession(transcript: condensedTranscript)
}
```

## Controlling output variance
```swift
// Deterministic output
let response = try await session.respond(
    to: prompt,
    options: GenerationOptions(sampling: .greedy)
)

// Low-variance output
let response = try await session.respond(
    to: prompt,
    options: GenerationOptions(temperature: 0.5)
)

// High-variance output
let response = try await session.respond(
    to: prompt,
    options: GenerationOptions(temperature: 2.0)
)
```

## Language support handling
```swift
var session = LanguageModelSession()

do {
    let answer = try await session.respond(to: userInput)
    print(answer.content)
} catch LanguageModelSession.GenerationError.unsupportedLanguageOrLocale {
    // Handle unsupported language
}

let supportedLanguages = SystemLanguageModel.default.supportedLanguages
guard supportedLanguages.contains(Locale.current.language) else {
    // Show unsupported language message
    return
}
```

## Creating complex Generable structs
```swift
@Generable
struct NPC {
    let name: String
    let coffeeOrder: String
}

func makeNPC() async throws -> NPC {
    let session = LanguageModelSession(instructions: "...")
    let response = try await session.respond(
        to: "Generate a character that orders a coffee.",
        generating: NPC.self
    )
    return response.content
}
```

## Generable with enum cases
```swift
@Generable
struct NPC {
    let name: String
    let encounter: Encounter

    @Generable
    enum Encounter {
        case orderCoffee(String)
        case wantToTalkToManager(complaint: String)
    }
}
```

## Advanced Generable with guides
```swift
@Generable
struct NPC {
    @Guide(description: "A full name")
    let name: String
    @Guide(.range(1...10))
    let level: Int
    @Guide(.count(3))
    let attributes: [Attribute]
    let encounter: Encounter

    @Generable
    enum Attribute {
        case sassy
        case tired
        case hungry
    }
    
    @Generable
    enum Encounter {
        case orderCoffee(String)
        case wantToTalkToManager(complaint: String)
    }
}
```

## Regex constraints with guides
```swift
@Generable
struct NPC {
    @Guide(Regex {
        Capture {
            ChoiceOf {
                "Mr"
                "Mrs"
            }
        }
        ". "
        OneOrMore(.word)
    })
    let name: String
}

let response = try await session.respond(
    to: "Generate a fun NPC", 
    generating: NPC.self
)
// Result: {name: "Mrs. Brewster"}
```

## Nested Generable structures
```swift
@Generable
struct Riddle {
    let question: String
    let answers: [Answer]

    @Generable
    struct Answer {
        let text: String
        let isCorrect: Bool
    }
}
```

## Dynamic schema generation
```swift
struct LevelObjectCreator {
    var properties: [DynamicGenerationSchema.Property] = []
    let name: String

    mutating func addStringProperty(name: String) {
        let property = DynamicGenerationSchema.Property(
            name: name,
            schema: DynamicGenerationSchema(type: String.self)
        )
        properties.append(property)
    }

    mutating func addArrayProperty(name: String, customType: String) {
        let property = DynamicGenerationSchema.Property(
            name: name,
            schema: DynamicGenerationSchema(
                arrayOf: DynamicGenerationSchema(referenceTo: customType)
            )
        )
        properties.append(property)
    }
    
    var root: DynamicGenerationSchema {
        DynamicGenerationSchema(
            name: name,
            properties: properties
        )
    }
}
```

## Using dynamic schemas
```swift
var riddleBuilder = LevelObjectCreator(name: "Riddle")
riddleBuilder.addStringProperty(name: "question")
riddleBuilder.addArrayProperty(name: "answers", customType: "Answer")

var answerBuilder = LevelObjectCreator(name: "Answer")
answerBuilder.addStringProperty(name: "text")
answerBuilder.addBoolProperty(name: "isCorrect")

let schema = try GenerationSchema(
    root: riddleBuilder.root,
    dependencies: [answerBuilder.root]
)

let session = LanguageModelSession()
let response = try await session.respond(
    to: "Generate a fun riddle about coffee",
    schema: schema
)

let question = try response.content.value(String.self, forProperty: "question")
let answers = try response.content.value([GeneratedContent].self, forProperty: "answers")
```

## Advanced tool with enums
```swift
import FoundationModels
import Contacts

struct FindContactTool: Tool {
    let name = "findContact"
    let description = "Finds a contact from a specified age generation"
    
    @Generable
    struct Arguments {
        let generation: Generation
        
        @Generable
        enum Generation {
            case babyBoomers
            case genX
            case millennial
            case genZ
        }
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactBirthdayKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)

        var contacts: [CNContact] = []
        try store.enumerateContacts(with: request) { contact, stop in
            if let year = contact.birthday?.year {
                if arguments.generation.yearRange.contains(year) {
                    contacts.append(contact)
                }
            }
        }
        
        guard let pickedContact = contacts.randomElement() else {
            return ToolOutput("Could not find a contact.")
        }
        return ToolOutput(pickedContact.givenName)
    }
}
```

## Using tools with sessions
```swift
let session = LanguageModelSession(
    tools: [FindContactTool()],
    instructions: "Generate fun NPCs"
)
```

## Stateful tools
```swift
class FindContactTool: Tool {
    let name = "findContact"
    let description = "Finds a contact from a specified age generation"
    
    var pickedContacts = Set<String>()
    
    // ...existing Arguments enum...
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        // ...existing contact fetching logic...
        contacts.removeAll(where: { pickedContacts.contains($0.givenName) })
        
        guard let pickedContact = contacts.randomElement() else {
            return ToolOutput("Could not find a contact.")
        }
        
        pickedContacts.insert(pickedContact.givenName)
        return ToolOutput(pickedContact.givenName)
    }
}
```

## Event-based tools
```swift
import FoundationModels
import EventKit

struct GetContactEventTool: Tool {
    let name = "getContactEvent"
    let description = "Get an event with a contact"
    
    let contactName: String
    
    @Generable
    struct Arguments {
        let day: Int
        let month: Int
        let year: Int
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        // Implementation for fetching events
        // ...
    }
}
```