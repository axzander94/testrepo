# Development Tasks: JustBrief

**Feature:** JustBrief Campaign Briefing Platform  
**Epic:** JSN-11995  
**Total Estimated Dev-Days:** 45  

---

## MVP 1: Pipeline Visibility (8 tasks, ~12 dev-days)

### TASK-001 [BE] [TEST] Write Failing Tests for Pipeline Domain
**Files:** `JustBrief.Tests/Domain/PipelineTests.cs`, `JustBrief.Tests/Services/PipelineServiceTests.cs`  
**AC:** NUnit tests written for Pipeline entity validation, PipelineService CRUD operations, all tests failing  
**Estimate:** 3 hours  

### TASK-002 [DB] Create Pipeline Database Schema
**Files:** `Migrations/20260320_001_CreateJustBriefTables.sql`  
**AC:** Pipeline table created with indexes, foreign keys, and constraints as per design  
**Estimate:** 2 hours  

### TASK-003 [BE] Implement Pipeline Domain Entity
**Files:** `JustBrief.Domain/Entities/Pipeline.cs`, `JustBrief.Domain/Enums/PipelineStatus.cs`  
**AC:** Pipeline entity with NPoco mappings, validation attributes, status enum  
**Estimate:** 4 hours  

### TASK-004 [BE] Implement Pipeline Service & Repository
**Files:** `JustBrief.Application/Services/PipelineService.cs`, `JustBrief.Infrastructure/Repositories/PipelineRepository.cs`  
**AC:** CRUD operations, filtering, CSV export functionality, hexagonal architecture compliance  
**Estimate:** 4 hours  

### TASK-005 [BE] Implement Pipeline API Controller
**Files:** `JustBrief.API/Controllers/PipelineController.cs`  
**AC:** REST endpoints for pipeline CRUD, OpenAPI documentation, proper HTTP status codes  
**Estimate:** 3 hours  

### TASK-006 [FE] Create Pipeline Management UI Components
**Files:** `Frontend/components/Pipeline/PipelineList.tsx`, `Frontend/components/Pipeline/CreatePipelineModal.tsx`  
**AC:** Pipeline list view, create/edit modals, market assignment interface  
**Estimate:** 4 hours  

### TASK-007 [BE] Implement SIGA Authentication Integration
**Files:** `JustBrief.Infrastructure/Authentication/SigaAuthenticationService.cs`, `JustBrief.API/Middleware/SigaAuthMiddleware.cs`  
**AC:** JWT validation, role extraction, permission checking, error handling  
**Estimate:** 4 hours  

### TASK-008 [TEST] Integration Tests for Pipeline Module
**Files:** `JustBrief.Integration/PipelineIntegrationTests.cs`  
**AC:** End-to-end tests against real SQL Server, SIGA mock integration  
**Estimate:** 4 hours  

---

## MVP 2: Basic Campaign Brief Submission (6 tasks, ~8 dev-days)

### TASK-009 [BE] [TEST] Write Failing Tests for Brief Domain
**Files:** `JustBrief.Tests/Domain/BriefTests.cs`, `JustBrief.Tests/Services/BriefServiceTests.cs`  
**AC:** NUnit tests for Brief entity, BriefService operations, validation rules  
**Estimate:** 3 hours  

### TASK-010 [DB] Create Brief Database Schema
**Files:** `Migrations/20260320_002_CreateBriefTables.sql`  
**AC:** Brief table with JSON content storage, foreign keys to Pipeline table  
**Estimate:** 2 hours  

### TASK-011 [BE] Implement Brief Domain & Service
**Files:** `JustBrief.Domain/Entities/Brief.cs`, `JustBrief.Application/Services/BriefService.cs`  
**AC:** Brief entity with content serialization, CRUD operations, status management  
**Estimate:** 4 hours  

### TASK-012 [BE] Implement Brief API Controller
**Files:** `JustBrief.API/Controllers/BriefController.cs`  
**AC:** Brief CRUD endpoints, validation, market-specific filtering  
**Estimate:** 3 hours  

### TASK-013 [FE] Create Basic Brief Submission Form
**Files:** `Frontend/components/Brief/BriefForm.tsx`, `Frontend/services/briefService.ts`  
**AC:** Form for basic campaign details, file upload placeholder, draft saving  
**Estimate:** 4 hours  

