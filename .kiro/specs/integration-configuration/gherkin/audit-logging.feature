@integration-configuration @audit-logging @security @mvp1
Feature: Audit Logging and Trail
  As a compliance officer
  I want all integration configuration changes to be logged immutably
  So that we can track who made what changes and maintain SOC 2 compliance

  Background:
    Given the audit logging system is operational
    And audit logs are stored in the IntegrationAuditLog table
    And the retention policy is set to 2 years minimum

  # Audit Log Creation Scenarios

  Scenario: Log credential update action
    Given user "admin@justscan.com" with IntegrationAdmin role
    When they update credentials for integration "PMI-DB-UK-001"
    Then an audit log entry should be created with:
      | Field      | Value                                |
      | Action     | UPDATE_CREDENTIALS                   |
      | EntityType | Integration                          |
      | EntityId   | 550e8400-e29b-41d4-a716-446655440000 |
      | UserId     | admin@justscan.com                   |
      | UserRole   | IntegrationAdmin                     |
      | Timestamp  | 2024-12-19T14:22:00Z                 |
      | IpAddress  | 192.168.1.100                        |
    And the log entry should NOT contain credential values
    And the log entry should be immutable

  Scenario: Log endpoint toggle action
    Given user "admin@justscan.com" toggles endpoint "sendOTP" to disabled
    When the operation completes
    Then an audit log entry should be created with:
      | Field      | Value                                                         |
      | Action     | TOGGLE_ENDPOINT                                               |
      | EntityType | IntegrationEndpoint                                           |
      | OldValue   | {"endpointName":"sendOTP","enabled":true}                     |
      | NewValue   | {"endpointName":"sendOTP","enabled":false}                    |
      | UserId     | admin@justscan.com                                            |
      | UserRole   | IntegrationAdmin                                              |
    And the log entry should include market code
    And the log entry should be immutable

  Scenario: Log database assignment action
    Given user "admin@justscan.com" assigns database to market "UK"
    When the assignment completes
    Then an audit log entry should be created with:
      | Field      | Value                                                         |
      | Action     | ASSIGN_MARKET                                                 |
      | EntityType | MarketIntegration                                             |
      | NewValue   | {"market":"UK","integrationId":"550e8400-e29b-41d4-a716-446655440000"} |
      | UserId     | admin@justscan.com                                            |
      | UserRole   | IntegrationAdmin                                              |
    And the log entry should be immutable

  Scenario: Log database unassignment action
    Given user "admin@justscan.com" unassigns database from market "UK"
    When the unassignment completes
    Then an audit log entry should be created with:
      | Field      | Value                                                         |
      | Action     | UNASSIGN_MARKET                                               |
      | EntityType | MarketIntegration                                             |
      | OldValue   | {"market":"UK","integrationId":"550e8400-e29b-41d4-a716-446655440000","isActive":true} |
      | NewValue   | {"market":"UK","integrationId":"550e8400-e29b-41d4-a716-446655440000","isActive":false} |
      | UserId     | admin@justscan.com                                            |
    And the log entry should be immutable

  # Immutability Scenarios

  @security
  Scenario: Audit log entries cannot be modified
    Given an audit log entry exists with ID "audit-001"
    When an attempt is made to update the entry
    Then the database should reject the update
    And the original entry should remain unchanged
    And the attempt should be logged as a security event

  @security
  Scenario: Audit log entries cannot be deleted
    Given an audit log entry exists with ID "audit-001"
    When an attempt is made to delete the entry
    Then the database should reject the deletion
    And the entry should remain in the audit log
    And the attempt should be logged as a security event

  @security
  Scenario: Audit log table has no UPDATE or DELETE permissions
    Given the audit log database schema
    When database permissions are reviewed
    Then only INSERT and SELECT permissions should exist
    And no user should have UPDATE permission
    And no user should have DELETE permission
    And only database administrators should have SELECT permission

  # Sensitive Data Protection

  @security
  Scenario: Credential values never logged
    Given user updates credentials with API key "sk_live_abc123xyz789"
    When the audit log entry is created
    Then the log should contain action "UPDATE_CREDENTIALS"
    But the log should NOT contain "sk_live_abc123xyz789"
    And the log should NOT contain any credential values
    And the log should only indicate that credentials were updated

  @security
  Scenario: Personal data not logged in audit trail
    Given user "john.doe@justscan.com" performs an action
    When the audit log entry is created
    Then the log should contain user ID "john.doe@justscan.com"
    But the log should NOT contain personal information beyond user ID
    And the log should NOT contain user's full name
    And the log should NOT contain user's phone number or address

  @security
  Scenario: IP addresses are logged but anonymized after 90 days
    Given an audit log entry was created 91 days ago with IP "192.168.1.100"
    When the anonymization job runs
    Then the IP address should be replaced with "ANONYMIZED"
    And the rest of the audit entry should remain unchanged
    And the anonymization should be logged

  # Audit Log Retrieval Scenarios

  Scenario: View audit log for specific integration
    Given integration "PMI-DB-UK-001" has 10 audit log entries
    When user with IntegrationAdmin role requests audit logs for this integration
    Then they should see all 10 entries
    And entries should be sorted by timestamp descending (newest first)
    And each entry should show action, user, timestamp, and changes

  Scenario: Filter audit logs by action type
    Given there are 50 audit log entries for various actions
    When user filters by action "UPDATE_CREDENTIALS"
    Then they should see only credential update entries
    And other action types should be excluded
    And the count should show "15 entries found"

  Scenario: Filter audit logs by date range
    Given there are audit log entries spanning 6 months
    When user filters by date range "2024-12-01" to "2024-12-31"
    Then they should see only entries within December 2024
    And entries outside this range should be excluded
    And the date filter should be clearly displayed

  Scenario: Filter audit logs by user
    Given multiple users have performed actions
    When user filters by "admin@justscan.com"
    Then they should see only entries created by this user
    And entries by other users should be excluded
    And the user filter should be clearly displayed

  Scenario: Search audit logs by integration name
    Given there are audit logs for 20 different integrations
    When user searches for "PMI-DB-UK"
    Then they should see entries for "PMI-DB-UK-001" and "PMI-DB-UK-002"
    And entries for other integrations should be excluded
    And the search term should be highlighted

  # Pagination and Performance

  @nfr @performance
  Scenario: Audit log pagination for large datasets
    Given there are 500 audit log entries
    When user views the audit log page
    Then they should see 50 entries on page 1
    And pagination controls should be visible
    And page indicator should show "Page 1 of 10"
    And the page should load within 2 seconds

  @nfr @performance
  Scenario: Audit log queries are optimized
    Given there are 10,000 audit log entries in the database
    When user requests audit logs for a specific integration
    Then the query should use the IntegrationId index
    And results should be returned within 500ms
    And the database should not perform full table scans

  # Retention Policy Scenarios

  Scenario: Audit logs retained for minimum 2 years
    Given an audit log entry was created on "2022-12-19"
    And the current date is "2024-12-19"
    When the retention policy is checked
    Then the entry should still exist in the database
    And it should be accessible for viewing
    And it should not be marked for deletion

  Scenario: Audit logs older than 2 years are archived
    Given an audit log entry was created on "2020-12-19"
    And the current date is "2024-12-20"
    And the entry is older than 2 years
    When the archival job runs
    Then the entry should be moved to cold storage
    And it should still be retrievable for compliance purposes
    And it should be marked as "ARCHIVED" in the system

  Scenario: Archived audit logs can be retrieved
    Given an audit log entry has been archived
    When a compliance officer requests archived logs
    Then they should be able to retrieve the entry
    And the retrieval may take up to 24 hours
    And they should see a message "Retrieving from archive..."

  # Access Control for Audit Logs

  Scenario: IntegrationAdmin can view audit logs
    Given user "admin@justscan.com" has IntegrationAdmin role
    When they navigate to the audit log page
    Then they should see all audit log entries
    And they should be able to filter and search logs
    And they should be able to export logs

  Scenario: IntegrationViewer can view audit logs
    Given user "viewer@justscan.com" has IntegrationViewer role
    When they navigate to the audit log page
    Then they should see all audit log entries
    And they should be able to filter and search logs
    And they should be able to export logs

  Scenario: Users without integration roles cannot view audit logs
    Given user "content_manager@justscan.com" has no integration roles
    When they attempt to access the audit log page
    Then they should receive a 403 Forbidden response
    And they should see error message "You do not have permission to view audit logs"

  # Audit Log Export Scenarios

  Scenario: Export audit logs to CSV
    Given user has IntegrationAdmin role
    And there are 100 audit log entries
    When they click "Export to CSV" button
    Then a CSV file should be generated
    And the file should contain all 100 entries
    And the file should include columns: Timestamp, Action, User, EntityType, EntityId, OldValue, NewValue
    And the file should be downloaded to their device

  Scenario: Export filtered audit logs
    Given user has filtered audit logs by date range and action type
    And the filter returns 25 entries
    When they click "Export to CSV"
    Then the CSV should contain only the 25 filtered entries
    And the filename should indicate the filter applied
    And the export should complete within 5 seconds

  Scenario: Export large audit log datasets
    Given there are 5,000 audit log entries to export
    When user clicks "Export to CSV"
    Then they should see a progress indicator
    And the export should be processed in the background
    And they should receive an email when the export is ready
    And the download link should be valid for 24 hours

  # Real-Time Audit Logging

  Scenario: Audit log entry created immediately after action
    Given user performs a credential update
    When the operation completes successfully
    Then the audit log entry should be created within 1 second
    And the entry should be immediately queryable
    And the entry should appear in the audit log viewer

  Scenario: Failed operations are also logged
    Given user attempts to update credentials
    When the operation fails due to validation error
    Then an audit log entry should be created with action "UPDATE_CREDENTIALS_FAILED"
    And the entry should include the failure reason
    And the entry should NOT include sensitive data from the failed attempt

  Scenario: Unauthorized access attempts are logged
    Given user "content_manager@justscan.com" has no integration roles
    When they attempt to access integration management
    Then an audit log entry should be created with action "UNAUTHORIZED_ACCESS_ATTEMPT"
    And the entry should include user ID, timestamp, and attempted resource
    And the entry should be flagged for security review

  # Audit Log Integrity

  @security
  Scenario: Audit log entries have cryptographic hash
    Given an audit log entry is created
    When the entry is stored in the database
    Then a SHA-256 hash should be computed for the entry
    And the hash should be stored with the entry
    And the hash should be used to verify entry integrity

  @security
  Scenario: Detect tampered audit log entries
    Given an audit log entry exists with a valid hash
    When the entry data is modified directly in the database
    And the integrity check runs
    Then the tampered entry should be detected
    And an alert should be sent to security team
    And the entry should be flagged as "INTEGRITY_VIOLATION"

  # Compliance Reporting

  Scenario: Generate compliance report for audit period
    Given there are audit logs for the period "2024-01-01" to "2024-12-31"
    When a compliance officer requests an annual audit report
    Then the report should include:
      | Metric                        | Value |
      | Total actions logged          | 1,250 |
      | Credential updates            | 45    |
      | Endpoint toggles              | 320   |
      | Database assignments          | 85    |
      | Unauthorized access attempts  | 3     |
      | Failed operations             | 12    |
    And the report should be in PDF format
    And the report should include executive summary

  Scenario: Audit log supports SOC 2 compliance
    Given the audit logging system is operational
    When a SOC 2 auditor reviews the system
    Then all configuration changes should be logged
    And logs should be immutable and tamper-proof
    And logs should be retained for at least 2 years
    And access to logs should be role-based
    And log integrity should be verifiable

  # NFR: Availability

  @nfr @availability
  Scenario: Audit logging does not block primary operations
    Given user performs a credential update
    When the audit log service is temporarily unavailable
    Then the credential update should still succeed
    And the audit log entry should be queued for retry
    And the entry should be created when the service recovers
    And no data should be lost

  @nfr @availability
  Scenario: Audit log writes are asynchronous
    Given user performs an action
    When the action completes
    Then the audit log write should happen asynchronously
    And the user should not wait for the log write to complete
    And the response time should not be impacted by logging

  # NFR: Performance

  @nfr @performance
  Scenario: Audit log writes do not impact system performance
    Given the system is under load with 25 concurrent users
    When all users perform actions that generate audit logs
    Then audit log writes should not slow down primary operations
    And API response times should remain under 500ms
    And audit log writes should be batched for efficiency

  # User Activity Tracking

  Scenario: Track user session activity
    Given user "admin@justscan.com" logs into backoffice
    When they perform multiple actions in a session
    Then all actions should be linked to the same session ID
    And the session start and end times should be recorded
    And the audit log should show the sequence of actions

  Scenario: Track user agent and browser information
    Given user performs an action from Chrome browser
    When the audit log entry is created
    Then the user agent should be recorded
    And the browser type should be identifiable
    And the operating system should be identifiable
    And this information should be available for security analysis
