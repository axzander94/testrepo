# Architecture Decision Record: Integration Configuration Management

**ADR ID:** ADR-2024-012  
**Title:** Self-Service Integration Configuration Management  
**Status:** Proposed  
**Date:** 2024-12-19  
**Authors:** Architecture Pipeline  
**Reviewers:** ARB Committee

---

## 1. Business Outline

### Current Process Limitations
JustScan integrates with external PMI databases via APIs to enrich consumer engagement across global markets. Currently, managing these integrations requires manual backend developer intervention for:
- Adding new database integrations
- Updating existing integration credentials  
- Enabling integrations for new markets
- Toggling individual API endpoints (sendOTP, lastName, firstName)

This creates significant operational friction:
- **Developer Distraction:** 15% of backend developer time spent on configuration tasks
- **Content Manager Delays:** 8-12 hours/week waiting for integration changes
- **Risk Exposure:** Manual configuration changes introduce human error risk
- **Scalability Bottleneck:** Cannot scale to support rapid market expansion

### Business Problem
The manual integration management process slows campaign launches, creates developer bottlenecks, and introduces operational risk through manual configuration changes in production systems.

### Value Proposition
Self-service integration management will:
- **Reduce Time-to-Market:** Integration changes from 2-4 hours to 5 minutes
- **Increase Developer Productivity:** Reduce config tasks from 15% to <2% of developer time
- **Improve Operational Safety:** Eliminate manual production configuration changes
- **Enable Market Scalability:** Support rapid onboarding of new markets (<30 minutes vs 3-5 days)

---

## 2. Solution Outline

### Proposed Solution
Implement a comprehensive Integration Configuration Management module within the existing JustScan Backoffice system, providing self-service capabilities for content managers with appropriate permissions.

### Components Being Changed
1. **Backoffice System:** New Integration Management module with RBAC
2. **WebApp System:** Modified to read configuration from new centralized tables
3. **Database Schema:** New tables for integration configuration and audit logging
4. **Authentication System:** Extended Azure EntraID roles (IntegrationAdmin, IntegrationViewer)
5. **Infrastructure:** AWS Secrets Manager integration for secure credential storage

### Dependencies
- **External:** AWS Secrets Manager (new dependency)
- **Internal:** Azure EntraID (extended usage), SQL Server (new tables)
- **Teams:** IT (EntraID setup), DevOps (IAM roles), Security (review), DBA (retention policies)

### Regulatory/Compliance Drivers
- **SOC 2 Type II:** Audit trail retention ≥2 years for all configuration changes
- **GDPR:** No PII in error logs or monitoring systems  
- **PMI Security Standards:** Credential rotation tracking and secure storage
- **Data Residency:** Market-specific credential isolation requirements

---

## 3. Solution Technical Details

The solution implements a hexagonal architecture pattern with clear separation of concerns:

**API Layer:** RESTful endpoints with OpenAPI 3.x specification, role-based authorization via Azure EntraID integration, comprehensive input validation and error handling.

**Business Logic:** Integration service managing CRUD operations, credential lifecycle, endpoint configuration, and business rule enforcement (e.g., preventing database unassignment with active campaigns).

**Data Layer:** New SQL Server tables for integrations, market assignments, endpoint configurations, and immutable audit logging with proper indexing for performance.

**Infrastructure:** AWS Secrets Manager integration with IAM least-privilege access, VPC endpoints for secure communication, and Redis caching for configuration reads with 5-minute TTL.

**Security:** All credentials stored exclusively in AWS Secrets Manager with encryption at rest/transit, credential masking in UI/API responses, comprehensive audit logging without sensitive data exposure.

**Observability:** Structured logging via Serilog, New Relic metrics for performance monitoring, OpsGenie alerts for critical failures, and security monitoring for unauthorized access attempts.

---

## 4. Proposed Solution Architecture

```mermaid
graph TB
    subgraph "Backoffice System"
        UI[Integration Management UI<br/>React/TypeScript]
        API[Integration Controller<br/>ASP.NET Core]
        SVC[Integration Service<br/>Business Logic]
        REPO[Integration Repository<br/>Data Access]
    end
    
    subgraph "External Systems"
        ENTRA[Azure EntraID<br/>RBAC Provider]
        SECRETS[AWS Secrets Manager<br/>Credential Storage]
    end
    
    subgraph "Data Layer"
        DB[(SQL Server 2022<br/>Integration Tables)]
        CACHE[(Redis Cache<br/>Configuration)]
    end
    
    subgraph "WebApp System"
        WEBAPP[WebApp Service<br/>Campaign Engine]
        CONFIG[Config Service<br/>Integration Reader]
    end
    
    subgraph "Monitoring"
        LOGS[Serilog<br/>Structured Logging]
        METRICS[New Relic<br/>APM & Metrics]
        ALERTS[OpsGenie<br/>Alerting]
    end
    
    UI --> API
    API --> ENTRA
    API --> SVC
    SVC --> REPO
    SVC --> SECRETS
    REPO --> DB
    SVC --> CACHE
    
    CONFIG --> DB
    CONFIG --> CACHE
    WEBAPP --> CONFIG
    
    SVC --> LOGS
    API --> METRICS
    METRICS --> ALERTS
    
    classDef new fill:#e1f5fe
    classDef existing fill:#f3e5f5
    classDef external fill:#fff3e0
    
    class UI,API,SVC,REPO,SECRETS new
    class WEBAPP,CONFIG,DB,CACHE,ENTRA existing
    class LOGS,METRICS,ALERTS external
```

