# Project Overview

This is a SwiftUI-based iOS application with a structured foundation ready for development.

## Architecture

The project follows a classic iOS MVVM architecture with clear separation:

- **`/Tayan/`** - Main app code with SwiftUI App lifecycle (`TayanApp.swift`)
- **`/Models/`** - Data models
- **`/ViewModels/`** - Business logic and state management
- **`/Views/`** - SwiftUI views with `/Components/` for reusable UI elements
- **`/Services/`** - External integrations and data persistence
- **`/Playgrounds/`** - Development experimentation space

## Project Configuration

- **Target**: iOS 26.0+

## Development Guidelines

- First look up the latest API references below to check if needed for the task
- Respect the established folder structure and feel free to add new folders as needed
- Follow industry best practices for separation of concerns and object-oriented design
- Don't duplicate code in different places; instead, create reusable components, functions, structs, or classes
- Follow SwiftUI best practices with declarative UI patterns
- Place reusable UI components in `Views/Components/`
- SwiftUI views should include `#Preview` blocks for development
- Create simple scripts in `/Playgrounds/` for testing new features or APIs
- Ignore warnings like `module unavailable` or `type unavailable` since they are available in the latest iOS SDK configured in the project
  - e.g. `FoundationModels` is available in iOS 26.0+ but may show as unavailable in earlier SDKs

## Latest API References

- [FoundationModels Basics](./instructions/FoundationModels_Basics.md)
- [FoundationModels DeepDive](./instructions/FoundationModels_DeepDive.md)
- [Rich TextEditor with AttributedString](./instructions/RichTextEditorWithAttributedString_Basics.md)
