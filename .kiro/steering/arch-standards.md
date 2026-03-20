---
inclusion: always
---

# Architecture Review Board Standards

## Mandatory ADR Sections (non-negotiable)
1. Executive Summary ≤200 words
2. Business Context & Problem Statement
3. Requirements Traceability Table (REQ-ID → design decision)
4. Proposed Solution with Mermaid C4 component diagram
5. Sequence diagrams for all primary flows
6. Alternatives Considered (minimum 2, with trade-off matrix)
7. NFR Analysis (latency, throughput, availability, security)
8. Risk Register (likelihood × impact × mitigation)
9. Phased Implementation Plan
10. Open Questions requiring ARB decision

## What Triggers an ARB Review
- New service or removal of existing service
- New external dependency (any third-party system)
- Shared data model changes affecting 2+ services
- Auth/authz mechanism changes
- Changes touching more than 3 services

## Quality Bar
ARB rejects proposals that:
- Have requirements not traceable to a design decision
- Lack at least 2 alternatives with honest trade-offs  
- Have no risk register
- Propose patterns not in tech-stack.md without justification