#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

step() { printf '\n=== %s ===\n' "$1"; }
ok() { printf '  OK\n'; }
fail() { printf '  FAIL: %s\n' "$1"; FAIL=1; }

step "1. Public-surface files present"
for f in SKILL.md README.md LICENSE docs/methodology.md examples/sample-generated-CLAUDE.md; do
  test -r "$ROOT/$f" && echo "  found: $f" || fail "missing: $f"
done

step "2. SKILL.md frontmatter description ≤200 chars"
desc_len=$(awk '/^description:/ { sub(/^description: /, ""); print length($0); exit }' "$ROOT/SKILL.md")
if [ "$desc_len" -le 200 ]; then echo "  description length: $desc_len"; ok; else fail "description length $desc_len > 200"; fi

step "3. Templates exist for every required file"
for t in templates/CLAUDE.md.tmpl templates/README.md.tmpl templates/meta/standards.md.tmpl templates/meta/research-methodology.md.tmpl templates/meta/frontier-scan-status.md.tmpl templates/meta/decisions.md.tmpl templates/treatments/candidates/README.md.tmpl templates/treatments/tried.md.tmpl templates/treatments/current.md.tmpl templates/treatments/ruled-out.md.tmpl templates/intake/journey.md.tmpl templates/intake/treatments.md.tmpl templates/intake/current-state.md.tmpl templates/intake/constraints.md.tmpl templates/intake/diagnostics.md.tmpl templates/intake/open-questions.md.tmpl templates/literature/sources.md.tmpl templates/literature/news-sources.md.tmpl templates/literature/landmark-papers.md.tmpl; do
  test -r "$ROOT/$t" && echo "  found: $t" || fail "missing template: $t"
done

step "4. Redaction grep — no source-specific terms in any tracked file"
# Strip comment lines and blank lines from redaction-terms.txt before grep
TERMS_FILE="$(mktemp)"
trap "rm -f '$TERMS_FILE'" EXIT
test -r "$ROOT/docs/internal/redaction-terms.txt" || { fail "missing docs/internal/redaction-terms.txt (must exist locally even though it is gitignored)"; }
grep -v '^#' "$ROOT/docs/internal/redaction-terms.txt" | grep -v '^$' > "$TERMS_FILE"

# Scan every tracked file (i.e. every file that will be public on push).
# git ls-files honors .gitignore so internal/superpowers paths are excluded automatically.
TRACKED="$(cd "$ROOT" && git ls-files)"
hits=""
while IFS= read -r f; do
  [ -n "$f" ] || continue
  # Skip the term file itself if somehow tracked (it should be gitignored)
  case "$f" in docs/internal/*) continue ;; esac
  match=$(grep -i -H -n -F -f "$TERMS_FILE" "$ROOT/$f" 2>/dev/null || true)
  if [ -n "$match" ]; then
    hits="${hits}${match}
"
  fi
done <<< "$TRACKED"

if [ -z "$hits" ]; then ok; else printf '%s' "$hits"; fail "redaction terms found in tracked files"; fi

step "5. Placeholder grep — no leaked {{...}} in fixture renders"
if [ -d "$ROOT/scripts/renders" ]; then
  leaked=$(grep -r -E '\{\{[a-z_]+\}\}' "$ROOT/scripts/renders/" | grep -v -F '<!-- ' | grep -v -F '```' || true)
  if [ -z "$leaked" ]; then ok; else echo "$leaked"; fail "leaked placeholders in renders"; fi
else
  echo "  no renders/ directory; skipping (re-run scripts/render-fixture.sh first)"
fi

step "6. frontier-scan-status template has machine-readable status"
grep -q '^status: incomplete$' "$ROOT/templates/meta/frontier-scan-status.md.tmpl" && ok || fail "frontier-scan-status template missing status: incomplete frontmatter line"

step "7. CLAUDE.md template carries safety-floor sentence verbatim"
grep -q "disclaimers-off relaxes routine hedging, never emergency triage" "$ROOT/templates/CLAUDE.md.tmpl" && ok || fail "safety-floor sentence missing or modified"

step "8. CLAUDE.md template has all 10 required H2 sections"
for h in "## Role" "## Context" "## Working style" "## Epistemic discipline" "## Research methodology" "## Frontier-scan gate" "## Candidate discipline" "## Population" "## Outgoing communications" "## Repository layout"; do
  grep -qF "$h" "$ROOT/templates/CLAUDE.md.tmpl" && echo "  found: $h" || fail "missing: $h"
done

step "9. standards.md template has all 8 condition-specific TODO sections"
todos=$(grep -c "TODO: fill during frontier scan" "$ROOT/templates/meta/standards.md.tmpl")
if [ "$todos" -ge 8 ]; then echo "  found $todos TODO sections"; ok; else fail "expected ≥8 TODO sections, found $todos"; fi

step "10. SKILL.md does not reference the /research skill"
# Match the /research slash-command (not /research-methodology, which is a legit file in the generated repo)
# or the research-recipes.md file shipped with the /research skill.
if grep -E '(^|[^-A-Za-z])/research([^-A-Za-z]|$)|research-recipes' "$ROOT/SKILL.md" "$ROOT/templates/meta/research-methodology.md.tmpl"; then fail "leaked /research skill reference"; else ok; fi

if [ "$FAIL" -eq 0 ]; then
  printf '\nALL CHECKS PASSED.\n'
  exit 0
else
  printf '\nVALIDATION FAILED. See output above.\n' >&2
  exit 1
fi
