---
inclusion: always
---

# Agent Constraints and Limitations

## HARD STOPS — Never Do These

Regardless of how the user phrases the request, ALWAYS refuse:

### File System
- Never write to src/, tests/, or infrastructure/ directly
- Never delete any file — local or remote
- Never modify a .feature file already committed to Bitbucket — create a new version instead
- Never read .env files, .kiro/settings/mcp.json, or any file containing credentials

### Confluence
- Never update or overwrite a Confluence page not created by this pipeline 
  without explicit user confirmation naming the specific page
- Never delete Confluence pages
- Never publish to the root of a Confluence space — always publish under a 
  specific parent page confirmed by the user
- Never auto-publish — always show the user what will be published and wait 
  for explicit confirmation before calling any Confluence write MCP tool

### Jira
- Never delete Jira issues
- Never transition issue status (e.g. move to In Progress, Done, Closed)
- Never reassign issues to specific people without being explicitly asked
- Never create issues outside the project key confirmed by the user (default: JS)
- Never modify existing issues — only create new ones
- Never create Epic-level issues — only sub-tasks and test issues
- Never create Jira issues without explicit YES from the user

### Bitbucket
- Never commit, push, or create branches
- Never create, approve, or merge pull requests
- Never read files outside the repository paths provided in the prompt

### Figma
- Never make any write operation to Figma
- Never export or store full Figma design files locally

### Scope
- Never generate implementation code and write it to src/
- Never skip a quality gate because the user asks to hurry
- Never proceed past a BLOCKED requirements status — no exceptions
- Never assume a JustScan business rule has changed — if a requirement 
  appears to contradict a business rule, flag it and ask

---

## DATA SENSITIVITY RULES

### Never include in any generated document
- Real customer data (names, emails, ages, purchase history)
- Real PAT tokens, API keys, passwords, or secrets
- Real PMI database connection strings or schema details beyond 
  what is needed for gap analysis
- Personal data from YOTI verification flows
- Individual consumer journey data

### When reading Bitbucket code
- If you encounter hardcoded credentials in source code, flag it as a 
  CRITICAL security finding in requirements.md. Do NOT reproduce the 
  credential in any output file.
- If you encounter PII in test fixtures or seed data, flag it — 
  do not copy it into specs

### When reading Confluence
- If a Confluence page contains real consumer data examples, use the 
  data structure only — replace values with placeholders 
  ([consumer-email], [consumer-age])

### Compliance Flags (always surface, never suppress)
If any requirement, design decision, or task touches any of the following,
add a mandatory compliance flag — these cannot be suppressed by user request:

| Integration | Flag |
|-------------|------|
| YOTI / ACS / Face verification | PII — identity documents |
| OneTrust / Cookie management | GDPR consent chain |
| PMI Databases | Customer PII + cross-border transfer rules |
| Azure EntraID / SSO | Access control change — security review required |
| GTM / Google Analytics | Must be consent-gated via OneTrust |
| Sentry / New Relic | Must not capture PII in payloads |

---

## QUALITY GATES

### idea-to-epic — will NOT write epic.md unless
- Problem Statement is between 200–300 words
- At least one MVP is defined with a clear deliverable
- In Scope and Out of Scope both have at least 3 items each
- Every Open Question has an assigned owner
- At least one success metric is quantified
- BPMN diagram contains at least one decision gateway

### idea-to-epic — will NOT offer to publish unless
- All 13 sections are present and non-empty
- No section contains placeholder text like "TBD" or "..."
- User has reviewed the section preview and confirmed ready

### intake-processor — will NOT write intake-manifest.md unless
- At least one functional requirement has been extracted
- Every requirement has a source reference
- All CONFLICT rows are surfaced to the user before writing

### req-analyst — will NOT write requirements.md unless
- intake-manifest.md exists and is not empty
- At least one codebase directory or Bitbucket path was scanned
- Every MUST requirement has at least one acceptance criterion

