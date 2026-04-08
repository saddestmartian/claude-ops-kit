## Swift / SwiftUI Conventions

### Architecture
- Use MVVM with `@Observable` (Swift 5.9+) or `ObservableObject` for view models
- Keep Views thin — business logic in view models, data logic in services/repositories
- Use dependency injection (environment objects or initializer injection)

### SwiftUI Patterns
- Prefer `@State` for local view state, `@Binding` for parent-child, `@Environment` for app-wide
- Extract reusable views into their own files when used in 2+ places
- Use `ViewModifier` for reusable styling, not extension methods on View
- Prefer `task {}` over `onAppear` for async work (cancellation built in)

### Concurrency
- Use structured concurrency (`async/await`, `TaskGroup`) over GCD
- Mark main-actor-isolated types with `@MainActor`
- Never block the main thread with synchronous I/O

### Error Handling
- Use `Result<T, Error>` for functions that can fail in expected ways
- Use `throws` for functions that can fail in unexpected ways
- Never force-unwrap (`!`) in production code — use `guard let` or `if let`

### Naming
- Follow Swift API Design Guidelines: clarity at the point of use
- Use grammatical English phrases for method names: `insert(item, at: index)`
- Boolean properties read as assertions: `isEmpty`, `isValid`, `hasContent`
