# Rich TextEditor with AttributedString — [SwiftUI Basics](https://developer.apple.com/videos/play/wwdc2025/280)

## TextEditor with String
```swift
import SwiftUI

struct RecipeEditor: View {
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
    }
}
```

## TextEditor with AttributedString
```swift
import SwiftUI

struct RecipeEditor: View {
    @Binding var text: AttributedString

    var body: some View {
        TextEditor(text: $text)
    }
}
```

## AttributedString basics
```swift
var text = AttributedString(
    "Hello 👋🏻! Who's ready to get "
)

var cooking = AttributedString("cooking")
cooking.foregroundColor = .orange
text += cooking

text += AttributedString("?")

text.font = .largeTitle
```

## Slicing AttributedString with a Range
```swift
var text = AttributedString(
    "Hello 👋🏻! Who's ready to get cooking?"
)

guard let cookingRange = text.range(of: "cooking") else {
    fatalError("Unable to find range of cooking")
}

text[cookingRange].foregroundColor = .orange
```

## Slicing AttributedString with a RangeSet
```swift
var text = AttributedString(
    "Hello 👋🏻! Who's ready to get cooking?"
)

let uppercaseRanges = text.characters
    .indices(where: \.isUppercase)

text[uppercaseRanges].foregroundColor = .blue
```

## AttributedString views
```swift
// Character View
text.characters[index] // "👋🏻"

// Unicode Scalar View
text.unicodeScalars[index] // "👋"

// Runs View
text.runs[index] // "Hello 👋🏻! ..."

// UTF-8 View
text.utf8[index] // "240"

// UTF-16 View
text.utf16[index] // "55357"
```

## Updating indices during AttributedString mutations
```swift
var text = AttributedString(
    "Hello 👋🏻! Who's ready to get cooking?"
)

guard var cookingRange = text.range(of: "cooking") else {
    fatalError("Unable to find range of cooking")
}

let originalRange = cookingRange
text.transform(updating: &cookingRange) { text in
    text[originalRange].foregroundColor = .orange
    
    let insertionPoint = text
        .index(text.startIndex, offsetByCharacters: 6)
    
    text.characters
        .insert(contentsOf: "chef ", at: insertionPoint)
}

print(text[cookingRange])
```

## Custom controls: Basic setup (initial attempt)
```swift
import SwiftUI

struct RecipeEditor: View {
    @Binding var text: AttributedString
    @State private var selection = AttributedTextSelection()

    var body: some View {
        TextEditor(text: $text, selection: $selection)
            .preference(key: NewIngredientPreferenceKey.self, value: newIngredientSuggestion)
    }

    private var newIngredientSuggestion: IngredientSuggestion {
        let name = text[selection.indices(in: text)] // build error

        return IngredientSuggestion(
            suggestedName: AttributedString())
    }
}
```

## Custom controls: Basic setup (fixed)
```swift
import SwiftUI

struct RecipeEditor: View {
    @Binding var text: AttributedString
    @State private var selection = AttributedTextSelection()

    var body: some View {
        TextEditor(text: $text, selection: $selection)
            .preference(key: NewIngredientPreferenceKey.self, value: newIngredientSuggestion)
    }

    private var newIngredientSuggestion: IngredientSuggestion {
        let name = text[selection]

        return IngredientSuggestion(
            suggestedName: AttributedString(name))
    }
}
```

## Custom attributes definition
```swift
import SwiftUI

struct IngredientAttribute: CodableAttributedStringKey {
    typealias Value = Ingredient.ID

    static let name = "SampleRecipeEditor.IngredientAttribute"
}

extension AttributeScopes {
    /// An attribute scope for custom attributes defined by this app.
    struct CustomAttributes: AttributeScope {
        /// An attribute for marking text as a reference to an recipe's ingredient.
        let ingredient: IngredientAttribute
    }
}

extension AttributeDynamicLookup {
    /// The subscript for pulling custom attributes into the dynamic attribute lookup.
    ///
    /// This makes them available throughout the code using the name they have in the
    /// `AttributeScopes.CustomAttributes` scope.
    subscript<T: AttributedStringKey>(
        dynamicMember keyPath: KeyPath<AttributeScopes.CustomAttributes, T>
    ) -> T {
        self[T.self]
    }
}
```

## Modifying text (initial attempt)
```swift
import SwiftUI

struct RecipeEditor: View {
    @Binding var text: AttributedString
    @State private var selection = AttributedTextSelection()

    var body: some View {
        TextEditor(text: $text, selection: $selection)
            .preference(key: NewIngredientPreferenceKey.self, value: newIngredientSuggestion)
    }

    private var newIngredientSuggestion: IngredientSuggestion {
        let name = text[selection]

        return IngredientSuggestion(
            suggestedName: AttributedString(name),
            onApply: { ingredientId in
                let ranges = text.characters.ranges(of: name.characters)

                for range in ranges {
                    // modifying `text` without updating `selection` is invalid and resets the cursor 
                    text[range].ingredient = ingredientId
                }
            })
    }
}
```

## Modifying text (fixed)
```swift
import SwiftUI

struct RecipeEditor: View {
    @Binding var text: AttributedString
    @State private var selection = AttributedTextSelection()

    var body: some View {
        TextEditor(text: $text, selection: $selection)
            .preference(key: NewIngredientPreferenceKey.self, value: newIngredientSuggestion)
    }

    private var newIngredientSuggestion: IngredientSuggestion {
        let name = text[selection]

        return IngredientSuggestion(
            suggestedName: AttributedString(name),
            onApply: { ingredientId in
                let ranges = RangeSet(text.characters.ranges(of: name.characters))

                text.transform(updating: &selection) { text in
                    text[ranges].ingredient = ingredientId
                }
            })
    }
}
```

## Text formatting definition scope
```swift
struct RecipeFormattingDefinition: AttributedTextFormattingDefinition {
    struct Scope: AttributeScope {
        let foregroundColor: AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute
        let adaptiveImageGlyph: AttributeScopes.SwiftUIAttributes.AdaptiveImageGlyphAttribute
        let ingredient: IngredientAttribute
    }

    var body: some AttributedTextFormattingDefinition<Scope> {
        IngredientsAreGreen()
    }
}

// Pass the custom formatting definition to the TextEditor:
TextEditor(text: $text, selection: $selection)
    .preference(key: NewIngredientPreferenceKey.self, value: newIngredientSuggestion)
    .attributedTextFormattingDefinition(RecipeFormattingDefinition())
```

## Value constraints
```swift
struct IngredientsAreGreen: AttributedTextValueConstraint {
    typealias Scope = RecipeFormattingDefinition.Scope
    typealias AttributeKey = AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute

    func constrain(_ container: inout Attributes) {
        if container.ingredient != nil {
            container.foregroundColor = .green
        } else {
            container.foregroundColor = nil
        }
    }
}
```

## AttributedStringKey constraints
```swift
struct IngredientAttribute: CodableAttributedStringKey {
    typealias Value = Ingredient.ID

    static let name = "SampleRecipeEditor.IngredientAttribute"

    // Constraint: Inherited by added text
    static let inheritedByAddedText: Bool = false

    // Constraint: Invalidation conditions
    static let invalidationConditions: Set<AttributedString.AttributeInvalidationCondition>? = [.textChanged]

    // Constraint: Run boundaries
    static let runBoundaries: AttributedString.AttributeRunBoundaries? = .paragraph
}
```
