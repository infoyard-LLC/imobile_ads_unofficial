#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

forbidden_regex='(^|/)(imobileSdkAds\.jar|ImobileSdkAds\.xcframework($|/)|imobile_for_SP_app_[^/]*($|/))|(^|/)ios/Frameworks/|(^|/)android/libs/.*\.(jar|aar)$'

fail_if_forbidden() {
  local label="$1"
  local input="$2"
  local matches
  matches="$(printf '%s\n' "$input" | grep -Ei "$forbidden_regex" || true)"
  if [[ -n "$matches" ]]; then
    echo "ERROR: Forbidden i-mobile SDK content found in ${label}:" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

# 1. Block prohibited files even when they are untracked.
filesystem_entries="$({
  find . -path './.git' -prune -o \
    \( -type f -o -type d \) \
    \( -iname 'imobileSdkAds.jar' \
       -o -iname 'ImobileSdkAds.xcframework' \
       -o -path './ios/Frameworks/*' \
       -o -path './android/libs/*.jar' \
       -o -path './android/libs/*.aar' \
       -o -iname 'imobile_for_SP_app_*' \) \
    -print
} || true)"
fail_if_forbidden "working tree" "$filesystem_entries"

# 2. Block prohibited content in Git history's current index.
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  fail_if_forbidden "Git index" "$(git ls-files)"
fi

# 3. Verify the exact pub.dev upload candidate.
if command -v flutter >/dev/null 2>&1; then
  publish_cmd=(flutter pub publish --dry-run)
elif command -v dart >/dev/null 2>&1; then
  publish_cmd=(dart pub publish --dry-run)
else
  echo "ERROR: Flutter or Dart is required to run the publication dry-run." >&2
  exit 1
fi

dry_run_log="$(mktemp)"
trap 'rm -f "$dry_run_log"' EXIT

"${publish_cmd[@]}" 2>&1 | tee "$dry_run_log"
fail_if_forbidden "pub publish --dry-run output" "$(cat "$dry_run_log")"

echo "OK: No prohibited i-mobile SDK binaries are present or scheduled for publication."