---

## 5. Financial Impact on Infrastructure

### New Infrastructure Costs (Annual)

| Component | Monthly Cost | Annual Cost | Notes |
|-----------|-------------|-------------|-------|
| AWS Secrets Manager | $120 | $1,440 | ~300 secrets, 10K API calls/month |
| Additional RDS Storage | $45 | $540 | 50GB for new tables and audit logs |
| ElastiCache (Redis) Scaling | $80 | $960 | Increased cache usage for config |
| CloudWatch Logs | $25 | $300 | Additional structured logging |
| **Total New Costs** | **$270** | **$3,240** | |

### Cost Savings (Annual)

| Benefit | Monthly Savings | Annual Savings | Calculation |
|---------|----------------|----------------|-------------|
| Developer Time Reduction | $8,750 | $105,000 | 2 developers × 15% → 2% time savings |
| Faster Campaign Launches | $4,200 | $50,400 | 15% → 2% delay reduction impact |
| Reduced Manual Errors | $1,000 | $12,000 | Estimated incident cost reduction |
| **Total Savings** | **$13,950** | **$167,400** | |

### Net Financial Impact
- **Annual Cost:** $3,240
- **Annual Savings:** $167,400  
- **Net Annual Benefit:** $164,160
- **ROI:** 5,067%
- **Payback Period:** 0.7 months

---

## 6. Alternatives Considered

### Alternative 1: Configuration Management Service
**Description:** Build a separate microservice dedicated to integration configuration management.

| Criteria | Score | Rationale |
|----------|-------|-----------|
| Development Effort | 2/5 | Requires new service, deployment pipeline, monitoring |
| Operational Complexity | 2/5 | Additional service to maintain, network calls between services |
| Security | 4/5 | Service isolation provides security benefits |
| Performance | 3/5 | Network latency for configuration reads |
| Cost | 2/5 | Additional infrastructure for new service |
| **Total** | **13/25** | |

### Alternative 2: Direct Database Configuration
**Description:** Store credentials in encrypted database columns instead of AWS Secrets Manager.

| Criteria | Score | Rationale |
|----------|-------|-----------|
| Development Effort | 4/5 | Simpler implementation, no external service integration |
| Operational Complexity | 4/5 | Fewer moving parts, standard database operations |
| Security | 2/5 | Database encryption less secure than dedicated secrets service |
| Performance | 5/5 | No external API calls for credential retrieval |
| Cost | 5/5 | No additional infrastructure costs |
| **Total** | **20/25** | |

### Alternative 3: Proposed Solution (Backoffice Module + Secrets Manager)
**Description:** Extend existing Backoffice with integration management module using AWS Secrets Manager.

| Criteria | Score | Rationale |
|----------|-------|-----------|
| Development Effort | 4/5 | Leverages existing infrastructure and patterns |
| Operational Complexity | 4/5 | Integrates with existing monitoring and deployment |
| Security | 5/5 | AWS Secrets Manager provides enterprise-grade security |
| Performance | 4/5 | Caching mitigates Secrets Manager latency |
| Cost | 4/5 | Minimal infrastructure additions |
| **Total** | **21/25** | **SELECTED** |

### Trade-off Analysis
The proposed solution (Alternative 3) provides the best balance of security, maintainability, and cost-effectiveness. While Alternative 2 offers simplicity, it fails to meet PMI security standards for credential management. Alternative 1 provides good isolation but introduces unnecessary complexity for this use case.

---

## 7. NFR Analysis

### Latency Requirements
- **Integration List Load:** <2 seconds for 100 integrations ✅
- **Credential Updates:** <5 seconds end-to-end ✅  
- **Endpoint Toggles:** <1 second response time ✅
- **Configuration Propagation:** <5 minutes to WebApp ✅

**Mitigation:** Redis caching with 5-minute TTL, database indexing, connection pooling

### Throughput Requirements  
- **Concurrent Users:** 25 integration administrators ✅
- **API Requests:** 1,000 requests/hour peak ✅
- **Credential Operations:** 50 updates/hour ✅
- **Bulk Assignments:** 20 markets in <30 seconds ✅

**Mitigation:** Horizontal scaling via ECS Fargate, database read replicas, async processing

### Availability Requirements
- **Uptime Target:** 99.5% during business hours ✅
- **Recovery Time:** <15 minutes for critical failures ✅
- **Backup Strategy:** Point-in-time recovery for audit logs ✅

**Mitigation:** Multi-AZ deployment, health checks, graceful degradation for Secrets Manager outages