### TASK-014 [TEST] Integration Tests for Brief Module
**Files:** `JustBrief.Integration/BriefIntegrationTests.cs`  
**AC:** Brief CRUD operations tested against real database  
**Estimate:** 4 hours  

---

## MVP 3: Jira Integration & Automation (4 tasks, ~6 dev-days)

### TASK-015 [BE] [TEST] Write Failing Tests for Jira Integration
**Files:** `JustBrief.Tests/Services/JiraIntegrationServiceTests.cs`  
**AC:** Mock Jira API tests, ticket creation scenarios, error handling  
**Estimate:** 2 hours  

### TASK-016 [BE] Implement Jira Integration Service
**Files:** `JustBrief.Infrastructure/Integrations/JiraTicketService.cs`  
**AC:** Jira REST API client, ticket creation from brief data, error handling with retries  
**Estimate:** 4 hours  

### TASK-017 [BE] Implement Brief Submission Workflow
**Files:** `JustBrief.Application/Services/BriefSubmissionService.cs`  
**AC:** Orchestrates brief submission, Jira ticket creation, status updates, notifications  
**Estimate:** 3 hours  

### TASK-018 [TEST] Integration Tests for Jira Workflow
**Files:** `JustBrief.Integration/JiraIntegrationTests.cs`  
**AC:** End-to-end submission workflow with Jira mock, error scenarios  
**Estimate:** 3 hours
---

## MVP 4: Enhanced Campaign Brief Submission (7 tasks, ~9 dev-days)

### TASK-019 [BE] [TEST] Write Failing Tests for Enhanced Brief Features
**Files:** `JustBrief.Tests/Domain/BriefContentTests.cs`, `JustBrief.Tests/Validation/BriefValidationTests.cs`  
**AC:** Tests for structured brief content, validation rules, mandatory field checking  
**Estimate:** 3 hours  

### TASK-020 [BE] Implement Enhanced Brief Content Model
**Files:** `JustBrief.Domain/ValueObjects/BriefContent.cs`, `JustBrief.Domain/Validation/BriefValidator.cs`  
**AC:** Structured content model, comprehensive validation, business rules enforcement  
**Estimate:** 4 hours  

### TASK-021 [FE] Create Structured Brief Form Components
**Files:** `Frontend/components/Brief/StructuredBriefForm.tsx`, `Frontend/components/Brief/ValidationSummary.tsx`  
**AC:** Multi-step form, field validation, progress tracking, mandatory field indicators  
**Estimate:** 4 hours  

### TASK-022 [BE] Implement Brief Content Validation API
**Files:** `JustBrief.API/Controllers/ValidationController.cs`  
**AC:** Real-time validation endpoints, field-level validation, error messaging  
**Estimate:** 2 hours  

### TASK-023 [FE] Implement Form State Management
**Files:** `Frontend/hooks/useBriefForm.ts`, `Frontend/context/BriefFormContext.tsx`  
**AC:** Form state persistence, auto-save, validation state management  
**Estimate:** 3 hours  

### TASK-024 [FE] Create Brief Preview & Summary
**Files:** `Frontend/components/Brief/BriefPreview.tsx`, `Frontend/components/Brief/SubmissionSummary.tsx`  
**AC:** Read-only preview, submission checklist, final validation before submit  
**Estimate:** 3 hours  

### TASK-025 [TEST] Integration Tests for Enhanced Brief Features
**Files:** `JustBrief.Integration/EnhancedBriefTests.cs`  
**AC:** Validation scenarios, form submission workflows, error handling  
**Estimate:** 3 hours  

---

## MVP 5: Asset Upload & Flow Definition (9 tasks, ~12 dev-days)

### TASK-026 [BE] [TEST] Write Failing Tests for Asset Management
**Files:** `JustBrief.Tests/Services/AssetServiceTests.cs`, `JustBrief.Tests/Domain/AssetTests.cs`  
**AC:** Asset upload tests, S3 integration mocks, metadata validation  
**Estimate:** 3 hours  

### TASK-027 [DB] Create Asset Database Schema
**Files:** `Migrations/20260320_003_CreateAssetTables.sql`  
**AC:** Asset table with metadata JSON storage, foreign keys to Brief table  
**Estimate:** 2 hours  

