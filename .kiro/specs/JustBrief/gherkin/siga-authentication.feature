@justbrief @authentication @siga
Feature: SIGA RBAC Authentication and Authorization
  As a JustBrief platform user
  I want to authenticate via SIGA RBAC system
  So that my access is controlled based on my assigned role and permissions

  Background:
    Given the SIGA RBAC system is available
    And the JustBrief platform is running

  # ============================================================================
  # HAPPY PATH SCENARIOS
  # ============================================================================

  @smoke @JSN-014
  Scenario: Regional SPOC successfully authenticates via SIGA
    Given a user with SIGA role "regional_spoc"
    And the user has valid SIGA credentials
    When the user logs into JustBrief with their SIGA token
    Then the user is authenticated successfully
    And the user session contains role "regional_spoc"
    And the user can access pipeline management features

  @smoke @JSN-014
  Scenario: Market user successfully authenticates via SIGA
    Given a user with SIGA role "market_user"
    And the user has valid SIGA credentials
    When the user logs into JustBrief with their SIGA token
    Then the user is authenticated successfully
    And the user session contains role "market_user"
    And the user can access campaign selection features

  @smoke @JSN-014
  Scenario: EPAM admin successfully authenticates via SIGA
    Given a user with SIGA role "epam_admin"
    And the user has valid SIGA credentials
    When the user logs into JustBrief with their SIGA token
    Then the user is authenticated successfully
    And the user session contains role "epam_admin"
    And the user can access all administrative features

  # ============================================================================
  # ROLE-BASED ACCESS CONTROL
  # ============================================================================

  @regression @JSN-015
  Scenario: Regional SPOC can create pipelines
    Given a user is authenticated as "regional_spoc"
    When the user attempts to create a new pipeline
    Then the action is permitted
    And the pipeline is created successfully

  @regression @JSN-015
  Scenario: Market user cannot create pipelines
    Given a user is authenticated as "market_user"
    When the user attempts to create a new pipeline
    Then the action is denied with status code 403
    And the error message is "Insufficient permissions to create pipelines"

  @regression @JSN-015
  Scenario: Market user can view assigned campaigns
    Given a user is authenticated as "market_user" for market "DE"
    And campaigns exist assigned to market "DE"
    When the user requests the campaign list
    Then the action is permitted
    And only campaigns assigned to market "DE" are returned

  @regression @JSN-015
  Scenario: Market user cannot view campaigns from other markets
    Given a user is authenticated as "market_user" for market "DE"
    And campaigns exist assigned to market "FR"
    When the user requests campaigns for market "FR"
    Then the action is denied with status code 403
    And no campaign data is returned

  @regression @JSN-016
  Scenario: EPAM admin can view all submitted briefs
    Given a user is authenticated as "epam_admin"
    And briefs exist for markets "DE", "FR", and "IT"
    When the user requests all submitted briefs
    Then the action is permitted
    And briefs from all markets are returned

  @regression @JSN-016
  Scenario: Regional SPOC can view briefs within their region
    Given a user is authenticated as "regional_spoc" for region "EU"
    And briefs exist for markets "DE" (EU) and "JP" (AP)
    When the user requests submitted briefs
    Then the action is permitted
    And only briefs from EU markets are returned

  # ============================================================================
  # PERMISSION CHECKS
  # ============================================================================

  @regression @JSN-015
  Scenario: User with pipeline_create permission can create pipelines
    Given a user is authenticated with permission "pipeline_create"
    When the user attempts to create a new pipeline
    Then the action is permitted
    And the pipeline is created successfully

  @regression @JSN-015
  Scenario: User without pipeline_create permission cannot create pipelines
    Given a user is authenticated without permission "pipeline_create"
    When the user attempts to create a new pipeline
    Then the action is denied with status code 403
    And the error message is "Missing required permission: pipeline_create"

  @regression @JSN-015
  Scenario: User with brief_submit permission can submit briefs
    Given a user is authenticated with permission "brief_submit"
    And a draft brief exists for the user's market
    When the user attempts to submit the brief
    Then the action is permitted
    And the brief status changes to "Submitted"

  @regression @JSN-015
  Scenario: User without brief_submit permission cannot submit briefs
    Given a user is authenticated without permission "brief_submit"
    And a draft brief exists
    When the user attempts to submit the brief
    Then the action is denied with status code 403
    And the brief status remains "Draft"

  # ============================================================================
  # TOKEN VALIDATION
  # ============================================================================

  @regression @JSN-014
  Scenario: Valid JWT token is accepted
    Given a user has a valid SIGA JWT token
    And the token expiry is in the future
    When the user makes an API request with the token
    Then the token is validated successfully
    And the request is processed

  @regression @JSN-014
  Scenario: Expired JWT token is rejected
    Given a user has an expired SIGA JWT token
    When the user makes an API request with the token
    Then the token validation fails
    And the response status code is 401
    And the error message is "Token has expired"

  @regression @JSN-014
  Scenario: Malformed JWT token is rejected
    Given a user has a malformed JWT token
    When the user makes an API request with the token
    Then the token validation fails
    And the response status code is 401
    And the error message is "Invalid token format"

  @regression @JSN-014
  Scenario: Missing JWT token is rejected
    Given a user makes an API request without a token
    When the request is processed
    Then authentication fails
    And the response status code is 401
    And the error message is "Authentication token required"

  # ============================================================================
  # SESSION MANAGEMENT
  # ============================================================================

  @regression @JSN-014
  Scenario: User session contains correct role information
    Given a user authenticates with SIGA role "market_user"
    When the authentication is successful
    Then the user session contains role "market_user"
    And the session contains the user's market assignment
    And the session contains the user's permissions list

  @regression @JSN-014
  Scenario: User session expires after token expiry
    Given a user is authenticated with a token expiring in 1 hour
    When 61 minutes have passed
    And the user makes an API request
    Then the session is invalid
    And the response status code is 401
    And the user must re-authenticate

  # ============================================================================
  # UNAUTHORIZED ACCESS SCENARIOS
  # ============================================================================

  @regression @JSN-015
  Scenario: Unauthenticated user cannot access pipeline list
    Given a user is not authenticated
    When the user attempts to view the pipeline list
    Then the action is denied with status code 401
    And the error message is "Authentication required"

  @regression @JSN-015
  Scenario: Unauthenticated user cannot create briefs
    Given a user is not authenticated
    When the user attempts to create a brief
    Then the action is denied with status code 401
    And the error message is "Authentication required"

  @regression @JSN-015
  Scenario: User with expired session cannot submit briefs
    Given a user was authenticated but the session has expired
    And a draft brief exists
    When the user attempts to submit the brief
    Then the action is denied with status code 401
    And the error message is "Session expired, please re-authenticate"

  # ============================================================================
  # ROLE CACHING
  # ============================================================================

  @regression @JSN-026
  Scenario: User roles are cached for performance
    Given a user authenticates successfully
    When SIGA returns the user's roles
    Then the roles are cached for 15 minutes
    And subsequent requests use the cached roles
    And no additional SIGA API calls are made within the cache period

  @regression @JSN-026
  Scenario: Cached roles expire after TTL
    Given a user's roles are cached
    And 16 minutes have passed since caching
    When the user makes an API request
    Then the roles are fetched from SIGA again
    And the cache is refreshed with new role data

  # ============================================================================
  # ERROR SCENARIOS
  # ============================================================================

  @regression @error-handling
  Scenario: SIGA service unavailable during authentication
    Given the SIGA RBAC system is unavailable
    When a user attempts to authenticate
    Then the authentication fails gracefully
    And the response status code is 502
    And the error message is "Authentication service temporarily unavailable"
    And the error is logged for monitoring

  @regression @error-handling
  Scenario: SIGA service timeout during role validation
    Given the SIGA RBAC system is slow to respond
    When a user's roles are being validated
    And the SIGA API does not respond within 5 seconds
    Then the request times out
    And the response status code is 504
    And the error message is "Authentication service timeout"

  @regression @error-handling
  Scenario: SIGA returns invalid role data
    Given a user authenticates successfully
    When SIGA returns malformed role data
    Then the authentication fails
    And the response status code is 502
    And the error message is "Invalid authentication response"
    And the error is logged with full details

  # ============================================================================
  # NFR SCENARIOS
  # ============================================================================

  @nfr @performance
  Scenario: Authentication completes within acceptable time
    Given a user has valid SIGA credentials
    When the user authenticates
    Then the authentication completes within 2 seconds
    And the JWT token is returned

  @nfr @performance
  Scenario: Role validation uses cached data for performance
    Given 50 concurrent users are authenticated
    And their roles are cached
    When all users make simultaneous API requests
    Then role validation completes within 100ms per request
    And SIGA API is not called for cached roles

  @nfr @security
  Scenario: Failed authentication attempts are logged
    Given a user attempts to authenticate with invalid credentials
    When the authentication fails
    Then the failed attempt is logged with timestamp and user identifier
    And the log entry includes the failure reason
    And no sensitive data is logged

  @nfr @security
  Scenario: Successful authentication is audited
    Given a user authenticates successfully
    When the authentication completes
    Then an audit log entry is created
    And the entry contains user ID, timestamp, and IP address
    And the entry contains the assigned role
