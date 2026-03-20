# Development Tasks: Integration Configuration Management

**Feature:** Integration Configuration Management  
**Epic ID:** JSN-INTCFG  
**Total Estimated Effort:** 42 dev-days  
**MVPs:** 3 phases

---

## MVP 1: Read-Only Integration Visibility + RBAC (14 days)

### TASK-001: [BE] [DB] Create integration domain model and database schema
**Files:** 
- `src/Backoffice/Domain/Integration.cs`
- `src/Backoffice/Domain/MarketIntegration.cs`
- `src/Backoffice/Domain/IntegrationEndpoint.cs`
- `src/Backoffice/Domain/IntegrationAuditLog.cs`
- `src/Backoffice/Migrations/20241219_001_CreateIntegrationTables.sql`

**Acceptance Criteria:** 
- All 4 tables created with proper constraints and indexes
- NPoco POCOs map correctly to database schema
- Migration script runs successfully on SQL Server 2022

**Effort:** 4 hours  
**Dependencies:** None

### TASK-002: [BE] [TEST] Write failing NUnit tests for integration service
**Files:**
- `src/Backoffice.Tests/Services/IntegrationServiceTests.cs`
- `src/Backoffice.Tests/Controllers/IntegrationControllerTests.cs`

**Acceptance Criteria:**
- Test coverage for all CRUD operations
- Mock dependencies (repository, secrets manager, audit service)
- Tests initially fail (red phase of TDD)

**Effort:** 3 hours  
**Dependencies:** TASK-001

### TASK-003: [BE] Implement RBAC authorization attributes
**Files:**
- `src/Backoffice/Authorization/IntegrationRoleRequirement.cs`
- `src/Backoffice/Authorization/IntegrationRoleHandler.cs`
- `src/Backoffice/Extensions/ServiceCollectionExtensions.cs`

**Acceptance Criteria:**
- IntegrationAdmin and IntegrationViewer roles enforced
- Azure EntraID group membership validation
- Unauthorized access returns 403 Forbidden

**Effort:** 4 hours  
**Dependencies:** None

### TASK-004: [BE] Create integration repository with read operations
**Files:**
- `src/Backoffice/Repositories/IIntegrationRepository.cs`
- `src/Backoffice/Repositories/IntegrationRepository.cs`

**Acceptance Criteria:**
- GetIntegrationsAsync with market filtering
- GetIntegrationDetailAsync with endpoint status
- Proper error handling for not found scenarios
- Connection pooling and query optimization

**Effort:** 4 hours  
**Dependencies:** TASK-001

### TASK-005: [BE] Implement integration service (read-only operations)
**Files:**
- `src/Backoffice/Services/IIntegrationService.cs`
- `src/Backoffice/Services/IntegrationService.cs`

**Acceptance Criteria:**
- Business logic for integration listing and details
- Market-based filtering logic
- Proper exception handling and logging
- Cache integration for performance

**Effort:** 4 hours  
**Dependencies:** TASK-003, TASK-004

### TASK-006: [BE] Create integration API controller
**Files:**
- `src/Backoffice/API/Controllers/IntegrationController.cs`
- `src/Backoffice/API/Models/IntegrationListResponse.cs`
- `src/Backoffice/API/Models/IntegrationDetailResponse.cs`

**Acceptance Criteria:**
- GET /api/v1/integrations endpoint with market filter
- GET /api/v1/integrations/{id} endpoint
- OpenAPI 3.x specification generated
- Proper HTTP status codes and error responses

**Effort:** 3 hours  
**Dependencies:** TASK-005

### TASK-007: [FE] Create integration list page component
**Files:**
- `src/Backoffice/Frontend/components/IntegrationList.tsx`
- `src/Backoffice/Frontend/components/IntegrationCard.tsx`
- `src/Backoffice/Frontend/hooks/useIntegrations.ts`

**Acceptance Criteria:**
- Market filter dropdown functionality
- Integration cards show status and endpoint count
- Loading states and error handling
- Responsive design for tablet/desktop

**Effort:** 6 hours  
**Dependencies:** TASK-006

