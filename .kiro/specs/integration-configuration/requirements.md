# Requirements Specification: Integration Configuration Management

**Feature:** Integration Configuration Management  
**Epic ID:** JSN-INTCFG  
**Version:** 1.0  
**Date:** 2024-12-19  
**Status:** READY

---

## 1. Executive Summary

### Business Problem
JustScan integrates with external PMI databases via APIs. Currently, adding new database integrations, updating existing ones, enabling them for markets, or toggling endpoints requires manual backend developer intervention. This creates developer distraction, slows content managers, and introduces risk from manual configuration changes.

### Solution Overview
Self-service integration management in the backoffice admin panel, allowing content managers with appropriate permissions to manage database integrations without developer involvement.

### Scope
- **In Scope:** Backoffice module for integration management, RBAC, credential management via AWS Secrets Manager
- **Out of Scope:** Consumer-facing WebApp changes, payments, refunds

---

## 2. Functional Requirements

### 2.1 Role-Based Access Control (RBAC)

**JSN-001** WHEN a user attempts to access the integration module THE system SHALL verify they have IntegrationAdmin or IntegrationViewer role via Azure EntraID  
**Source:** AC-001 | **Priority:** MUST  
**Given** a user is logged into backoffice  
**When** they navigate to integration management  
**Then** system checks Azure EntraID group membership  
**And** grants access only if user has IntegrationAdmin or IntegrationViewer role

**JSN-002** WHEN a user has IntegrationViewer role THE system SHALL provide read-only access to integration data  
**Source:** AC-002 | **Priority:** MUST  
**Given** user has IntegrationViewer role  
**When** they access integration module  
**Then** all modification actions are disabled  
**And** only view operations are available

**JSN-003** WHEN a user has IntegrationAdmin role THE system SHALL provide full read-write access to integration management  
**Source:** AC-003 | **Priority:** MUST  
**Given** user has IntegrationAdmin role  
**When** they access integration module  
**Then** all CRUD operations are available  
**And** credential management is accessible

### 2.2 Integration List Management

**JSN-004** WHEN a user accesses the integration list page THE system SHALL display all integrations grouped by market and database  
**Source:** AC-014 | **Priority:** MUST  
**Given** user has appropriate permissions  
**When** they access integration list  
**Then** integrations are displayed in market/database hierarchy  
**And** status indicators show active/inactive state

**JSN-005** WHEN displaying integration status THE system SHALL show endpoint-level enable/disable states  
**Source:** AC-015 | **Priority:** MUST  
**Given** integration list is displayed  
**When** user views integration details  
**Then** individual endpoint states (sendOTP, lastName, firstName) are visible  
**And** overall integration health is indicated

### 2.3 Market-Database Assignment

**JSN-006** WHEN a user assigns a database to a market THE system SHALL validate the assignment is permitted  
**Source:** AC-062 | **Priority:** MUST  
**Given** user attempts database assignment  
**When** assignment is submitted  
**Then** system validates market-database compatibility  
**And** prevents conflicting assignments

**JSN-007** WHEN a user unassigns a database from a market THE system SHALL check for active campaigns  
**Source:** AC-068 | **Priority:** MUST  
**Given** user attempts database unassignment  
**When** unassignment is requested  
**Then** system checks for active campaigns using this database  
**And** blocks unassignment if campaigns would be affected  
**And** provides clear error message with campaign details

### 2.4 Credential Management

**JSN-008** WHEN credentials are stored THE system SHALL use AWS Secrets Manager exclusively  
**Source:** AC-033 | **Priority:** MUST  
**Given** user updates integration credentials  
**When** credentials are saved  
**Then** they are stored in AWS Secrets Manager  
**And** never stored in database plaintext  
**And** never stored in environment variables

**JSN-009** WHEN credentials are displayed THE system SHALL mask sensitive values  
**Source:** AC-040 | **Priority:** MUST  
**Given** user views credential information  
**When** credentials are rendered in UI  
**Then** sensitive values are masked (e.g., *****)  
**And** full values are never transmitted to browser  
**And** only credential existence is indicated

**JSN-010** WHEN credentials are updated THE system SHALL validate format before saving  
**Source:** AC-041 | **Priority:** MUST  
**Given** user submits new credentials  
**When** validation is performed  
**Then** credential format is verified  
**And** required fields are checked  
**And** invalid credentials are rejected with specific error

### 2.5 Endpoint Management

**JSN-011** WHEN a user toggles an endpoint THE system SHALL update configuration immediately  
**Source:** AC-046 | **Priority:** MUST  
**Given** user has IntegrationAdmin role  
**When** they toggle endpoint state (enable/disable)  
**Then** configuration is updated in real-time  
**And** WebApp reads new configuration within 5 minutes  
**And** audit log records the change

**JSN-012** WHEN endpoint configuration changes THE system SHALL notify dependent services  
**Source:** AC-047 | **Priority:** MUST  
**Given** endpoint state is modified  
**When** change is committed  
**Then** cache invalidation is triggered  
**And** dependent services are notified of configuration change

### 2.6 Audit and Compliance

