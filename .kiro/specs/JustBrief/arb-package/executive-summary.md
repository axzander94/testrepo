# Executive Summary: JustBrief Platform

**Project:** JustBrief Campaign Briefing Platform  
**Epic:** JSN-11995  
**Prepared for:** Architecture Review Board  
**Date:** 20 March 2026

---

## Business Case

### Problem Statement
The current campaign submission process is fragmented across multiple tools (PowerPoint, PDF, Jira, email, Teams), resulting in:
- **Inefficiency:** Brief submission takes several days instead of minutes
- **Quality Issues:** 40% of briefs require clarification cycles due to incomplete information
- **Poor Traceability:** No clear link between pipeline, brief, and execution
- **Manual Overhead:** Significant coordination effort between markets and EPAM

### Solution Value
JustBrief centralizes the entire campaign briefing workflow into a single platform, delivering:
- **Time Savings:** Reduce brief submission from days to ~30 minutes
- **Quality Improvement:** Structured forms ensure complete submissions
- **Automation:** Automatic Jira ticket creation eliminates manual steps
- **Traceability:** Complete audit trail from pipeline to execution

### Financial Impact
- **Investment:** $1,926/year infrastructure costs
- **Savings:** $36,000/year in operational efficiency
- **ROI:** 1,769% annually
- **Payback Period:** < 1 month

---

## Technical Overview

### Architecture Approach
- **Pattern:** Hexagonal architecture for maintainability and testability
- **Technology:** .NET 8 backend, React 18 frontend (aligned with JustScan stack)
- **Integration:** SIGA RBAC, Jira API, AWS S3, PMI Database
- **Deployment:** AWS ECS Fargate with auto-scaling

### Key Technical Decisions
1. **Standalone Service:** Separate from JustScan backoffice for better maintainability
2. **SIGA Integration:** Leverage existing PMI authentication infrastructure
3. **PMI Database Storage:** Ensure data governance compliance
4. **AWS S3 Assets:** Scalable storage for campaign materials

---

## Risk Assessment

### High-Priority Risks
| Risk | Mitigation |
|------|------------|
| SIGA Integration Complexity | Early technical spike, fallback authentication |
| User Adoption Resistance | Training program, gradual rollout |

### Medium-Priority Risks
| Risk | Mitigation |
|------|------------|
| Asset Upload Performance | Multipart uploads, progress indication |
| Database Schema Impact | Migration strategy, backward compatibility |

**Overall Risk Level:** Medium - manageable with proper mitigation strategies

---

## Implementation Plan

### Development Phases
1. **MVP 1:** Pipeline visibility (3 weeks)
2. **MVP 2:** Basic brief submission (2 weeks)
3. **MVP 3:** Jira integration (1.5 weeks)
4. **MVP 4:** Enhanced brief forms (2.5 weeks)
5. **MVP 5:** Asset upload & flow builder (3 weeks)
6. **MVP 6:** Advanced management (1.5 weeks)

**Total Timeline:** 13.5 weeks (3.4 months)

### Resource Requirements
- **Backend Developer:** 1 FTE for 3.4 months
- **Frontend Developer:** 1 FTE for 3.4 months
- **DevOps Engineer:** 0.5 FTE for infrastructure setup
- **QA Engineer:** 0.5 FTE for testing

---

## ARB Review Triggers

This proposal triggers ARB review due to:
- ✅ **New Service:** JustBrief platform
- ✅ **External Dependencies:** Jira API integration
- ✅ **Auth Changes:** SIGA RBAC integration
- ✅ **Multi-Service Impact:** JustBrief, SIGA, Jira, PMI Database, S3

---

## Recommendation

**Approve** the JustBrief platform implementation with the following conditions:
1. Complete SIGA integration technical spike before development start
2. Implement phased rollout starting with pilot markets
3. Establish monitoring and alerting for all external integrations
4. Conduct security review before production deployment

**Expected Benefits:**
- Immediate operational efficiency gains
- Improved campaign brief quality and completeness
- Enhanced traceability and audit capabilities
- Foundation for future campaign management enhancements

**Next Steps:**
1. ARB approval by 15 April 2026
2. Technical spike completion by 30 April 2026
3. Development start by 15 May 2026
4. Production deployment by 31 August 2026