### TASK-008: [FE] Create integration detail view component
**Files:**
- `src/Backoffice/Frontend/components/IntegrationDetail.tsx`
- `src/Backoffice/Frontend/components/EndpointStatus.tsx`

**Acceptance Criteria:**
- Display integration metadata and configuration
- Show endpoint enable/disable status (read-only in MVP1)
- Breadcrumb navigation back to list
- Role-based UI element visibility

**Effort:** 4 hours  
**Dependencies:** TASK-007

### TASK-009: [BE] Implement audit logging infrastructure
**Files:**
- `src/Backoffice/Services/IAuditService.cs`
- `src/Backoffice/Services/AuditService.cs`
- `src/Backoffice/Repositories/IAuditRepository.cs`
- `src/Backoffice/Repositories/AuditRepository.cs`

**Acceptance Criteria:**
- Structured audit logging to IntegrationAuditLog table
- No sensitive data in audit logs
- Immutable audit entries with proper indexing
- 2+ year retention policy configuration

**Effort:** 4 hours  
**Dependencies:** TASK-001

### TASK-010: [TEST] Integration tests for MVP1 functionality
**Files:**
- `src/Backoffice.Integration/IntegrationManagementTests.cs`

**Acceptance Criteria:**
- End-to-end test against real SQL Server 2022
- RBAC authorization testing with mock Azure EntraID
- API response validation and error scenarios
- Performance testing for 100+ integrations

**Effort:** 4 hours  
**Dependencies:** All previous MVP1 tasks

---

## MVP 2: Credential Management + Endpoint Toggle (16 days)

### TASK-011: [INFRA] Setup AWS Secrets Manager integration
**Files:**
- `src/Backoffice/Infrastructure/SecretsManagerService.cs`
- `src/Backoffice/Infrastructure/ISecretsManagerService.cs`
- `terraform/secrets-manager.tf`
- `terraform/iam-roles.tf`

**Acceptance Criteria:**
- IAM roles with least privilege for Secrets Manager access
- VPC endpoint configuration for secure access
- Error handling for Secrets Manager unavailability
- Encryption at rest and in transit

**Effort:** 6 hours  
**Dependencies:** DevOps team for IAM setup

### TASK-012: [BE] [TEST] Write failing tests for credential management
**Files:**
- `src/Backoffice.Tests/Services/SecretsManagerServiceTests.cs`
- `src/Backoffice.Tests/Services/IntegrationServiceCredentialTests.cs`

**Acceptance Criteria:**
- Mock AWS Secrets Manager SDK calls
- Test credential validation and format checking
- Test error scenarios (invalid format, AWS unavailable)
- Security test: ensure no credentials in logs

**Effort:** 3 hours  
**Dependencies:** TASK-011

### TASK-013: [BE] Implement credential update operations
**Files:**
- `src/Backoffice/Services/IntegrationService.cs` (extend)
- `src/Backoffice/API/Models/UpdateCredentialsRequest.cs`
- `src/Backoffice/API/Models/CredentialsDto.cs`

**Acceptance Criteria:**
- UpdateCredentialsAsync method with validation
- Credential format validation (API key, connection string)
- Audit logging for all credential operations
- Cache invalidation after credential updates

**Effort:** 5 hours  
**Dependencies:** TASK-011, TASK-012

### TASK-014: [BE] Add credential update API endpoint
**Files:**
- `src/Backoffice/API/Controllers/IntegrationController.cs` (extend)

**Acceptance Criteria:**
- PUT /api/v1/integrations/{id}/credentials endpoint
- IntegrationAdmin role required
- Request validation and error handling
- No credential values in API responses (masked)

**Effort:** 3 hours  
**Dependencies:** TASK-013

### TASK-015: [FE] Create secure credential input form
**Files:**
- `src/Backoffice/Frontend/components/CredentialForm.tsx`
- `src/Backoffice/Frontend/components/MaskedInput.tsx`
- `src/Backoffice/Frontend/hooks/useCredentials.ts`

**Acceptance Criteria:**
- Password-type inputs with masking
- Client-side validation for required fields
- Success/error notifications
- No credential values stored in browser state

