---
inclusion: always
---

# Project Knowledge Base

## How to Read Intake Files
When processing files from .kiro/intake/:
- `.html` files are Confluence page exports — parse the main content body, 
  ignore nav/header/footer chrome
- `.csv` files from Jira have columns: Issue Key, Summary, Issue Type, 
  Status, Priority, Description, Acceptance Criteria, Labels, Epic Link
- `.pdf` files are architecture documents or meeting notes — extract all text
- `.md` or `.txt` files are pre-processed requirements — use as-is
- `.json` files may be Jira API exports — parse the `issues` array

## Requirement ID Convention
When intake files lack IDs, auto-assign: REQ-[3-digit-number]
Always preserve original IDs if present (e.g. PROJ-1234, FR-001).

## System Overview
<!-- Fill in your actual system description -->
- System: [Your system name]
- Domain: [e.g. financial services, healthcare]
- Architecture: [e.g. microservices on Kubernetes]
- Primary language: [e.g. Java 21 + TypeScript]
- Repo layout: src/services/ (one dir per service)

## Key Contacts for ARB
- Architecture Review Board chair: [Name]
- ARB meeting cadence: [e.g. every 2nd Tuesday]
- Submission deadline: [e.g. 5 days before meeting]