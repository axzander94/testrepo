# JustScan — Kiro Pipeline: Day-to-Day Activity Guide

> **Who this is for:** Everyone on the JustScan team — developers, tech leads, BAs  
> **What this covers:** Every common situation you will encounter, with exact prompts to use  
> **Prerequisite:** `.kiro/` folder is committed to your repo and MCP connections are green in Kiro

---

## The 30-Second Mental Model

```
You have an idea or a task
         ↓
Switch to the right agent
         ↓
Type one prompt
         ↓
Review output → decide to publish or keep local
         ↓
Continue to next stage or hand off to developer
```

Every stage writes files to `.kiro/specs/[feature-name]/` regardless of what you publish.  
Confluence and Jira are mirrors. Your local specs folder is always the source of truth.

---

## Agent Reference Card

| Agent | When to Use | Switch Command |
|---|---|---|
| `confluence-sync` | Confluence docs have been updated — resync steering files | `/agent swap confluence-sync` |
| `idea-to-epic` | Starting from a rough idea or stakeholder brief | `/agent swap idea-to-epic` |
| `design-analyst` | Figma designs are ready and you want UI requirements extracted | `/agent swap design-analyst` |
| `intake-processor` | Have a Confluence URL, Jira Epic ID, or exported files to process | `/agent swap intake-processor` |
| `req-analyst` | `intake-manifest.md` exists — analyse requirements against the codebase | `/agent swap req-analyst` |
| `tech-spec-writer` | `requirements.md` is READY — write the technical design and task list | `/agent swap tech-spec-writer` |
| `gherkin-writer` | `design.md` exists — generate Gherkin test cases | `/agent swap gherkin-writer` |
| `arb-prep` | ARB review is needed — generate the full submission package | `/agent swap arb-prep` |
| `arch-pipeline` | Run the full pipeline or continue from a known stage | `/agent swap arch-pipeline` |

---

## Activity 1: First-Time Setup on a New Machine

Do this once when you first clone the repo, and again whenever your Confluence architecture pages are updated.

```
/agent swap confluence-sync

Sync steering files from these Confluence pages:
- Tech stack: https://confluence.company.com/display/JS/Tech-Stack
- Architecture standards: https://confluence.company.com/display/JS/ARB-Standards
- Project overview: https://confluence.company.com/display/JS/JustScan-Overview
```

**What happens:**
- Agent fetches all three pages live via Atlassian MCP
- Rewrites `.kiro/steering/tech-stack.md`, `arch-standards.md`, `project-knowledge.md`
- Adds sync timestamp to each file
- Preserves any steering file sections that do not exist in Confluence

**Output:**
```
✅ CONFLUENCE SYNC COMPLETE
  tech-stack.md        → synced from [URL]
  arch-standards.md    → synced from [URL]
  project-knowledge.md → synced from [URL]
```

**When to re-run:** Any time an architecture decision, tech stack update, or ARB standard changes in Confluence. Takes 2 minutes.

---

## Activity 2: Starting a Feature From a Rough Idea

Use this when a product owner, architect, or stakeholder brings you a feature request and you need to turn it into something the team can act on.

**Step 1 — Switch agent and describe the idea**

```
/agent swap idea-to-epic

I want to add a wave distribution preview to the Gift Catalogs 
module in the backoffice. Content managers currently configure 
waves blind — they cannot see how codes will be distributed 
per day before saving.

Affected component: Backoffice
Module: Gift Catalogs
Markets: EU and AP
Does NOT touch YOTI, OneTrust, or PMI databases.
Out of scope: editing live waves that have already started.
Success metric: reduce wave misconfiguration support tickets by 50%.
```

**Step 2 — Answer any follow-up questions**

The agent may ask for missing context (persona, deadline, competing approaches). Answer in plain text.

**Step 3 — Review the generated summary**

The agent outputs a section preview — not the full document. Check:
- Section 3 (MVPs) — does the phasing make sense?
- Section 6 (Scope) — anything wrongly included or excluded?
- Section 12 (Risks) — anything flagged you need to action?
- Section 13 (Open Questions) — assign owners and due dates

