---
inclusion: always
---

# Architecture Review Board Standards

## Mandatory ADR Sections (non-negotiable)
1. Business Outline (Brief overview of the current process/system and its limitations,What business problem or opportunity is being addressed,Value Proposition: How will the solution benefit the business)
2. Solution outline (Brief description of the proposed solution,What components or Flow we are changing,Dependencies and Regulatory/Compliance Drivers)
3. Solution techincal details (up to 200 words)
4. Proposed Solution with Mermaid diagram
5. Financial impact on infrastructure
6. Alternatives Considered (minimum 2, with trade-off matrix)
7. NFR Analysis (latency, throughput, availability, security)
8. Risk Register (likelihood × impact × mitigation)
9. Open Questions requiring ARB decision

## What Triggers an ARB Review
- New service or removal of existing service
- New external dependency (any third-party system)
- Shared data model changes affecting 2+ services
- Auth/authz mechanism changes
- Changes touching more than 3 services

## Quality Bar
ARB rejects proposals that:
- Have requirements not traceable to a design decision
- Have no risk register
- Propose patterns not in tech-stack.md without justification