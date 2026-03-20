@integration-configuration @error-scenarios @resilience @mvp2
Feature: Error Handling and Edge Cases
  As a system
  I want to handle errors gracefully across all integration management operations
  So that users receive clear feedback and the system remains stable

  Background:
    Given the user "admin@justscan.com" has IntegrationAdmin role
    And the user is logged into backoffice

  # AWS Secrets Manager Outage Scenarios

  @security @nfr
  Scenario: AWS Secrets Manager is completely unavailable
    Given AWS Secrets Manager service is down
    When the user attempts to update credentials for integration "PMI-DB-UK-001"
    Then they should see error message "Credential service temporarily unavailable. Please try again in a few minutes."
    And the operation should not proceed
    And the error should be logged to Sentry with severity "CRITICAL"
    And an OpsGenie alert should be triggered
    And the user should see a "Retry" button

  @security @nfr
  Scenario: AWS Secrets Manager returns 503 Service Unavailable
    Given AWS Secrets Manager is experiencing high load
    When the user attempts to retrieve credentials
    Then the system should retry up to 3 times with exponential backoff
    And the user should see "Retrying..." indicator
    And if all retries fail, they should see error message
    And the error should be logged with retry count

  @security @nfr
  Scenario: AWS Secrets Manager timeout
    Given AWS Secrets Manager response time exceeds 30 seconds
    When the user attempts to update credentials
    Then the request should be cancelled after 30 seconds
    And they should see error message "Request timed out. Please try again."
    And no partial data should be saved
    And the timeout should be logged

  @security @nfr
  Scenario: AWS Secrets Manager returns invalid response
    Given AWS Secrets Manager returns malformed data
    When the user attempts to retrieve credentials
    Then the system should detect the invalid response
    And they should see error message "Unable to retrieve credentials. Please contact support."
    And the error should be logged with response details
    And no invalid data should be used

  @security @nfr
  Scenario: Graceful degradation when AWS Secrets Manager is slow
    Given AWS Secrets Manager response time is 8 seconds
    When the user updates credentials
    Then they should see a progress indicator
    And the operation should complete successfully
    And they should see message "Update completed (slower than usual)"
    And the slow response should be logged for monitoring

  # Invalid Credential Scenarios

  Scenario: Credential format validation fails
    Given the user enters API key "invalid"
    When they attempt to save credentials
    Then they should see validation error "API Key must start with 'sk_' and be at least 20 characters"
    And the form should not be submitted
    And no API call should be made
    And the invalid field should be highlighted

  Scenario: Connection string missing required parameters
    Given the user enters connection string "Server=test"
    When they attempt to save credentials
    Then they should see validation error "Connection String must contain 'Server=' and 'Database=' parameters"
    And the form should not be submitted
    And the invalid field should be highlighted

  Scenario: Credentials exceed maximum length
    Given the user enters an API key with 500 characters
    When they attempt to save credentials
    Then they should see validation error "API Key exceeds maximum length of 200 characters"
    And the form should not be submitted

  Scenario: Empty credentials submitted
    Given the user submits the credential form with all fields empty
    When the form is validated
    Then they should see error "At least one credential field must be provided"
    And the form should not be submitted

  # Concurrent Modification Conflicts

  Scenario: Concurrent credential updates by different users
    Given user "admin1@justscan.com" is updating credentials for "PMI-DB-UK-001"
    And user "admin2@justscan.com" simultaneously updates the same credentials
    When both users submit their changes
    Then the first submission should succeed
    And the second submission should receive a 409 Conflict response
    And the second user should see message "Credentials were updated by another user. Please refresh and try again."
    And the second user should see option to "Refresh" or "Force Update"

  Scenario: Concurrent endpoint toggles
    Given user "admin1@justscan.com" toggles endpoint "sendOTP" to disabled
    And user "admin2@justscan.com" simultaneously toggles the same endpoint
    When both requests are processed
    Then the first request should succeed
    And the second request should receive a 409 Conflict response
    And the second user should see message "Endpoint was modified by another user. Refreshing..."
    And the page should automatically refresh to show current state

  Scenario: Concurrent database assignments
    Given user "admin1@justscan.com" assigns "PMI-DB-UK-001" to market "UK"
    And user "admin2@justscan.com" simultaneously assigns the same database to "UK"
    When both requests are processed
    Then the first request should succeed
    And the second request should receive a 409 Conflict response
    And the second user should see message "Database already assigned to this market"

  Scenario: Optimistic locking prevents lost updates
    Given the user loads the credential update form at version 5
    And another admin updates the credentials to version 6
    When the user submits their changes based on version 5
    Then they should receive a 409 Conflict response
    And they should see message "Credentials have been modified. Please refresh to see latest version."
    And their changes should not overwrite version 6

  # Permission Boundary Cases

  Scenario: User role changes during active session
    Given user "admin@justscan.com" has IntegrationAdmin role
    And they have an active session
    And their role is changed to IntegrationViewer in Azure EntraID
    When they attempt to update credentials after 15 minutes
    Then they should receive a 403 Forbidden response
    And they should see message "Your permissions have changed. Please refresh your session."
    And they should be prompted to re-authenticate

  Scenario: User removed from all integration roles mid-session
    Given user "admin@justscan.com" has IntegrationAdmin role
    And they are viewing the integration detail page
    And they are removed from all integration groups in Azure EntraID
    When they attempt any operation after 15 minutes
    Then they should receive a 403 Forbidden response
    And they should see message "Integration access has been revoked"
    And they should be redirected to the home page

  Scenario: Session token expires during operation
    Given user has been logged in for 9 hours
    And their session token has expired
    When they attempt to update credentials
    Then they should receive a 401 Unauthorized response
    And they should be redirected to login page
    And they should see message "Your session has expired. Please log in again."
    And their form data should be preserved if possible

  Scenario: Azure EntraID sync delay causes permission mismatch
    Given a new user is added to IntegrationAdmin group
    And Azure EntraID sync has not yet completed
    When they log in within 2 minutes
    And they attempt to access integration management
    Then they should receive a 403 Forbidden response
    And they should see message "Permissions are being synchronized. Please try again in a few minutes."
    And they should see option to "Refresh Permissions"

  # Database and Network Errors

  Scenario: SQL Server database connection failure
    Given the SQL Server database is temporarily unavailable
    When the user attempts to view the integration list
    Then they should see error message "Unable to load integrations. Please try again."
    And they should see a "Retry" button
    And the error should be logged to Sentry
    And an OpsGenie alert should be triggered

  Scenario: SQL Server query timeout
    Given a database query takes longer than 30 seconds
    When the user requests integration details
    Then the query should be cancelled
    And they should see error message "Request timed out. Please try again."
    And the timeout should be logged
    And no partial data should be displayed

  Scenario: SQL Server deadlock during update
    Given two concurrent operations cause a database deadlock
    When the deadlock is detected
    Then one transaction should be rolled back
    And the rolled-back operation should be automatically retried
    And if retry succeeds, the user should see success message
    And if retry fails, they should see error message

  Scenario: Network connectivity loss during operation
    Given the user is updating credentials
    And network connectivity is lost mid-request
    When the request fails
    Then they should see error message "Network error. Please check your connection."
    And they should see a "Retry" button
    And no partial data should be saved
    And the form data should be preserved

  # Redis Cache Failures

  Scenario: Redis cache is unavailable
    Given the Redis cache service is down
    When the user requests integration configuration
    Then the system should fetch data directly from database
    And the operation should succeed without cache
    And they should see a warning "System running in degraded mode"
    And the cache failure should be logged

  Scenario: Redis cache returns stale data
    Given the Redis cache contains outdated configuration
    And the cache TTL has expired
    When the user requests integration configuration
    Then the system should detect stale data
    And it should fetch fresh data from database
    And it should update the cache with fresh data
    And the user should receive current data

  Scenario: Cache invalidation fails
    Given the user updates endpoint configuration
    And the Redis cache invalidation fails
    When the update completes
    Then the database should be updated successfully
    And the cache invalidation should be queued for retry
    And the user should see success message
    And a warning should be logged about cache invalidation failure

  # External Database Connection Errors

  Scenario: External PMI database is unreachable during test connection
    Given the user tests connection to external database
    And the external database is unreachable
    When the test executes
    Then they should see error "Connection failed: Database unreachable"
    And they should see suggestion "Please verify network connectivity and firewall rules"
    And the error should include technical details
    And they should see a "Retry" button

  Scenario: External database authentication fails
    Given the user tests connection with invalid credentials
    When the test executes
    Then they should see error "Connection failed: Authentication failed"
    And they should see suggestion "Please verify your credentials are correct"
    And the error should not expose credential values
    And the failure should be logged

  Scenario: External database rate limit exceeded
    Given the external database API has rate limits
    And the rate limit has been exceeded
    When the user tests connection
    Then they should see error "Connection failed: Rate limit exceeded"
    And they should see estimated wait time "Retry available in 5 minutes"
    And the rate limit should be logged

  # Data Validation Errors

  Scenario: Invalid integration ID format
    Given the user attempts to access integration with ID "invalid-id"
    When the request is processed
    Then they should receive a 400 Bad Request response
    And they should see error message "Invalid integration ID format"
    And they should be redirected to integration list

  Scenario: Invalid market code format
    Given the user attempts to assign database to market "INVALID123"
    When the assignment is validated
    Then they should see validation error "Invalid market code format"
    And the assignment should be blocked
    And the invalid input should be highlighted

  Scenario: Endpoint name not recognized
    Given the user attempts to toggle endpoint "unknownEndpoint"
    When the request is processed
    Then they should receive a 400 Bad Request response
    And they should see error message "Endpoint 'unknownEndpoint' is not valid for this integration"

  # Business Rule Violations

  Scenario: Attempt to unassign database with active campaigns
    Given integration "PMI-DB-UK-001" is assigned to market "UK"
    And there are 3 active campaigns using this integration
    When the user attempts to unassign the database
    Then they should receive a 400 Bad Request response
    And they should see error "Cannot unassign: 3 active campaigns depend on this database"
    And they should see list of affected campaigns
    And the unassignment should be blocked

  Scenario: Attempt to disable all endpoints
    Given integration "PMI-DB-UK-001" has 3 endpoints
    And 2 endpoints are already disabled
    When the user attempts to disable the last enabled endpoint
    Then they should see warning "Disabling all endpoints will make this integration unusable"
    And they should see confirmation "Are you sure you want to proceed?"
    And they should be able to proceed or cancel

  Scenario: Attempt to delete integration with active assignments
    Given integration "PMI-DB-UK-001" is assigned to 5 markets
    When the user attempts to delete the integration
    Then they should receive a 400 Bad Request response
    And they should see error "Cannot delete: Integration is assigned to 5 markets"
    And they should see suggestion "Please unassign from all markets first"

  # API Error Responses

  Scenario: Handle 500 Internal Server Error
    Given the API encounters an unexpected error
    When the user performs any operation
    Then they should see error message "An unexpected error occurred. Please try again."
    And they should see a "Retry" button
    And the error should be logged to Sentry with full stack trace
    And an OpsGenie alert should be triggered for critical errors

  Scenario: Handle 503 Service Unavailable
    Given the backend service is temporarily unavailable
    When the user attempts any operation
    Then they should see error message "Service temporarily unavailable. Please try again in a few minutes."
    And they should see a "Retry" button
    And the error should be logged

  Scenario: Handle malformed API response
    Given the API returns invalid JSON
    When the user requests integration data
    Then the system should detect the malformed response
    And they should see error message "Unable to process server response. Please try again."
    And the error should be logged with response details

  # UI Error States

  Scenario: Form validation errors are clearly displayed
    Given the user submits a form with multiple validation errors
    When the form is validated
    Then all error messages should be displayed
    And each invalid field should be highlighted in red
    And the first invalid field should receive focus
    And an error summary should be shown at the top of the form

  Scenario: Error messages are user-friendly
    Given any error occurs in the system
    When the error message is displayed
    Then it should be in plain English
    And it should explain what went wrong
    And it should suggest how to fix the issue
    And it should not expose technical implementation details
    And it should not expose sensitive information

  Scenario: Error recovery options are provided
    Given an error occurs during an operation
    When the error message is displayed
    Then the user should see at least one recovery option
    And options should include "Retry", "Cancel", or "Contact Support"
    And the user should be able to easily recover from the error

  # Logging and Monitoring

  @nfr
  Scenario: All errors are logged to Sentry
    Given any error occurs in the system
    When the error is handled
    Then it should be logged to Sentry
    And the log should include error type, message, and stack trace
    And the log should include user context (ID, role)
    And the log should include request context (URL, method, parameters)
    And the log should NOT include sensitive data (credentials, PII)

  @nfr
  Scenario: Critical errors trigger OpsGenie alerts
    Given a critical error occurs (AWS Secrets Manager down, database unavailable)
    When the error is detected
    Then an OpsGenie alert should be triggered
    And the alert should include error details and affected service
    And the alert should be routed to the on-call engineer
    And the alert should have appropriate severity level

  @nfr
  Scenario: Error rates are monitored in New Relic
    Given errors are occurring in the system
    When error rate exceeds threshold (5% of requests)
    Then New Relic should trigger an alert
    And the alert should include error rate and affected endpoints
    And the alert should be sent to the engineering team

  # Graceful Degradation

  @nfr @resilience
  Scenario: System continues operating with degraded functionality
    Given a non-critical service is unavailable (Redis cache)
    When users perform operations
    Then core functionality should continue to work
    And users should see a banner "System running in degraded mode"
    And performance may be slower but operations should succeed
    And the degraded state should be logged

  @nfr @resilience
  Scenario: Automatic recovery after service restoration
    Given AWS Secrets Manager was unavailable
    And the system was in degraded mode
    When AWS Secrets Manager becomes available again
    Then the system should automatically detect recovery
    And it should resume normal operation
    And the degraded mode banner should be removed
    And the recovery should be logged
