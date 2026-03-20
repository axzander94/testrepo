# Requirements Specification: JustBrief

**Feature:** JustBrief Campaign Briefing Platform  
**Epic:** JSN-11995  
**Date:** 20 March 2026  
**Status:** READY  

---

## 1. Functional Requirements

### 1.1 Pipeline Management (Regional SPOCs / EPAM)

**JSN-001** [FROM-EPIC] [MUST]  
WHEN a Regional SPOC or EPAM user accesses the pipeline management interface  
THE system SHALL provide capabilities to create new campaign pipelines  
**AC:** Given authenticated SPOC user, When creating pipeline, Then system captures campaign details, target markets, and availability dates  
**Source:** Epic AC #2

**JSN-002** [FROM-EPIC] [MUST]  
WHEN a Regional SPOC defines a campaign in the pipeline  
THE system SHALL allow assignment of specific markets that can access this campaign  
**AC:** Given campaign creation, When assigning markets, Then only assigned markets see this campaign in their view  
**Source:** Epic AC #3, #19

**JSN-003** [FROM-EPIC] [MUST]  
WHEN a Regional SPOC or EPAM user manages pipelines  
THE system SHALL provide capabilities to modify campaign status (including marking as Cancelled)  
**AC:** Given existing campaign, When changing status, Then campaign remains in system for traceability but access is controlled by status  
**Source:** Epic Scope - campaigns cannot be permanently deleted

**JSN-004** [FROM-EPIC] [SHOULD]  
WHEN a Regional SPOC exports pipeline data  
THE system SHALL generate CSV files with filtering options (campaign status, market, campaign type)  
**AC:** Given pipeline data, When exporting with filters, Then CSV contains only matching campaigns with all relevant metadata  
**Source:** Epic Scope, MVP 6

### 1.2 Campaign Selection (Markets)

**JSN-005** [FROM-EPIC] [MUST]  
WHEN a Market user accesses the platform  
THE system SHALL display only campaigns available to their assigned market  
**AC:** Given market user authentication, When viewing campaigns, Then only campaigns assigned to user's market are visible  
**Source:** Epic AC #4, #19

**JSN-006** [FROM-EPIC] [MUST]  
WHEN a Market user selects a campaign from the pipeline  
THE system SHALL initiate the briefing process for that specific campaign  
**AC:** Given available campaign, When user selects campaign, Then briefing interface opens with campaign context pre-populated  
**Source:** Epic AC #5

### 1.3 Brief Submission (Markets)

**JSN-007** [FROM-EPIC] [MUST]  
WHEN a Market user completes a campaign briefing  
THE system SHALL provide structured forms with mandatory field validation  
**AC:** Given briefing form, When submitting with missing required fields, Then system prevents submission and highlights missing fields  
**Source:** Epic AC #6, #7, #11

**JSN-008** [FROM-EPIC] [MUST]  
WHEN a Market user uploads campaign assets  
THE system SHALL accept file uploads and capture asset-specific metadata  
**AC:** Given asset upload interface, When uploading files, Then system stores files and captures metadata (name, description, usage context)  
**Source:** Epic AC #8, #9

**JSN-009** [FROM-EPIC] [MUST]  
WHEN a Market user defines campaign flow  
THE system SHALL provide visual interface for drawing campaign structure and logic  
**AC:** Given flow definition interface, When creating flow, Then system captures visual representation and underlying logic structure  
**Source:** Epic AC #10

**JSN-010** [FROM-EPIC] [MUST]  
WHEN a Market user submits a complete brief  
THE system SHALL register the submission and store all associated data  
**AC:** Given complete brief, When submitting, Then system persists all data and generates unique submission ID  
**Source:** Epic AC #12

### 1.4 Jira Integration & Automation

**JSN-011** [FROM-EPIC] [MUST]  
WHEN a campaign brief is successfully submitted  
THE system SHALL automatically create a Jira ticket containing all brief information  
**AC:** Given successful brief submission, When processing, Then Jira ticket created with structured data and submission ID reference  
**Source:** Epic AC #13, #14

