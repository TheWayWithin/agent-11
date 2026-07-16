# BOS-AI ↔ AGENT-11 Integration

**Status**: This document has been superseded.

The implemented handoff between BOS-AI and AGENT-11 is documented in
**[project/field-manual/bos-ai-handoff.md](project/field-manual/bos-ai-handoff.md)**.

In short:

- BOS-AI (business repo) defines WHAT to build; AGENT-11 (dev repo) builds it.
- The PRD is the bridge artifact. Copy foundation documents into the dev repo's
  `documents/foundations/`, run `/foundations init`, then `/bootstrap`.
- The handoff is a **one-time release with ownership transfer**: after it, the dev
  repo owns the PRD and all product-shaped documents. The business repo keeps a
  pointer, not copies. There is no ongoing sync, by design.
- Ad-hoc builds skip BOS-AI entirely (lite tier): a single `documents/foundations/prd.md`
  enters the same `/foundations` → `/bootstrap` rail.

The earlier "document bundle / validation gateway / progress report" architecture
described in previous versions of this file was a design proposal that was not
implemented. Historical design material remains in
`BOS-AI-AGENT-11-INTEGRATION-ARCHITECTURE.md`, `INTEGRATION-STANDARDS.md`, and
`WORKFLOWS.md` — treat those as archive, not instructions.
