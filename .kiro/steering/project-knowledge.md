---
inclusion: always
---

# Project Knowledge Base — JustScan

## System Overview

**JustScan** is a global PMI (Philip Morris International) tool that enables 
markets to create responsive, multi-channel marketing campaigns deployable 
across single and multi-channel depending on market objectives and KPIs.

Markets can create custom localised consumer journeys and connect with 
existing PMI databases to enrich consumer engagement.

**Type:** Multi-tenant SaaS web platform  
**Scope:** Global — multiple markets, multiple languages, multiple regions  
**Access model:** SSO via Azure EntraID (backoffice), public URL (webapp)  
**Regions:** EU, AP (Asia Pacific)

---

## System Components

### 1. WebApp (consumer-facing)
**Domain:** `scanpack.com`  
**Audience:** End consumer  
**Purpose:** Delivers marketing campaigns to consumers. The UI surfaces 
campaign flows built by content managers in the backoffice. Campaigns are 
interactive, story-like journeys that can include games, instant win 
mechanics, age verification, and multimedia content.

**Embedding modes:**
- Standalone at `scanpack.com`
- Embedded in third-party microsites via **JustScan Library** (managed)
- Embedded via unmanaged `<iframe>` tag
- **Scanpack** is a web application that recognises a physical pack (via QR 
  or image recognition). Each recognised pack leads the user to a campaign 
  — a sequence of image, video, or webpage content.

### 2. Backoffice (content manager-facing)
**Domain:** `bokarcampaigns.com` (EU and AP regions)  
**Audience:** Content managers, market administrators  
**Auth:** SSO login via Azure EntraID. Adding a user in backoffice alone 
is insufficient — permissions must also be granted via SSO management.

**Backoffice Modules:**

#### Users
- Manages user permissions and new user onboarding
- Requires SSO permission grant — backoffice user creation alone is not enough

#### Secured Access URL Sets
- Creates and manages batches of QR codes printed on physical packs
- Each pack has a unique QR code: 1 QR = 1 attempt to win a prize
- Provides security and enforces gift logic integrity

#### Cookie Management
- Manages cookies across websites
- Integrates with **OneTrust** for cookie consent management
- Supports domain assignment per market

#### Gift Catalogs
- Create and manage gifts with images
- Two code generation modes:
  - **Auto-generated codes** — system generates; count adjustable before 
    assigning to campaign; supports wave distribution with date ranges 
    and recurrence settings
  - **Imported codes (CSV)** — total code count cannot be changed without 
    importing an additional CSV file
- Gift statistics: allocated, total, won, not-yet-won
- **Waves:** distribute gifts in time-boxed waves with start/end dates and 
  recurrence. Wave duration, gifts, and codes cannot be changed after a 
  wave has started. Unwinnable codes can be exported after wave ends.
- Gifts must be assigned a number of randomly winnable codes before 
  allocation to a campaign

#### Font Library
- Upload and manage custom fonts for use in campaigns
- Supported upload formats: `.zip`
- Supported font formats: `.woff2`, `.woff`, `.otf`, `.ttf`

#### Translations
- Add and assign translations per market and language
- Markets support multiple languages
- CSS and HTML editor for legal text: Cookie Policy, FAQ, ACS FAQ, 
  Terms & Conditions, Privacy Policy

#### Campaigns (list view)
- Lists campaigns with: name, market (can be global), status, dates, 
  age validation type, gift assignment indicator
- **Campaign statuses:** Published, Published Ended, Draft, Draft Ended, 
  Draft Not Started, Archived

#### Campaign View (configuration)
- Supported languages
- Assigned gifts
- Security measures: reCAPTCHA, Akamai
- Enabled devices: tablet, desktop, mobile
- Analytics configuration: Category, Brand, Objective, Campaign Type, 
  Trigger Mode, Age Gate Type

#### Campaign Creation (flow builder)
- Visual flow builder (Miro-like diagram interface)
- **Screen components** with CSS, JSON, and HTML editing per screen
- **Available actions and widgets:**
  - Screen (with CSS/JSON/HTML editor)
  - Decision
  - Redirection
  - API Call
  - Download Media Action
  - Audio Effect
  - Instant Win (Spin the Wheel)
  - Get Won Vouchers
  - Instant Win Limit Check
  - Track Event
  - Notify Parent
  - Quiz / Poll
  - Clear Cookies
  - Face validation group
  - Other identity validation groups
  - Swiper Group (image carousel with swipe)
  - Embed Video (via **Video23** platform)
  - iFrame embed (for Scanpack pack recognition)

#### Analytics
- Implemented via frontend DataLayer event tracking
- Configured through GTM (Google Tag Manager) and Google Analytics
- New Relic used for APM and frontend performance monitoring

---

## Domains

| Domain | Component | Notes |
|--------|-----------|-------|
| `scanpack.com` | WebApp | Consumer-facing campaign delivery |
| `content.scanpack.com` | Market content | Games and interactive content assets |
| `bokarcampaigns.com` | Backoffice | EU and AP regions |
| `pmiagedetect.com` | ACS | Age Verification Service |

