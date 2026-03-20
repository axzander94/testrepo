# JustBrief Test Plan

**Epic:** JSN-11995  
**Platform:** JustScan (PMI)  
**Date:** 20 March 2026  
**Test Framework:** Gherkin/Cucumber with NUnit 4.2.2

---

## Executive Summary

This test plan provides comprehensive BDD test coverage for the JustBrief campaign briefing platform. The plan covers all 6 MVPs with 10 feature files containing 300+ scenarios across functional, non-functional, security, and error handling domains.

**Coverage Metrics:**
- **Total Feature Files:** 10
- **Total Scenarios:** 300+
- **Requirements Covered:** 28 (JSN-001 through JSN-028)
- **Test Types:** Smoke, Regression, Boundary, Concurrency, NFR, Error Handling

---

## Feature Files Overview

| # | Feature File | Requirements | Scenarios | Priority | Focus Area |
|---|--------------|--------------|-----------|----------|------------|
| 1 | `siga-authentication.feature` | JSN-014, JSN-015, JSN-016, JSN-026 | 35 | Critical | SIGA RBAC integration, role enforcement, permission checks |
| 2 | `pipeline-management.feature` | JSN-001, JSN-002, JSN-003 | 40 | Critical | Pipeline CRUD, market assignment, status management |
| 3 | `pipeline-visibility.feature` | JSN-005, JSN-006 | 30 | High | Market user campaign view, scoping, selection |
| 4 | `brief-submission.feature` | JSN-007, JSN-010 | 45 | Critical | Brief creation, validation, draft saving, submission |
| 5 | `asset-upload.feature` | JSN-008, JSN-020 | 40 | High | File upload, S3 storage, metadata, size limits |
| 6 | `campaign-flow-builder.feature` | JSN-009 | 35 | High | Visual flow definition, node types, validation |
| 7 | `jira-integration.feature` | JSN-011, JSN-012, JSN-013, JSN-027 | 40 | Critical | Automatic ticket creation, notifications, traceability |
| 8 | `pipeline-export.feature` | JSN-004 | 25 | Medium | CSV export, filtering, data formatting |
| 9 | `data-governance.feature` | JSN-017, JSN-018, JSN-019 | 35 | Critical | PMI database storage, audit trail, compliance |
| 10 | `error-scenarios.feature` | All | 30 | High | SIGA/Jira/S3 failures, resilience, error handling |

---

## Requirements Traceability Matrix

| Requirement ID | Description | Feature Files | Scenario Count | Status |
|----------------|-------------|---------------|----------------|--------|
| JSN-001 | Pipeline creation and management | pipeline-management.feature | 8 | ✅ Covered |
| JSN-002 | Market assignment to pipelines | pipeline-management.feature, pipeline-visibility.feature | 12 | ✅ Covered |
| JSN-003 | Pipeline status management (Cancelled state) | pipeline-management.feature | 6 | ✅ Covered |
| JSN-004 | CSV export with filters | pipeline-export.feature | 25 | ✅ Covered |
| JSN-005 | Market user view of available campaigns | pipeline-visibility.feature | 18 | ✅ Covered |
| JSN-006 | Campaign selection and briefing initiation | pipeline-visibility.feature | 12 | ✅ Covered |
| JSN-007 | Structured brief form with validation | brief-submission.feature | 30 | ✅ Covered |
| JSN-008 | Asset upload with metadata | asset-upload.feature | 25 | ✅ Covered |
| JSN-009 | Visual campaign flow builder | campaign-flow-builder.feature | 35 | ✅ Covered |
| JSN-010 | Brief submission and persistence | brief-submission.feature | 15 | ✅ Covered |
| JSN-011 | Automatic Jira ticket creation | jira-integration.feature | 20 | ✅ Covered |
| JSN-012 | EPAM team notification | jira-integration.feature | 8 | ✅ Covered |
| JSN-013 | Pipeline-to-Jira traceability | jira-integration.feature, data-governance.feature | 12 | ✅ Covered |
| JSN-014 | SIGA RBAC authentication | siga-authentication.feature | 12 | ✅ Covered |
| JSN-015 | Role-based access control | siga-authentication.feature | 15 | ✅ Covered |
| JSN-016 | SPOC/EPAM read access to briefs | siga-authentication.feature | 3 | ✅ Covered |
| JSN-017 | PMI database storage | data-governance.feature | 20 | ✅ Covered |
| JSN-018 | Data retrieval and audit trail | data-governance.feature | 10 | ✅ Covered |
| JSN-019 | Standardized campaign submissions | data-governance.feature | 5 | ✅ Covered |
| JSN-020 | Asset upload size limits and progress | asset-upload.feature | 15 | ✅ Covered |
| JSN-026 | SIGA integration (not Azure EntraID) | siga-authentication.feature | 5 | ✅ Covered |
| JSN-027 | Jira API error handling | jira-integration.feature, error-scenarios.feature | 15 | ✅ Covered |