### Security Requirements
- **Credential Protection:** AWS Secrets Manager encryption ✅
- **Access Control:** Azure EntraID RBAC integration ✅  
- **Audit Compliance:** Immutable logs with 2+ year retention ✅
- **Network Security:** HTTPS-only, VPC endpoints ✅

**Mitigation:** Defense in depth, least privilege access, comprehensive audit logging

---

## 8. Risk Register

| Risk ID | Risk Description | Likelihood | Impact | Score | Mitigation Strategy |
|---------|------------------|------------|--------|-------|-------------------|
| R-001 | AWS Secrets Manager outage | Low | High | 6 | Graceful degradation, cached credentials, monitoring alerts |
| R-002 | Incorrect credentials break campaigns | Medium | Critical | 9 | Test connection validation, rollback capability, staging environment |
| R-003 | Insufficient IAM permissions | Medium | Medium | 6 | Least privilege principle, automated permission testing |
| R-004 | Race conditions on concurrent updates | Low | Low | 2 | Optimistic locking, conflict resolution, audit logging |
| R-005 | Audit log retention compliance failure | Medium | Medium | 6 | Automated retention policies, compliance monitoring |
| R-006 | Secrets Manager rate limiting | Low | Medium | 4 | Caching strategy, exponential backoff, monitoring |
| R-007 | Accidental database unassignment | Low | Low | 2 | Active campaign validation, confirmation dialogs |
| R-008 | Database migration breaks existing campaigns | Medium | Critical | 9 | Blue-green deployment, rollback plan, extensive testing |
| R-009 | Azure EntraID sync delays | Low | Medium | 4 | Permission caching, manual refresh option |
| R-010 | Credential exposure in browser | Low | Critical | 6 | Server-side masking, no client-side credential storage |

### High-Priority Risk Mitigation (Score ≥6)
- **R-002 & R-008:** Comprehensive testing strategy with staging environment validation
- **R-001:** Implement circuit breaker pattern for Secrets Manager calls
- **R-010:** Security review of all credential handling code paths
- **R-003 & R-005:** Automated compliance monitoring and alerting

---

## 9. Open Questions Requiring ARB Decision

### Q1: Credential Versioning Strategy
**Question:** Should the system maintain multiple versions of credentials for rollback scenarios?  
**Options:**
- A) Store only current credentials (simpler, lower cost)
- B) Maintain 3 previous versions (enables rollback, higher complexity)
- C) Full credential history with retention policy (complete audit trail, highest cost)

**Recommendation:** Option B - provides rollback capability without excessive complexity  
**ARB Decision Required:** Approve versioning strategy and retention policy

### Q2: OAuth 2.0 Support Timeline  
**Question:** When should OAuth 2.0 authentication be implemented for PMI database connections?  
**Context:** Current solution supports API key authentication; some PMI databases may migrate to OAuth 2.0  
**Options:**
- A) Include in MVP 2 (delays delivery by 2 weeks)
- B) Post-MVP enhancement (faster delivery, potential rework)
- C) Conditional implementation based on PMI database roadmap

**Recommendation:** Option C - implement when PMI databases confirm OAuth 2.0 migration timeline  
**ARB Decision Required:** Approve OAuth 2.0 implementation strategy

### Q3: Multi-Region Credential Isolation
**Question:** Should credentials be isolated per region for compliance with data residency requirements?  
**Context:** Some markets have strict data residency laws requiring credential storage in specific regions  
**Impact:** May require multiple AWS Secrets Manager instances across regions  
**ARB Decision Required:** Approve multi-region architecture requirements

### Q4: Integration Testing Strategy with Production PMI Databases
**Question:** How should integration testing be conducted with live PMI database connections?  
**Options:**
- A) Mock all external database calls (safer, less realistic)
- B) Dedicated test credentials for production databases (realistic, requires PMI coordination)
- C) Separate test environment databases (most realistic, highest cost)

**ARB Decision Required:** Approve testing strategy and PMI coordination requirements

---

## ARB Checklist Status

### Mandatory Sections Complete
- ✅ Business Outline with value proposition
- ✅ Solution outline with dependencies  
- ✅ Technical details (200 words)
- ✅ Architecture diagram with Mermaid
- ✅ Financial impact analysis
- ✅ Alternatives considered (3 options with trade-off matrix)
- ✅ NFR analysis (latency, throughput, availability, security)
- ✅ Risk register (likelihood × impact × mitigation)
- ✅ Open questions requiring ARB decision (4 questions)

### Items Requiring Human Sign-off
1. **Security Review:** Credential handling and AWS Secrets Manager integration
2. **Compliance Review:** SOC 2 and GDPR audit trail requirements  
3. **PMI Coordination:** External database testing and OAuth 2.0 timeline
4. **Budget Approval:** $3,240 annual infrastructure cost approval

### Recommended ARB Submission Date
**Target Date:** January 15, 2025  
**Rationale:** Allows time for security review completion and PMI coordination discussions