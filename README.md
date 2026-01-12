# Awesome Agent Hooks

A collection of useful hooks for Claude Code and OpenCode.

## Hooks

| Hook | Description | Trigger | Behavior |
|------|-------------|---------|----------|
| [check-duplicate-functions.sh](hooks/check-duplicate-functions.sh) | Warns when creating a function that already exists in the codebase | `PostToolUse` on Write/Edit | Warning |
| [no-dynamic-imports.sh](hooks/no-dynamic-imports.sh) | Blocks dynamic imports in favor of static imports | `PreToolUse` on Write/Edit | Blocks |

## Installation

### Claude Code

```bash
# Copy hooks
cp hooks/*.sh ~/.claude/hooks/

# Make executable
chmod +x ~/.claude/hooks/*.sh
```

Then configure in `~/.claude/settings.json`.

### OpenCode

```bash
# Copy hooks
mkdir -p ~/.config/opencode/hooks
cp hooks/*.sh ~/.config/opencode/hooks/

# Make executable
chmod +x ~/.config/opencode/hooks/*.sh
```

## Configuration Example

Add to your `settings.json`:

```json
{
  "hooks": {
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
    ],
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
    ]
  }
}
```

## License

MIT
