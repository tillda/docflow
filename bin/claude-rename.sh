#!/bin/bash
# Rename a Claude Code session from outside the app - no /rename needed.
#
# /rename persists a session's name as one JSON line appended to the session's
# transcript ({"type":"agent-name","agentName":...,"sessionId":...}); the
# /resume picker reads the last such line. This script appends that same
# record, so an externally-set name is indistinguishable from a /rename.
# A tmux-dashboard retitle pass that reads transcripts (claude-dash.sh) picks
# it up on its next tick. The one thing this cannot update is a LIVE session's
# own prompt bar - the running CLI holds its name in memory.
#
# Ships with the docflow plugin (bin/ is on PATH inside sessions) so its
# skills can label their session after the feature they are working on.
#
# Usage:
#   claude-rename.sh <name> [session-id]
#     name        letters/digits/space/._- only (JSON- and tmux-safe)
#     session-id  defaults to $CLAUDE_CODE_SESSION_ID, which Claude Code sets
#                 in its Bash tool - so a skill can rename its own session.

set -euo pipefail

name="${1:-}"
sid="${2:-${CLAUDE_CODE_SESSION_ID:-}}"

if [[ -z "$name" || -z "$sid" ]]; then
  echo "usage: claude-rename.sh <name> [session-id]  (session-id defaults to \$CLAUDE_CODE_SESSION_ID)" >&2
  exit 2
fi

re='^[A-Za-z0-9][A-Za-z0-9 ._-]*$'
if [[ ! "$name" =~ $re ]]; then
  echo "claude-rename: name must match $re (got: $name)" >&2
  exit 2
fi

# Session ids are globally unique, so find the transcript by id alone.
transcript=""
for t in "$HOME"/.claude/projects/*/"$sid".jsonl; do
  [[ -f "$t" ]] && { transcript="$t"; break; }
done
if [[ -z "$transcript" ]]; then
  echo "claude-rename: no transcript found for session $sid" >&2
  exit 1
fi

printf '{"type":"agent-name","agentName":"%s","sessionId":"%s"}\n' "$name" "$sid" >> "$transcript"
echo "claude-rename: session $sid named '$name' (dashboard tab syncs on its next tick)"