**JSN-013** WHEN any integration configuration changes THE system SHALL log the action  
**Source:** AC-026 | **Priority:** MUST  
**Given** user performs any modification  
**When** action is completed  
**Then** audit log captures: user, timestamp, action, old/new values  
**And** log entry is immutable  
**And** retention period is ≥2 years

**JSN-014** WHEN credentials are accessed THE system SHALL log access events  
**Source:** AC-027 | **Priority:** MUST  
**Given** user views or modifies credentials  
**When** access occurs  
**Then** security audit log records: user, timestamp, action type  
**And** no sensitive data is logged  
**And** log is available for security review

### 2.7 Test Connection

**JSN-015** WHEN credentials are updated THE system SHOULD offer test connection validation  
**Source:** AC-052 | **Priority:** SHOULD  
**Given** user has updated credentials  
**When** test connection is requested  
**Then** system attempts connection to external database  
**And** reports success/failure within 10 seconds  
**And** provides specific error details on failure

---

## 3. Non-Functional Requirements

### 3.1 Performance

**JSN-NFR-001** Integration list page SHALL load within 2 seconds for up to 100 integrations  
**Source:** NFR-006 | **Priority:** MUST

**JSN-NFR-002** Credential updates SHALL complete within 5 seconds  
**Source:** NFR-016 | **Priority:** MUST

**JSN-NFR-003** Endpoint toggle operations SHALL complete within 1 second  
**Source:** NFR-018 | **Priority:** MUST

### 3.2 Security

**JSN-NFR-004** All credential operations SHALL use HTTPS with TLS 1.2+  
**Source:** NFR-012 | **Priority:** MUST

**JSN-NFR-005** AWS Secrets Manager access SHALL use IAM roles with least privilege  
**Source:** NFR-013 | **Priority:** MUST

**JSN-NFR-006** Audit logs SHALL be tamper-proof and encrypted at rest  
**Source:** NFR-010 | **Priority:** MUST

### 3.3 Availability

**JSN-NFR-007** Integration management SHALL maintain 99.5% uptime during business hours  
**Source:** NFR-025 | **Priority:** MUST

**JSN-NFR-008** System SHALL gracefully handle AWS Secrets Manager outages  
**Source:** NFR-014 | **Priority:** MUST

### 3.4 Scalability

**JSN-NFR-009** System SHALL support up to 50 markets and 20 databases per market  
**Source:** NFR-004 | **Priority:** MUST

**JSN-NFR-010** Concurrent user limit SHALL be 25 integration administrators  
**Source:** NFR-008 | **Priority:** SHOULD

---

## 4. Edge Cases and Error Scenarios

### 4.1 Credential Management Errors

**Edge Case 1:** AWS Secrets Manager unavailable during credential update  
**Behavior:** Display user-friendly error, queue operation for retry, log incident

**Edge Case 2:** Invalid credential format provided  
**Behavior:** Validate client-side and server-side, provide specific format requirements

**Edge Case 3:** Credential test connection timeout  
**Behavior:** Timeout after 10 seconds, provide retry option, log timeout event

### 4.2 Assignment Conflicts

**Edge Case 4:** Attempting to unassign database with active campaigns  
**Behavior:** Block operation, display affected campaigns, require campaign completion first

**Edge Case 5:** Simultaneous assignment modifications by multiple users  
**Behavior:** Use optimistic locking, last-write-wins with conflict notification

### 4.3 Permission Boundary Cases

**Edge Case 6:** User role changes while session active  
**Behavior:** Re-validate permissions on each operation, force re-authentication if needed

**Edge Case 7:** Azure EntraID sync delay  
**Behavior:** Cache permissions for 15 minutes, provide manual refresh option

---

## 5. Readiness Assessment

**Status: READY**

### Requirements Completeness
- ✅ All MUST requirements defined with acceptance criteria
- ✅ Non-functional requirements specified with measurable targets
- ✅ Edge cases and error scenarios documented
- ✅ Security and compliance requirements addressed

### Traceability
- ✅ All requirements traced to intake-manifest acceptance criteria
- ✅ Priority levels assigned (MUST/SHOULD/COULD)
- ✅ Source references provided for each requirement

### ARB Triggers Identified
1. **New external dependency:** AWS Secrets Manager integration
2. **Auth/authz mechanism changes:** New RBAC roles via Azure EntraID  
3. **Shared data model changes:** New tables affect Backoffice and WebApp services

### Scope Boundary Alerts
- Integration with existing campaign system requires careful coordination
- WebApp configuration reading mechanism needs design consideration
- Audit log retention policy must align with SOC 2 compliance

### No Blocking Items
All requirements are well-defined and implementable with current technology stack.

---

## 6. Dependencies

### External Teams
- **IT Team:** Azure EntraID group creation (IntegrationAdmin, IntegrationViewer)
- **DevOps Team:** IAM role configuration for Secrets Manager access  
- **Security Team:** Security review sign-off before MVP 2 deployment
- **DBA Team:** SQL Server retention policy configuration

### Technical Dependencies
- AWS Secrets Manager (new dependency)
- Azure EntraID (existing, extended usage)
- SQL Server 2022 (existing, new tables)
- Existing campaign system (read-only integration)

---

## 7. Success Criteria

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