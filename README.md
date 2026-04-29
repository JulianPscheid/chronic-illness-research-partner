# chronic-illness-research-partner

A Claude Code skill that scaffolds a long-running personal research project for someone with a refractory or complex chronic illness, configuring AI as a research partner rather than a tracker or symptom logger.

## What it does

Run the skill once. It interviews you for ~10 minutes (13 questions across identity, clinical context, working style, and research-methodology calibration) and generates a tailored repo at `~/{ConditionSlug}Research/` containing:

- `CLAUDE.md` — the operating contract every future session in the repo follows
- `meta/standards.md` — universal evidence-discipline rules + condition-specific TODO sections you fill during your first session ("frontier scan")
- `meta/research-methodology.md` — standalone search, round-trip, and quote-bank protocols
- `meta/frontier-scan-status.md` — the gate file: candidate-treatment work is refused until the frontier scan is complete
- Skeleton intake (journey, treatments, current state, constraints, diagnostics, open questions), treatments (tried, current, candidates, ruled-out), causes, mechanisms, literature (papers, topics, searches, sources, landmark papers), data, clinician (visits, pre-visit), and notes directories

After setup, the skill is done. The persistent discipline lives in the generated repo's `CLAUDE.md`.

## Who it's for

- Adults with a refractory or complex chronic illness — or caregivers researching on their behalf — who want AI as a research partner across many sessions.
- People who already work with at least one specialist clinician.
- People comfortable engaging with primary literature at the abstract-and-methods level, or motivated to grow into that comfort.

## Who it's not for

- Symptom tracking or logging (existing apps do this).
- Diagnosis. The skill assumes a working diagnostic label, contested or not.
- Replacing a clinician. Output is refined questions and candidate lists, not prescriptions.
- Basic patient education. If you need your condition's standard diagnostic criteria explained, you are not the floor.

## What you get on day one

A walkthrough of the operating contract, then a prompt to do your first session: the **frontier scan**. This is mandatory. The skill generates `meta/frontier-scan-status.md` with a checklist; treatment-candidate work is gated on its completion. The Claude instance running in the generated repo will refuse to create `treatments/candidates/*` files until the scan is marked complete.

This is not gatekeeping for its own sake. The "why is this not just repeating the standard treatment ladder?" rule (the core candidate-discipline rule) cannot be applied without knowing what the standard ladder is for your condition. The frontier scan is what populates that knowledge with cited sources.

## Install

Method A (v1):

```bash
git clone https://github.com/JulianPscheid/chronic-illness-research-partner.git ~/.claude/skills/chronic-illness-research-partner/
```

(Or whatever your Claude Code installation uses for the skills directory.)

Method B (future): Claude Code plugin install — not yet supported.

## Usage

Open a Claude Code session and either:
- invoke the skill by name: `/chronic-illness-research-partner`, or
- describe what you want: "I want to set up a long-running research project on my [condition]."

The skill will run the interview, confirm the target path, generate the repo, and commit the initial scaffold. Expect ~10 minutes for the interview plus generation.

## Privacy

**The repo this skill generates will accumulate personal health information.** Even seemingly-innocuous notes — combinations of condition, region, and treatment history — can re-identify you. Do not push the generated repo to a public remote without an explicit redaction review.

The skill repo (this one) contains zero patient data and is safe to share.

## Examples

See `examples/sample-generated-CLAUDE.md` for a worked example for a fictional refractory long COVID case.

## Methodology

See `docs/methodology.md` for long-form rationale: why "research partner" framing, why evidence tags + applicability annotation, why PMID/DOI round-trip and quote bank, why the why-not-standard-ladder rule, why the mandatory frontier scan, why the outgoing-communications anti-AI-tells.

## License

MIT. See `LICENSE`.

## Contributing

Issues and PRs welcome. Worth a heads-up before opening a large PR:

- **Methodology changes** (evidence tags, frontier-scan gate, candidate discipline, anti-AI-tells): start with an issue describing the case for the change. The methodology is opinionated by design; changes need a reason beyond preference.
- **Template content tweaks** (wording, generalization, condition-agnostic phrasing): smaller PRs are fine to open directly.
- **New condition-specific knowledge baked into the skill**: out of scope. The skill stays condition-agnostic; condition-specific definitions belong in the user's own `meta/standards.md` after the frontier scan.
- **Run `./scripts/validate.sh`** before submitting. If a check fails, fix the underlying file rather than weakening the check.
