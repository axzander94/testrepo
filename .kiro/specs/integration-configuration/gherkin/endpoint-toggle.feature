@integration-configuration @endpoint-toggle @mvp2
Feature: Endpoint Enable/Disable Management
  As an integration administrator
  I want to enable or disable specific integration endpoints
  So that I can control which data points are available for campaigns without changing credentials

  Background:
    Given the user "admin@justscan.com" has IntegrationAdmin role
    And the user is logged into backoffice
    And the following integration exists:
      | Field  | Value                                |
      | Id     | 550e8400-e29b-41d4-a716-446655440000 |
      | Name   | PMI-DB-UK-001                        |
      | Market | UK                                   |
    And the integration has the following endpoints:
      | Endpoint  | Enabled | LastUpdated          |
      | sendOTP   | true    | 2024-12-19T10:00:00Z |
      | lastName  | true    | 2024-12-19T10:00:00Z |
      | firstName | true    | 2024-12-19T10:00:00Z |

  # Happy Path Scenarios

  Scenario: Disable an enabled endpoint
    Given the user is on the integration detail page for "PMI-DB-UK-001"
    And endpoint "sendOTP" is currently enabled
    When they toggle the "sendOTP" endpoint switch to disabled
    Then they should see a confirmation dialog "Disable sendOTP endpoint?"
    When they confirm the action
    Then the endpoint status should change to "Disabled"
    And they should see success message "Endpoint sendOTP disabled"
    And the toggle switch should reflect the disabled state
    And an audit log entry should be created

  Scenario: Enable a disabled endpoint
    Given the user is on the integration detail page for "PMI-DB-UK-001"
    And endpoint "sendOTP" is currently disabled
    When they toggle the "sendOTP" endpoint switch to enabled
    Then they should see a confirmation dialog "Enable sendOTP endpoint?"
    When they confirm the action
    Then the endpoint status should change to "Enabled"
    And they should see success message "Endpoint sendOTP enabled"
    And the toggle switch should reflect the enabled state
    And an audit log entry should be created

  Scenario: Toggle multiple endpoints independently
    Given the user is on the integration detail page
    When they disable endpoint "sendOTP"
    And they disable endpoint "lastName"
    And they keep endpoint "firstName" enabled
    Then "sendOTP" should show status "Disabled"
    And "lastName" should show status "Disabled"
    And "firstName" should show status "Enabled"
    And 2 separate audit log entries should be created

  # Real-Time Update Scenarios

  Scenario: Endpoint toggle updates configuration immediately
    Given the user toggles endpoint "sendOTP" to disabled
    When the operation completes successfully
    Then the configuration should be updated in the database immediately
    And the change should be reflected in the UI within 1 second
    And the endpoint status indicator should update

  Scenario: Cache invalidation after endpoint toggle
    Given integration "PMI-DB-UK-001" configuration is cached in Redis
    When the user toggles endpoint "sendOTP" to disabled
    Then the Redis cache for this integration should be invalidated immediately
    And subsequent API calls should fetch fresh configuration
    And the cache TTL should be reset to 5 minutes

  @nfr @performance
  Scenario: WebApp receives configuration update within 5 minutes
    Given the user toggles endpoint "sendOTP" to disabled
    When the operation completes successfully
    Then WebApp configuration cache should be invalidated
    And WebApp should reload configuration within 5 minutes
    And campaigns should respect the new endpoint state for next API call
    And no active campaign requests should be interrupted

  # Audit Logging Scenarios

  @audit
  Scenario: Endpoint toggle is logged in audit trail
    Given the user toggles endpoint "sendOTP" to disabled
    When the operation completes
    Then an audit log entry should be created with:
      | Field      | Value                                |
      | Action     | TOGGLE_ENDPOINT                      |
      | EntityType | IntegrationEndpoint                  |
      | EntityId   | endpoint-id-for-sendOTP              |
      | OldValue   | {"endpointName":"sendOTP","enabled":true} |
      | NewValue   | {"endpointName":"sendOTP","enabled":false} |
      | UserId     | admin@justscan.com                   |
      | UserRole   | IntegrationAdmin                     |
      | Timestamp  | 2024-12-19T14:22:00Z                 |
    And the audit log should be immutable
    And the audit log should be retained for at least 2 years

  @audit
  Scenario: Multiple endpoint toggles create separate audit entries
    Given the user toggles 3 endpoints in sequence
    When all operations complete
    Then 3 separate audit log entries should be created
    And each entry should have a unique timestamp
    And each entry should reference the specific endpoint modified

  # Confirmation Dialog Scenarios

  Scenario: Confirmation dialog shows endpoint impact
    Given the user attempts to disable endpoint "sendOTP"
    When the confirmation dialog appears
    Then it should display "Disable sendOTP endpoint?"
    And it should show warning "This will affect campaigns using this endpoint"
    And it should show "Campaigns will not be able to send OTP codes"
    And it should have "Cancel" and "Confirm" buttons

  Scenario: Cancel endpoint toggle in confirmation dialog
    Given the user attempts to disable endpoint "sendOTP"
    And the confirmation dialog appears
    When they click "Cancel"
    Then the dialog should close
    And the endpoint state should remain unchanged
    And no audit log entry should be created
    And no API call should be made

  # Optimistic UI Update Scenarios

  Scenario: Optimistic UI update with rollback on error
    Given the user toggles endpoint "sendOTP" to disabled
    When the toggle switch is clicked
    Then the UI should immediately show the disabled state
    And a loading indicator should appear
    When the API returns an error
    Then the toggle switch should revert to enabled state
    And they should see error message "Failed to disable endpoint. Please try again."

  Scenario: Optimistic UI update confirmed on success
    Given the user toggles endpoint "sendOTP" to disabled
    When the toggle switch is clicked
    Then the UI should immediately show the disabled state
    When the API confirms success
    Then the disabled state should remain
    And the loading indicator should disappear
    And success message should appear briefly

  # Permission Scenarios

  Scenario: IntegrationViewer cannot toggle endpoints
    Given a user "viewer@justscan.com" has IntegrationViewer role
    And the user is on the integration detail page
    When they view the endpoint list
    Then all endpoint toggle switches should be disabled
    And they should see tooltip "IntegrationAdmin role required to modify endpoints"
    And clicking a toggle should have no effect

  Scenario: IntegrationAdmin can toggle all endpoints
    Given the user has IntegrationAdmin role
    And the user is on the integration detail page
    When they view the endpoint list
    Then all endpoint toggle switches should be enabled
    And they should be able to toggle any endpoint
    And no permission errors should occur

  # Error Scenarios

  Scenario: Handle API error during endpoint toggle
    Given the user attempts to toggle endpoint "sendOTP"
    When the API returns a 500 Internal Server Error
    Then the toggle switch should revert to original state
    And they should see error message "Unable to update endpoint. Please try again."
    And the error should be logged to Sentry
    And no audit log entry should be created

  Scenario: Handle network timeout during endpoint toggle
    Given the user attempts to toggle endpoint "sendOTP"
    When the API request times out after 10 seconds
    Then the toggle switch should revert to original state
    And they should see error message "Request timed out. Please check your connection."
    And they should see a "Retry" button

  Scenario: Handle concurrent modification conflict
    Given user "admin1@justscan.com" toggles endpoint "sendOTP" to disabled
    And user "admin2@justscan.com" simultaneously toggles the same endpoint
    When both requests are processed
    Then the first request should succeed
    And the second request should receive a 409 Conflict response
    And the second user should see message "Endpoint was modified by another user. Refreshing..."
    And the page should automatically refresh to show current state

  # Bulk Toggle Scenarios

  Scenario: Disable all endpoints at once
    Given the user is on the integration detail page
    When they click "Disable All Endpoints" button
    Then they should see confirmation dialog "Disable all 3 endpoints?"
    When they confirm
    Then all endpoints should be disabled
    And they should see success message "All endpoints disabled"
    And 3 separate audit log entries should be created

  Scenario: Enable all endpoints at once
    Given all endpoints are currently disabled
    When the user clicks "Enable All Endpoints" button
    Then they should see confirmation dialog "Enable all 3 endpoints?"
    When they confirm
    Then all endpoints should be enabled
    And they should see success message "All endpoints enabled"
    And 3 separate audit log entries should be created

  # Endpoint Status Indicators

  Scenario: Visual indicators reflect endpoint state
    Given the user is viewing the endpoint list
    When endpoint "sendOTP" is enabled
    Then it should display a green toggle switch
    And it should show green "Enabled" badge
    When endpoint "lastName" is disabled
    Then it should display a grey toggle switch
    And it should show grey "Disabled" badge

  Scenario: Endpoint count updates after toggle
    Given the integration has 3 endpoints with 3 enabled
    When the user disables endpoint "sendOTP"
    Then the integration card should show "2 of 3 endpoints enabled"
    And the status indicator should change to amber
    When they disable another endpoint
    Then the integration card should show "1 of 3 endpoints enabled"

  # Campaign Impact Scenarios

  Scenario: Warning when disabling endpoint used by active campaigns
    Given endpoint "sendOTP" is used by 5 active campaigns
    When the user attempts to disable the endpoint
    Then the confirmation dialog should show "5 active campaigns use this endpoint"
    And it should list the affected campaign names
    And it should show warning "These campaigns may fail if this endpoint is disabled"
    And the user should be able to proceed or cancel

  Scenario: No warning when disabling unused endpoint
    Given endpoint "sendOTP" is not used by any active campaigns
    When the user attempts to disable the endpoint
    Then the confirmation dialog should show standard message
    And no campaign warning should appear
    And the user can proceed without additional confirmation

  # Real-Time Notification Scenarios

  Scenario: Other users see endpoint state change after refresh
    Given user "admin1@justscan.com" is viewing the integration detail page
    And user "admin2@justscan.com" toggles endpoint "sendOTP" to disabled
    When user "admin1@justscan.com" refreshes the page
    Then they should see endpoint "sendOTP" as disabled
    And they should see the updated timestamp
    And they should see who made the change

  Scenario: Stale data notification after endpoint toggle by another user
    Given the user has been viewing the integration detail page for 3 minutes
    And another admin toggles an endpoint
    When the page detects stale data
    Then they should see a banner "Endpoint configuration has changed. Refresh to see updates."
    And a "Refresh Now" button should be visible

  # NFR: Performance

  @nfr @performance
  Scenario: Endpoint toggle completes within 1 second
    Given the user toggles an endpoint
    When the operation executes
    Then the database update should complete within 500ms
    And the UI should reflect the change within 1 second
    And the success message should appear immediately

  @nfr @performance
  Scenario: Bulk endpoint toggle completes efficiently
    Given the user toggles all 3 endpoints at once
    When the operation executes
    Then all updates should complete within 2 seconds
    And the UI should update progressively
    And a single cache invalidation should occur

  # NFR: Usability

  @nfr @usability
  Scenario: Toggle switches are accessible on mobile
    Given the user is viewing the page on a mobile device
    When they view the endpoint list
    Then toggle switches should be at least 44x44 pixels
    And they should be easily tappable
    And visual feedback should be immediate on tap

  @nfr @usability
  Scenario: Keyboard navigation for endpoint toggles
    Given the user is navigating with keyboard
    When they tab to an endpoint toggle switch
    Then the switch should have visible focus indicator
    And they should be able to toggle using Space or Enter key
    And the confirmation dialog should be keyboard accessible

  # NFR: Accessibility

  @nfr @accessibility
  Scenario: Screen reader announces endpoint toggle state
    Given the user is using a screen reader
    When they navigate to an endpoint toggle
    Then the screen reader should announce "sendOTP endpoint, enabled, toggle switch"
    When they toggle the switch
    Then the screen reader should announce "sendOTP endpoint disabled"
    And the confirmation dialog should be announced

  # Integration with WebApp

  Scenario: WebApp respects disabled endpoint configuration
    Given endpoint "sendOTP" is disabled for "PMI-DB-UK-001"
    And WebApp configuration cache has been invalidated
    When a campaign attempts to call the "sendOTP" endpoint
    Then the WebApp should skip the API call
    And the campaign should continue without the OTP functionality
    And an info log should be created "Endpoint sendOTP is disabled for this integration"

  Scenario: WebApp uses enabled endpoint configuration
    Given endpoint "sendOTP" is enabled for "PMI-DB-UK-001"
    When a campaign attempts to call the "sendOTP" endpoint
    Then the WebApp should make the API call to the external database
    And the campaign should receive the OTP response
    And the endpoint should function normally
