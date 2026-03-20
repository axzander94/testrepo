Feature: Endpoint Management
  As an integration administrator
  I want to enable and disable individual endpoints for each database integration
  So that I can control which API functions are available per market without affecting others

  Background:
    Given I am logged in as a user with "IntegrationAdmin" role
    And the integration "PMI_Database_US" is assigned to market "US"
    And the integration has the following endpoints:
      | Endpoint Name | Current Status | Description |
      | sendOTP | Enabled | Send one-time password |
      | lastName | Enabled | Retrieve customer last name |
      | firstName | Enabled | Retrieve customer first name |
      | phoneNumber | Disabled | Retrieve customer phone |

  @smoke
  Scenario: Successfully enable a disabled endpoint
    Given the endpoint "phoneNumber" is currently disabled
    When I navigate to integration endpoint management
    And I toggle the "phoneNumber" endpoint to enabled
    Then I should see "Endpoint enabled successfully" message
    And the endpoint status should show as "Enabled"
    And the WebApp should receive the configuration update within 5 minutes
    And an audit log entry should record the endpoint change

  @smoke
  Scenario: Successfully disable an enabled endpoint
    Given the endpoint "sendOTP" is currently enabled
    When I toggle the "sendOTP" endpoint to disabled
    Then I should see "Endpoint disabled successfully" message
    And the endpoint status should show as "Disabled"
    And the WebApp should stop using this endpoint immediately
    And an audit log entry should record the endpoint change

  @real-time
  Scenario: Endpoint changes take effect immediately
    Given the endpoint "lastName" is currently enabled
    And there are active campaigns using the "lastName" endpoint
    When I disable the "lastName" endpoint
    Then the configuration cache should be invalidated immediately
    And new campaign requests should not use the "lastName" endpoint
    And existing campaign sessions should gracefully handle the change

  @edge-case
  Scenario: Toggle endpoint for integration used by multiple markets
    Given the integration "PMI_Database_Global" is assigned to markets "US", "CA", "MX"
    And the "sendOTP" endpoint is enabled for all markets
    When I disable the "sendOTP" endpoint for market "US" only
    Then the endpoint should remain enabled for markets "CA" and "MX"
    And only market "US" should have the endpoint disabled
    And each market's configuration should be updated independently

  @error-handling
  Scenario: Handle endpoint toggle during system maintenance
    Given the system is in maintenance mode
    When I attempt to toggle the "firstName" endpoint
    Then I should see "System maintenance in progress" message
    And the endpoint change should be queued for after maintenance
    And I should receive notification when the change is applied

  @business-rule
  Scenario: Prevent disabling critical endpoints with active usage
    Given the endpoint "sendOTP" has 50 active sessions in the last hour
    When I attempt to disable the "sendOTP" endpoint
    Then I should see a warning "This endpoint has high current usage"
    And I should see "50 active sessions in the last hour"
    And I should be asked to confirm the change
    When I confirm the change
    Then the endpoint should be disabled
    And active sessions should be gracefully handled

  @performance
  Scenario: Endpoint toggle completes within acceptable time
    Given I am toggling the "lastName" endpoint
    When I submit the toggle request
    Then the change should complete within 1 second
    And I should receive immediate UI feedback
    And the configuration should propagate to WebApp within 5 minutes

  @edge-case
  Scenario: Bulk endpoint management for multiple integrations
    Given I have selected 3 integrations for bulk endpoint management
    When I disable the "phoneNumber" endpoint for all selected integrations
    Then all 3 integrations should have "phoneNumber" disabled
    And I should see "Endpoint disabled for 3 integrations" message
    And separate audit entries should be created for each integration

  @error-handling
  Scenario: Handle concurrent endpoint modifications
    Given user "Admin1" is disabling the "sendOTP" endpoint
    And user "Admin2" simultaneously enables the same endpoint
    When both changes are submitted
    Then the last change should take precedence
    And both users should be notified of the conflict
    And both operations should be logged with timestamps