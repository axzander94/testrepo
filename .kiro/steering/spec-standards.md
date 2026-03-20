---
inclusion: always
---

# Specification Writing Standards

## Requirements (requirements.md)
- EARS notation: WHEN [trigger] THE [system] SHALL [behaviour]
- Every req has unique ID (REQ-XXX), source reference, and priority
- Acceptance criteria in Given/When/Then
- Edge cases and error scenarios explicitly named — never implied

## Design (design.md)
- Sequence diagram for every non-trivial flow
- Every new/modified class listed with method signatures
- Every DB change shown as both entity change AND migration SQL
- Observability: what to log, which metrics, what to alert on
- Error handling: which exceptions, which HTTP codes, which retries

## Tasks (tasks.md)
- Max 4 hours per task, one developer
- Always first task: write failing tests
- Always last task: integration + smoke test
- Each task: files to touch, exact changes, acceptance criterion
- Labels: [BE] [FE] [DB] [INFRA] [TEST]
- Dependencies explicit: "🔒 Requires TASK-00X"