**Step 4 — Decide what to do with it**

```
What would you like to do?
  A) Publish to Confluence as-is
  B) Modify specific sections first
  C) Keep locally only
  D) Continue pipeline without publishing
```

If publishing:
```
A — publish under:
https://confluence.company.com/display/JS/Product-Epics
```

**What is generated:**
```
.kiro/specs/gift-wave-preview/
├── epic.md              ← 13-section Epic document
└── intake-manifest.md   ← requirements pre-extracted with REQ-IDs
```

---

## Activity 3: Processing a Confluence Page or Jira Epic (Live MCP)

Use this when requirements already exist in Confluence or Jira and you want to pull them into the pipeline without manual exports.

**Option A — You have a Confluence requirements page:**
```
/agent swap intake-processor

Feature: campaign-ab-testing
Confluence URL: https://confluence.company.com/display/JS/Campaign-AB-Testing-Requirements
```

**Option B — You have a Jira Epic:**
```
/agent swap intake-processor

Feature: campaign-ab-testing
Jira Epic: JS-1234
```

**Option C — Both (recommended when available):**
```
/agent swap intake-processor

Feature: campaign-ab-testing
Confluence URL: https://confluence.company.com/display/JS/Campaign-AB-Testing-Requirements
Jira Epic: JS-1234
```

**What happens:**
- Agent fetches the Confluence page and all child pages
- Fetches the Jira Epic and ALL child stories and sub-tasks
- Cross-references them — flags UNTRACKED (doc with no Jira story) and UNDOCUMENTED (Jira story with no Confluence backing)
- If `epic.md` already exists → runs in ENRICHMENT MODE, merges without overwriting
- Writes `enrichment-log.md` documenting every addition, confirmation, and conflict

**⚠️ Gate 1 — Conflicts**

If conflicts are found between Confluence and epic.md:
```
⚠️ CONFLICTS FOUND
  REQ-007: Wave minimum duration
    epic.md says:    "1 day minimum"
    Confluence says: "3 days minimum"
```
Tell the agent which version is correct before continuing.

---

## Activity 4: Processing Files When MCP Is Unavailable

Use this when you are offline, on VPN, or Confluence/Jira is down.

**Step 1 — Export from Confluence:**
Open the page → `...` menu → Export → HTML → save to:
```
.kiro/intake/requirements/campaign-ab-testing.html
```

**Step 2 — Export from Jira:**
Open the Epic → Export → Excel CSV (all fields) → save to:
```
.kiro/intake/jira-export/JS-1234-export.csv
```

**Step 3 — The hook fires automatically**

When you save a file to `.kiro/intake/`, the `intake-watcher` hook activates and asks:
1. Feature name?
2. Relevant source directories?
3. Do you have a Confluence URL or Jira ID to fetch live via MCP too?
4. Run full pipeline or just intake-processor?

**Step 4 — Run intake-processor**
```
/agent swap intake-processor

Feature: campaign-ab-testing
Source mode: FILE
```

---

## Activity 5: Adding Figma Designs to the Pipeline

Figma is optional. Run this whenever designs become available — before or after intake-processor.

**Getting the Figma URL:**
In Figma: right-click any frame → Copy link to selection. The URL must contain `node-id`.

```
/agent swap design-analyst

Feature: gift-wave-preview
Figma URL: https://www.figma.com/design/abc123/JustScan?node-id=42-1
Cross-reference with epic.md: yes
Are these final designs or WIP? Final
```

**What is extracted:**
- Screen inventory with breakpoints (desktop/tablet/mobile)
- Component breakdown — which exist in codebase, which need building
- UI requirements in EARS format tagged `UI-XXX`
- Copy strings for the Translations module
- Design token mapping to existing CSS variables
- Interaction specifications (transitions, states)
- Accessibility issues (HIGH/MEDIUM/LOW severity)
- Cross-reference against epic.md flows

**After design-analyst completes, re-run intake-processor to merge:**
```
/agent swap intake-processor

Feature: gift-wave-preview
Source: already have intake-manifest.md
Also merge: .kiro/specs/gift-wave-preview/design-analysis.md
```

