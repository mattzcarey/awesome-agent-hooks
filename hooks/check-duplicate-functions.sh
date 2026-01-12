#!/bin/bash
# Check for duplicate function names in the codebase
# Uses ripgrep to find existing functions with the same name

RG=/opt/homebrew/bin/rg
JQ=/usr/bin/jq

# Read JSON input from stdin
INPUT=$(cat)

# Extract content and file path from the JSON
CONTENT=$(echo "$INPUT" | $JQ -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | $JQ -r '.tool_input.file_path // empty' 2>/dev/null)

# If no content, allow
[ -z "$CONTENT" ] && exit 0

# Get the working directory (default to current)
WORK_DIR=$(pwd)

# Extract function names from the content being written
# Patterns for various languages:
# - JavaScript/TypeScript: function name(, const name = (, async function name(
# - Python: def name(
# - Zig: fn name(, pub fn name(
# - Go: func name(
# - Rust: fn name(, pub fn name(

FUNC_NAMES=$(echo "$CONTENT" | $RG -o '(?:function|async function|const|let|var|def|pub fn|fn|func)\s+([a-zA-Z_][a-zA-Z0-9_]*)' --only-matching -r '$1' 2>/dev/null | sort -u)

# Also catch arrow functions: const name = (
ARROW_FUNCS=$(echo "$CONTENT" | $RG -o '(?:const|let|var)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=' --only-matching -r '$1' 2>/dev/null | sort -u)

# Combine and dedupe
ALL_FUNCS=$(echo -e "$FUNC_NAMES\n$ARROW_FUNCS" | grep -v '^$' | sort -u)

# If no functions found, allow
[ -z "$ALL_FUNCS" ] && exit 0

DUPLICATES=""

while IFS= read -r func_name; do
    [ -z "$func_name" ] && continue

    # Skip very short or common names
    [ ${#func_name} -lt 3 ] && continue

    # Search for existing function definitions with this name
    # Exclude the target file itself, node_modules, and common build directories
    # Pattern: function/fn/def/func followed by name, then optional whitespace, then ( or =
    EXISTING=$($RG -l \
        "(function|async function|const|let|var|def|pub fn|fn|func)\s+${func_name}\s*[(=]" \
        --type-add 'code:*.{js,ts,tsx,jsx,py,zig,go,rs,c,cpp,h,hpp}' \
        --type code \
        --glob '!node_modules/*' \
        --glob '!dist/*' \
        --glob '!build/*' \
        --glob '!.git/*' \
        --glob '!*.min.js' \
        "$WORK_DIR" 2>/dev/null | grep -v "^${FILE_PATH}$" | head -3)

    if [ -n "$EXISTING" ]; then
        # Get more context about where the function is defined
        LOCATIONS=$($RG -n \
            "(function|async function|const|let|var|def|pub fn|fn|func)\s+${func_name}\s*[(=]" \
            --type-add 'code:*.{js,ts,tsx,jsx,py,zig,go,rs,c,cpp,h,hpp}' \
            --type code \
            --glob '!node_modules/*' \
            --glob '!dist/*' \
            --glob '!build/*' \
            --glob '!.git/*' \
            "$WORK_DIR" 2>/dev/null | grep -v "^${FILE_PATH}:" | head -3)

        if [ -n "$LOCATIONS" ]; then
            DUPLICATES="${DUPLICATES}Function '${func_name}' already exists:\n${LOCATIONS}\n\n"
        fi
    fi
done <<< "$ALL_FUNCS"

# If duplicates found, warn (but don't block - exit 0 with message)
if [ -n "$DUPLICATES" ]; then
    echo "DUPLICATE FUNCTION WARNING: Please check if you can use the existing function(s) instead of creating a new one with the same name." >&2
    echo -e "$DUPLICATES" >&2
fi

# Always allow - this is just a warning, not a blocker
exit 0