**JSN-012** [FROM-EPIC] [MUST]  
WHEN a Jira ticket is created from brief submission  
THE system SHALL notify the appropriate EPAM team  
**AC:** Given Jira ticket creation, When ticket is created, Then notification sent to designated EPAM team members  
**Source:** Epic AC #15

**JSN-013** [FROM-EPIC] [MUST]  
WHEN a brief is submitted and processed  
THE system SHALL maintain traceability between pipeline entry, brief, and Jira ticket  
**AC:** Given submission process, When complete, Then clear audit trail exists linking pipeline → brief → Jira ticket  
**Source:** Epic AC #16

### 1.5 Access Control & Security

**JSN-014** [FROM-EPIC] [MUST]  
WHEN any user accesses the platform  
THE system SHALL enforce role-based access control via SIGA integration  
**AC:** Given user authentication, When accessing features, Then permissions enforced based on SIGA role definitions  
**Source:** Epic AC #17, #18

**JSN-015** [FROM-EPIC] [MUST]  
WHEN users interact with the platform  
THE system SHALL ensure users only access features permitted by their role  
**AC:** Given role-based permissions, When attempting restricted actions, Then system blocks unauthorized access  
**Source:** Epic AC #17

**JSN-016** [FROM-EPIC] [MUST]  
WHEN Regional SPOCs or EPAM users access submitted briefs  
THE system SHALL provide read access to all submissions within their scope  
**AC:** Given SPOC/EPAM role, When viewing submissions, Then access granted to relevant briefs based on role permissions  
**Source:** Epic AC #20

### 1.6 Data Management & Persistence

**JSN-017** [FROM-EPIC] [MUST]  
WHEN any brief or pipeline data is created  
THE system SHALL store all data within PMI database infrastructure  
**AC:** Given data creation, When persisting, Then data stored in PMI-approved database systems, not EPAM local storage  
**Source:** Epic Architecture section

**JSN-018** [FROM-EPIC] [MUST]  
WHEN briefs and related data are submitted  
THE system SHALL ensure data is retrievable for future reference and auditing  
**AC:** Given stored data, When querying historical submissions, Then complete data retrieval possible with audit trail  
**Source:** Epic AC #21

**JSN-019** [FROM-EPIC] [MUST]  
WHEN the platform processes submissions  
THE system SHALL ensure standardized campaign submissions across all markets  
**AC:** Given submission process, When different markets submit, Then consistent data structure and validation applied  
**Source:** Epic AC #22

---

## 2. Non-Functional Requirements

### 2.1 Performance

**JSN-020** [DERIVED] [MUST]  
WHEN users upload campaign assets  
THE system SHALL support file uploads up to 100MB per file with progress indication  
**AC:** Given large file upload, When uploading, Then progress shown and upload completes within 5 minutes on standard connection  

**JSN-021** [DERIVED] [SHOULD]  
WHEN multiple users access the platform simultaneously  
THE system SHALL support at least 50 concurrent users without performance degradation  
**AC:** Given 50 concurrent users, When performing typical operations, Then response times remain under 3 seconds  

### 2.2 Availability

**JSN-022** [DERIVED] [MUST]  
WHEN the platform is in production  
THE system SHALL maintain 99.5% uptime during business hours (8 AM - 6 PM CET)  
**AC:** Given production deployment, When measuring uptime, Then availability meets SLA requirements  

### 2.3 Security

**JSN-023** [DERIVED] [MUST]  
WHEN handling uploaded assets and brief data  
THE system SHALL encrypt data in transit and at rest  
**AC:** Given data transmission and storage, When security audit performed, Then encryption standards met  

**JSN-024** [DERIVED] [MUST]  
WHEN integrating with SIGA and Jira  
THE system SHALL use secure API authentication with credential rotation  
**AC:** Given API integrations, When security review conducted, Then credentials managed via AWS Secrets Manager  

### 2.4 Usability

**JSN-025** [DERIVED] [SHOULD]  
WHEN Market users interact with the briefing interface  
THE system SHALL provide intuitive UX reducing brief completion time to under 30 minutes  
**AC:** Given typical campaign brief, When user completes process, Then completion time measured and optimized  