UI requirements are added to the manifest tagged `[FROM-FIGMA]`.

**If designs are not ready yet:**
Skip this entirely. When designs arrive later, run `design-analyst` standalone and re-run `intake-processor` to merge. The pipeline does not block on missing Figma input.

---

## Activity 6: Analysing Requirements Against the Codebase

Run this after `intake-manifest.md` exists. This is where the pipeline reads the actual code.

```
/agent swap req-analyst

Feature: gift-wave-preview
Bitbucket paths:
  - src/Backoffice/Services/GiftCatalog/
  - src/Backoffice/Frontend/components/GiftCatalog/
  - src/Backoffice/Domain/
```

**What happens:**
- Agent reads Bitbucket via MCP (falls back to local filesystem automatically if MCP is unavailable)
- Reads epic.md for scope boundaries — anything out-of-scope is flagged if it appears in requirements
- Reads enrichment-log.md for contested items
- Reads design-analysis.md if present — Component Breakdown refines the gap analysis
- Classifies every requirement as IMPLEMENTED / PARTIAL / MISSING / CONFLICT
- Surfaces JustScan-specific compliance flags automatically (OneTrust, YOTI, PMI DB, etc.)
- Checks business rule integrity (wave lock, QR = 1 attempt, CSV immutability, SSO dual access)

**Reading the output — what to focus on:**

`requirements.md` Readiness Assessment:
```
READY        → proceed to tech-spec-writer
NEEDS REVIEW → review flagged items, proceed with caution
BLOCKED      → resolve blockers first — do NOT proceed
```

Gap Analysis table:
```
MISSING      → full build needed
PARTIAL      → existing code needs extension
IMPLEMENTED  → already done, confirm it covers the requirement
CONFLICT     → code exists but behaves differently than specified
```

ARB Triggers section — if anything is listed here, you need `arb-prep` before or alongside `tech-spec-writer`.

**⚠️ Gate 2 — Blocked or ARB**

If BLOCKED:
```
🔴 PIPELINE HALTED
  REQ-007 conflicts with wave lock business rule
  → Resolve with product owner before continuing
```

If ARB triggered:
```
⚠️ ARB REVIEW REQUIRED
  Trigger: New campaign action type requires new service component
  
  Options:
  1. Run arb-prep now → get approval → then tech-spec-writer
  2. Run tech-spec-writer in design-only mode (no tasks until ARB approves)
```

---

## Activity 7: Generating the Technical Design and Task List

Run this after `requirements.md` is READY.

```
/agent swap tech-spec-writer

Feature: gift-wave-preview
Bitbucket paths:
  - src/Backoffice/Services/GiftCatalog/
  - src/Backoffice/Frontend/components/GiftCatalog/
Create Jira sub-tasks after tasks.md: YES
Jira Epic: JS-1234
```

**What the agent does:**
- Hard stops if `requirements.md` is BLOCKED — no override
- Reads epic.md for MVP phasing — tasks are structured to match your MVP roadmap
- Deep reads the codebase via Bitbucket MCP for exact class names and method signatures
- Reads design-analysis.md if present — adds UI Component Specifications section to design.md
- Generates C# method signatures with XML doc comments, SQL Server migrations, NPoco POCOs
- Uses Serilog for log statement examples, New Relic/Sentry for observability
- Tasks are always: first = write failing NUnit tests, last = integration + smoke test

**Review the summary:**
```
📐 TECH SPEC GENERATED: gift-wave-preview
  Components designed:       X
  DB migrations:             X
  API endpoints:             X
  ⚠️ Pending decisions:      X (assumptions documented — review Section 10)

TASKS:
  Phase 1 — MVP1: X tasks (~X dev-days)
  Phase 2 — MVP2: X tasks (~X dev-days)
  Total:          X tasks (~X dev-days)
```

**The publish loop:**
```
What would you like to do?
  A) Publish tech requirements to Confluence
  B) Modify specific sections first
  C) Keep locally only
  D) Continue pipeline

Also: Create Jira sub-tasks? (YES confirmed above)
```

