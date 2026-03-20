# Test Plan: Integration Configuration Management

**Epic:** Integration Configuration Management  
**Epic ID:** JSN-INTCFG  
**Version:** 1.0  
**Date:** 2024-12-19  
**Status:** READY FOR EXECUTION

---

## Executive Summary

This test plan provides comprehensive coverage for the Integration Configuration Management epic across 3 MVPs. The plan includes 9 feature files with 200+ scenarios covering functional requirements, security, performance, accessibility, and error handling.

### Coverage Statistics

| Category | Scenarios | Feature Files |
|----------|-----------|---------------|
| RBAC & Access Control | 24 | 1 |
| Integration List Management | 28 | 1 |
| Integration Detail View | 26 | 1 |
| Credential Management | 38 | 1 |
| Endpoint Toggle | 32 | 1 |
| Database Assignment | 34 | 1 |
| Audit Logging | 28 | 1 |
| Test Connection | 26 | 1 |
| Error Scenarios | 42 | 1 |
| **TOTAL** | **278** | **9** |

---

## Feature File Overview

### 1. rbac-access-control.feature
**MVP:** 1  
**Priority:** CRITICAL  
**Tags:** @integration-configuration @rbac @security @mvp1

**Coverage:**
- IntegrationAdmin and IntegrationViewer role enforcement
- Unauthorized access scenarios (403, 401)
- Role changes mid-session
- Azure EntraID sync delays
- Concurrent session handling
- Permission boundary cases
- Audit logging for access attempts
- Performance: role validation < 500ms

**Key Scenarios:**
- Happy path: Admin and Viewer access
- Unauthorized: No role, wrong role, expired session
- Edge cases: Role downgrade/upgrade, sync delay, manual refresh
- NFR: Permission cache, validation performance

**Requirements Covered:** JSN-001, JSN-002, JSN-003, NFR-001, NFR-004, NFR-005

---

### 2. integration-list.feature
**MVP:** 1  
**Priority:** HIGH  
**Tags:** @integration-configuration @integration-list @mvp1

**Coverage:**
- View all integrations with market filtering
- Status display (Active/Inactive)
- Pagination (50 items per page)
- Empty states (no integrations, no results)
- Loading states and performance
- Endpoint status display
- Search and sort functionality
- Responsive design (tablet, mobile)
- Error handling (API errors, timeouts)
- Accessibility (keyboard navigation, screen readers)

**Key Scenarios:**
- Happy path: List view, filtering, pagination
- Empty states: No data, no results
- Performance: Load < 2s for 100 integrations
- Responsive: Tablet (2 columns), Mobile (1 column)
- Accessibility: Keyboard nav, ARIA labels

**Requirements Covered:** JSN-004, JSN-005, NFR-001, NFR-009

---

### 3. integration-detail.feature
**MVP:** 1  
**Priority:** HIGH  
**Tags:** @integration-configuration @integration-detail @mvp1

**Coverage:**
- View detailed integration information
- Endpoint status display
- Breadcrumb navigation with state preservation
- Read-only mode for IntegrationViewer
- Credential masking
- Market assignment display
- Audit history display
- Error handling (404, 500)
- Loading states
- Responsive design
- Accessibility

**Key Scenarios:**
- Happy path: Detail view, metadata, endpoints
- Breadcrumb: Navigation, filter preservation
- Read-only: Viewer restrictions
- Security: Credential masking, no exposure
- Performance: Load < 1s
- Accessibility: Keyboard nav, screen reader

**Requirements Covered:** JSN-004, JSN-005, JSN-009, NFR-001

---

### 4. credential-management.feature
**MVP:** 2  
**Priority:** CRITICAL  
**Tags:** @integration-configuration @credential-management @security @mvp2

**Coverage:**
- Update credentials securely
- AWS Secrets Manager integration
- Credential masking in UI
- Validation (format, required fields)
- AWS Secrets Manager error handling
- Concurrent update handling
- Audit logging (no credential values)
- Cache invalidation
- Test connection integration
- Security: No plaintext, no logs, HTTPS only
- Performance: Update < 5s

**Key Scenarios:**
- Happy path: Update, mask, store in AWS
- Validation: Format, required fields
- AWS errors: Unavailable, timeout, invalid response
- Concurrent: Optimistic locking, conflict resolution
- Security: No plaintext, no logs, no browser storage
- Performance: Update < 5s, form load < 500ms

