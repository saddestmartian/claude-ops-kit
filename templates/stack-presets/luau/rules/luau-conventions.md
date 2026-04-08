## Luau / Roblox Conventions

### Tooling
- **Selene** for linting (`selene src/` — std = "roblox")
- **StyLua** for formatting (`stylua --check src/`)
- **Wally** for package management (`wally.toml` + `wally.lock`)
- **Argon** for filesystem ↔ Studio sync (two-way, use server priority)

### Code Patterns
- Use `local` for all variables — never globals
- Use `task.delay()` over `wait()` (deprecated)
- Guard delayed `:Destroy()` calls: `if frame and frame.Parent then frame:Destroy() end`
- Use `os.clock()` for elapsed time, `os.time()` for persistent timestamps — never `tick()` (deprecated)

### Roblox API Safety
- `PromptBulkPurchase`: 20 items max, `Id` field MUST be `tostring(assetId)` (string, not number)
- `GetBatchItemDetails`: 100 req/sec experience-wide, throws 406 on deleted/moderated items
- `PlayerOwnsAsset` is stale after bulk purchase — trust engine event status instead
- `PromptBulkPurchaseFinished` does NOT fire in Studio — only in live with real Robux

### Studio Testing Limitations
- `Camera.ViewportSize` always reports Studio editor viewport, not emulated device
- `UserInputService.TouchEnabled` always returns `false` in Studio
- Use `workspace:SetAttribute("DebugBreakpoint", "mobile")` to force responsive breakpoints

### Module Pattern
```lua
local MyModule = {}

function MyModule.init()
    -- setup
end

function MyModule.doSomething()
    -- implementation
end

return MyModule
```