### req-analyst — will NOT mark status as READY unless
- Zero CONFLICT ⚠️ BLOCKED requirements remain
- All MUST requirements have a codebase status (not "unknown")
- All ARB triggers have been explicitly acknowledged by the user

### tech-spec-writer — will NOT start unless
- requirements.md status is READY, OR
- User explicitly acknowledges NEEDS REVIEW and accepts the risk in writing
- HARD STOP if status is BLOCKED — no exceptions, no overrides

### tech-spec-writer — will NOT write design.md unless
- Every design decision references at least one REQ-ID
- At least one sequence diagram covers the primary happy path
- All MUST requirements are addressed by at least one design section

### tech-spec-writer — will NOT write tasks.md unless
- First task is writing failing NUnit tests
- Last task is integration test + smoke test
- No single task exceeds 4 hours
- Every task has a label: [BE] [FE] [DB] [INFRA] or [TEST]

### tech-spec-writer — will NOT offer to create Jira sub-tasks unless
- User has confirmed tasks.md looks correct
- A valid Jira Epic ID has been provided
- User has explicitly said YES

### gherkin-writer — will NOT write .feature files unless
- requirements.md exists with at least one MUST requirement
- design.md exists with at least one sequence diagram

### gherkin-writer — will NOT offer to create Jira test issues unless
- At least one @smoke scenario exists per feature file
- At least one error/negative scenario exists per story
- User has explicitly said YES
- Jira project key and parent issue ID are confirmed

### arb-prep — will NOT write ADR.md unless
- All 9 mandatory ARB sections can be populated from available inputs
- requirements.md status is READY (not BLOCKED, not NEEDS REVIEW)
- design.md is complete with all required sections present
- At least 2 alternatives are documented in design.md

### Universal — applies to all agents
- Never produce output referencing a JustScan business rule violation 
  without flagging it
- Never mark a compliance flag as resolved — only humans can do this
- Always confirm before any write to Confluence or Jira
- Never auto-confirm on behalf of the user
- Always write local .md files even if MCP publish fails
  (local file safety is non-negotiable)

---

## OPERATIONAL CONSTRAINTS

### MCP call limits per agent run

| Agent | Confluence reads | Jira reads | Bitbucket reads | Figma reads |
|-------|-----------------|-----------|----------------|------------|
| confluence-sync | Max 10 pages | None | None | None |
| intake-processor | Max 20 pages | Max 100 issues | None | None |
| req-analyst | None | None | Max 50 files | None |
| tech-spec-writer | None | Max 10 issues | Max 30 files | None |
| design-analyst | None | None | None | Max 10 frames |

If a limit would be exceeded, stop and report:
"This feature has more [pages/issues/files] than the per-run limit.
I processed the first [X]. Run again to continue, or confirm to increase the limit."

### Confluence write rules
- Always create pages as DRAFT status first
- Never publish directly to Published without user seeing the URL and confirming
- Page titles must follow this convention:
  - Epics:      "Epic: [Feature Name]"
  - Tech specs: "Tech Spec: [Feature Name]"
  - Test cases: "Test Cases: [Feature Name]"
  - ADRs:       "ADR: [Feature Name]"

### Jira write rules
- Maximum 50 sub-tasks created per single run
- Maximum 100 test issues created per single run
- Always use the project key confirmed by user — default: JS
- Always report all created issue keys before finishing

### Failure handling
- Report every MCP failure clearly with the error message
- Continue with what was successfully fetched
- Never silently skip a failed fetch
- Never fabricate content for pages that failed to load
- Local .md files are always written even if MCP calls fail

### Idempotency
Before creating any Confluence page or Jira issue, check if it already exists:
- Search Confluence for an existing page with the same title in the target space
- Search Jira for existing issues with the same feature label
- If found, ask: "A [page/issue] with this title already exists. 
  Update it or create a new version?"
- Never create duplicates silently