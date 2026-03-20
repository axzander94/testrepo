---
inclusion: always
---

# Specification Writing Standards

## Requirements (requirements.md)
- EARS notation: WHEN [trigger] THE [system] SHALL [behaviour]
- Every req has unique ID (JSN-XXX), source reference, and priority
- Acceptance criteria in Given/When/Then
- Edge cases and error scenarios explicitly named — never implied

## Design (design.md)
- Sequence diagram for every non-trivial flow
- Every new/modified class listed with method signatures
- Every DB change shown as both entity change AND migration SQL
- Observability: what to log, which metrics, what to alert on
- Error handling: which exceptions, which HTTP codes, which retries

## tasks.md Standards

- First task always: write failing NUnit tests
- Last task always: integration test against real SQL Server 2022
  + smoke test in dev environment
- Each task: exact .cs files and SQL migration files to touch,
  acceptance criterion, max 4 hours
- Labels: [BE] [FE] [DB] [INFRA] [TEST]
- Backend test projects follow naming: [ServiceName].Tests
- Frontend test files use Jest (co-located with component)
- E2E tests use Playwright (TypeScript)