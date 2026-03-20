@integration-configuration @integration-list @mvp1
Feature: Integration List Management
  As a content manager with integration permissions
  I want to view all integrations with market filtering
  So that I can quickly find and manage relevant database integrations

  Background:
    Given the user "admin@justscan.com" has IntegrationAdmin role
    And the user is logged into backoffice
    And the following integrations exist:
      | Name           | Market | DatabaseType  | Status | Endpoints                      |
      | PMI-DB-UK-001  | UK     | PMI_TYPE_A    | Active | sendOTP, lastName, firstName   |
      | PMI-DB-UK-002  | UK     | PMI_TYPE_B    | Active | sendOTP, lastName              |
      | PMI-DB-DE-001  | DE     | PMI_TYPE_A    | Active | sendOTP, firstName             |
      | PMI-DB-JP-001  | JP     | PMI_TYPE_C    | Inactive | sendOTP, lastName, firstName |
      | PMI-DB-AU-001  | AU     | PMI_TYPE_A    | Active | sendOTP                        |

  # Happy Path Scenarios

  Scenario: View all integrations without filter
    Given the user navigates to "/integrations"
    When the integration list page loads
    Then they should see 5 integrations displayed
    And each integration card should show name, market, status, and endpoint count
    And integrations should be sorted by market code alphabetically

  Scenario: Filter integrations by single market
    Given the user is on the integration list page
    When they select "UK" from the market filter dropdown
    Then they should see 2 integrations displayed
    And all displayed integrations should have market "UK"
    And the filter should show "UK" as selected

  Scenario: View integration status indicators
    Given the user is on the integration list page
    When they view the integration cards
    Then "PMI-DB-UK-001" should display a green "Active" badge
    And "PMI-DB-JP-001" should display a grey "Inactive" badge
    And each card should show the number of enabled endpoints

  # Market Filtering Scenarios

  Scenario: Filter integrations by multiple markets
    Given the user is on the integration list page
    When they select "UK" and "DE" from the market filter
    Then they should see 3 integrations displayed
    And displayed integrations should only be from "UK" or "DE" markets

  Scenario: Clear market filter to show all integrations
    Given the user has filtered integrations by "UK" market
    And they see 2 integrations
    When they click "Clear Filter" button
    Then they should see all 5 integrations
    And the market filter should show "All Markets"

  Scenario: Market filter persists across page navigation
    Given the user has filtered integrations by "DE" market
    When they navigate to integration detail page
    And they return to the integration list page
    Then the "DE" market filter should still be applied
    And they should see only 1 integration

  # Pagination Scenarios

  Scenario: Pagination displays when more than 50 integrations exist
    Given there are 75 integrations in the system
    When the user navigates to the integration list page
    Then they should see 50 integrations on page 1
    And pagination controls should be visible
    And page indicator should show "Page 1 of 2"

  Scenario: Navigate to next page of integrations
    Given there are 75 integrations in the system
    And the user is on page 1 of the integration list
    When they click "Next Page" button
    Then they should see 25 integrations on page 2
    And page indicator should show "Page 2 of 2"
    And "Previous Page" button should be enabled

  Scenario: Pagination resets when filter is applied
    Given there are 75 integrations in the system
    And the user is on page 2 of the integration list
    When they apply a market filter for "UK"
    Then they should be on page 1 of filtered results
    And pagination should reflect the filtered count

  # Empty State Scenarios

  Scenario: Display empty state when no integrations exist
    Given there are no integrations in the system
    When the user navigates to "/integrations"
    Then they should see an empty state message "No integrations configured"
    And they should see a "Contact Administrator" button
    And no integration cards should be displayed

  Scenario: Display empty state when filter returns no results
    Given the user is on the integration list page
    When they filter by market "US"
    And no integrations exist for "US" market
    Then they should see a message "No integrations found for US market"
    And they should see a "Clear Filter" button
    And the market filter should remain set to "US"

  # Loading State Scenarios

  @nfr @performance
  Scenario: Display loading indicator while fetching integrations
    Given the user navigates to "/integrations"
    When the API request is in progress
    Then they should see a loading spinner
    And no integration cards should be displayed yet
    And the page should not be interactive

  @nfr @performance
  Scenario: Integration list loads within performance target
    Given there are 100 integrations in the system
    When the user navigates to "/integrations"
    Then the integration list should load within 2 seconds
    And all integration cards should be rendered
    And status indicators should be visible

  # Endpoint Status Display Scenarios

  Scenario: Display endpoint count per integration
    Given the user is on the integration list page
    When they view integration "PMI-DB-UK-001"
    Then the card should show "3 endpoints configured"
    And the card should show "3 enabled" in green

  Scenario: Display mixed endpoint states
    Given integration "PMI-DB-UK-001" has endpoints:
      | Endpoint  | Enabled |
      | sendOTP   | true    |
      | lastName  | false   |
      | firstName | true    |
    When the user views the integration card
    Then it should show "2 of 3 endpoints enabled"
    And the status should be displayed in amber color

  # Search and Sort Scenarios

  Scenario: Search integrations by name
    Given the user is on the integration list page
    When they enter "UK" in the search box
    Then they should see 2 integrations matching "UK"
    And non-matching integrations should be hidden
    And the search term should be highlighted in results

  Scenario: Sort integrations by name ascending
    Given the user is on the integration list page
    When they click the "Name" column header
    Then integrations should be sorted alphabetically by name
    And "PMI-DB-AU-001" should appear first
    And "PMI-DB-UK-002" should appear last

  Scenario: Sort integrations by status
    Given the user is on the integration list page
    When they click the "Status" column header
    Then active integrations should appear before inactive ones
    And within each status group, integrations should be sorted by name

  # Responsive Design Scenarios

  @nfr @usability
  Scenario: Integration list displays correctly on tablet
    Given the user is viewing the page on a tablet device
    When they navigate to "/integrations"
    Then integration cards should display in 2 columns
    And all card information should be readable
    And touch targets should be at least 44x44 pixels

  @nfr @usability
  Scenario: Integration list displays correctly on mobile
    Given the user is viewing the page on a mobile device
    When they navigate to "/integrations"
    Then integration cards should display in 1 column
    And market filter should be a full-width dropdown
    And cards should be scrollable vertically

  # Error Scenarios

  Scenario: Handle API error gracefully
    Given the user navigates to "/integrations"
    When the API returns a 500 Internal Server Error
    Then they should see an error message "Unable to load integrations. Please try again."
    And they should see a "Retry" button
    And the error should be logged to Sentry

  Scenario: Handle network timeout gracefully
    Given the user navigates to "/integrations"
    When the API request times out after 10 seconds
    Then they should see an error message "Request timed out. Please check your connection."
    And they should see a "Retry" button
    And no partial data should be displayed

  # Refresh and Real-Time Updates

  Scenario: Manual refresh reloads integration list
    Given the user is on the integration list page
    When they click the "Refresh" button
    Then the integration list should reload
    And any changes made by other users should be visible
    And the current filter and sort settings should be preserved

  Scenario: Integration status updates reflect immediately after toggle
    Given the user is viewing the integration list
    And another admin toggles an endpoint for "PMI-DB-UK-001"
    When the user refreshes the page
    Then the updated endpoint count should be displayed
    And the status indicator should reflect the new state

  # Accessibility Scenarios

  @nfr @accessibility
  Scenario: Integration list is keyboard navigable
    Given the user is on the integration list page
    When they navigate using Tab key
    Then focus should move through filter, search, and integration cards in logical order
    And focused elements should have visible focus indicators
    And they should be able to activate cards using Enter key

  @nfr @accessibility
  Scenario: Screen reader announces integration information
    Given the user is using a screen reader
    When they navigate to an integration card
    Then the screen reader should announce name, market, status, and endpoint count
    And status badges should have appropriate ARIA labels
    And the page should have proper heading hierarchy
