@integration-configuration @integration-detail @mvp1
Feature: Integration Detail View
  As a content manager with integration permissions
  I want to view detailed information about a specific integration
  So that I can understand its configuration and endpoint status

  Background:
    Given the user "admin@justscan.com" has IntegrationAdmin role
    And the user is logged into backoffice
    And the following integration exists:
      | Field          | Value                        |
      | Id             | 550e8400-e29b-41d4-a716-446655440000 |
      | Name           | PMI-DB-UK-001                |
      | Market         | UK                           |
      | DatabaseType   | PMI_TYPE_A                   |
      | Status         | Active                       |
      | Description    | UK primary customer database |
      | CreatedAt      | 2024-01-15T10:30:00Z         |
      | CreatedBy      | admin@justscan.com           |
      | UpdatedAt      | 2024-12-19T14:22:00Z         |
      | UpdatedBy      | admin@justscan.com           |

  # Happy Path Scenarios

  Scenario: View integration detail page
    Given the user is on the integration list page
    When they click on integration "PMI-DB-UK-001"
    Then they should be navigated to "/integrations/550e8400-e29b-41d4-a716-446655440000"
    And they should see the integration name "PMI-DB-UK-001"
    And they should see market "UK"
    And they should see database type "PMI_TYPE_A"
    And they should see status "Active"
    And they should see description "UK primary customer database"

  Scenario: View endpoint status on detail page
    Given integration "PMI-DB-UK-001" has the following endpoints:
      | Endpoint  | Enabled | LastUpdated          | UpdatedBy              |
      | sendOTP   | true    | 2024-12-19T14:22:00Z | admin@justscan.com     |
      | lastName  | true    | 2024-12-19T14:22:00Z | admin@justscan.com     |
      | firstName | false   | 2024-12-18T09:15:00Z | viewer@justscan.com    |
    When the user views the integration detail page
    Then they should see 3 endpoints listed
    And "sendOTP" should show status "Enabled" with green indicator
    And "lastName" should show status "Enabled" with green indicator
    And "firstName" should show status "Disabled" with grey indicator

  Scenario: View integration metadata
    Given the user is on the integration detail page for "PMI-DB-UK-001"
    Then they should see "Created on: 15 Jan 2024 at 10:30 UTC"
    And they should see "Created by: admin@justscan.com"
    And they should see "Last updated: 19 Dec 2024 at 14:22 UTC"
    And they should see "Last updated by: admin@justscan.com"

  # Breadcrumb Navigation Scenarios

  Scenario: Breadcrumb navigation from detail to list
    Given the user is on the integration detail page for "PMI-DB-UK-001"
    When they view the breadcrumb navigation
    Then they should see "Integrations > PMI-DB-UK-001"
    When they click "Integrations" in the breadcrumb
    Then they should be navigated back to "/integrations"
    And the integration list should be displayed

  Scenario: Breadcrumb preserves previous filter state
    Given the user filtered integrations by "UK" market
    And they navigated to detail page for "PMI-DB-UK-001"
    When they click "Integrations" in the breadcrumb
    Then they should return to the integration list
    And the "UK" market filter should still be applied

  # Read-Only Mode for IntegrationViewer

  Scenario: IntegrationViewer sees read-only detail view
    Given a user "viewer@justscan.com" has IntegrationViewer role
    And the user is logged into backoffice
    When they navigate to the integration detail page for "PMI-DB-UK-001"
    Then they should see all integration information
    But "Update Credentials" button should not be visible
    And endpoint toggle switches should be disabled
    And "Test Connection" button should not be visible
    And a message should display "You have read-only access to this integration"

  Scenario: IntegrationAdmin sees full detail view with actions
    Given the user has IntegrationAdmin role
    When they navigate to the integration detail page for "PMI-DB-UK-001"
    Then they should see all integration information
    And "Update Credentials" button should be visible and enabled
    And endpoint toggle switches should be enabled
    And "Test Connection" button should be visible and enabled

  # Endpoint Details Display

  Scenario: View endpoint configuration details
    Given the user is on the integration detail page
    When they expand endpoint "sendOTP" details
    Then they should see endpoint name "sendOTP"
    And they should see endpoint type "API"
    And they should see last updated timestamp
    And they should see who last modified the endpoint

  Scenario: View all endpoints collapsed by default
    Given the user navigates to the integration detail page
    When the page loads
    Then all endpoint detail sections should be collapsed
    And only endpoint names and status should be visible
    And an expand icon should be visible next to each endpoint

  # Credential Information Display

  Scenario: Credential information is masked
    Given the user is on the integration detail page
    When they view the credentials section
    Then they should see "API Key: ••••••••••••••••"
    And they should see "Connection String: ••••••••••••••••"
    And they should see "Last updated: 19 Dec 2024"
    But they should not see actual credential values

  Scenario: Credential section shows update button for admin
    Given the user has IntegrationAdmin role
    And they are on the integration detail page
    When they view the credentials section
    Then they should see an "Update Credentials" button
    And the button should be enabled

  # Market Assignment Display

  Scenario: View markets assigned to integration
    Given integration "PMI-DB-UK-001" is assigned to markets:
      | Market | AssignedAt           | AssignedBy         |
      | UK     | 2024-01-15T10:30:00Z | admin@justscan.com |
      | IE     | 2024-02-20T14:15:00Z | admin@justscan.com |
    When the user views the integration detail page
    Then they should see "Assigned to 2 markets"
    And they should see market "UK" with assignment date
    And they should see market "IE" with assignment date

  # Error Scenarios

  Scenario: Handle integration not found
    Given the user navigates to "/integrations/00000000-0000-0000-0000-000000000000"
    When the integration does not exist
    Then they should see a 404 error page
    And they should see message "Integration not found"
    And they should see a "Back to Integrations" button

  Scenario: Handle API error when loading detail
    Given the user navigates to the integration detail page
    When the API returns a 500 Internal Server Error
    Then they should see an error message "Unable to load integration details"
    And they should see a "Retry" button
    And the error should be logged to Sentry

  # Loading State Scenarios

  @nfr @performance
  Scenario: Display loading state while fetching integration details
    Given the user navigates to the integration detail page
    When the API request is in progress
    Then they should see a loading spinner
    And no integration details should be displayed yet
    And action buttons should be disabled

  @nfr @performance
  Scenario: Integration detail page loads within performance target
    Given the user navigates to the integration detail page
    When the page loads
    Then all integration details should be displayed within 1 second
    And endpoint statuses should be visible
    And all action buttons should be enabled

  # Refresh and Real-Time Updates

  Scenario: Manual refresh reloads integration details
    Given the user is on the integration detail page
    When they click the "Refresh" button
    Then the integration details should reload
    And any changes made by other users should be visible
    And the page should remain on the same integration

  Scenario: Stale data warning after 5 minutes
    Given the user has been viewing the integration detail page for 6 minutes
    When the page detects stale data
    Then they should see a banner "This data may be outdated. Refresh to see latest changes."
    And a "Refresh Now" button should be visible in the banner

  # Audit History Display

  Scenario: View recent audit history on detail page
    Given integration "PMI-DB-UK-001" has recent audit entries:
      | Action             | User               | Timestamp            |
      | UPDATE_CREDENTIALS | admin@justscan.com | 2024-12-19T14:22:00Z |
      | TOGGLE_ENDPOINT    | admin@justscan.com | 2024-12-19T14:20:00Z |
      | ASSIGN_MARKET      | admin@justscan.com | 2024-12-18T09:15:00Z |
    When the user views the integration detail page
    Then they should see "Recent Activity" section
    And they should see the 3 most recent audit entries
    And each entry should show action, user, and timestamp
    And they should see a "View Full Audit Log" link

  # Navigation and URL Handling

  Scenario: Direct URL access to integration detail
    Given the user is logged into backoffice
    When they navigate directly to "/integrations/550e8400-e29b-41d4-a716-446655440000"
    Then the integration detail page should load
    And all integration information should be displayed
    And breadcrumb should show correct navigation path

  Scenario: Browser back button returns to list with preserved state
    Given the user navigated from filtered integration list to detail page
    When they click the browser back button
    Then they should return to the integration list
    And the previous filter state should be restored
    And the scroll position should be preserved

  # Responsive Design Scenarios

  @nfr @usability
  Scenario: Integration detail displays correctly on tablet
    Given the user is viewing the page on a tablet device
    When they navigate to the integration detail page
    Then all sections should be readable and properly formatted
    And action buttons should be appropriately sized for touch
    And endpoint list should be scrollable if needed

  @nfr @usability
  Scenario: Integration detail displays correctly on mobile
    Given the user is viewing the page on a mobile device
    When they navigate to the integration detail page
    Then information should be displayed in a single column
    And sections should stack vertically
    And action buttons should be full-width
    And breadcrumb should be condensed for mobile view

  # Accessibility Scenarios

  @nfr @accessibility
  Scenario: Integration detail page is keyboard navigable
    Given the user is on the integration detail page
    When they navigate using Tab key
    Then focus should move through breadcrumb, sections, and action buttons in logical order
    And focused elements should have visible focus indicators
    And they should be able to activate buttons using Enter key

  @nfr @accessibility
  Scenario: Screen reader announces integration details
    Given the user is using a screen reader
    When they navigate to the integration detail page
    Then the screen reader should announce the integration name as page heading
    And each section should have proper heading hierarchy
    And endpoint statuses should have appropriate ARIA labels
    And masked credentials should announce "credential value hidden"

  # Security Scenarios

  @security
  Scenario: Credential values never exposed in HTML or network responses
    Given the user is on the integration detail page
    When they inspect the page HTML
    Then no actual credential values should be present in the DOM
    And API responses should only contain masked values
    And browser developer tools should not reveal credentials

  @security
  Scenario: Unauthorized user cannot access detail page via direct URL
    Given a user "content_manager@justscan.com" has no integration roles
    When they attempt to navigate to "/integrations/550e8400-e29b-41d4-a716-446655440000"
    Then they should receive a 403 Forbidden response
    And they should see an error message "You do not have permission to view this integration"
