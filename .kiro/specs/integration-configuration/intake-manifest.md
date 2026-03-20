# Intake Manifest: Integration Configuration Management

## Epic Information
- **Epic Name:** Integration Configuration Management
- **Epic ID:** TBD (to be created in Jira)
- **Status:** Draft
- **Priority:** HIGH
- **Target Release:** Q2 2024

---

## Stories

### MVP 1: Read-Only Integration Visibility + RBAC

#### S-001: RBAC: Define integration roles and permissions
- **Type:** Backend
- **Size:** M (2 days)
- **Priority:** MUST
- **Requirements:** AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, NFR-001, NFR-002, NFR-003

#### S-002: Backend: Create integration configuration domain model
- **Type:** Backend + Database
- **Size:** L (3 days)
- **Priority:** MUST
- **Requirements:** AC-007, AC-008, AC-009, AC-010, AC-011, AC-012, AC-013, NFR-004, NFR-005

#### S-003: Backend: Implement GET endpoints for integration list
- **Type:** Backend
- **Size:** M (2 days)
- **Priority:** MUST
- **Requirements:** AC-014, AC-015, AC-016, AC-017, AC-018, AC-019, NFR-006, NFR-007
- **Dependencies:** S-001, S-002

#### S-004: Frontend: Integration list page with market filter
- **Type:** Frontend
- **Size:** L (3 days)
- **Priority:** MUST
- **Requirements:** AC-020, AC-021, AC-022, AC-023, AC-024, AC-025, NFR-008, NFR-009
- **Dependencies:** S-003

#### S-005: Frontend: Integration detail view per market
- **Type:** Frontend
- **Size:** M (2 days)
- **Priority:** MUST
- **Requirements:** (Covered in Section 5 detailed stories)
- **Dependencies:** S-003, S-004

#### S-006: Backend: Audit log infrastructure
- **Type:** Backend
- **Size:** M (2 days)
- **Priority:** MUST
- **Requirements:** AC-026, AC-027, AC-028, AC-029, AC-030, AC-031, AC-032, NFR-010, NFR-011
- **Dependencies:** S-002

#### S-007: Frontend: Audit log viewer UI
- **Type:** Frontend
- **Size:** S (1 day)
- **Priority:** SHOULD
- **Requirements:** (Covered in Section 5 detailed stories)
- **Dependencies:** S-006

---

### MVP 2: Credential Management + Endpoint Toggle

#### S-008: Backend: AWS Secrets Manager integration service
- **Type:** Backend + Infrastructure
- **Size:** L (3 days)
- **Priority:** MUST
- **Requirements:** AC-033, AC-034, AC-035, AC-036, AC-037, AC-038, NFR-012, NFR-013, NFR-014, NFR-015

#### S-009: Backend: Update credentials API endpoint
- **Type:** Backend
- **Size:** M (2 days)
- **Priority:** MUST
- **Requirements:** AC-039, AC-040, AC-041, AC-042, AC-043, AC-044, AC-045, NFR-016, NFR-017
- **Dependencies:** S-008

#### S-010: Frontend: Secure credential input form with masking
- **Type:** Frontend
- **Size:** M (2 days)
- **Priority:** MUST
- **Requirements:** (Covered in Section 5 detailed stories)
- **Dependencies:** S-009

#### S-011: Backend: Endpoint toggle API (enable/disable)
- **Type:** Backend
- **Size:** M (2 days)
- **Priority:** MUST
- **Requirements:** AC-046, AC-047, AC-048, AC-049, AC-050, AC-051, NFR-018
- **Dependencies:** S-002

#### S-012: Frontend: Endpoint toggle UI per database
- **Type:** Frontend
- **Size:** S (1 day)
- **Priority:** MUST
- **Requirements:** (Covered in Section 5 detailed stories)
- **Dependencies:** S-011

#### S-013: Backend: Credential validation and test connection
- **Type:** Backend
- **Size:** M (2 days)
- **Priority:** SHOULD
- **Requirements:** AC-052, AC-053, AC-054, AC-055, AC-056, NFR-019, NFR-020
- **Dependencies:** S-008

#### S-014: Integration: WebApp reads config from new tables
- **Type:** Backend Integration
- **Size:** L (3 days)
- **Priority:** MUST
- **Requirements:** AC-057, AC-058, AC-059, AC-060, AC-061, NFR-021, NFR-022
- **Dependencies:** S-002, S-008

---

### MVP 3: Database Assignment Management

#### S-015: Backend: Add new database definition API
- **Type:** Backend
- **Size:** M (2 days)
- **Priority:** MUST
- **Requirements:** (Covered in Section 5 detailed stories)
- **Dependencies:** S-002

#### S-016: Backend: Assign/unassign database to market API
- **Type:** Backend
- **Size:** M (2 days)
- **Priority:** MUST
- **Requirements:** AC-062, AC-063, AC-064, AC-065, AC-066, AC-067, NFR-023
- **Dependencies:** S-002, S-015

#### S-017: Frontend: Database assignment management UI
- **Type:** Frontend
- **Size:** L (3 days)
- **Priority:** MUST
- **Requirements:** (Covered in Section 5 detailed stories)
- **Dependencies:** S-016

#### S-018: Backend: Safety checks for unassignment (active campaigns)
- **Type:** Backend
- **Size:** M (2 days)
- **Priority:** MUST
- **Requirements:** AC-068, AC-069, AC-070, AC-071, NFR-024
- **Dependencies:** S-016