**Requirements Covered:** JSN-008, JSN-009, JSN-010, NFR-002, NFR-004, NFR-005, NFR-006

---

### 5. endpoint-toggle.feature
**MVP:** 2  
**Priority:** HIGH  
**Tags:** @integration-configuration @endpoint-toggle @mvp2

**Coverage:**
- Enable/disable endpoints (sendOTP, lastName, firstName)
- Real-time configuration updates
- Cache invalidation
- WebApp propagation within 5 minutes
- Audit logging
- Confirmation dialogs
- Optimistic UI updates with rollback
- Permission enforcement
- Bulk toggle operations
- Campaign impact warnings
- Performance: Toggle < 1s

**Key Scenarios:**
- Happy path: Enable, disable, multiple endpoints
- Real-time: Immediate update, cache invalidation
- Audit: Separate entries per toggle
- Optimistic UI: Immediate feedback, rollback on error
- Bulk: Enable/disable all
- Performance: Toggle < 1s, bulk < 2s

**Requirements Covered:** JSN-011, JSN-012, NFR-003

---

### 6. database-assignment.feature
**MVP:** 3  
**Priority:** HIGH  
**Tags:** @integration-configuration @database-assignment @mvp3

**Coverage:**
- Assign database to single/multiple markets
- Unassign with safety checks (active campaigns)
- Bulk assignment operations
- Assignment validation
- Confirmation dialogs
- Audit logging
- Drag-and-drop UI
- Market selector with search
- Concurrent modification handling
- Error handling
- Performance: Assignment < 1s, bulk < 5s

**Key Scenarios:**
- Happy path: Assign, unassign, bulk assign
- Safety checks: Block unassign with active campaigns
- Bulk: Partial failure handling
- Validation: Duplicate, invalid market
- Concurrent: Conflict resolution
- Performance: Assignment < 1s, safety check < 500ms

**Requirements Covered:** JSN-006, JSN-007, NFR-009

---

### 7. audit-logging.feature
**MVP:** 1  
**Priority:** CRITICAL  
**Tags:** @integration-configuration @audit-logging @security @mvp1

**Coverage:**
- Log all configuration changes
- Immutable audit entries
- 2-year retention policy
- No sensitive data in logs
- Audit log retrieval and filtering
- Pagination for large datasets
- Access control (Admin/Viewer can view)
- Export to CSV
- Real-time logging
- Integrity verification (cryptographic hash)
- Compliance reporting (SOC 2)

**Key Scenarios:**
- Creation: All actions logged (credentials, endpoints, assignments)
- Immutability: No UPDATE/DELETE permissions
- Security: No credentials, PII anonymization after 90 days
- Retrieval: Filter by action, date, user, integration
- Performance: Query < 500ms, pagination
- Compliance: SOC 2 requirements met

**Requirements Covered:** JSN-013, JSN-014, NFR-006, NFR-010, NFR-011

---

### 8. test-connection.feature
**MVP:** 2  
**Priority:** MEDIUM  
**Tags:** @integration-configuration @test-connection @mvp2

**Coverage:**
- Test connection with new/existing credentials
- Success and failure scenarios
- Timeout after 10 seconds
- Retry functionality
- Detailed error information
- Different database types
- Security: No credential logging
- Audit logging
- UI/UX: Progress indicator, result display
- Performance: Complete within 10s

**Key Scenarios:**
- Happy path: Successful test
- Failures: Invalid credentials, network error, timeout
- Retry: After failure, with modified credentials
- Security: No logging, secure channel, no browser storage
- Performance: Complete < 10s, cancellable

**Requirements Covered:** JSN-015, NFR-019, NFR-020

---

### 9. error-scenarios.feature
**MVP:** 2  
**Priority:** HIGH  
**Tags:** @integration-configuration @error-scenarios @resilience @mvp2

**Coverage:**
- AWS Secrets Manager outages
- Invalid credentials
- Concurrent modification conflicts
- Permission boundary cases
- Database and network errors
- Redis cache failures
- External database connection errors
- Data validation errors
- Business rule violations
- API error responses (500, 503)
- UI error states
- Logging and monitoring
- Graceful degradation

**Key Scenarios:**
- AWS: Unavailable, timeout, invalid response, slow
- Concurrent: Credentials, endpoints, assignments
- Permissions: Role change, removal, session expiry
- Database: Connection failure, timeout, deadlock
- Cache: Unavailable, stale data, invalidation failure
- Errors: All logged to Sentry, critical to OpsGenie
- Degradation: Continue with reduced functionality