---

## Access & Identity Model

| Layer | Mechanism | Notes |
|-------|-----------|-------|
| Backoffice login | SSO via Azure EntraID | User must exist in both backoffice AND EntraID |
| Consumer age verification | ACS (`pmiagedetect.com`) | Supports soft, custom, Yoti, face |
| Campaign access control | Geofencing, age gate, reCAPTCHA, Akamai WAF | Per-campaign configuration |
| API security | AWS WAF + Akamai | Edge protection |
| Secrets | AWS Secrets Manager | Never environment variables |

---

## Age Verification Types

JustScan supports multiple age gate mechanisms:
- **Soft age verification** — self-declared date of birth
- **Custom age verification** — market-specific flow
- **Face age estimation** — camera-based via ACS
- **YOTI** — third-party identity document verification
- **Banner** — simple legal notice gate

---

## Multi-Tenancy & Market Model

- Platform is global; each deployment is scoped to a **market**
- Markets have their own: languages, legal text, cookie configuration, 
  campaigns, gifts, fonts, and translations
- Campaigns can be **market-specific** or **global**
- Content restricted based on: market, product category, legal guidelines
- Each market may have different regulatory requirements (GDPR, local laws)

---

## Key Business Rules (Agents Must Know)

These rules must be reflected in any technical design or spec:

| Rule | Context |
|------|---------|
| 1 QR code = 1 prize attempt | Secured Access URL Sets — enforced at system level |
| Wave cannot be modified after start | Gift Catalog — dates, gifts, codes are locked once wave begins |
| Imported CSV codes = fixed total | Cannot reduce or expand without uploading additional CSV |
| User needs both backoffice + SSO access | Adding in backoffice alone gives no actual access |
| Auto-generated codes adjustable pre-campaign | Count can be changed before campaign assignment only |

---

## Third-Party Integrations (Compliance-Critical)

When any of the following are touched by a feature, flag for additional 
compliance and security review:

| Integration | Purpose | Compliance Flag |
|-------------|---------|----------------|
| **YOTI** | Identity / age document verification | PII — identity documents |
| **OneTrust** | Cookie consent management | GDPR consent chain |
| **PMI Databases** | Customer data enrichment | PII — customer data, cross-border transfer rules |
| **Azure EntraID** | SSO and identity | Access control — all backoffice access |
| **Akamai** | CDN + WAF + bot protection | Security perimeter |
| **AWS Cognito** | Consumer auth flows | Consumer identity |
| **Google Tag Manager / GA** | Analytics and tracking | GDPR — consent required before firing |
| **Sentry** | Error monitoring | Must not capture PII in error payloads |
| **New Relic** | APM and frontend monitoring | Must not capture PII in traces |
| **Video23** | Embedded video delivery | Third-party content |
| **OpsGenie** | Alerting and on-call | Operational |

---

## Repository & Codebase Structure
```
src/
├── WebApp/             ← Consumer-facing React/TypeScript frontend
│   ├── components/     ← Campaign widgets (swiper, instant win, etc.)
│   ├── flows/          ← Campaign flow engine
│   └── tracking/       ← DataLayer event tracking
│
├── Backoffice/         ← Content manager .NET 8 + React frontend
│   ├── API/            ← REST API controllers (C#)
│   ├── Services/       ← Business logic (C#)
│   ├── Domain/         ← NPoco POCOs mapped to SQL Server
│   ├── Migrations/     ← SQL migration scripts (YYYYMMDD_NNN_desc.sql)
│   └── Frontend/       ← React/TypeScript backoffice UI
│
├── ACS/                ← Age Verification Service
│   └── Domain: pmiagedetect.com
│
├── Infrastructure/     ← Terraform (AWS resources)
│   ├── ECS/            ← Fargate task definitions
│   ├── RDS/            ← SQL Server config
│   ├── CloudFront/     ← CDN + Lambda@Edge
│   └── WAF/            ← AWS WAF rules
│
└── tests/
    ├── [Service].Tests/        ← NUnit unit tests
    ├── [Service].Integration/  ← Integration tests (real SQL Server)
    └── [Service].Specs/        ← SpecFlow feature files
        ├── Features/
        └── Steps/
```

---

## How to Read Intake Files

When processing files from `.kiro/intake/`:

| Format | Source | Parse Strategy |
|--------|--------|---------------|
| `.html` | Confluence export | Strip nav/header/footer chrome, extract body content |
| `.csv` | Jira export | Columns: Issue Key, Summary, Issue Type, Status, Priority, Description, Acceptance Criteria, Labels, Epic Link |
| `.pdf` | Architecture docs, meeting notes | Extract all text, treat headings as categories |
| `.md` / `.txt` | Pre-processed requirements | Use as-is, assign REQ-IDs if missing |
| `.json` | Jira API export | Parse `issues` array |

Auto-assign IDs when none present: `REQ-001`, `REQ-002`...  
Preserve original IDs when present: `PROJ-1234`, `FR-001`.

---