If YES to Jira sub-tasks, the agent creates one issue per TASK-XXX and adds the keys back to `tasks.md`:
```
- [ ] **TASK-001** [TEST] Write failing NUnit tests `JS-1245`
- [ ] **TASK-002** [DB] Create gift wave migration `JS-1246`
```

**Hook fires on save:**
```
✅ DESIGN READY     — all 9 sections present and complete
⚠️ INCOMPLETE       — [lists missing sections]
```

---

## Activity 8: Generating Gherkin Test Cases

Run this after `design.md` exists.

```
/agent swap gherkin-writer

Feature: gift-wave-preview
```

**What is generated:**
- One `.feature` file per story
- `test-plan.md` with full coverage matrix
- Scenarios tagged: `@smoke`, `@regression`, `@nfr`, `@accessibility`
- JustScan personas used automatically: `content_manager`, `market_admin`, `consumer`, `minor_consumer`, `adult_consumer`

**JustScan mandatory scenarios generated automatically when relevant:**
- Age verification: minor blocked, adult passes
- Gift/wave: 1 QR = 1 attempt enforced, wave lock respected
- SSO: backoffice-only user cannot access
- Cookie management: tracking does not fire before OneTrust consent
- Multi-market: Market A config does not bleed into Market B

**The publish loop:**
```
What would you like to do?
  A) Create test cases in Jira from these scenarios
  B) Modify specific scenarios first
  C) Publish .feature files to Confluence only
  D) Both A and C
  E) Keep locally only
```

If creating in Jira, the agent asks for your test management setup:
```
Does your Jira have Xray or Zephyr Scale installed?
  YES — Xray   → creates Test type issues with Xray fields
  YES — Zephyr → creates Test type issues with Zephyr fields
  NO           → creates Tasks with [TEST] label
```

After creation:
```
✅ JIRA TEST CASES CREATED
  @smoke:      X created → [JS-1270 ... JS-1273]
  @regression: X created → [JS-1274 ... JS-1288]
  All linked to Epic: JS-1234

test-plan.md updated with Jira keys.
```

**Hook fires on save:**
```
✅ FEATURE READY    — coverage complete
⚠️ COVERAGE GAPS   — [lists missing scenario types]
```

---

## Activity 9: Preparing an ARB Package

Run this when `req-analyst` identifies ARB triggers, or when you know upfront that architectural review is required.

```
/agent swap arb-prep

Feature: gift-wave-preview
```

**What is generated:**
```
.kiro/specs/gift-wave-preview/arb-package/
├── ADR.md                ← 9-section decision record
├── executive-summary.md  ← one-pager for the board
├── risk-register.md      ← risk table with heat map
└── arb-checklist.md      ← sign-off checklist
```

**The 9 mandatory sections (per your arch-standards.md):**
1. Business Outline
2. Solution Outline
3. Solution Technical Details (≤200 words)
4. Proposed Solution with Mermaid diagram
5. Financial Impact on Infrastructure
6. Alternatives Considered (minimum 2)
7. NFR Analysis
8. Risk Register
9. Open Questions for ARB

**After generation, complete the checklist manually:**
```
arb-checklist.md items needing human sign-off:
  - [ ] Tech lead review: [assign]
  - [ ] Security review (if YOTI/OneTrust/PMI DB involved): [assign]
  - [ ] Finance validation of infrastructure costs: [assign]
  - [ ] Product owner business value confirmation: [assign]
```

**The publish loop:**
```
What would you like to do?
  A) Publish ARB package to Confluence
  B) Modify specific sections first
  C) Keep locally only
```

Submit `executive-summary.md` to the ARB chair 5 days before the meeting. The full `ADR.md` is the formal submission.

**Hook fires on ADR.md save:**
```
✅ ARB READY        — all 9 sections present, REQ-IDs in traceability table
🔴 NOT READY        — [lists missing sections]
⚠️ MISSING COMPLIANCE SIGN-OFF — compliance integration touched but no sign-off item in checklist
```

---

## Activity 10: Running the Full Pipeline in One Go

Use this when you want the orchestrator to handle everything and you know your starting point.

