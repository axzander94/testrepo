# JustBrief Gherkin Feature Files

**Epic:** JSN-11995 - JustBrief Campaign Briefing Platform  
**Generated:** 20 March 2026  
**Framework:** Gherkin/Cucumber with NUnit 4.2.2

---

## Overview

This directory contains comprehensive BDD test scenarios for the JustBrief platform, covering all 6 MVPs with 300+ scenarios across 10 feature files.

---

## Feature Files

### 1. `siga-authentication.feature`
**Requirements:** JSN-014, JSN-015, JSN-016, JSN-026  
**Scenarios:** 35  
**Focus:** SIGA RBAC authentication, role-based access control, permission enforcement

**Key Coverage:**
- User authentication via SIGA (not Azure EntraID)
- Role validation (regional_spoc, market_user, epam_admin)
- Permission checks for pipeline and brief operations
- JWT token validation and session management
- Role caching with 15-minute TTL
- Unauthorized access prevention
- SIGA unavailability error handling

**Tags:** `@justbrief @authentication @siga @smoke @regression @nfr @error-handling`

---

### 2. `pipeline-management.feature`
**Requirements:** JSN-001, JSN-002, JSN-003  
**Scenarios:** 40  
**Focus:** Campaign pipeline CRUD operations, market assignment, status management

**Key Coverage:**
- Pipeline creation by Regional SPOC and EPAM admin
- Market assignment to pipelines
- Pipeline status changes (Draft → Active → Cancelled → Completed)
- Pipelines cannot be permanently deleted (only Cancelled)
- Pipeline updates and validation
- Concurrent pipeline modifications
- Audit trail for all pipeline operations

**Tags:** `@justbrief @pipeline-management @smoke @regression @boundary @concurrency`

---

### 3. `pipeline-visibility.feature`
**Requirements:** JSN-005, JSN-006  
**Scenarios:** 30  
**Focus:** Market user view of available campaigns, market scoping, campaign selection

**Key Coverage:**
- Market users see only campaigns assigned to their market
- Campaign filtering by type, date, status
- Campaign search and sorting
- Campaign selection to start briefing
- Draft brief continuation
- Empty states and pagination
- Real-time campaign list updates

**Tags:** `@justbrief @pipeline-visibility @smoke @regression @nfr`

---

### 4. `brief-submission.feature`
**Requirements:** JSN-007, JSN-010  
**Scenarios:** 45  
**Focus:** Campaign brief creation, structured forms, validation, draft saving, submission

**Key Coverage:**
- Brief creation and draft saving
- Mandatory field validation
- Multi-step form navigation
- Auto-save functionality
- Brief preview before submission
- Brief submission workflow
- Read-only mode after submission
- Concurrent editing prevention

**Tags:** `@justbrief @brief-submission @smoke @regression @boundary @concurrency @nfr`

---

### 5. `asset-upload.feature`
**Requirements:** JSN-008, JSN-020  
**Scenarios:** 40  
**Focus:** File upload, S3 storage, metadata capture, size limits, progress tracking

**Key Coverage:**
- Single and multiple asset uploads
- Drag-and-drop upload interface
- Upload progress tracking with cancellation
- File size validation (100 MB limit)
- File type validation
- Asset metadata management
- S3 storage with unique keys
- Presigned URL generation for downloads
- Asset list and deletion

**Tags:** `@justbrief @asset-upload @smoke @regression @boundary @concurrency @nfr`

---

### 6. `campaign-flow-builder.feature`
**Requirements:** JSN-009  
**Scenarios:** 35  
**Focus:** Visual campaign flow definition, node types, connections, validation

**Key Coverage:**
- Flow creation with multiple node types (Screen, Decision, Redirection, Instant Win, API Call)
- Node connections and branching logic
- Node configuration and metadata
- Flow validation (disconnected nodes, circular references, terminal nodes)
- Flow editing (move, delete, duplicate nodes)
- Flow persistence as JSON
- Auto-save and recovery
- Flow visualization (zoom, pan, color-coding)
- Flow templates

**Tags:** `@justbrief @campaign-flow-builder @smoke @regression @boundary @nfr`

---

### 7. `jira-integration.feature`
**Requirements:** JSN-011, JSN-012, JSN-013, JSN-027  
**Scenarios:** 40  
**Focus:** Automatic Jira ticket creation, notifications, traceability, error handling

**Key Coverage:**
- Automatic Jira ticket creation on brief submission
- Ticket content mapping (brief data, assets, flow)
- Custom field population
- EPAM team email notifications
- Complete traceability (Pipeline → Brief → Jira)
- Jira API error handling with retry logic
- Manual ticket creation/linking for failures
- Ticket updates on brief status changes

**Tags:** `@justbrief @jira-integration @smoke @regression @boundary @concurrency @nfr @error-handling`

---

### 8. `pipeline-export.feature`
**Requirements:** JSN-004  
**Scenarios:** 25  
**Focus:** CSV export with filtering, data formatting, permissions

**Key Coverage:**
- CSV export of pipeline data
- Filtering by status, market, campaign type, date range
- CSV formatting and encoding (UTF-8)
- Special character handling
- Export permissions by role
- Large dataset handling
- Column selection and export presets
- Alternative formats (Excel, JSON)

**Tags:** `@justbrief @pipeline-export @smoke @regression @boundary @nfr`

---

