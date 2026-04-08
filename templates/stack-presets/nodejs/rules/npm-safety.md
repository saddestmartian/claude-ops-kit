## Node.js Conventions

### Package Management
- Never run `npm install <package>` without user approval — adding dependencies is a project decision
- Always commit `package-lock.json` changes
- Prefer `npm ci` over `npm install` in CI/automated contexts
- Check for outdated packages periodically: `npm outdated`

### Code Patterns
- Use `async/await` over raw Promises or callbacks
- Always handle rejected promises — unhandled rejections crash the process in Node 15+
- Use `const` by default, `let` when reassignment is needed, never `var`
- Prefer named exports over default exports for discoverability

### Error Handling
- At system boundaries (API endpoints, CLI entry points): catch, log, and return appropriate error responses
- Internal code: let errors propagate — don't catch-and-rethrow without adding context
- Never swallow errors silently (`catch (e) {}`)

### Security
- Never use `eval()` or `new Function()` with user input
- Validate and sanitize all external input (request bodies, query params, headers)
- Use parameterized queries for database access — never string concatenation
- Keep secrets in environment variables, never in code
