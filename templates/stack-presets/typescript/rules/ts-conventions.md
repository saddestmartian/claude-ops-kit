## TypeScript Conventions

### Type Safety
- Use `strict: true` in tsconfig.json — no exceptions
- Prefer interfaces over type aliases for object shapes (interfaces are extendable, have better error messages)
- Never use `any` — use `unknown` and narrow, or define a proper type
- Use discriminated unions over optional fields for state variants
- Prefer `as const` over enum for string constants

### Module Patterns
- Use ES module syntax (`import`/`export`), not CommonJS (`require`)
- Barrel files (`index.ts`) are acceptable for public API surfaces, but avoid deep re-exports
- Keep type imports separate: `import type { Foo } from './foo'`

### Error Handling
- Define error types — don't throw raw strings
- Use Result/Either patterns for expected failure cases (validation, parsing)
- Reserve exceptions for unexpected failures (network errors, bugs)

### Naming
- PascalCase: types, interfaces, classes, React components
- camelCase: variables, functions, methods
- SCREAMING_SNAKE_CASE: constants
- Prefix interfaces with `I` only if there's a concrete class with the same name (otherwise no prefix)
