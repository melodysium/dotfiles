#!/bin/bash
input=$(cat)
success=$(printf '%s' "$input" | jq -r '.tool_response.success // true')
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

[ "$success" = "true" ] || exit 0
printf '%s' "$cmd" | grep -qE '(^|[;&|]|[[:space:]])jj[[:space:]]+(commit|describe)([[:space:]]|$)' || exit 0

rev='@'
printf '%s' "$cmd" | grep -qE '(^|[;&|]|[[:space:]])jj[[:space:]]+commit([[:space:]]|$)' && rev='@-'

desc=$(jj log -r "$rev" -T 'description' --no-graph --color=never 2>/dev/null)
[ -n "$desc" ] || exit 0
printf '%s' "$desc" | grep -q 'Co-Authored-By: Claude' && exit 0

newdesc=$(printf '%s\n\nCo-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>' "$desc")
jj describe -r "$rev" -m "$newdesc" >/dev/null 2>&1
