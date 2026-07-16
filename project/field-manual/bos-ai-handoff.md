# BOS-AI Handoff Guide

How business strategy documents flow from BOS-AI into an AGENT-11 dev project — and who owns them afterwards.

## Roles

| Framework | Job | Produces |
|-----------|-----|----------|
| **BOS-AI** (business repo) | Defines WHAT to build | Foundation documents: PRD, vision, ICP, brand, positioning, roadmap, research, marketing, pricing |
| **AGENT-11** (dev repo) | Builds HOW | Working software, architecture, project plan |

The PRD is the bridge artifact. Everything else is supporting context.

## The ownership-transfer rule

**The handoff is a release, not the start of a sync obligation.**

When you copy foundation documents into the dev repo and run `/foundations init`, ownership of the PRD and all product-shaped documents transfers permanently to the dev repo:

- All post-handoff edits happen in the dev repo (`documents/foundations/`), followed by `/foundations refresh`.
- The business repo keeps a one-line pointer, not copies: `Authoritative copy: <dev-repo>/documents/foundations/`.
- Never copy documents back and forth after handoff. The source of truth always migrates to where build decisions are made — fighting that with manual syncing produces stale, diverged copies.

The business repo remains the home for documents you operate a *business* with (marketing execution, sales, finance). Product definition lives with the product.

## Two entry tiers

### Tier 1 — Full handoff (products with business ambitions)

You've run BOS-AI's foundation process in a business repo and have the document suite.

```bash
# In your new dev project (after installing AGENT-11)
mkdir -p documents/foundations
cp ~/BusinessProjects/<product>-Business/documents/foundation/*.md documents/foundations/

/foundations init     # scan, validate, extract to structured YAML
/architect            # optional: architecture design pass
/bootstrap            # generate project-plan.md from the extracts
/coord continue       # start building
```

Then apply the ownership-transfer rule: replace the copied files in the business repo with a pointer.

### Tier 2 — Lite (ad-hoc products, no BOS-AI)

For smaller builds — a tool, an open-source utility, an experiment — skip BOS-AI entirely. All you need is a PRD.

```bash
# Have a draft spec? Drop it in directly:
mkdir -p documents/foundations
cp ~/wherever/my-spec.md documents/foundations/prd.md

# Or create one from scratch with the strategist:
# @strategist Create a PRD for <idea> and save it to documents/foundations/prd.md

/foundations init
/bootstrap
/coord continue
```

Same rail, one document instead of nine. A vision document is recommended for SaaS products (`/bootstrap` expects one for saas project types) but optional for tools and libraries.

## What `/foundations` produces

- `.context/structured/<category>.yaml` — structured extraction of each document (what build agents actually consume)
- `handoff-manifest.yaml` — source paths, checksums, extraction status
- Validation report — `prd` is required; other categories are advisable

See `/foundations` command documentation for the filename→category mapping table and extraction details. Schemas for each category are installed to `schemas/foundation-*.schema.yaml`.

## Updating documents after handoff

1. Edit the document in the dev repo's `documents/foundations/`.
2. Run `/foundations refresh` — changed files are re-extracted (checksum-detected).
3. If the change affects the plan, run `/plan` to reconcile `project-plan.md`.

Do not edit the business repo's copy — it no longer exists (you replaced it with a pointer).

## Do I need BOS-AI at all?

| Situation | Path |
|-----------|------|
| Real product, business model, marketing, pricing to figure out | BOS-AI first, then Tier 1 handoff |
| You already know what to build and just need it built well | Tier 2: write the PRD, skip BOS-AI |
| Existing codebase, no foundation docs | `/coord dev-alignment` to analyze it, then add a PRD when ready |

## Troubleshooting

- **`/foundations` finds no documents**: files must be in `documents/foundations/` (plural), named so the category mapper recognizes them — `prd.md`, `vision.md`, `brand-style-guide.md`, etc. Check the mapping table in the command docs.
- **`/bootstrap` refuses to run**: it requires `handoff-manifest.yaml` and `.context/structured/prd.yaml` — run `/foundations init` first.
- **Development drifts from the vision**: the extracts are stale. Run `/foundations refresh` after every document edit.
