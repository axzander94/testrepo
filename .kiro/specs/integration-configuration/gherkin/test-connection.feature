@integration-configuration @test-connection @mvp2
Feature: Test Database Connection
  As an integration administrator
  I want to test database connections before saving credentials
  So that I can verify connectivity and avoid configuration errors

  Background:
    Given the user "admin@justscan.com" has IntegrationAdmin role
    And the user is logged into backoffice
    And the following integration exists:
      | Field        | Value                                |
      | Id           | 550e8400-e29b-41d4-a716-446655440000 |
      | Name         | PMI-DB-UK-001                        |
      | Market       | UK                                   |
      | DatabaseType | PMI_TYPE_A                           |

  # Happy Path Scenarios

  Scenario: Successfully test connection with valid credentials
    Given the user is on the update credentials form
    And they have entered valid credentials:
      | Field             | Value                          |
      | API Key           | sk_live_abc123xyz789           |
      | Connection String | Server=pmi-uk.db;Database=prod |
    When they click "Test Connection" button
    Then they should see a loading indicator "Testing connection..."
    And the test should complete within 10 seconds
    And they should see success message "Connection successful"
    And they should see a green checkmark icon
    And the "Save Credentials" button should be enabled

  Scenario: Test connection with existing credentials
    Given the integration has existing credentials stored
    And the user is on the integration detail page
    When they click "Test Connection" button
    Then the system should test using the stored credentials
    And they should see loading indicator
    And they should see result within 10 seconds
    And the result should indicate success or failure

  # Connection Failure Scenarios

  Scenario: Test connection fails with invalid API key
    Given the user has entered invalid API key "invalid-key-123"
    When they click "Test Connection"
    Then they should see loading indicator
    And the test should complete within 10 seconds
    And they should see error message "Connection failed: Invalid API key"
    And they should see a red X icon
    And they should see suggestion "Please verify your API key and try again"

  Scenario: Test connection fails with invalid connection string
    Given the user has entered invalid connection string "Server=invalid"
    When they click "Test Connection"
    Then they should see loading indicator
    And the test should complete within 10 seconds
    And they should see error message "Connection failed: Unable to connect to database server"
    And they should see suggestion "Please verify the server address and database name"

  Scenario: Test connection fails due to network error
    Given the user has entered valid credentials
    And the external database is unreachable due to network issue
    When they click "Test Connection"
    Then they should see loading indicator
    And the test should complete within 10 seconds
    And they should see error message "Connection failed: Network error"
    And they should see suggestion "Please check network connectivity and firewall rules"

  Scenario: Test connection fails due to authentication error
    Given the user has entered credentials with incorrect password
    When they click "Test Connection"
    Then they should see error message "Connection failed: Authentication failed"
    And they should see suggestion "Please verify your credentials are correct"
    And the error should not expose the actual password

  Scenario: Test connection fails due to insufficient permissions
    Given the user has entered credentials with read-only access
    And the integration requires write access
    When they click "Test Connection"
    Then they should see error message "Connection failed: Insufficient permissions"
    And they should see suggestion "The provided credentials do not have required permissions"

  # Timeout Scenarios

  Scenario: Test connection times out after 10 seconds
    Given the user has entered valid credentials
    And the external database is slow to respond
    When they click "Test Connection"
    And 10 seconds elapse without response
    Then the test should be cancelled
    And they should see error message "Connection test timed out after 10 seconds"
    And they should see a "Retry" button
    And they should see suggestion "The database may be slow or unreachable"

  Scenario: User can cancel test connection in progress
    Given the user has clicked "Test Connection"
    And the test is in progress
    When they click "Cancel Test" button
    Then the test should be cancelled immediately
    And they should see message "Connection test cancelled"
    And the form should return to editable state

  # Retry Scenarios

  Scenario: Retry failed connection test
    Given the user tested connection and it failed
    And they see error message and "Retry" button
    When they click "Retry" button
    Then the test should run again with the same credentials
    And they should see loading indicator
    And they should see result within 10 seconds

  Scenario: Modify credentials and retry
    Given the user tested connection and it failed
    When they modify the API key
    And they click "Test Connection" again
    Then the test should use the new credentials
    And the previous error should be cleared
    And they should see fresh test result

  # Test Connection Without Saving

  Scenario: Test connection does not save credentials
    Given the user has entered new credentials
    When they click "Test Connection"
    And the test succeeds
    Then the credentials should NOT be saved to AWS Secrets Manager
    And the credentials should remain in the form only
    And they should still need to click "Save Credentials" to persist

  Scenario: Save credentials without testing
    Given the user has entered valid credentials
    And they have not clicked "Test Connection"
    When they click "Save Credentials"
    Then they should see warning dialog "Save without testing connection?"
    And the dialog should show "It is recommended to test the connection first"
    When they confirm
    Then the credentials should be saved
    And they should see success message with note "Credentials saved without testing"

  # Detailed Error Information

  Scenario: Test connection provides detailed error information
    Given the user tests connection with invalid credentials
    When the test fails
    Then they should see error category "Authentication Error"
    And they should see error code "AUTH_FAILED_001"
    And they should see error message "Invalid API key format"
    And they should see timestamp of the test
    And they should see option to "View Technical Details"

  Scenario: View technical details of connection failure
    Given the user has a failed connection test
    When they click "View Technical Details"
    Then they should see expanded error information:
      | Field          | Value                                    |
      | Error Code     | AUTH_FAILED_001                          |
      | Error Message  | Invalid API key format                   |
      | Timestamp      | 2024-12-19T14:22:00Z                     |
      | Database Type  | PMI_TYPE_A                               |
      | Test Duration  | 2.3 seconds                              |
      | Server Response| 401 Unauthorized                         |
    And they should be able to copy error details for support

  # Different Database Types

  Scenario Outline: Test connection for different database types
    Given the integration has database type "<DatabaseType>"
    And the user has entered credentials for "<DatabaseType>"
    When they click "Test Connection"
    Then the system should use the appropriate connector for "<DatabaseType>"
    And the test should validate "<DatabaseType>" specific requirements
    And they should see result within 10 seconds

    Examples:
      | DatabaseType |
      | PMI_TYPE_A   |
      | PMI_TYPE_B   |
      | PMI_TYPE_C   |

  # Security Scenarios

  @security
  Scenario: Test connection does not log credentials
    Given the user tests connection with credentials
    When the test completes (success or failure)
    Then application logs should NOT contain credential values
    And Sentry error logs should NOT contain credentials
    And New Relic traces should NOT contain credentials
    And only the test result should be logged

  @security
  Scenario: Test connection uses secure channel
    Given the user tests connection
    When the test executes
    Then all communication should use HTTPS/TLS
    And credentials should be encrypted in transit
    And no credentials should be transmitted over HTTP

  @security
  Scenario: Test connection credentials not stored in browser
    Given the user enters credentials for testing
    When they test the connection
    Then credentials should not be stored in browser local storage
    And credentials should not be stored in session storage
    And credentials should not be stored in browser memory after test

  # Audit Logging

  @audit
  Scenario: Successful connection test is logged
    Given the user tests connection successfully
    When the test completes
    Then an audit log entry should be created with action "TEST_CONNECTION_SUCCESS"
    And the log should include user, timestamp, and integration ID
    And the log should NOT include credential values
    And the log should include database type

  @audit
  Scenario: Failed connection test is logged
    Given the user tests connection and it fails
    When the test completes
    Then an audit log entry should be created with action "TEST_CONNECTION_FAILED"
    And the log should include error category
    And the log should NOT include credential values
    And the log should include test duration

  # UI/UX Scenarios

  Scenario: Test connection button is disabled during test
    Given the user clicks "Test Connection"
    When the test is in progress
    Then the "Test Connection" button should be disabled
    And a loading spinner should be visible
    And the button text should change to "Testing..."
    And other form fields should remain editable

  Scenario: Test connection result is clearly visible
    Given the user tests connection
    When the test completes
    Then the result should be displayed prominently
    And success should be shown in green with checkmark
    And failure should be shown in red with X icon
    And the result should remain visible until form is closed or retested

  Scenario: Test connection progress indicator
    Given the user clicks "Test Connection"
    When the test is in progress
    Then they should see a progress indicator
    And they should see elapsed time "Testing... 3s"
    And they should see a cancel button
    And the indicator should update every second

  # Integration with Credential Form

  Scenario: Test connection validates form before testing
    Given the user has not entered any credentials
    When they click "Test Connection"
    Then they should see validation error "Please enter credentials before testing"
    And the test should not execute
    And no API call should be made

  Scenario: Test connection with partial credentials
    Given the user has entered API key but not connection string
    When they click "Test Connection"
    Then they should see validation error "Both API key and connection string are required"
    And the test should not execute

  Scenario: Test connection result influences save button state
    Given the user has tested connection successfully
    When the test completes
    Then the "Save Credentials" button should be highlighted
    And a tooltip should suggest "Connection verified - ready to save"
    And the save action should be encouraged

  # NFR: Performance

  @nfr @performance
  Scenario: Test connection completes within timeout
    Given the user tests connection with valid credentials
    When the test executes
    Then the test should complete within 10 seconds
    And the result should be displayed immediately after completion
    And the UI should remain responsive during the test

  @nfr @performance
  Scenario: Multiple concurrent connection tests are handled
    Given 5 users test connections simultaneously
    When all tests execute
    Then each test should complete independently
    And no test should block others
    And all results should be returned within 10 seconds

  # NFR: Resilience

  @nfr @resilience
  Scenario: Test connection handles transient failures gracefully
    Given the external database has intermittent connectivity
    When the user tests connection
    And the first attempt fails with transient error
    Then the system should automatically retry once
    And the user should see "Retrying..." indicator
    And if retry succeeds, they should see success message
    And if retry fails, they should see failure message with retry option

  @nfr @resilience
  Scenario: Test connection does not impact other operations
    Given the user is testing connection
    When the test is in progress
    Then other users should be able to perform operations
    And the test should not lock database resources
    And the test should not impact system performance

  # Accessibility

  @nfr @accessibility
  Scenario: Test connection is keyboard accessible
    Given the user navigates with keyboard
    When they tab to "Test Connection" button
    Then the button should have visible focus indicator
    And they should be able to activate it with Enter or Space key
    And the result should be announced by screen readers

  @nfr @accessibility
  Scenario: Screen reader announces test connection result
    Given the user is using a screen reader
    When they test connection
    And the test completes
    Then the screen reader should announce "Connection test successful" or "Connection test failed"
    And error messages should be announced immediately
    And the result should be in an ARIA live region

  # Edge Cases

  Scenario: Test connection with very slow database
    Given the external database responds in 9 seconds
    When the user tests connection
    Then the test should wait for the full response
    And they should see elapsed time indicator
    And the test should succeed if response is valid
    And they should see warning "Database response was slow (9s)"

  Scenario: Test connection with database that requires VPN
    Given the external database requires VPN connection
    And the user is not connected to VPN
    When they test connection
    Then they should see error "Connection failed: Network unreachable"
    And they should see suggestion "Please ensure you are connected to the required VPN"

  Scenario: Test connection with rate-limited API
    Given the external database API has rate limits
    And the rate limit has been exceeded
    When the user tests connection
    Then they should see error "Connection failed: Rate limit exceeded"
    And they should see suggestion "Please wait a few minutes and try again"
    And they should see estimated wait time "Retry available in 5 minutes"