---

## Test Scenario Categories

### 1. Smoke Tests (@smoke)
**Purpose:** Critical path validation for each MVP  
**Execution:** Every build, pre-deployment  
**Count:** 25 scenarios

**Key Smoke Scenarios:**
- User authentication via SIGA
- Pipeline creation and market assignment
- Campaign selection by market user
- Brief submission with all required data
- Asset upload to S3
- Campaign flow creation and save
- Jira ticket automatic creation
- CSV export generation

### 2. Regression Tests (@regression)
**Purpose:** Comprehensive feature validation  
**Execution:** Nightly, pre-release  
**Count:** 200+ scenarios

**Coverage Areas:**
- All CRUD operations
- Validation rules
- Business logic
- Data persistence
- Integration points
- Edge cases

### 3. Boundary Tests (@boundary)
**Purpose:** Validate limits and edge values  
**Execution:** Weekly, pre-release  
**Count:** 25 scenarios

**Test Cases:**
- Maximum field lengths (255 chars for names)
- File size limits (100 MB per asset)
- Maximum number of assets per brief
- Maximum number of nodes in flow (100)
- Date range boundaries
- Concurrent user limits (50)

### 4. Concurrency Tests (@concurrency)
**Purpose:** Validate multi-user scenarios  
**Execution:** Weekly, performance testing  
**Count:** 15 scenarios

**Test Cases:**
- Simultaneous pipeline updates
- Concurrent brief editing
- Multiple asset uploads
- Parallel Jira ticket creation
- Database deadlock handling

### 5. NFR Tests (@nfr)
**Purpose:** Non-functional requirements validation  
**Execution:** Weekly, performance testing  
**Count:** 40 scenarios

**Sub-categories:**
- **@nfr @performance:** Response times, throughput
- **@nfr @security:** Authentication, authorization, encryption
- **@nfr @usability:** UI/UX, accessibility, mobile responsiveness
- **@nfr @reliability:** Error recovery, retry logic
- **@nfr @observability:** Logging, monitoring, alerting

### 6. Error Handling Tests (@error-handling)
**Purpose:** Validate resilience and error recovery  
**Execution:** Weekly, pre-release  
**Count:** 30 scenarios

**Coverage:**
- SIGA unavailability
- Jira API failures
- Database connection issues
- S3 storage failures
- Network interruptions
- Validation errors
- Session expiry

---

## Test Execution Strategy

### Phase 1: Unit Testing (TDD)
**Framework:** NUnit 4.2.2  
**Scope:** Domain entities, services, validators  
**Execution:** Every commit via CI/CD

**Test Projects:**
- `JustBrief.Tests` - Unit tests for business logic
- `JustBrief.Domain.Tests` - Entity and value object tests
- `JustBrief.Application.Tests` - Service layer tests