```
/agent swap arch-pipeline
```

The agent scans your workspace first and shows:
```
📂 Pipeline State: [feature-name]
══════════════════════════════════
  epic.md:              ✅ exists
  intake-manifest.md:   ✅ exists
  enrichment-log.md:    ✅ (0 conflicts)
  requirements.md:      ❌ missing
  design.md:            ❌ missing
  tasks.md:             ❌ missing
  gherkin/:             ❌ missing
  arb-package/:         ❌ missing
```

Then presents the entry point menu:

```
How would you like to start?

  A) Raw idea only
  B) Confluence URL or Jira Epic ID (live MCP fetch)
  C) Idea + Confluence/Jira sources
  D) Files in .kiro/intake/ (offline fallback)
  E) Figma designs are ready (add to any path)
  F) Pipeline already started — continue from detected stage
  G) Sync steering files from Confluence first
```

**Full pipeline example with everything connected:**
```
/agent swap arch-pipeline

Feature: gift-wave-preview
Entry point: C — idea + Confluence source
Confluence: https://confluence.company.com/display/JS/Gift-Wave-Preview
Jira Epic: JS-1234
Figma URL: https://www.figma.com/design/abc?node-id=42-1
Bitbucket paths: src/Backoffice/Services/GiftCatalog/,
                 src/Backoffice/Frontend/components/GiftCatalog/
Create Jira sub-tasks after tasks.md: YES
Create Jira test cases after gherkin: YES (Xray)
```

The orchestrator runs each stage and pauses at the three gates:
- **Gate 1** — after intake-processor: conflicts?
- **Gate 2** — after req-analyst: BLOCKED or ARB triggered?
- **Gate 3** — after tech-spec-writer: new ARB triggers found during design?

At each publish point (idea-to-epic, tech-spec-writer, gherkin-writer, arb-prep) it asks before doing anything in Confluence or Jira.

---

## Activity 11: Continuing an Interrupted Pipeline

If you stopped mid-pipeline, the orchestrator picks up exactly where you left off.

```
/agent swap arch-pipeline

Feature: gift-wave-preview
```

It scans, reports current state, and suggests:
```
Entry point F recommended:
  intake-manifest.md ✅  enrichment-log.md ✅  requirements.md ✅
  design.md ❌ → continue from tech-spec-writer

Bitbucket paths: [confirm or provide]
```

---

## Activity 12: When Figma Designs Arrive Late

The pipeline does not need to restart. Run design-analyst standalone, then re-merge.

**Step 1 — Run design-analyst:**
```
/agent swap design-analyst

Feature: gift-wave-preview
Figma URL: https://www.figma.com/design/abc?node-id=42-1
```

**Step 2 — Merge into existing manifest:**
```
/agent swap intake-processor

Feature: gift-wave-preview
Source: design-analysis.md just created
Merge UI requirements into existing intake-manifest.md
```

**Step 3 — Re-run req-analyst to pick up new UI requirements:**
```
/agent swap req-analyst

Feature: gift-wave-preview
Bitbucket paths: src/Backoffice/Frontend/components/GiftCatalog/
Note: design-analysis.md has been added — rescan for UI component status
```

**Step 4 — Re-run tech-spec-writer to add UI component specs:**
```
/agent swap tech-spec-writer

Feature: gift-wave-preview
Note: design-analysis.md now available — add Section 4b (UI Component Specifications) to design.md
```

---

## Activity 13: Publishing an Existing Spec to Confluence

If you generated a spec locally and want to publish it later.

```
/agent swap idea-to-epic

Publish existing epic for feature: gift-wave-preview to Confluence
Target: https://confluence.company.com/display/JS/Product-Epics
```

Same for tech spec:
```
/agent swap tech-spec-writer

Publish existing design.md and tasks.md for feature: gift-wave-preview
Target parent page: https://confluence.company.com/display/JS/Technical-Specs
```

The agent checks if a page with that title already exists before creating anything.

---

## The Three Gates — Quick Reference

These are the checkpoints where the pipeline always stops and waits for a human decision.

