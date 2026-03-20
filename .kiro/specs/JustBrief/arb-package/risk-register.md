# Risk Register: JustBrief Platform

**Project:** JustBrief Campaign Briefing Platform  
**Epic:** JSN-11995  
**Last Updated:** 20 March 2026  
**Risk Assessment Date:** 20 March 2026

---

## Risk Assessment Methodology

**Likelihood Scale:**
- Very Low (10%): Unlikely to occur
- Low (25%): May occur in exceptional circumstances
- Medium (50%): May occur under normal circumstances
- High (75%): Likely to occur
- Very High (90%): Almost certain to occur

**Impact Scale:**
- Very Low (1-2): Minimal impact on project
- Low (3-4): Minor delays or cost increases
- Medium (5-6): Moderate impact requiring management attention
- High (7-8): Significant impact requiring executive attention
- Very High (9-10): Critical impact threatening project success

**Risk Score = Likelihood × Impact**

---

## High-Priority Risks (Score ≥ 4.0)

### RISK-001: SIGA Integration Complexity
**Category:** Technical Integration  
**Likelihood:** Medium (60%)  
**Impact:** High (8)  
**Risk Score:** 4.8  

**Description:** SIGA RBAC system may have limited API capabilities or complex authentication flows that could delay integration or require architectural changes.

**Potential Consequences:**
- 2-4 week development delay
- Need for alternative authentication approach
- Reduced functionality in initial release
- Additional development costs ($15,000-30,000)

**Mitigation Strategies:**
1. **Pre-Development Spike:** Conduct 1-week technical spike to validate SIGA API capabilities
2. **Fallback Authentication:** Design alternative authentication using existing JustScan patterns
3. **Early Engagement:** Involve SIGA team in architecture review and planning
4. **Phased Integration:** Implement basic authentication first, advanced features later

**Contingency Plan:** If SIGA integration proves unfeasible, implement JWT-based authentication with manual role assignment as interim solution.

**Owner:** Lead Backend Developer  
**Review Date:** Weekly during development

---

### RISK-002: User Adoption Resistance
**Category:** Business/Organizational  
**Likelihood:** High (70%)  
**Impact:** Medium (5)  
**Risk Score:** 3.5  

**Description:** Markets accustomed to email/document-based processes may resist transitioning to structured platform workflows.

**Potential Consequences:**
- Slow adoption rates (< 50% in first 6 months)
- Continued use of legacy processes
- Reduced ROI and business value
- Need for extended support and training

**Mitigation Strategies:**
1. **Comprehensive Training:** Develop training materials and conduct workshops
2. **Gradual Rollout:** Start with pilot markets, expand based on feedback
3. **User Feedback Loop:** Regular feedback sessions and iterative improvements
4. **Change Management:** Involve market representatives in design process
5. **Incentivization:** Highlight time savings and efficiency gains

**Contingency Plan:** Implement parallel processes during transition period, gradually phase out legacy methods.

**Owner:** Product Manager  
**Review Date:** Monthly post-launch

---

## Medium-Priority Risks (Score 2.0-3.9)

### RISK-003: Asset Upload Performance Issues
**Category:** Technical Performance  
**Likelihood:** Medium (40%)  
**Impact:** Medium (6)  
**Risk Score:** 2.4  

**Description:** Large asset uploads (50-100MB) may cause timeouts, poor user experience, or S3 storage issues.

**Mitigation Strategies:**
1. **Multipart Uploads:** Implement S3 multipart upload for files > 10MB
2. **Progress Indication:** Real-time upload progress and status updates
3. **File Size Limits:** Enforce reasonable limits with clear messaging
4. **Compression:** Automatic compression for supported file types
5. **Load Testing:** Performance testing with realistic file sizes

**Owner:** Backend Developer  
**Review Date:** During MVP 5 development

---

### RISK-004: PMI Database Schema Impact
**Category:** Technical Infrastructure  
**Likelihood:** Low (30%)  
**Impact:** High (7)  
**Risk Score:** 2.1  

**Description:** New database tables and relationships may conflict with existing PMI database schemas or performance requirements.

**Mitigation Strategies:**
1. **Schema Review:** Early review with PMI database team
2. **Migration Strategy:** Comprehensive database migration planning
3. **Performance Testing:** Load testing with realistic data volumes
4. **Backward Compatibility:** Ensure no impact on existing systems
5. **Rollback Plan:** Database rollback procedures if issues arise

**Owner:** Database Administrator  
**Review Date:** Before production deployment

---

## Low-Priority Risks (Score < 2.0)

### RISK-005: GDPR Compliance Issues
**Category:** Legal/Compliance  
**Likelihood:** Low (20%)  
**Impact:** High (9)  
**Risk Score:** 1.8  

**Description:** Asset uploads may contain personal data requiring specific GDPR handling procedures.

**Mitigation Strategies:**
1. **Legal Review:** Comprehensive legal review of data handling
2. **Data Classification:** Implement data classification for uploaded assets
3. **Privacy Controls:** User consent mechanisms and data retention policies
4. **Audit Trail:** Complete audit logging for data access and processing

**Owner:** Legal/Compliance Team  
**Review Date:** Before production deployment

---

### RISK-006: S3 Storage Cost Escalation
**Category:** Financial  
**Likelihood:** Medium (50%)  
**Impact:** Low (3)  
**Risk Score:** 1.5  

**Description:** Asset storage costs may exceed projections if usage patterns differ from estimates.

**Mitigation Strategies:**
1. **Storage Lifecycle:** Implement S3 lifecycle policies for cost optimization
2. **Monitoring:** Real-time cost monitoring and alerting
3. **Compression:** Automatic compression for supported file types
4. **Usage Analytics:** Track storage patterns and optimize accordingly

**Owner:** DevOps Engineer  
**Review Date:** Monthly post-launch

---

### RISK-007: Jira API Rate Limiting
**Category:** Technical Integration  
**Likelihood:** Low (20%)  
**Impact:** Medium (6)  
**Risk Score:** 1.2  

**Description:** Jira API may impose rate limits that could affect automatic ticket creation during peak usage.

**Mitigation Strategies:**
1. **Request Batching:** Batch multiple operations where possible
2. **Retry Logic:** Exponential backoff retry mechanisms
3. **SLA Agreement:** Establish SLA with Jira team for API usage
4. **Queue System:** Implement queue for ticket creation during high load

**Owner:** Integration Developer  
**Review Date:** During MVP 3 development

---

## Risk Monitoring and Review

### Review Schedule
- **Weekly:** During active development phases
- **Bi-weekly:** During testing and deployment phases
- **Monthly:** Post-production monitoring

### Escalation Criteria
- Risk score increases above 4.0
- New risks identified with score > 3.0
- Mitigation strategies prove ineffective
- Multiple risks materialize simultaneously

### Risk Reporting
- **Weekly Status:** Include risk updates in project status reports
- **Monthly Dashboard:** Risk trend analysis and mitigation effectiveness
- **Quarterly Review:** Comprehensive risk register review and updates

---

## Risk Response Strategies Summary

| Risk Level | Response Strategy | Approval Required |
|------------|------------------|-------------------|
| High (≥4.0) | Active mitigation, contingency planning | Project Manager |
| Medium (2.0-3.9) | Mitigation planning, regular monitoring | Team Lead |
| Low (<2.0) | Accept with monitoring | Team Lead |

**Risk Budget:** $50,000 allocated for risk mitigation activities  
**Risk Owner:** Project Manager  
**Next Review:** 27 March 2026