### 9. `data-governance.feature`
**Requirements:** JSN-017, JSN-018, JSN-019  
**Scenarios:** 35  
**Focus:** PMI database storage, audit trail, data retrieval, compliance

**Key Coverage:**
- All data stored in PMI database infrastructure (not EPAM)
- Historical data retrieval for audit
- Complete audit trail for all operations
- Immutable audit logs
- Data standardization across markets
- Data retention policies
- Data backup and recovery
- Encryption at rest and in transit
- Database access control
- Data isolation by market/region
- GDPR and data residency compliance

**Tags:** `@justbrief @data-governance @smoke @regression @nfr`

---

### 10. `error-scenarios.feature`
**Requirements:** All (cross-cutting)  
**Scenarios:** 30  
**Focus:** Error handling, resilience, graceful degradation

**Key Coverage:**
- SIGA unavailability and timeout
- Jira API failures (unavailable, auth error, timeout)
- PMI database failures (unavailable, timeout, deadlock)
- S3 storage failures (unavailable, timeout, insufficient storage)
- Network failures and interruptions
- Validation errors (client and server-side)
- Concurrent access conflicts
- Session expiry and permission loss
- Browser errors and crashes
- Rate limiting and throttling
- Data corruption handling

**Tags:** `@justbrief @error-scenarios @smoke @regression @error-handling @nfr`

---

## Test Plan

See **`test-plan.md`** for:
- Comprehensive test strategy
- Requirements traceability matrix
- Test execution phases
- Test data management
- Environment requirements
- Defect management process
- Test metrics and reporting
- Risk assessment
- Success criteria

---

## Running the Tests

### Prerequisites
```bash
# Install dependencies
dotnet restore
npm install

# Set up test database
dotnet ef database update --project JustBrief.Infrastructure

# Configure test environment variables
export SIGA_API_URL=https://siga-test.pmi.com
export JIRA_API_URL=https://jira-test.pmi.com
export AWS_S3_BUCKET=justbrief-test-assets
```

### Execute Smoke Tests
```bash
dotnet test JustBrief.Specs --filter "Tag=@smoke"
```

### Execute Regression Tests
```bash
dotnet test JustBrief.Specs --filter "Tag=@regression"
```

### Execute Feature-Specific Tests
```bash
# Authentication tests
dotnet test JustBrief.Specs --filter "Tag=@authentication"

# Pipeline management tests
dotnet test JustBrief.Specs --filter "Tag=@pipeline-management"

# Brief submission tests
dotnet test JustBrief.Specs --filter "Tag=@brief-submission"
```

### Execute NFR Tests
```bash
dotnet test JustBrief.Specs --filter "Tag=@nfr"
```

### Execute Error Handling Tests
```bash
dotnet test JustBrief.Specs --filter "Tag=@error-handling"
```

### Generate Test Report
```bash
dotnet test JustBrief.Specs --logger "html;LogFileName=test-results.html"
```

---

## Test Data

### Standard Test Personas

| Persona | Role | Market/Region | Used In |
|---------|------|---------------|---------|
| `regional_spoc_eu` | Regional SPOC | EU | Pipeline management, export |
| `epam_admin` | EPAM Admin | Global | All administrative scenarios |
| `market_user_de` | Market User | DE (Germany) | Brief submission, assets, flow |
| `market_user_fr` | Market User | FR (France) | Market isolation scenarios |
| `market_user_it` | Market User | IT (Italy) | Multi-market scenarios |

### Test Data Seeding

Test data is automatically seeded before each test run:
- 10 pipelines (various statuses and markets)
- 5 briefs (draft and submitted)
- 20 assets (various types and sizes)
- 3 campaign flows (simple, branching, complex)

---

## Continuous Integration

Tests are executed automatically in the CI/CD pipeline:

1. **On every commit:** Unit tests
2. **On every PR:** Unit + Integration tests
3. **Nightly:** Full regression suite
4. **Pre-release:** Smoke + Regression + NFR + E2E

---

## Coverage Summary

| Category | Scenarios | Requirements | Status |
|----------|-----------|--------------|--------|
| **Smoke Tests** | 25 | All critical paths | ✅ Complete |
| **Regression Tests** | 200+ | All functional requirements | ✅ Complete |
| **Boundary Tests** | 25 | Edge cases and limits | ✅ Complete |
| **Concurrency Tests** | 15 | Multi-user scenarios | ✅ Complete |
| **NFR Tests** | 40 | Performance, security, usability | ✅ Complete |
| **Error Handling** | 30 | Resilience and recovery | ✅ Complete |
| **Total** | **300+** | **28 requirements** | ✅ Complete |

---

## Maintenance

### Adding New Scenarios
1. Identify the appropriate feature file
2. Follow existing scenario structure
3. Use Given/When/Then format
4. Tag appropriately (@smoke, @regression, etc.)
5. Update test-plan.md traceability matrix

### Updating Existing Scenarios
1. Maintain backward compatibility
2. Update scenario tags if priority changes
3. Update test-plan.md if requirements change
4. Re-run affected test suite

### Deprecating Scenarios
1. Mark scenario with @deprecated tag
2. Document reason in scenario comments
3. Plan removal for next major release
4. Update test-plan.md

---

## Support

**QA Team Lead:** [Name]  
**BA Owner:** Chamaa, Zaki  
**Tech Lead:** [Name]  

**Questions?** Contact the QA team via Slack: #justbrief-qa

---

**Last Updated:** 20 March 2026  
**Version:** 1.0  
**Status:** Ready for Implementation