**Requirements Covered:** All error handling aspects of JSN-001 through JSN-015, NFR-007, NFR-008, NFR-014, NFR-015

---

## Test Execution Strategy

### Phase 1: MVP 1 (Read-Only + RBAC)
**Duration:** 2 sprints  
**Focus:** RBAC, list, detail, audit logging

**Execution Order:**
1. rbac-access-control.feature (CRITICAL)
2. audit-logging.feature (CRITICAL)
3. integration-list.feature (HIGH)
4. integration-detail.feature (HIGH)

**Success Criteria:**
- All @smoke scenarios pass
- All @security scenarios pass
- Performance targets met (list < 2s, detail < 1s)
- Accessibility compliance verified

---

### Phase 2: MVP 2 (Credentials + Endpoints)
**Duration:** 3 sprints  
**Focus:** Credential management, endpoint toggle, test connection, error handling

**Execution Order:**
1. credential-management.feature (CRITICAL)
2. endpoint-toggle.feature (HIGH)
3. test-connection.feature (MEDIUM)
4. error-scenarios.feature (HIGH)

**Success Criteria:**
- All @security scenarios pass (no credential exposure)
- AWS Secrets Manager integration verified
- WebApp configuration propagation < 5 minutes
- Performance targets met (credential update < 5s, toggle < 1s)

---

### Phase 3: MVP 3 (Database Assignment)
**Duration:** 2 sprints  
**Focus:** Database assignment, safety checks, bulk operations

**Execution Order:**
1. database-assignment.feature (HIGH)
2. Regression: All previous feature files

**Success Criteria:**
- Safety checks prevent unassignment with active campaigns
- Bulk operations handle partial failures
- Performance targets met (assignment < 1s, bulk < 5s)
- Full regression suite passes

---

## Test Environment Requirements

### Backend
- .NET 8 / C# 12
- SQL Server 2022 (real instance for integration tests)
- AWS Secrets Manager (test environment)
- Azure EntraID (test tenant with mock groups)
- Redis (ElastiCache test instance)

### Frontend
- TypeScript 5 + React 18
- Jest 29 for unit tests
- Playwright for E2E tests
- Browser matrix: Chrome, Firefox, Safari, Edge

### Infrastructure
- AWS test environment with VPC
- IAM roles configured for Secrets Manager
- New Relic test account
- Sentry test project
- OpsGenie test integration

---

## Test Data Requirements

### Users
- `admin@justscan.com` - IntegrationAdmin role
- `viewer@justscan.com` - IntegrationViewer role
- `content_manager@justscan.com` - No integration roles
- `admin1@justscan.com`, `admin2@justscan.com` - For concurrent tests

### Integrations
- PMI-DB-UK-001 (PMI_TYPE_A, UK market)
- PMI-DB-UK-002 (PMI_TYPE_B, UK market)
- PMI-DB-DE-001 (PMI_TYPE_A, DE market)
- PMI-DB-JP-001 (PMI_TYPE_C, JP market)
- PMI-DB-AU-001 (PMI_TYPE_A, AU market)

### Markets
- UK, IE, DE, JP, AU, US (minimum 6 markets)

### Campaigns
- 3 active campaigns for safety check testing
- Various statuses: Published, Draft, Archived

---

## Automation Strategy

### Unit Tests (NUnit)
- All service layer logic
- Repository layer with in-memory database
- Validation logic
- Error handling logic
- Target: 80% code coverage

### Integration Tests (NUnit)
- API endpoints against real SQL Server 2022
- AWS Secrets Manager integration (test environment)
- Azure EntraID mock integration
- Cache integration with Redis
- Target: All critical paths covered

### E2E Tests (Playwright)
- All @smoke scenarios
- All @security scenarios
- Critical user journeys
- Cross-browser testing
- Target: All happy paths + critical errors

### Manual Testing
- Accessibility testing with screen readers
- Responsive design on real devices
- Exploratory testing for edge cases
- Usability testing with content managers

---

## NFR Validation

