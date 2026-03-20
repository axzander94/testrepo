Feature: RBAC Integration Access Control
  As a system administrator
  I want to control access to integration management based on user roles
  So that only authorized users can view or modify integration configurations

  Background:
    Given the integration management module is available
    And Azure EntraID is configured with integration roles

  @smoke @security
  Scenario: IntegrationAdmin can access all integration features
    Given I am logged in as a user with "IntegrationAdmin" role
    When I navigate to the integration management page
    Then I should see the integration list
    And I should see "Create Integration" button
    And I should see "Update Credentials" options
    And I should see "Toggle Endpoints" controls

  @smoke @security
  Scenario: IntegrationViewer has read-only access
    Given I am logged in as a user with "IntegrationViewer" role
    When I navigate to the integration management page
    Then I should see the integration list
    But I should not see "Create Integration" button
    And I should not see "Update Credentials" options
    And I should not see "Toggle Endpoints" controls
    And all modification buttons should be disabled

  @security
  Scenario: User without integration roles is denied access
    Given I am logged in as a user without integration roles
    When I attempt to navigate to the integration management page
    Then I should receive a "403 Forbidden" response
    And I should see an "Access Denied" message
    And I should be redirected to the main dashboard

  @security
  Scenario: Unauthenticated user cannot access integration management
    Given I am not logged in
    When I attempt to access the integration management API
    Then I should receive a "401 Unauthorized" response
    And I should be redirected to the login page

  @security
  Scenario: IntegrationViewer cannot call admin-only API endpoints
    Given I am logged in as a user with "IntegrationViewer" role
    When I attempt to call "PUT /api/v1/integrations/123/credentials"
    Then I should receive a "403 Forbidden" response
    And the audit log should record the unauthorized attempt

  @security
  Scenario: Role changes take effect immediately
    Given I am logged in as a user with "IntegrationAdmin" role
    And I am viewing the integration management page
    When my role is changed to "IntegrationViewer" in Azure EntraID
    And I refresh the page
    Then all modification controls should be disabled
    And I should only have read-only access

  @edge-case
  Scenario: User with expired session cannot perform operations
    Given I am logged in as a user with "IntegrationAdmin" role
    And my session has expired
    When I attempt to update integration credentials
    Then I should receive a "401 Unauthorized" response
    And I should be prompted to re-authenticate

  @edge-case
  Scenario: Azure EntraID service unavailable during role check
    Given Azure EntraID service is temporarily unavailable
    When I attempt to access the integration management page
    Then I should see a "Service temporarily unavailable" message
    And I should be able to retry the operation
    And the system should log the EntraID service failure