**Effort:** 5 hours  
**Dependencies:** TASK-014

### TASK-016: [BE] Implement endpoint toggle operations
**Files:**
- `src/Backoffice/Services/IntegrationService.cs` (extend)
- `src/Backoffice/API/Models/ToggleEndpointRequest.cs`

**Acceptance Criteria:**
- ToggleEndpointAsync method with validation
- Real-time configuration updates
- Cache invalidation and WebApp notification
- Audit logging for endpoint changes

**Effort:** 4 hours  
**Dependencies:** TASK-013

### TASK-017: [BE] Add endpoint toggle API endpoint
**Files:**
- `src/Backoffice/API/Controllers/IntegrationController.cs` (extend)

**Acceptance Criteria:**
- PATCH /api/v1/integrations/{id}/endpoints/{name} endpoint
- IntegrationAdmin role required
- Optimistic concurrency handling
- WebApp cache invalidation trigger

**Effort:** 3 hours  
**Dependencies:** TASK-016

### TASK-018: [FE] Create endpoint toggle UI components
**Files:**
- `src/Backoffice/Frontend/components/EndpointToggle.tsx`
- `src/Backoffice/Frontend/components/EndpointList.tsx`

**Acceptance Criteria:**
- Toggle switches for each endpoint (sendOTP, lastName, firstName)
- Real-time status updates
- Optimistic UI updates with rollback on error
- Disabled state for IntegrationViewer role

**Effort:** 4 hours  
**Dependencies:** TASK-017

### TASK-019: [BE] Implement test connection functionality
**Files:**
- `src/Backoffice/Services/IntegrationService.cs` (extend)
- `src/Backoffice/Infrastructure/DatabaseConnectors/`

**Acceptance Criteria:**
- TestConnectionAsync method with 10-second timeout
- Support for different PMI database types
- Detailed error messages for connection failures
- No credential exposure in error logs

**Effort:** 6 hours  
**Dependencies:** TASK-013

### TASK-020: [FE] Add test connection UI
**Files:**
- `src/Backoffice/Frontend/components/TestConnection.tsx`

**Acceptance Criteria:**
- Test connection button in credential form
- Loading spinner during test (max 10 seconds)
- Success/failure status display
- Retry functionality on failure

**Effort:** 3 hours  
**Dependencies:** TASK-019

### TASK-021: [BE] WebApp configuration integration
**Files:**
- `src/WebApp/Services/IntegrationConfigService.cs`
- `src/WebApp/Cache/IntegrationConfigCache.cs`

**Acceptance Criteria:**
- WebApp reads configuration from new tables
- 5-minute cache TTL for configuration
- Graceful fallback if configuration unavailable
- No breaking changes to existing campaigns

**Effort:** 5 hours  
**Dependencies:** TASK-016

### TASK-022: [TEST] Integration tests for MVP2 functionality
**Files:**
- `src/Backoffice.Integration/CredentialManagementTests.cs`
- `src/WebApp.Integration/ConfigurationIntegrationTests.cs`

**Acceptance Criteria:**
- End-to-end credential update flow
- Endpoint toggle with WebApp configuration update
- AWS Secrets Manager integration testing
- Security testing: no credential leakage

**Effort:** 4 hours  
**Dependencies:** All previous MVP2 tasks

---

## MVP 3: Database Assignment Management (12 days)

### TASK-023: [BE] [TEST] Write failing tests for database assignment
**Files:**
- `src/Backoffice.Tests/Services/IntegrationServiceAssignmentTests.cs`

**Acceptance Criteria:**
- Test assignment/unassignment operations
- Test safety checks for active campaigns
- Test concurrent assignment scenarios
- Test bulk assignment operations

**Effort:** 3 hours  
**Dependencies:** MVP2 completion

### TASK-024: [BE] Implement database assignment operations
**Files:**
- `src/Backoffice/Services/IntegrationService.cs` (extend)
- `src/Backoffice/API/Models/AssignDatabaseRequest.cs`

