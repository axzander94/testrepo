@integration-configuration @rbac @security @mvp1
Feature: RBAC Access Control for Integration Management
  As a system administrator
  I want role-based access control for integration management
  So that only authorized users can view or modify integration configurations

  Background:
    Given the backoffice application is running
    And Azure EntraID is configured with integration roles

  # Happy Path Scenarios

  Scenario: IntegrationAdmin can access integration management module
    Given a user "admin@justscan.com" has IntegrationAdmin role in Azure EntraID
    And the user is logged into backoffice
    When they navigate to "/integrations"
    Then they should see the integration list page
    And all CRUD operations should be enabled

  Scenario: IntegrationViewer can view integrations in read-only mode
    Given a user "viewer@justscan.com" has IntegrationViewer role in Azure EntraID
    And the user is logged into backoffice
    When they navigate to "/integrations"
    Then they should see the integration list page
    And all modification actions should be disabled
    And only view operations should be available

  # Unauthorized Access Scenarios

  Scenario: User without integration role cannot access integration module
    Given a user "content_manager@justscan.com" has no integration roles in Azure EntraID
    And the user is logged into backoffice
    When they attempt to navigate to "/integrations"
    Then they should receive a 403 Forbidden response
    And they should see an error message "You do not have permission to access integration management"

  Scenario: Unauthenticated user cannot access integration endpoints
    Given a user is not logged into backoffice
    When they attempt to access "/api/v1/integrations"
    Then they should receive a 401 Unauthorized response
    And they should be redirected to the login page

  Scenario: IntegrationViewer cannot update credentials
    Given a user "viewer@justscan.com" has IntegrationViewer role in Azure EntraID
    And the user is logged into backoffice
    And they are viewing integration "PMI-DB-UK-001"
    When they attempt to update credentials via PUT "/api/v1/integrations/{id}/credentials"
    Then they should receive a 403 Forbidden response
    And they should see an error message "IntegrationAdmin role required for this operation"

  Scenario: IntegrationViewer cannot toggle endpoints
    Given a user "viewer@justscan.com" has IntegrationViewer role in Azure EntraID
    And the user is logged into backoffice
    And they are viewing integration "PMI-DB-UK-001"
    When they attempt to toggle endpoint "sendOTP" via PATCH "/api/v1/integrations/{id}/endpoints/sendOTP"
    Then they should receive a 403 Forbidden response
    And the endpoint state should remain unchanged

  # Role Change Mid-Session Scenarios

  Scenario: User role downgrade is enforced on next operation
    Given a user "admin@justscan.com" has IntegrationAdmin role in Azure EntraID
    And the user is logged into backoffice with an active session
    And the user's role is changed to IntegrationViewer in Azure EntraID
    When they attempt to update credentials after 5 minutes
    Then they should receive a 403 Forbidden response
    And they should see a message "Your permissions have changed. Please refresh your session."

  Scenario: User role upgrade is recognized after permission cache expires
    Given a user "viewer@justscan.com" has IntegrationViewer role in Azure EntraID
    And the user is logged into backoffice with an active session
    And the user's role is upgraded to IntegrationAdmin in Azure EntraID
    When they wait for 15 minutes for permission cache to expire
    And they attempt to update credentials
    Then the operation should succeed
    And they should have full IntegrationAdmin capabilities

  # Azure EntraID Sync Delay Scenarios

  Scenario: New user added to IntegrationAdmin group experiences sync delay
    Given a new user "newadmin@justscan.com" is added to IntegrationAdmin group in Azure EntraID
    And Azure EntraID sync has not yet completed
    When they log into backoffice within 2 minutes
    And they attempt to access "/integrations"
    Then they should receive a 403 Forbidden response
    But after waiting 5 minutes for sync to complete
    And they refresh their session
    Then they should be able to access the integration module

  Scenario: Manual permission refresh option available
    Given a user "admin@justscan.com" has just been granted IntegrationAdmin role
    And the user is logged into backoffice
    And permission cache has not yet expired
    When they click "Refresh Permissions" in user menu
    Then the system should re-validate their Azure EntraID group membership
    And their new permissions should be immediately available

  # Concurrent Session Scenarios

  @security
  Scenario: User with multiple sessions has consistent permissions
    Given a user "admin@justscan.com" has IntegrationAdmin role
    And they have active sessions in 2 different browsers
    When their role is changed to IntegrationViewer in Azure EntraID
    Then both sessions should enforce the new role after cache expiry
    And any admin operations should be blocked in both sessions

  # Permission Boundary Cases

  Scenario: User with expired session token cannot access integrations
    Given a user "admin@justscan.com" has IntegrationAdmin role
    And they logged into backoffice 9 hours ago
    And their session token has expired
    When they attempt to access "/api/v1/integrations"
    Then they should receive a 401 Unauthorized response
    And they should be redirected to login page

  Scenario: User removed from all integration roles loses access immediately
    Given a user "admin@justscan.com" has IntegrationAdmin role
    And the user is logged into backoffice
    And they are removed from all integration groups in Azure EntraID
    When they attempt any integration operation after 15 minutes
    Then they should receive a 403 Forbidden response
    And they should see a message "Integration access has been revoked"

  # Audit Logging for Access Attempts

  @audit @nfr
  Scenario: Unauthorized access attempts are logged
    Given a user "content_manager@justscan.com" has no integration roles
    When they attempt to access "/api/v1/integrations"
    Then the attempt should be logged in security audit log
    And the log entry should contain user ID, timestamp, attempted resource, and result "403 Forbidden"
    And no sensitive data should be included in the log

  Scenario: Successful role-based access is logged
    Given a user "admin@justscan.com" has IntegrationAdmin role
    When they successfully access "/integrations"
    Then the access should be logged in audit log
    And the log entry should contain user ID, role, timestamp, and action "VIEW_INTEGRATIONS"

  # NFR: Performance

  @nfr @performance
  Scenario: Role validation completes within acceptable time
    Given a user "admin@justscan.com" has IntegrationAdmin role
    When they access the integration module
    Then Azure EntraID role validation should complete within 500ms
    And the page should load within 2 seconds

  @nfr @performance
  Scenario: Permission cache reduces Azure EntraID calls
    Given a user "admin@justscan.com" has IntegrationAdmin role
    And they have accessed integrations within the last 10 minutes
    When they perform 5 consecutive operations
    Then Azure EntraID should be queried only once
    And subsequent operations should use cached permissions