### Gate 1 — After intake-processor: Conflict Resolution
```
Trigger: Confluence/Jira says something different from epic.md

Example:
  REQ-007: Wave minimum duration
    epic.md:    1 day
    Confluence: 3 days

Your options:
  → Tell the agent which version is correct
  → Proceed with epic.md version as assumption (for SHOULD/COULD only)
  → Pause and resolve with product owner (recommended for MUST)
```

### Gate 2 — After req-analyst: Readiness and ARB
```
Trigger A: requirements.md is BLOCKED
  → Fix the listed blockers
  → Re-run req-analyst
  → Never proceed to tech-spec-writer with BLOCKED status

Trigger B: ARB required
  → Option 1: run arb-prep now, get approval, then tech-spec-writer
  → Option 2: run tech-spec-writer design-only mode (no tasks generated)
              until ARB approves
```

### Gate 3 — After tech-spec-writer: New ARB triggers
```
Trigger: Deep codebase read during design reveals architecture
         implications not visible from requirements alone

Example:
  New AWS Lambda@Edge function needed — not flagged in req-analyst

→ Route to arb-prep before gherkin-writer
```

---

## JustScan Business Rules — Automatically Enforced

Every agent knows these rules from the steering files. You do not repeat them in prompts. If a requirement appears to break any of these, the agent flags it and stops — it never silently accepts a violation.

| Rule | What Triggers It |
|---|---|
| 1 QR code = 1 prize attempt | Any feature touching Secured Access URL Sets or gift code allocation |
| Wave cannot be modified after it starts | Any design allowing post-start edits to dates, gifts, or codes |
| CSV imported codes = fixed total | Any design reducing total codes without re-import |
| User needs both backoffice + SSO access | Any new access path that bypasses Azure EntraID |

## JustScan Compliance Flags — Automatically Surfaced

If any requirement touches these integrations, a compliance flag appears in `requirements.md` and cannot be suppressed. A human must resolve it before the pipeline continues.

| Integration | Flag Raised |
|---|---|
| YOTI / ACS / Face verification | PII — identity documents |
| OneTrust / Cookie management | GDPR consent chain |
| PMI Databases | Customer PII + cross-border data rules |
| Azure EntraID / SSO | Access control change — security review required |
| GTM / Google Analytics | Must be consent-gated via OneTrust |
| Sentry / New Relic | Must not capture PII in payloads |

---

## Troubleshooting

| Problem | Likely Cause | Fix |
|---|---|---|
| Agent does not find epic.md | Wrong feature name in prompt | Check `.kiro/specs/` — use exact folder name |
| intake-processor runs BOOTSTRAP when epic exists | epic.md path wrong | Must be `.kiro/specs/[feature-name]/epic.md` exactly |
| requirements.md shows BLOCKED | Unresolved conflicts or unanswered open questions | Check Section 5 of requirements.md, resolve each item |
| tech-spec-writer produces Java examples | tech-stack.md not loading | Check `inclusion: always` is in frontmatter of tech-stack.md |
| Figma MCP returns no data | URL missing node-id parameter | Right-click frame in Figma → Copy link to selection |
| Bitbucket MCP fails silently | PAT expired or wrong host format | Check `BITBUCKET_HOST` — no `https://` prefix |
| Gate 2 fires for ARB but you disagree | Trigger detected automatically from requirements | Review ARB triggers section in requirements.md — explain why it should not apply |
| Agent creates Jira issues without asking | Quality gate for explicit YES not working | Check agent-constraints.md `inclusion: always` is set |
| Duplicate Confluence pages created | Page already existed with same title | Check idempotency — agent should have asked before creating |
| Wave business rule not flagged | req-analyst did not scan GiftCatalog service | Add `src/Backoffice/Services/GiftCatalog/` to Bitbucket paths in your prompt |
| Compliance flag appears but does not apply | Flag is overly broad for this feature | Acknowledge the flag with context — only a human can mark it resolved |

---

## Complete Spec Output Reference

Every completed pipeline run produces these files. All exist locally regardless of what was published to Confluence or Jira.