**Acceptance Criteria:**
- AssignDatabaseToMarketAsync method
- UnassignDatabaseFromMarketAsync with safety checks
- Integration with CampaignService for active campaign validation
- Proper error handling for business rule violations

**Effort:** 5 hours  
**Dependencies:** TASK-023

### TASK-025: [BE] Add database assignment API endpoints
**Files:**
- `src/Backoffice/API/Controllers/IntegrationController.cs` (extend)

**Acceptance Criteria:**
- POST /api/v1/markets/{market}/integrations/{id} (assign)
- DELETE /api/v1/markets/{market}/integrations/{id} (unassign)
- Validation for active campaigns before unassignment
- Bulk assignment endpoint for multiple markets

**Effort:** 4 hours  
**Dependencies:** TASK-024

### TASK-026: [FE] Create database assignment management UI
**Files:**
- `src/Backoffice/Frontend/components/DatabaseAssignment.tsx`
- `src/Backoffice/Frontend/components/MarketSelector.tsx`
- `src/Backoffice/Frontend/components/BulkAssignment.tsx`

**Acceptance Criteria:**
- Drag-and-drop interface for database assignment
- Market selection with multi-select capability
- Visual indicators for assignment status
- Confirmation dialogs for unassignment operations

**Effort:** 6 hours  
**Dependencies:** TASK-025

### TASK-027: [BE] Implement safety checks for active campaigns
**Files:**
- `src/Backoffice/Services/CampaignIntegrationService.cs`
- `src/Backoffice/Repositories/ICampaignRepository.cs` (extend)

**Acceptance Criteria:**
- GetActiveCampaignsUsingIntegration method
- Detailed campaign information in error responses
- Performance optimization for large campaign datasets
- Caching for frequently checked integrations

**Effort:** 4 hours  
**Dependencies:** TASK-024

### TASK-028: [FE] Add bulk assignment operations
**Files:**
- `src/Backoffice/Frontend/components/BulkAssignment.tsx` (extend)
- `src/Backoffice/Frontend/hooks/useBulkAssignment.ts`

**Acceptance Criteria:**
- Select multiple markets for bulk assignment
- Progress indicator for bulk operations
- Partial failure handling and reporting
- Undo functionality for recent assignments

**Effort:** 4 hours  
**Dependencies:** TASK-026

### TASK-029: [INFRA] Setup observability and alerting
**Files:**
- `src/Backoffice/Observability/IntegrationMetrics.cs`
- `terraform/cloudwatch-alarms.tf`
- `config/newrelic-dashboard.json`

**Acceptance Criteria:**
- New Relic dashboard for integration metrics
- OpsGenie alerts for critical failures
- Performance monitoring for credential operations
- Security monitoring for unauthorized access attempts

**Effort:** 3 hours  
**Dependencies:** All previous tasks

### TASK-030: [TEST] End-to-end integration tests and smoke tests
**Files:**
- `src/Backoffice.Integration/FullIntegrationWorkflowTests.cs`
- `src/E2E.Tests/IntegrationManagementE2E.spec.ts`

**Acceptance Criteria:**
- Complete workflow testing: create → assign → configure → test
- Playwright E2E tests for all user journeys
- Performance testing under load (25 concurrent users)
- Smoke tests for dev environment deployment

**Effort:** 4 hours  
**Dependencies:** All previous tasks

---

## Task Summary

### Total Tasks: 30
- **Backend:** 18 tasks (60%)
- **Frontend:** 8 tasks (27%)
- **Infrastructure:** 2 tasks (7%)
- **Testing:** 2 tasks (7%)

### Effort Distribution
- **MVP 1:** 14 days (33%)
- **MVP 2:** 16 days (38%)
- **MVP 3:** 12 days (29%)

### Critical Path Dependencies
1. Database schema → Repository → Service → Controller → UI
2. AWS Secrets Manager setup → Credential management → WebApp integration
3. RBAC implementation → All user-facing features
4. Campaign safety checks → Database assignment features

### Risk Mitigation
- All tasks limited to 6 hours maximum
- Test-first approach with failing tests
- Integration tests against real SQL Server 2022
- Incremental deployment with feature flags