<!-- Thanks for the PR. Quick checklist below — please fill in. -->

## What this PR does

<!-- 1–3 sentence summary of the change. -->

## Type of change

- [ ] Bug fix
- [ ] Template wording / generalization tweak
- [ ] Methodology change (linked issue: #___ )
- [ ] Documentation
- [ ] Other:

## Pre-submit checklist

- [ ] `./scripts/validate.sh` passes
- [ ] If this is a methodology change, a prior issue exists and was given a green light
- [ ] If any template changed, I re-ran `./scripts/render-fixture.sh 1` and read through `examples/sample-generated-CLAUDE.md` to confirm it still renders cleanly
- [ ] I did NOT add condition-specific knowledge to the skill (the skill stays condition-agnostic; condition-specific definitions belong in the user's own `meta/standards.md` after the frontier scan)
- [ ] No personal health information, real patient names, or private project paths anywhere in the diff

## Notes for the reviewer

<!-- Anything worth flagging — breaking changes, things you're unsure about, edge cases, alternatives you considered. -->
