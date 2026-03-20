Feature: Role-Based Access Control
  As a system administrator
  I want to ensure proper access control via SIGA integration
  So that users only access features appropriate to their role

  Background:
    Given the SIGA integration is configured and operational

  Scenario Outline: Role-based feature access
    Given I am authenticated as a "<Role>" user
    When I access the JustBrief platform
    Then I should "<PipelineAccess>" pipeline management features
    And I should "<BriefAccess>" brief submission features
    And I should "<AdminAccess>" administrative features

    Examples:
      | Role | PipelineAccess | BriefAccess | AdminAccess |
      | Regional SPOC | have access to | not have access to | have access to |
      | EPAM User | have access to | not have access to | have access to |
      | Market User | not have access to | have access to | not have access to |

  Scenario: Market-specific data isolation
    Given I am authenticated as a "US" market user
    When I access the platform
    Then I should only see pipelines assigned to "US" market
    And I should only see my own brief submissions
    When I try to access "UK" market data via direct URL
    Then I should receive "Access Denied" error
    And the attempt should be logged for security monitoring

  Scenario: SIGA authentication failure handling
    Given the SIGA service is temporarily unavailable
    When I try to authenticate
    Then I should see "Authentication service unavailable" message
    And I should not be able to access any protected features
    And the system should retry authentication automatically
    And administrators should be alerted to the SIGA outage

  Scenario: Token expiration and refresh
    Given I am authenticated with a valid SIGA token
    When my token expires during a session
    Then I should be prompted to re-authenticate
    And my current work should be preserved
    When I re-authenticate successfully
    Then I should be able to continue from where I left off

  Scenario: Permission validation for API endpoints
    Given I am authenticated as a "Market User"
    When I try to call pipeline management API endpoints
    Then I should receive HTTP 403 Forbidden response
    And the unauthorized access attempt should be logged
    When I call brief submission API endpoints
    Then I should receive successful responses for my market data only

  Scenario: Role changes reflected in real-time
    Given I am authenticated with "Market User" role
    When my role is changed to "Regional SPOC" in SIGA
    And I refresh my session
    Then I should have access to pipeline management features
    And my previous market-specific restrictions should be lifted