@justbrief @data-governance
Feature: Data Governance and Persistence
  As a PMI compliance officer
  I want all JustBrief data stored in PMI database infrastructure
  So that data governance policies and audit requirements are met

  Background:
    Given the JustBrief platform is running
    And the PMI database infrastructure is available

  # ============================================================================
  # DATA STORAGE REQUIREMENTS
  # ============================================================================

  @smoke @JSN-017
  Scenario: All pipeline data is stored in PMI database
    Given a Regional SPOC creates a new pipeline
    When the pipeline is saved
    Then the pipeline data is stored in the PMI database
    And the data is not stored in EPAM local storage
    And the database connection uses PMI infrastructure

  @smoke @JSN-017
  Scenario: All brief data is stored in PMI database
    Given a market user creates a campaign brief
    When the brief is saved
    Then the brief data is stored in the PMI database
    And all brief content is persisted in PMI infrastructure
    And the data complies with PMI data governance policies

  @smoke @JSN-017
  Scenario: Asset metadata is stored in PMI database
    Given a market user uploads campaign assets
    When the assets are processed
    Then asset metadata is stored in the PMI database
    And asset files are stored in AWS S3 (PMI-approved storage)
    And S3 keys are stored in the PMI database

  @regression @JSN-017
  Scenario: Campaign flow definitions are stored in PMI database
    Given a market user defines a campaign flow
    When the flow is saved
    Then the flow JSON is stored in the PMI database
    And the flow structure is persisted in PMI infrastructure

  # ============================================================================
  # DATA RETRIEVAL AND AUDIT
  # ============================================================================

  @smoke @JSN-018
  Scenario: Historical pipeline data is retrievable
    Given pipelines were created 2 years ago
    When an EPAM admin queries historical pipelines
    Then all historical pipeline data is retrieved
    And the data includes complete pipeline details
    And the data includes creation and modification history

  @smoke @JSN-018
  Scenario: Submitted briefs are retrievable for audit
    Given briefs were submitted 1 year ago
    When an auditor queries historical briefs
    Then all submitted briefs are retrieved
    And the data includes complete brief content
    And the data includes submission timestamps
    And the data includes submitter information

  @regression @JSN-018
  Scenario: Cancelled pipelines remain retrievable
    Given a pipeline was marked as "Cancelled" 6 months ago
    When a user queries the pipeline
    Then the pipeline data is retrieved successfully
    And the cancellation date is included
    And the cancellation reason is included
    And the complete audit trail is available

  @regression @JSN-018
  Scenario: Asset metadata is retrievable after brief submission
    Given a brief was submitted with assets 3 months ago
    When a user queries the brief assets
    Then all asset metadata is retrieved
    And S3 download links are generated
    And asset upload history is available

  # ============================================================================
  # AUDIT TRAIL
  # ============================================================================

  @smoke @JSN-018
  Scenario: Complete audit trail exists for pipeline lifecycle
    Given a pipeline was created, modified, and completed
    When an auditor queries the pipeline audit trail
    Then the audit trail shows:
      | Event                | Timestamp | User      |
      | Pipeline Created     | [date]    | [user ID] |
      | Markets Assigned     | [date]    | [user ID] |
      | Status Changed       | [date]    | [user ID] |
      | Pipeline Completed   | [date]    | [user ID] |
    And each event includes full details

  @smoke @JSN-018
  Scenario: Complete audit trail exists for brief lifecycle
    Given a brief was created, edited, and submitted
    When an auditor queries the brief audit trail
    Then the audit trail shows:
      | Event                | Timestamp | User      |
      | Brief Created        | [date]    | [user ID] |
      | Draft Saved          | [date]    | [user ID] |
      | Assets Uploaded      | [date]    | [user ID] |
      | Flow Defined         | [date]    | [user ID] |
      | Brief Submitted      | [date]    | [user ID] |
      | Jira Ticket Created  | [date]    | System    |

  @regression @JSN-018
  Scenario: Audit trail includes data modification history
    Given a pipeline was modified multiple times
    When an auditor queries the modification history
    Then each modification is recorded
    And the audit trail shows what changed
    And the audit trail shows old and new values
    And the audit trail shows who made the change

  @regression @JSN-018
  Scenario: Audit trail is immutable
    Given audit log entries exist
    When a user attempts to modify an audit log entry
    Then the modification is prevented
    And the audit log remains unchanged
    And the attempt is logged as a security event

  # ============================================================================
  # DATA STANDARDIZATION
  # ============================================================================

  @smoke @JSN-019
  Scenario: Campaign submissions follow standardized structure
    Given market users from "DE", "FR", and "IT" submit briefs
    When the briefs are stored
    Then all briefs follow the same data structure
    And all briefs have the same mandatory fields
    And all briefs use the same validation rules
    And data is consistent across markets

  @regression @JSN-019
  Scenario: Pipeline data structure is consistent
    Given pipelines are created by different users
    When the pipelines are stored
    Then all pipelines follow the same schema
    And all pipelines have consistent field types
    And all pipelines use standardized enums for status

  @regression @JSN-019
  Scenario: Asset metadata follows standardized format
    Given assets are uploaded by different markets
    When the asset metadata is stored
    Then all metadata follows the same JSON schema
    And all metadata includes required fields
    And custom properties are stored consistently

  # ============================================================================
  # DATA RETENTION
  # ============================================================================

  @regression @JSN-017 @JSN-018
  Scenario: Pipeline data is retained indefinitely
    Given pipelines exist in the system
    When the data retention policy is applied
    Then pipeline data is never automatically deleted
    And historical pipelines remain accessible
    And the data complies with PMI retention policies

  @regression @JSN-017 @JSN-018
  Scenario: Brief data is retained for compliance
    Given briefs exist in the system
    When the data retention policy is applied
    Then brief data is retained for at least 7 years
    And submitted briefs are never deleted
    And draft briefs may be archived after 1 year of inactivity

  @regression @JSN-017 @JSN-018
  Scenario: Audit logs are retained permanently
    Given audit log entries exist
    When the data retention policy is applied
    Then audit logs are retained indefinitely
    And audit logs are never deleted
    And audit logs comply with regulatory requirements

  # ============================================================================
  # DATA BACKUP AND RECOVERY
  # ============================================================================

  @regression @JSN-017
  Scenario: Pipeline data is backed up regularly
    Given pipelines exist in the PMI database
    When the backup process runs
    Then pipeline data is included in the backup
    And backups are stored in PMI-approved locations
    And backups are encrypted at rest

  @regression @JSN-017
  Scenario: Brief data can be recovered from backup
    Given a brief was accidentally deleted
    When the recovery process is initiated
    Then the brief data is restored from backup
    And all brief content is recovered
    And all associated assets are recovered

  @regression @JSN-017
  Scenario: Database backup includes all JustBrief tables
    Given the PMI database backup runs
    When the backup completes
    Then all JustBrief tables are included:
      | Table Name           |
      | JustBrief_Pipelines  |
      | JustBrief_Briefs     |
      | JustBrief_Assets     |
      | JustBrief_AuditLog   |

  # ============================================================================
  # DATA ENCRYPTION
  # ============================================================================

  @regression @JSN-017
  Scenario: Data is encrypted at rest in PMI database
    Given data is stored in the PMI database
    When the data is persisted
    Then the data is encrypted at rest
    And encryption uses AES-256 or stronger
    And encryption keys are managed by PMI

  @regression @JSN-017
  Scenario: Data is encrypted in transit
    Given the JustBrief API communicates with the database
    When data is transmitted
    Then the connection uses TLS 1.3
    And all data is encrypted in transit
    And no plaintext data is transmitted

  # ============================================================================
  # DATA ACCESS CONTROL
  # ============================================================================

  @regression @JSN-017
  Scenario: Database access is restricted to authorized services
    Given the PMI database contains JustBrief data
    When database access is attempted
    Then only the JustBrief API service can access the data
    And access is authenticated via service credentials
    And access is logged for audit purposes

  @regression @JSN-017
  Scenario: Database credentials are stored securely
    Given the JustBrief API connects to the PMI database
    When the connection is established
    Then credentials are retrieved from AWS Secrets Manager
    And credentials are never hardcoded
    And credentials are rotated regularly

  # ============================================================================
  # DATA ISOLATION
  # ============================================================================

  @regression @JSN-017
  Scenario: Market data is logically isolated
    Given briefs exist for markets "DE" and "FR"
    When a market "DE" user queries briefs
    Then only "DE" briefs are returned
    And "FR" briefs are not accessible
    And data isolation is enforced at the database query level

  @regression @JSN-017
  Scenario: Regional data is logically isolated
    Given pipelines exist for regions "EU" and "AP"
    When an "EU" Regional SPOC queries pipelines
    Then only "EU" pipelines are returned
    And "AP" pipelines are not accessible
    And data isolation is enforced by role-based queries

  # ============================================================================
  # DATA INTEGRITY
  # ============================================================================

  @regression @JSN-017
  Scenario: Foreign key constraints ensure data integrity
    Given a brief is linked to a pipeline
    When the pipeline is queried
    Then the brief-to-pipeline relationship is enforced
    And orphaned briefs cannot exist
    And referential integrity is maintained

  @regression @JSN-017
  Scenario: Database constraints prevent invalid data
    Given a user attempts to create a pipeline
    When mandatory fields are missing
    Then the database insert fails
    And the error is returned to the application
    And no invalid data is persisted

  @regression @JSN-017
  Scenario: Database transactions ensure atomicity
    Given a brief submission involves multiple database operations
    When one operation fails
    Then all operations are rolled back
    And the database remains in a consistent state
    And no partial data is persisted

  # ============================================================================
  # COMPLIANCE SCENARIOS
  # ============================================================================

  @regression @JSN-017
  Scenario: Data storage complies with PMI governance policies
    Given JustBrief data is stored
    When a compliance audit is performed
    Then all data is stored in PMI-approved infrastructure
    And all data follows PMI data classification rules
    And all data complies with regional regulations

  @regression @JSN-017
  Scenario: Personal data is handled per GDPR requirements
    Given briefs contain user information
    When the data is stored
    Then personal data is identified and classified
    And personal data is protected appropriately
    And data subject rights can be exercised

  @regression @JSN-017
  Scenario: Data residency requirements are met
    Given briefs are submitted from EU markets
    When the data is stored
    Then EU data is stored in EU regions
    And data residency requirements are met
    And cross-border data transfers comply with regulations

  # ============================================================================
  # DATA MIGRATION AND VERSIONING
  # ============================================================================

  @regression @JSN-017
  Scenario: Database schema changes are versioned
    Given the JustBrief database schema evolves
    When a schema change is deployed
    Then the change is versioned with a migration script
    And the migration is tracked in the database
    And the migration can be rolled back if needed

  @regression @JSN-017
  Scenario: Data migration preserves historical data
    Given a database schema change is deployed
    When existing data is migrated
    Then all historical data is preserved
    And no data is lost during migration
    And data integrity is maintained

  # ============================================================================
  # ERROR SCENARIOS
  # ============================================================================

  @regression @error-handling
  Scenario: Database connection failure is handled gracefully
    Given the PMI database is unavailable
    When a user attempts to save data
    Then the operation fails gracefully
    And the error message is user-friendly
    And the error is logged for monitoring
    And the user is prompted to retry

  @regression @error-handling
  Scenario: Database transaction failure triggers rollback
    Given a brief submission is in progress
    When a database error occurs mid-transaction
    Then the transaction is rolled back
    And no partial data is saved
    And the user is notified of the failure

  # ============================================================================
  # NFR SCENARIOS
  # ============================================================================

  @nfr @performance
  Scenario: Database queries are optimized
    Given the PMI database contains 10000 pipelines
    When a user queries pipelines
    Then the query completes within 2 seconds
    And appropriate indexes are used
    And query performance is monitored

  @nfr @performance
  Scenario: Database writes are efficient
    Given a user submits a brief
    When the brief is saved to the database
    Then the write operation completes within 1 second
    And the operation does not block other users

  @nfr @scalability
  Scenario: Database supports concurrent users
    Given 50 users are using JustBrief simultaneously
    When all users perform database operations
    Then the database handles the load
    And response times remain acceptable
    And no deadlocks occur

  @nfr @availability
  Scenario: Database high availability is maintained
    Given the PMI database is configured for high availability
    When a database node fails
    Then the system fails over to a standby node
    And users experience minimal disruption
    And no data is lost

  @nfr @security
  Scenario: Database access is logged for security audit
    Given the JustBrief API accesses the database
    When database operations are performed
    Then all access is logged
    And logs include user context, operation type, and timestamp
    And logs are sent to security monitoring systems