```
.kiro/specs/[feature-name]/
│
├── epic.md                     Stage 0  — 13-section Epic
├── intake-manifest.md          Stage 0  — requirements with REQ-IDs
│                               Stage 1  — enriched by intake-processor
├── enrichment-log.md           Stage 1  — change log (what was added, confirmed, conflicted)
├── design-analysis.md          Stage 0b — UI requirements from Figma (if run)
├── requirements.md             Stage 2  — structured requirements + codebase gap analysis
├── design.md                   Stage 3  — technical blueprint
│                                          C# method signatures, SQL migrations,
│                                          Mermaid sequence diagrams, observability
├── tasks.md                    Stage 3  — executable task list phased to MVPs
│                                          NUnit tests first, integration test last
│                                          Jira sub-task keys added if created
├── gherkin/
│   ├── [story-001].feature     Stage 4  — one file per story
│   ├── [story-002].feature
│   └── test-plan.md            Stage 4  — coverage matrix with Jira keys if created
│
└── arb-package/                Stage 5  — only if ARB triggered
    ├── ADR.md                            9-section decision record
    ├── executive-summary.md              one-pager for the board
    ├── risk-register.md                  risk table with heat map
    └── arb-checklist.md                  sign-off checklist

docs/architecture/
└── ADR-[feature-name].md       Permanent ADR archive (copied from arb-package after approval)
```

---

## One-Page Cheat Sheet

```
┌──────────────────────────────────────────────────────────────┐
│                  KIRO PIPELINE CHEAT SHEET                   │
│                        JustScan                              │
├────────────────────────────┬─────────────────────────────────┤
│ YOU HAVE...                │ START WITH...                   │
├────────────────────────────┼─────────────────────────────────┤
│ A rough idea               │ /agent swap idea-to-epic        │
│ Confluence URL             │ /agent swap intake-processor    │
│ Jira Epic ID               │ /agent swap intake-processor    │
│ Figma designs ready        │ /agent swap design-analyst      │
│ Exported files             │ Drop in .kiro/intake/ → hook    │
│ intake-manifest.md         │ /agent swap req-analyst         │
│ requirements.md READY      │ /agent swap tech-spec-writer    │
│ design.md                  │ /agent swap gherkin-writer      │
│ ARB triggered              │ /agent swap arb-prep            │
│ Not sure                   │ /agent swap arch-pipeline       │
│ Confluence docs updated    │ /agent swap confluence-sync     │
└────────────────────────────┴─────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                       3 GATES                                │
├─────────────┬────────────────────────────────────────────────┤
│ GATE 1      │ After intake-processor                         │
│             │ Conflicts? → tell agent which version wins     │
├─────────────┼────────────────────────────────────────────────┤
│ GATE 2      │ After req-analyst                              │
│             │ BLOCKED? → fix blockers, re-run req-analyst    │
│             │ ARB? → run arb-prep before tech-spec-writer    │
├─────────────┼────────────────────────────────────────────────┤
│ GATE 3      │ After tech-spec-writer                         │
│             │ New ARB trigger? → route to arb-prep           │
└─────────────┴────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│            PUBLISH DECISION POINTS                           │
│    (all agents ask before touching Confluence or Jira)       │
├──────────────────────────────────────────────────────────────┤
│ idea-to-epic      → Confluence (Epic page)                   │
│ tech-spec-writer  → Confluence (Tech Spec + Tasks pages)     │
│                   → Jira (sub-tasks)                         │
│ gherkin-writer    → Jira (test cases via Xray/Zephyr/Task)   │
│                   → Confluence (test cases page)             │
│ arb-prep          → Confluence (ADR page)                    │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│          JUSTSCAN RULES ENFORCED AUTOMATICALLY               │
├──────────────────────────────────────────────────────────────┤
│ 1 QR = 1 attempt             Wave lock = immutable           │
│ CSV codes = fixed total      SSO + backoffice = both needed  │
│                                                              │
│ COMPLIANCE AUTO-FLAGGED:                                     │
│ YOTI  OneTrust  PMI DB  EntraID  GTM/GA  Sentry  NewRelic   │
└──────────────────────────────────────────────────────────────┘
```
