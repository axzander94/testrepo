# 1. Export from Confluence
#    Page → Export → HTML → save to:
.kiro/intake/requirements/feature-x-confluence.html

# 2. Export from Jira  (optional)
#    Epic → Export → CSV → save to:
.kiro/intake/jira-export/PROJ-1234-export.csv

# 3. Drop any existing architecture docs
.kiro/intake/architecture/existing-ADR-payments.md

# 4. Switch to the pipeline agent in Kiro
/agent swap arch-pipeline

# 5. Trigger the pipeline
Run the full architecture pipeline for:
- Feature name: payment-refund-flow
- Source directories: src/services/payments/, src/services/ledger/
- All intake files are ready in .kiro/intake/

# 6. Review outputs
.kiro/specs/payment-refund-flow/
├── intake-manifest.md      ← normalised requirements
├── requirements.md         ← structured + gap analysis
├── design.md               ← technical blueprint
├── tasks.md                ← developer task list
└── arb-package/
    ├── ADR.md              ← full architecture decision record
    ├── executive-summary.md
    ├── risk-register.md
    └── arb-checklist.md    ← fill in sign-offs, submit to ARB