### Performance Targets
| Operation | Target | Test Method |
|-----------|--------|-------------|
| Integration list load | < 2s | Load test with 100 integrations |
| Integration detail load | < 1s | Performance test |
| Credential update | < 5s | AWS Secrets Manager integration test |
| Endpoint toggle | < 1s | Real-time update test |
| Database assignment | < 1s | Assignment operation test |
| Bulk assignment (10 markets) | < 5s | Bulk operation test |
| Audit log query | < 500ms | Database query performance test |
| Test connection | < 10s | External database connection test |

### Security Validation
- [ ] No credentials in database plaintext
- [ ] No credentials in logs (Sentry, New Relic)
- [ ] No credentials in browser storage
- [ ] All API calls use HTTPS/TLS 1.2+
- [ ] RBAC enforced on all endpoints
- [ ] Audit logs immutable
- [ ] Sensitive data masked in UI

### Accessibility Validation
- [ ] WCAG 2.1 AA compliance
- [ ] Keyboard navigation functional
- [ ] Screen reader compatible
- [ ] Focus indicators visible
- [ ] ARIA labels correct
- [ ] Color contrast meets standards

---

## Risk Mitigation

### High Risk Areas
1. **AWS Secrets Manager integration** - Mitigation: Extensive error handling, retry logic, graceful degradation
2. **Concurrent modifications** - Mitigation: Optimistic locking, conflict resolution, clear error messages
3. **WebApp configuration propagation** - Mitigation: Cache invalidation, 5-minute TTL, monitoring
4. **Active campaign safety checks** - Mitigation: Thorough validation, clear error messages, campaign list display

### Test Data Management
- Automated test data setup scripts
- Database seeding for consistent state
- Cleanup after each test run
- Isolated test environments per tester

---

## Defect Management

### Severity Levels
- **Critical:** Security vulnerability, data loss, system crash
- **High:** Feature broken, major functionality impaired
- **Medium:** Feature partially working, workaround available
- **Low:** Cosmetic issue, minor inconvenience

### Defect Workflow
1. Tester logs defect in Jira with scenario reference
2. Developer reproduces using Gherkin scenario
3. Fix implemented with regression test
4. Tester verifies fix against original scenario
5. Defect closed after verification

---

## Sign-Off Criteria

### MVP 1 Sign-Off
- [ ] All @smoke scenarios pass
- [ ] All @security scenarios pass
- [ ] All @mvp1 scenarios pass
- [ ] Performance targets met
- [ ] Accessibility validated
- [ ] Security review completed
- [ ] UAT with 3 content managers

### MVP 2 Sign-Off
- [ ] All @mvp2 scenarios pass
- [ ] AWS Secrets Manager integration verified
- [ ] No credential exposure confirmed
- [ ] WebApp integration tested
- [ ] Performance targets met
- [ ] Security review completed
- [ ] UAT with 5 content managers

### MVP 3 Sign-Off
- [ ] All @mvp3 scenarios pass
- [ ] Safety checks validated
- [ ] Bulk operations tested
- [ ] Full regression suite passes
- [ ] Performance targets met
- [ ] UAT with 5 content managers
- [ ] Production readiness review

---

## Test Metrics and Reporting

### Daily Metrics
- Scenarios executed
- Pass/fail rate
- Defects found
- Defects fixed
- Test coverage %

### Sprint Metrics
- Feature completion %
- Automation coverage %
- Performance test results
- Security test results
- Accessibility test results

### Release Metrics
- Total scenarios: 278
- Automated scenarios: Target 90%
- Manual scenarios: Target 10%
- Code coverage: Target 80%
- Defect density: Target < 1 defect per 100 LOC

---

## Appendix: Scenario Tag Reference

### Priority Tags
- `@smoke` - Critical path scenarios (run on every commit)
- `@regression` - Full regression suite (run before release)
- `@mvp1`, `@mvp2`, `@mvp3` - MVP-specific scenarios

### Functional Tags
- `@rbac` - Role-based access control
- `@security` - Security-related scenarios
- `@audit` - Audit logging scenarios
- `@nfr` - Non-functional requirements

### NFR Tags
- `@performance` - Performance testing
- `@resilience` - Error handling and recovery
- `@usability` - User experience scenarios
- `@accessibility` - Accessibility compliance

### Test Type Tags
- `@integration-configuration` - All scenarios in this epic
- Feature-specific tags: `@credential-management`, `@endpoint-toggle`, etc.

---

**Document Version:** 1.0  
**Last Updated:** 2024-12-19  
**Next Review:** Before Sprint 1 kickoff
