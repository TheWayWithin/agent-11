# BOS-AI Handoff Example: TaskFlow

A realistic example of BOS-AI foundation documents, ready for the AGENT-11 handoff rail. Use it to learn the expected format before your first handoff, or as a test fixture for the workflow.

**Project**: TaskFlow — a simple task management SaaS for solopreneurs.

## Directory structure

```
examples/bos-ai-integration/
├── README.md                        # This file
└── documents/foundations/
    ├── prd.md                       # Product requirements (required)
    ├── vision.md                    # Long-term product vision
    ├── brand-style-guide.md         # Brand identity and voice
    └── market-research.md           # Business context and market analysis
```

The filenames matter: `/foundations` maps files to categories by name (`prd.md` → prd, `vision.md` → vision, `brand-style-guide.md` → brand, `market-research.md` → research). See the `/foundations` command documentation for the full mapping table.

## Try the workflow

```bash
# In a scratch directory with AGENT-11 installed:
mkdir taskflow-test && cd taskflow-test
# ... install AGENT-11 ...

# Copy the example documents in
cp -r <agent-11-repo>/examples/bos-ai-integration/documents ./

# Run the rail
/foundations init      # scan + extract to .context/structured/
/bootstrap             # generate project-plan.md
/coord continue        # start building
```

## What each document contributes

| File | Role | Category |
|------|------|----------|
| `prd.md` | The WHAT: features, user stories, acceptance criteria, success metrics | prd (required) |
| `vision.md` | The future: long-term goals, MVP scope prioritization | vision |
| `brand-style-guide.md` | The style: visual identity, tone, design principles | brand |
| `market-research.md` | The why: market opportunity, pain points, competition | research |

Only the PRD is required. This is the **lite tier** in practice: a single `documents/foundations/prd.md` is enough to run `/foundations init` → `/bootstrap`. The other documents enrich design and prioritization decisions when present.

## Format guidelines

- Standard Markdown: H2/H3 headers, bullet lists, bold for emphasis.
- User stories in INVEST format with testable acceptance criteria.
- MVP scope clearly separated from future features.
- Technical constraints stated with rationale.

## After the handoff

The copy is a one-time release. Once documents are in the dev repo, the dev repo owns them — edit them there and run `/foundations refresh`. Don't maintain parallel copies in the business repo. Full rationale: [BOS-AI Handoff Guide](../../project/field-manual/bos-ai-handoff.md).

## Helpful resources

- [BOS-AI Handoff Guide](../../project/field-manual/bos-ai-handoff.md) — the canonical handoff documentation
- [Getting Started](../../project/field-manual/getting-started.md) — AGENT-11 basics