---

## 3. Integration Requirements

### 3.1 SIGA RBAC Integration

**JSN-026** [FROM-EPIC] [MUST]  
WHEN authenticating users  
THE system SHALL integrate with existing SIGA RBAC system (not Azure EntraID)  
**AC:** Given user login, When authenticating, Then SIGA system validates credentials and returns role information  
**Source:** Epic Architecture section

### 3.2 Jira API Integration

**JSN-027** [FROM-EPIC] [MUST]  
WHEN creating Jira tickets automatically  
THE system SHALL use Jira REST API with proper authentication and error handling  
**AC:** Given brief submission, When creating ticket, Then API call succeeds or fails gracefully with retry logic  
**Source:** Epic Architecture section

### 3.3 PMI Database Integration

**JSN-028** [FROM-EPIC] [MUST]  
WHEN storing campaign and brief data  
THE system SHALL integrate with PMI database infrastructure following data governance policies  
**AC:** Given data persistence needs, When storing data, Then PMI data governance and retention policies enforced  
**Source:** Epic Architecture section

---

## 4. Constraints & Assumptions

### 4.1 Technical Constraints

- Must use .NET 8 / C# 12 backend with NPoco ORM
- Must use TypeScript 5 + React 18 frontend
- Must integrate with SIGA (not Azure EntraID) for authentication
- Must store data in PMI database infrastructure
- Must use AWS S3 for asset storage
- Must follow hexagonal architecture pattern

### 4.2 Business Constraints

- Cannot permanently delete campaigns (only mark as Cancelled)
- Must maintain complete audit trail from pipeline to execution
- Must support multiple markets and languages
- Must integrate with existing JustScan platform ecosystem

---

## 5. Readiness Assessment

**Status:** READY

**Requirements Summary:**
- MUST requirements: 22 (complete)
- SHOULD requirements: 3 (complete)
- COULD requirements: 0

**ARB Triggers Identified:**
- New service: JustBrief platform
- New external dependency: Jira API integration
- Auth/authz mechanism changes: SIGA RBAC integration
- Changes touching more than 3 services: JustBrief, SIGA, Jira, PMI Database, S3

**Scope Boundary Alerts:**
- Campaign execution is explicitly out of scope
- Token consumption tracking is out of scope
- Jira workflow modifications are out of scope

**Blocking Items:** None

---

## 6. Traceability Matrix

| Requirement ID | Epic AC | MVP | Priority | Status |
|---------------|---------|-----|----------|--------|
| JSN-001 | AC #2 | MVP 1 | MUST | Ready |
| JSN-002 | AC #3, #19 | MVP 1 | MUST | Ready |
| JSN-003 | Scope | MVP 6 | MUST | Ready |
| JSN-004 | MVP 6 | MVP 6 | SHOULD | Ready |
| JSN-005 | AC #4, #19 | MVP 1 | MUST | Ready |
| JSN-006 | AC #5 | MVP 2 | MUST | Ready |
| JSN-007 | AC #6, #7, #11 | MVP 4 | MUST | Ready |
| JSN-008 | AC #8, #9 | MVP 5 | MUST | Ready |
| JSN-009 | AC #10 | MVP 5 | MUST | Ready |
| JSN-010 | AC #12 | MVP 4 | MUST | Ready |
| JSN-011 | AC #13, #14 | MVP 3 | MUST | Ready |
| JSN-012 | AC #15 | MVP 3 | MUST | Ready |
| JSN-013 | AC #16 | MVP 3 | MUST | Ready |
| JSN-014 | AC #17, #18 | MVP 1 | MUST | Ready |
| JSN-015 | AC #17 | MVP 1 | MUST | Ready |
| JSN-016 | AC #20 | MVP 1 | MUST | Ready |
| JSN-017 | Architecture | All | MUST | Ready |
| JSN-018 | AC #21 | All | MUST | Ready |
| JSN-019 | AC #22 | All | MUST | Ready |
| JSN-020-028 | Derived | Various | MUST/SHOULD | Ready |