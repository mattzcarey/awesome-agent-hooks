#!/bin/bash
# Block dynamic imports like: await import("./something")
# Uses ripgrep for fast pattern matching

RG=/opt/homebrew/bin/rg
JQ=/usr/bin/jq

# Read JSON input from stdin
INPUT=$(cat)

# Extract content/new_string from the JSON (handles both Write and Edit tools)
CONTENT=$(echo "$INPUT" | $JQ -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)

# If no content, allow
[ -z "$CONTENT" ] && exit 0

# Check for dynamic imports using ripgrep (FAST!)
# Pattern matches: await import(
if echo "$CONTENT" | $RG -q 'await\s+import\s*\('; then
    echo "BLOCKED: Dynamic import detected (await import(...))" >&2
    echo "Use static imports instead: import { x } from 'module'" >&2
    exit 2
fi

# Allow the operation
exit 0