### TASK-028 [BE] Implement Asset Domain & Service
**Files:** `JustBrief.Domain/Entities/Asset.cs`, `JustBrief.Application/Services/AssetService.cs`  
**AC:** Asset entity, upload/download operations, metadata management  
**Estimate:** 4 hours  

### TASK-029 [BE] Implement S3 Integration
**Files:** `JustBrief.Infrastructure/Storage/S3AssetStorage.cs`  
**AC:** S3 upload/download, presigned URLs, file validation, error handling  
**Estimate:** 4 hours  

### TASK-030 [BE] Implement Asset API Controller
**Files:** `JustBrief.API/Controllers/AssetController.cs`  
**AC:** Multipart upload endpoint, download endpoint, asset listing  
**Estimate:** 3 hours  

### TASK-031 [FE] Create Asset Upload Components
**Files:** `Frontend/components/Assets/AssetUpload.tsx`, `Frontend/components/Assets/AssetList.tsx`  
**AC:** Drag-drop upload, progress indicators, metadata forms, file validation  
**Estimate:** 4 hours  

### TASK-032 [FE] Implement Campaign Flow Builder
**Files:** `Frontend/components/Flow/FlowBuilder.tsx`, `Frontend/components/Flow/FlowCanvas.tsx`  
**AC:** Visual flow editor, node creation, connection logic, flow validation  
**Estimate:** 4 hours  

### TASK-033 [BE] Implement Campaign Flow Storage
**Files:** `JustBrief.Domain/ValueObjects/CampaignFlow.cs`, `JustBrief.Application/Services/FlowService.cs`  
**AC:** Flow definition model, JSON serialization, validation rules  
**Estimate:** 3 hours  

### TASK-034 [TEST] Integration Tests for Asset & Flow Features
**Files:** `JustBrief.Integration/AssetFlowIntegrationTests.cs`  
**AC:** Asset upload/download workflows, flow persistence, S3 integration  
**Estimate:** 3 hours  

---

## MVP 6: Pipeline Management Enhancements (5 tasks, ~6 dev-days)

### TASK-035 [BE] [TEST] Write Failing Tests for Advanced Pipeline Features
**Files:** `JustBrief.Tests/Services/PipelineReportingTests.cs`  
**AC:** CSV export tests, filtering tests, reporting functionality  
**Estimate:** 2 hours  

### TASK-036 [BE] Implement Advanced Pipeline Filtering & Export
**Files:** `JustBrief.Application/Services/PipelineReportingService.cs`  
**AC:** Complex filtering, CSV generation, data aggregation, performance optimization  
**Estimate:** 4 hours  

### TASK-037 [FE] Create Advanced Pipeline Management UI
**Files:** `Frontend/components/Pipeline/PipelineFilters.tsx`, `Frontend/components/Pipeline/ExportDialog.tsx`  
**AC:** Filter interface, export options, bulk operations, advanced search  
**Estimate:** 4 hours  

### TASK-038 [BE] Implement Pipeline Analytics API
**Files:** `JustBrief.API/Controllers/AnalyticsController.cs`  
**AC:** Pipeline metrics, submission statistics, performance data  
**Estimate:** 3 hours  

### TASK-039 [TEST] Final Integration & Smoke Tests
**Files:** `JustBrief.Integration/SmokeTests.cs`, `JustBrief.E2E/PlaywrightTests.cs`  
**AC:** Complete end-to-end workflows, performance validation, production readiness  
**Estimate:** 3 hours  

---

## Summary by Phase

| MVP | Tasks | Dev-Days | Focus |
|-----|-------|----------|-------|
| MVP 1 | 8 | 12 | Pipeline visibility, SIGA integration |
| MVP 2 | 6 | 8 | Basic brief submission |
| MVP 3 | 4 | 6 | Jira automation |
| MVP 4 | 7 | 9 | Enhanced brief forms |
| MVP 5 | 9 | 12 | Assets & flow builder |
| MVP 6 | 5 | 6 | Advanced management |
| **Total** | **39** | **53** | **Complete platform** |

---

## Testing Strategy

- **Unit Tests:** NUnit 4.2.2 for all business logic
- **Integration Tests:** Real SQL Server 2022 + mocked external services
- **E2E Tests:** Playwright for critical user journeys
- **Performance Tests:** Load testing for asset uploads and concurrent users
- **Security Tests:** OWASP compliance, authentication/authorization validation