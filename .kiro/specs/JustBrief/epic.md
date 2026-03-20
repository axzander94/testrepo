# Epic: JustBrief
**Jira:** JSN-11995  
**BA Owner:** Chamaa, Zaki (contracted)  
**Component:** JustBrief  
**Date:** 20 March 2026  
**Platform:** JustScan (PMI)

---

## Problem Statement

The current campaign submission and pipeline management process is highly fragmented and relies on multiple disconnected tools and manual steps. Campaign requests are currently shared as PowerPoint presentations and PDF documents and circulated through Jira tickets, emails, Microsoft Teams messages, and shared files. This results in information being scattered across different communication channels.

Because there is no centralized system to manage the campaign pipeline and submissions, several operational issues occur:
- Campaign information is often incomplete or inconsistent
- Multiple clarification cycles are required between markets and EPAM
- There is no clear traceability between the campaign pipeline and the corresponding Jira ticket
- Campaign requests are difficult to track and manage
- The process requires manual coordination between several stakeholders

As a result, the time required to move from campaign idea to campaign execution becomes unnecessarily long, inefficient, and difficult to manage at scale.

---

## Solution

JustBrief is an all-in-one campaign briefing and pipeline management tool designed to centralize the entire campaign submission process in a single platform. Instead of relying on multiple disconnected steps, JustBrief merges them into one structured workflow, where every stakeholder interacts with the same system using role-based access.

- Regional SPOCs and the EPAM team manage the campaign pipeline
- Markets can view available campaigns directly from the pipeline
- Markets select a campaign, complete the briefing, upload assets, and design the campaign flow
- Once submitted, a Jira ticket is automatically created, and the EPAM team is notified to begin assessment and token estimation

JustBrief reduces the time required to submit a campaign brief from several days to approximately 30 minutes.

**Platform URL:** https://justbrief.bokarcampaigns.com

---

## Epic Story

As a Market representative, Regional SPOC, or Webmaster  
I want to manage campaign pipelines and submit campaign briefs through a centralized platform  
So that campaign requests can be submitted quickly, with complete information, and automatically forwarded for assessment and execution.

---

## MVP Decomposition (6 MVPs)

| MVP | Name | Description | Stories |
|-----|------|-------------|---------|
| MVP 1 | Pipeline Visibility | Create the basic platform where Regional SPOCs and EPAM can create campaign pipelines and markets can view available campaigns. No briefing functionality yet. Centralizes pipeline visibility, replacing current pipeline files shared manually. | 8 |
| MVP 2 | Basic Campaign Brief Submission | Introduce the campaign briefing interface where markets can upload PPTs and assets as zip files for a smooth transition. Focus on standardizing campaign submissions without friction. | 6 |
| MVP 3 | Jira Integration & Automation | Automatically create Jira tickets after brief submission and notify EPAM teams for assessment and estimation. Removes need for manual ticket creation and improves traceability. | 4 |
| MVP 4 | Campaign Brief Submission | Introduce the campaign briefing interface where markets can fill campaign details and submit briefs. Focus on ensuring required information is captured through structured forms. | 7 |
| MVP 5 | Asset Upload & Flow Definition | Allow markets to upload assets, provide asset metadata, and visually define the campaign flow within the platform. Helps EPAM teams understand campaign logic and asset usage before development begins. | 9 |
| MVP 6 | Pipeline Management Enhancements | Add advanced pipeline management capabilities including filtering, CSV export, and improved traceability of campaign submissions. Supports operational management and reporting needs. | 5 |

**Total Stories:** 39

---

## Key Design Decisions

| Decision | Rationale | Impact |
|----------|-----------|--------|
| SIGA RBAC Integration | Must integrate with existing PMI authorization framework, not Azure EntraID | Authentication architecture, user management |
| PMI Database Storage | All structured data stored within PMI infrastructure, not EPAM systems | Data governance, compliance, scalability |
| Jira API Integration | Automatic ticket creation via Jira API for seamless workflow | Integration complexity, notification system |
| Asset Storage in S3 | Large file uploads require scalable storage solution | Infrastructure costs, performance |
| Visual Flow Builder | Markets need intuitive way to define campaign logic | UI complexity, development effort |

---

## Scope Boundaries

### In Scope
- Pipeline management (create, view, manage campaigns)
- Campaign brief submission with structured forms
- Asset upload and metadata management
- Visual campaign flow definition
- Automated Jira ticket creation and notifications
- Role-based access control via SIGA
- CSV export and filtering capabilities

### Out of Scope
- Campaign execution and runtime configuration
- Integration with campaign deployment tools
- Token consumption tracking during execution
- Modification of existing Jira workflows
- Campaign performance analytics

---

## Assumptions

1. **SIGA Integration Available:** SIGA RBAC system has APIs available for role mapping and authorization
2. **PMI Database Access:** PMI database infrastructure can accommodate new JustBrief data models
3. **Jira API Permissions:** EPAM has necessary permissions to create tickets via Jira API
4. **S3 Storage Approval:** AWS S3 usage approved for campaign asset storage
5. **User Training:** Markets will receive training on new platform to ensure adoption
6. **Network Connectivity:** All users have reliable internet access for file uploads

---

## Open Questions

1. **RBAC Definition:** What exact roles will exist in JustBrief? How will these roles map to the existing SIGA RBAC structure?
2. **Data Storage Strategy:** Where will campaign briefs and pipeline data be stored? How will campaign flow definitions be persisted and versioned?
3. **Jira Integration Scope:** Which Jira project(s) will receive the automatically created tickets? What fields must be populated?
4. **Notification Mechanism:** How will EPAM teams be notified of new submissions (Jira notifications, email, or both)?
5. **Pipeline Ownership:** Who will be responsible for maintaining and updating campaign pipelines over time?
6. **Campaign Flow Representation:** What level of detail will markets be required to provide when drawing the campaign flow?
7. **Asset Validation:** What file formats and size limits will be allowed for asset uploads?

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| RBAC Integration with SIGA | Medium | High | Early technical spike to validate SIGA API capabilities |
| Data Storage Architecture | Medium | High | Define storage model in requirements phase |
| Jira Integration Complexity | Low | Medium | Prototype Jira API integration early |
| Incomplete Brief Submissions | High | Medium | Implement comprehensive validation and required fields |
| Asset Management Performance | Medium | Medium | Load testing with realistic file sizes |
| User Adoption Resistance | High | Low | Comprehensive training and gradual rollout |
| Pipeline Governance Issues | Medium | Medium | Define clear ownership and governance rules |

---

## Success Metrics

- **Efficiency:** Brief submission time reduced from several days to ~30 minutes
- **Completeness:** 95% of briefs submitted with all required information on first attempt
- **Traceability:** 100% of submitted briefs automatically linked to Jira tickets
- **Adoption:** 90% of markets using JustBrief within 6 months of rollout
- **Process Standardization:** Elimination of email-based brief submissions

---

## Dependencies

- **SIGA RBAC System:** For user authentication and authorization
- **PMI Database Infrastructure:** For data storage and persistence
- **Jira API:** For automated ticket creation
- **AWS S3:** For asset storage
- **JustScan Platform:** JustBrief will be integrated into existing JustScan ecosystem

---

## Compliance Considerations

- **Data Governance:** All data must comply with PMI data governance policies
- **GDPR:** Asset uploads may contain personal data requiring proper handling
- **Security:** Integration with SIGA ensures consistent security model
- **Audit Trail:** Complete traceability from pipeline to execution required