### Phase 2: Integration Testing
**Framework:** NUnit 4.2.2 + Real SQL Server 2022  
**Scope:** Database operations, external integrations  
**Execution:** Every build

**Test Projects:**
- `JustBrief.Integration` - Database integration tests
- `JustBrief.Infrastructure.Tests` - SIGA, Jira, S3 integration tests

### Phase 3: BDD/Acceptance Testing
**Framework:** SpecFlow + Gherkin  
**Scope:** End-to-end user scenarios  
**Execution:** Nightly, pre-release

**Test Projects:**
- `JustBrief.Specs` - Gherkin feature files
- `JustBrief.Specs.Steps` - Step definitions

### Phase 4: E2E Testing
**Framework:** Playwright (TypeScript)  
**Scope:** Full user journeys across UI  
**Execution:** Pre-release, staging environment

**Test Suites:**
- Critical user paths (smoke tests)
- Complete workflows (regression)
- Cross-browser compatibility

---

## Test Data Management

### Test Personas
Following JustScan standard personas:

| Persona | Role | Used In |
|---------|------|---------|
| `regional_spoc` | Regional SPOC with pipeline management permissions | Pipeline management, export scenarios |
| `epam_admin` | EPAM admin with full system access | All administrative scenarios |
| `market_user_de` | Market user for Germany | Brief submission, asset upload, flow builder |
| `market_user_fr` | Market user for France | Market isolation scenarios |
| `market_user_it` | Market user for Italy | Multi-market scenarios |

### Test Data Sets

**Pipelines:**
- Active pipelines for multiple markets
- Draft pipelines
- Cancelled pipelines
- Completed pipelines
- Global pipelines

**Briefs:**
- Complete briefs with all fields
- Partial drafts
- Submitted briefs
- Briefs with Jira tickets
- Briefs with multiple assets

**Assets:**
- Images (JPG, PNG) - various sizes
- Videos (MP4) - up to 100 MB
- Documents (PDF) - with metadata
- Invalid file types for negative testing

---

## Environment Requirements

### Test Environments

| Environment | Purpose | Data | Integrations |
|-------------|---------|------|--------------|
| **Local Dev** | Developer testing | Mocked | SIGA mocked, Jira mocked, S3 LocalStack |
| **CI/CD** | Automated testing | Seeded | SIGA mocked, Jira mocked, S3 LocalStack |
| **Staging** | Pre-production validation | Production-like | Real SIGA, Real Jira (test project), Real S3 |
| **Production** | Smoke tests only | Real | Real SIGA, Real Jira, Real S3 |

### Infrastructure Dependencies

**Required Services:**
- SQL Server 2022 (PMI database)
- AWS S3 (asset storage)
- SIGA RBAC API (authentication)
- Jira REST API (ticket creation)
- AWS Secrets Manager (credentials)

**Test Doubles:**
- SIGA mock service for local/CI testing
- Jira mock service for local/CI testing
- LocalStack for S3 simulation
- In-memory SQL Server for fast unit tests

---

## Defect Management

### Severity Levels

| Severity | Definition | Example | SLA |
|----------|------------|---------|-----|
| **Critical** | System unusable, data loss | SIGA authentication fails, database corruption | 4 hours |
| **High** | Major feature broken | Brief submission fails, Jira ticket not created | 1 day |
| **Medium** | Feature partially broken | Validation error not displayed, export formatting issue | 3 days |
| **Low** | Minor issue, workaround exists | UI alignment issue, tooltip missing | 1 week |

### Defect Workflow
1. Defect identified during test execution
2. Defect logged in Jira with:
   - Feature file and scenario reference
   - Steps to reproduce
   - Expected vs actual result
   - Environment details
   - Screenshots/logs
3. Defect triaged by BA and Tech Lead
4. Defect assigned to developer
5. Fix verified by QA using original test scenario
6. Regression tests executed
7. Defect closed

---

## Test Metrics and Reporting

