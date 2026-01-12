# Awesome Agent Hooks

A collection of useful hooks for Claude Code and OpenCode.

## Installation

### Claude Code

Copy hooks to `~/.claude/hooks/` and configure in `~/.claude/settings.json`.

### OpenCode

Copy hooks to `~/.config/opencode/hooks/` and configure in your opencode settings.

## Hooks

### check-duplicate-functions.sh

Warns when you're creating a function that already exists elsewhere in the codebase. Helps prevent code duplication.

**Trigger**: `PostToolUse` on `Write` and `Edit` tools

**Behavior**: Warning only (doesn't block)

**Supported languages**: JavaScript, TypeScript, Python, Zig, Go, Rust, C/C++

### no-dynamic-imports.sh

Blocks dynamic imports in favor of static imports. Detects patterns like `await` followed by `import()`.

**Trigger**: `PreToolUse` on `Write` and `Edit` tools

**Behavior**: Blocks with exit code 2

## Configuration Example

Add to your `settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/check-duplicate-functions.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/no-dynamic-imports.sh"
          }
        ]
      }
    ]
  }
}
```

## License

MIT
