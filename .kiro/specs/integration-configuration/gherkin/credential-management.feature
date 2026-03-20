@integration-configuration @credential-management @security @mvp2
Feature: Secure Credential Management
  As an integration administrator
  I want to securely update and manage integration credentials
  So that integrations can connect to external databases without exposing sensitive data

  Background:
    Given the user "admin@justscan.com" has IntegrationAdmin role
    And the user is logged into backoffice
    And AWS Secrets Manager is available and configured
    And the following integration exists:
      | Field        | Value                                |
      | Id           | 550e8400-e29b-41d4-a716-446655440000 |
      | Name         | PMI-DB-UK-001                        |
      | Market       | UK                                   |
      | SecretName   | justscan/integration/pmi-db-uk-001   |

  # Happy Path Scenarios

  Scenario: Successfully update integration credentials
    Given the user is on the integration detail page for "PMI-DB-UK-001"
    When they click "Update Credentials" button
    And they enter the following credentials:
      | Field             | Value                          |
      | API Key           | sk_live_abc123xyz789           |
      | Connection String | Server=pmi-uk.db;Database=prod |
    And they click "Save Credentials"
    Then they should see a success message "Credentials updated successfully"
    And the credentials should be stored in AWS Secrets Manager
    And the credentials should not be stored in the database
    And an audit log entry should be created
    And the credential update timestamp should be updated

  Scenario: Credential values are masked in UI
    Given the user is on the integration detail page
    When they view the credentials section
    Then the API Key should display as "••••••••••••••••"
    And the Connection String should display as "••••••••••••••••"
    And no actual credential values should be visible
    And they should see "Last updated: 19 Dec 2024 at 14:22 UTC"

  Scenario: Update credentials form shows masked current values
    Given the user clicks "Update Credentials" button
    When the credential form opens
    Then the API Key field should show placeholder "••••••••••••••••"
    And the Connection String field should show placeholder "••••••••••••••••"
    And a note should display "Leave blank to keep current value"
    And all fields should be password-type inputs

  # Credential Validation Scenarios

  Scenario: Validate required credential fields
    Given the user is on the update credentials form
    When they leave the API Key field empty
    And they leave the Connection String field empty
    And they click "Save Credentials"
    Then they should see validation error "At least one credential field must be provided"
    And the form should not be submitted
    And no API call should be made

  Scenario: Validate API key format
    Given the user is on the update credentials form
    When they enter an invalid API key "invalid-key"
    And they click "Save Credentials"
    Then they should see validation error "API Key must start with 'sk_' and be at least 20 characters"
    And the form should not be submitted

  Scenario: Validate connection string format
    Given the user is on the update credentials form
    When they enter an invalid connection string "not-a-valid-connection-string"
    And they click "Save Credentials"
    Then they should see validation error "Connection String must contain 'Server=' and 'Database=' parameters"
    And the form should not be submitted

  Scenario: Client-side validation before submission
    Given the user is on the update credentials form
    When they enter credentials with invalid format
    Then validation errors should appear immediately on blur
    And the "Save Credentials" button should be disabled
    And no API call should be made until validation passes

  # AWS Secrets Manager Integration

  @security
  Scenario: Credentials stored only in AWS Secrets Manager
    Given the user updates credentials for "PMI-DB-UK-001"
    When the credentials are saved successfully
    Then the credentials should be stored in AWS Secrets Manager under key "justscan/integration/pmi-db-uk-001"
    And the credentials should be encrypted at rest
    And the credentials should be encrypted in transit
    And no plaintext credentials should exist in SQL Server database
    And no credentials should be stored in environment variables

  @security
  Scenario: Credentials never logged in plaintext
    Given the user updates credentials for "PMI-DB-UK-001"
    When the update operation completes
    Then application logs should not contain credential values
    And Sentry error logs should not contain credential values
    And New Relic traces should not contain credential values
    And audit logs should only record "CREDENTIALS_UPDATED" action without values

  @security
  Scenario: Credentials never exposed in API responses
    Given the user requests integration details via API
    When the API returns integration data
    Then the response should contain masked credential indicators
    And the response should not contain actual credential values
    And the response should show last updated timestamp only
    And browser network tab should not reveal credentials

  # AWS Secrets Manager Error Scenarios

  Scenario: Handle AWS Secrets Manager unavailable
    Given AWS Secrets Manager is temporarily unavailable
    When the user attempts to update credentials
    Then they should see error message "Credential service temporarily unavailable. Please try again in a few minutes."
    And the operation should not proceed
    And the error should be logged to Sentry
    And an OpsGenie alert should be triggered

  Scenario: Retry credential update after AWS failure
    Given AWS Secrets Manager failed on first attempt
    And the user sees an error message
    When they click "Retry" button
    And AWS Secrets Manager is now available
    Then the credential update should succeed
    And they should see success message

  Scenario: Handle AWS Secrets Manager timeout
    Given AWS Secrets Manager response time exceeds 30 seconds
    When the user attempts to update credentials
    Then they should see error message "Request timed out. Please try again."
    And the operation should be cancelled
    And no partial data should be saved

  # Concurrent Update Scenarios

  Scenario: Handle concurrent credential updates
    Given user "admin1@justscan.com" is updating credentials for "PMI-DB-UK-001"
    And user "admin2@justscan.com" attempts to update the same credentials simultaneously
    When both users submit their changes
    Then the first submission should succeed
    And the second submission should receive a 409 Conflict response
    And the second user should see message "Credentials were updated by another user. Please refresh and try again."

  Scenario: Optimistic locking prevents lost updates
    Given the user loads the credential update form
    And another admin updates the credentials
    When the user submits their changes
    Then they should receive a conflict error
    And they should see the message "Credentials have been modified. Please refresh to see latest version."
    And their changes should not overwrite the newer version

  # Audit Logging Scenarios

  @audit
  Scenario: Credential update is logged in audit trail
    Given the user updates credentials for "PMI-DB-UK-001"
    When the update completes successfully
    Then an audit log entry should be created with:
      | Field      | Value                                |
      | Action     | UPDATE_CREDENTIALS                   |
      | EntityType | Integration                          |
      | EntityId   | 550e8400-e29b-41d4-a716-446655440000 |
      | UserId     | admin@justscan.com                   |
      | UserRole   | IntegrationAdmin                     |
      | Timestamp  | 2024-12-19T14:22:00Z                 |
    And the audit log should not contain credential values
    And the audit log should be immutable

  @audit
  Scenario: Failed credential update attempts are logged
    Given the user attempts to update credentials with invalid format
    When the validation fails
    Then an audit log entry should be created with action "UPDATE_CREDENTIALS_FAILED"
    And the log should include validation error reason
    And the log should not contain the invalid credential values

  # Cache Invalidation Scenarios

  Scenario: Credential update invalidates configuration cache
    Given integration "PMI-DB-UK-001" configuration is cached
    When the user updates credentials
    Then the Redis cache for this integration should be invalidated
    And subsequent API calls should fetch fresh configuration
    And WebApp should receive cache invalidation notification

  Scenario: WebApp receives credential update notification within 5 minutes
    Given the user updates credentials for "PMI-DB-UK-001"
    When the update completes successfully
    Then WebApp configuration cache should be invalidated
    And WebApp should reload configuration within 5 minutes
    And active campaigns should use new credentials for next API call

  # Test Connection Integration

  Scenario: Test connection with new credentials before saving
    Given the user is on the update credentials form
    And they have entered new credentials
    When they click "Test Connection" button
    Then the system should attempt to connect to the external database
    And they should see a loading indicator "Testing connection..."
    And the test should complete within 10 seconds
    And they should see result "Connection successful" or specific error

  Scenario: Save credentials without testing connection
    Given the user is on the update credentials form
    And they have entered valid credentials
    When they click "Save Credentials" without testing
    Then the credentials should be saved successfully
    And they should see a warning "Credentials saved without testing. Test connection recommended."

  # Security Boundary Scenarios

  @security
  Scenario: IntegrationViewer cannot access credential update form
    Given a user "viewer@justscan.com" has IntegrationViewer role
    When they attempt to access the credential update form
    Then they should not see "Update Credentials" button
    And direct API access should return 403 Forbidden
    And the attempt should be logged in security audit log

  @security
  Scenario: Credentials not stored in browser state or local storage
    Given the user updates credentials
    When they inspect browser local storage and session storage
    Then no credential values should be present
    And no credential values should be in Redux/state management
    And no credential values should be in browser memory after form close

  @security
  Scenario: Credential form uses HTTPS only
    Given the user accesses the credential update form
    When they inspect the network connection
    Then all requests should use HTTPS with TLS 1.2 or higher
    And no credentials should be transmitted over HTTP
    And certificate validation should be enforced

  # User Experience Scenarios

  Scenario: Show password visibility toggle
    Given the user is on the update credentials form
    When they enter credentials in password fields
    Then they should see an eye icon next to each field
    When they click the eye icon
    Then the credential should be temporarily visible
    And the icon should change to indicate visibility state

  Scenario: Credential form has clear cancel option
    Given the user is on the update credentials form
    And they have entered new credentials
    When they click "Cancel" button
    Then they should see confirmation dialog "Discard unsaved changes?"
    When they confirm cancellation
    Then the form should close without saving
    And they should return to the integration detail page

  Scenario: Show credential update confirmation
    Given the user has entered new credentials
    When they click "Save Credentials"
    Then they should see confirmation dialog "Update credentials for PMI-DB-UK-001?"
    And the dialog should warn "This will affect all campaigns using this integration"
    When they confirm
    Then the credentials should be updated

  # NFR: Performance

  @nfr @performance
  Scenario: Credential update completes within acceptable time
    Given the user submits valid credentials
    When the update operation executes
    Then the credentials should be stored in AWS Secrets Manager within 3 seconds
    And the user should see success confirmation within 5 seconds
    And the page should remain responsive during the operation

  @nfr @performance
  Scenario: Credential form loads quickly
    Given the user clicks "Update Credentials"
    When the form opens
    Then the form should be fully rendered within 500ms
    And all fields should be interactive immediately

  # NFR: Resilience

  @nfr @resilience
  Scenario: Graceful degradation when AWS Secrets Manager is slow
    Given AWS Secrets Manager response time is 8 seconds
    When the user updates credentials
    Then they should see a progress indicator
    And the operation should complete successfully
    And they should see message "Update completed (slower than usual)"

  @nfr @resilience
  Scenario: Automatic retry on transient AWS failures
    Given AWS Secrets Manager returns a transient error
    When the credential update is attempted
    Then the system should automatically retry up to 3 times
    And exponential backoff should be applied between retries
    And the user should see "Retrying..." indicator
    And if all retries fail, a clear error message should be shown