#### S-019: Frontend: Bulk assignment operations
- **Type:** Frontend
- **Size:** M (2 days)
- **Priority:** COULD
- **Requirements:** (Covered in Section 5 detailed stories)
- **Dependencies:** S-016, S-017

#### S-020: Observability: Metrics and alerts for integration failures
- **Type:** Infrastructure + Backend
- **Size:** S (1 day)
- **Priority:** SHOULD
- **Requirements:** AC-072, AC-073, AC-074, AC-075, AC-076, NFR-025, NFR-026

---

## Acceptance Criteria Summary

### Functional Requirements
- AC-001 through AC-076 (76 total functional acceptance criteria)
- Covers: RBAC, domain model, API endpoints, UI components, audit logging, credential management, endpoint toggles, database assignments, safety checks, observability

### Non-Functional Requirements
- NFR-001 through NFR-026 (26 total non-functional requirements)
- Categories: Performance, Security, Caching, Architecture, Database, Usability, Resilience, Observability, Alerting, Availability

---

## MVP Breakdown

### MVP 1: Read-Only Integration Visibility + RBAC
- **Stories:** 7 (S-001 through S-007)
- **Estimated Duration:** 2 sprints
- **Total Story Points:** 14 days
- **Key Deliverable:** Content managers can view integrations; security foundation established

### MVP 2: Credential Management + Endpoint Toggle
- **Stories:** 7 (S-008 through S-014)
- **Estimated Duration:** 3 sprints
- **Total Story Points:** 16 days
- **Key Deliverable:** Self-service credential updates and endpoint management

### MVP 3: Database Assignment Management
- **Stories:** 6 (S-015 through S-020)
- **Estimated Duration:** 2 sprints
- **Total Story Points:** 12 days
- **Key Deliverable:** Complete integration lifecycle management

---

## Risks Requiring Mitigation

### High Priority (Score ≥6)
- R-001: AWS Secrets Manager outage (Score: 6)
- R-002: Incorrect credentials break campaigns (Score: 9)
- R-003: Insufficient IAM permissions (Score: 6)
- R-005: Audit log retention insufficient (Score: 6)
- R-008: Migration breaks existing campaigns (Score: 9)
- R-010: Credential exposure in browser (Score: 6)

### Medium Priority (Score 4-5)
- R-004: Race condition on simultaneous updates (Score: 2)
- R-006: Secrets Manager rate limits (Score: 4)
- R-009: EntraID sync delay (Score: 4)
- R-012: Bulk assignment partial failure (Score: 4)

### Low Priority (Score ≤3)
- R-007: Accidental unassignment (Score: 2)
- R-011: External API changes (Score: 2)

---

## Open Questions Requiring Resolution

### Critical (Must resolve before Sprint 1)
- Q-001: Credential versioning for rollback?
- Q-003: IntegrationViewer access to audit logs?
- Q-004: Different credentials per market for same database?
- Q-005: Mandatory vs optional test connection?

### Important (Must resolve before Sprint 3)
- Q-008: OAuth 2.0 support needed?
- Q-009: Rate limiting on credential updates?
- Q-010: Disaster recovery plan for Secrets Manager?

### Nice to Have (Can defer to post-MVP)
- Q-002: Maximum markets for bulk assignment?
- Q-006: Retention policy for soft-deleted assignments?
- Q-007: Alert on credential age?

---

## Architecture Review Board Triggers

This Epic triggers ARB review due to:
1. **New external dependency:** AWS Secrets Manager integration
2. **Auth/authz mechanism changes:** New RBAC roles (IntegrationAdmin, IntegrationViewer)
3. **Shared data model changes:** New tables affect both Backoffice and WebApp services

ARB review must be completed before Sprint 2 begins.

---

## Compliance and Security Requirements

### Security Review Required
- Credential storage in AWS Secrets Manager (never plaintext)
- RBAC implementation with Azure EntraID integration
- Audit logging for all credential access
- Credential masking in all UI and API responses
- HTTPS-only communication

### Compliance Requirements
- SOC 2 Type II: Audit trail retention ≥2 years
- GDPR: No PII in error logs or monitoring systems
- PMI Security Standards: Credential rotation tracking

---

## Dependencies

### External Teams
- **IT Team:** Azure EntraID group creation (IntegrationAdmin, IntegrationViewer)
- **DevOps Team:** IAM role configuration for Secrets Manager access
- **Security Team:** Security review sign-off before MVP 2 deployment
- **DBA Team:** SQL Server retention policy configuration

### Infrastructure
- AWS Secrets Manager (new dependency)
- Azure EntraID (existing, extended usage)
- SQL Server 2022 (existing, new tables)
- New Relic (existing, new metrics)
- OpsGenie (existing, new alerts)

---

## Success Metrics

### Operational Metrics
- Integration config change time: 2-4 hours → 5 minutes
- Developer time on config tasks: 15% → <2%
- Content manager wait time: 8-12 hours/week → <1 hour/week

### Quality Metrics
- Credential exposure incidents: 2-3/year → 0
- Campaign launch delays: 15% → <2%
- Time to onboard new market: 3-5 days → <30 minutes

### Technical Metrics
- API response time: <500ms p95
- Test connection timeout: 10 seconds
- Credential cache TTL: 5 minutes
- Audit log retention: ≥2 years