### Key Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Test Coverage** | 95% of requirements | Scenarios mapped to requirements |
| **Pass Rate** | 98% for smoke tests | Passed scenarios / Total scenarios |
| **Defect Density** | < 5 defects per feature | Defects found / Feature files |
| **Test Execution Time** | < 30 minutes for smoke | CI/CD pipeline duration |
| **Automation Rate** | 90% of scenarios | Automated scenarios / Total scenarios |

### Reporting Cadence

**Daily:**
- CI/CD test results
- Failed test summary
- Defect count by severity

**Weekly:**
- Test execution summary
- Coverage report
- Defect trend analysis
- NFR test results

**Per Release:**
- Comprehensive test report
- Requirements coverage matrix
- Defect closure report
- Test metrics dashboard

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| SIGA integration delays | Medium | High | Mock SIGA early, parallel development |
| Jira API rate limiting | Low | Medium | Implement retry logic, monitor usage |
| S3 upload performance issues | Medium | Medium | Load testing, optimize chunk size |
| Database performance degradation | Low | High | Index optimization, query tuning |
| Test data management complexity | High | Low | Automated test data seeding scripts |
| Test environment instability | Medium | Medium | Infrastructure as Code, monitoring |

---

## Success Criteria

The JustBrief platform is ready for production when:

✅ All smoke tests pass (100%)  
✅ Regression test pass rate ≥ 98%  
✅ All critical and high severity defects resolved  
✅ NFR targets met (performance, security, usability)  
✅ Integration tests pass against real SIGA, Jira, S3  
✅ E2E tests pass in staging environment  
✅ Security scan passes (no critical vulnerabilities)  
✅ Load testing validates 50 concurrent users  
✅ Data governance audit passes  
✅ User acceptance testing completed by Regional SPOCs

---

## Appendix A: Test Automation Architecture

```
JustBrief.Tests/
├── Unit/
│   ├── Domain/
│   │   ├── PipelineTests.cs
│   │   ├── BriefTests.cs
│   │   └── AssetTests.cs
│   ├── Services/
│   │   ├── PipelineServiceTests.cs
│   │   ├── BriefServiceTests.cs
│   │   └── AssetServiceTests.cs
│   └── Validators/
│       ├── BriefValidatorTests.cs
│       └── FlowValidatorTests.cs
├── Integration/
│   ├── PipelineIntegrationTests.cs
│   ├── BriefIntegrationTests.cs
│   ├── JiraIntegrationTests.cs
│   └── S3IntegrationTests.cs
├── Specs/
│   ├── Features/
│   │   ├── siga-authentication.feature
│   │   ├── pipeline-management.feature
│   │   ├── brief-submission.feature
│   │   └── [other feature files]
│   └── Steps/
│       ├── AuthenticationSteps.cs
│       ├── PipelineSteps.cs
│       ├── BriefSteps.cs
│       └── [other step definitions]
└── E2E/
    ├── PlaywrightTests.cs
    └── SmokeTests.cs
```

---

## Appendix B: Continuous Integration Pipeline

```yaml
stages:
  - build
  - unit-test
  - integration-test
  - bdd-test
  - e2e-test
  - deploy-staging
  - smoke-test-staging
  - deploy-production

unit-test:
  script:
    - dotnet test JustBrief.Tests --filter Category=Unit
  coverage: 90%

integration-test:
  script:
    - dotnet test JustBrief.Integration --filter Category=Integration
  services:
    - sqlserver:2022

bdd-test:
  script:
    - dotnet test JustBrief.Specs --filter Tag=@smoke
    - dotnet test JustBrief.Specs --filter Tag=@regression
  artifacts:
    reports:
      - cucumber-report.json

e2e-test:
  script:
    - npx playwright test
  artifacts:
    - playwright-report/
```

---

**Document Version:** 1.0  
**Last Updated:** 20 March 2026  
**Maintained By:** QA Team  
**Review Cycle:** Per MVP release
