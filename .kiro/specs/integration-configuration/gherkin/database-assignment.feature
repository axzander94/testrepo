@integration-configuration @database-assignment @mvp3
Feature: Database Assignment to Markets
  As an integration administrator
  I want to assign and unassign databases to specific markets
  So that each market can use appropriate PMI databases for their campaigns

  Background:
    Given the user "admin@justscan.com" has IntegrationAdmin role
    And the user is logged into backoffice
    And the following integrations exist:
      | Id                                   | Name          | DatabaseType |
      | 550e8400-e29b-41d4-a716-446655440000 | PMI-DB-UK-001 | PMI_TYPE_A   |
      | 660e8400-e29b-41d4-a716-446655440001 | PMI-DB-DE-001 | PMI_TYPE_A   |
      | 770e8400-e29b-41d4-a716-446655440002 | PMI-DB-JP-001 | PMI_TYPE_C   |
    And the following markets exist:
      | MarketCode | Name           |
      | UK         | United Kingdom |
      | IE         | Ireland        |
      | DE         | Germany        |
      | JP         | Japan          |
      | AU         | Australia      |

  # Happy Path Scenarios

  Scenario: Assign database to a single market
    Given integration "PMI-DB-UK-001" is not assigned to any market
    And the user is on the database assignment page
    When they select integration "PMI-DB-UK-001"
    And they select market "UK"
    And they click "Assign Database"
    Then they should see confirmation dialog "Assign PMI-DB-UK-001 to UK market?"
    When they confirm the assignment
    Then the database should be assigned to market "UK"
    And they should see success message "Database assigned to UK successfully"
    And an audit log entry should be created
    And the assignment timestamp should be recorded

  Scenario: Assign database to multiple markets
    Given integration "PMI-DB-UK-001" is not assigned to any market
    When the user assigns it to market "UK"
    And they assign it to market "IE"
    Then the database should be assigned to both markets
    And each market should have independent endpoint configurations
    And 2 separate audit log entries should be created

  Scenario: View markets assigned to a database
    Given integration "PMI-DB-UK-001" is assigned to markets:
      | Market | AssignedAt           | AssignedBy         |
      | UK     | 2024-01-15T10:30:00Z | admin@justscan.com |
      | IE     | 2024-02-20T14:15:00Z | admin@justscan.com |
    When the user views the integration detail page
    Then they should see "Assigned to 2 markets"
    And they should see a list containing "UK" and "IE"
    And each market should show assignment date and user

  # Unassignment with Safety Checks

  Scenario: Unassign database from market with no active campaigns
    Given integration "PMI-DB-UK-001" is assigned to market "UK"
    And there are no active campaigns using this integration in "UK"
    When the user clicks "Unassign" for market "UK"
    Then they should see confirmation dialog "Unassign PMI-DB-UK-001 from UK market?"
    When they confirm
    Then the database should be unassigned from market "UK"
    And they should see success message "Database unassigned from UK successfully"
    And an audit log entry should be created

  Scenario: Block unassignment when active campaigns exist
    Given integration "PMI-DB-UK-001" is assigned to market "UK"
    And there are 3 active campaigns using this integration in "UK":
      | CampaignId | CampaignName        | Status    | StartDate  | EndDate    |
      | CAMP-001   | Summer Promo 2024   | Published | 2024-06-01 | 2024-08-31 |
      | CAMP-002   | Welcome Campaign    | Published | 2024-01-01 | 2024-12-31 |
      | CAMP-003   | Holiday Special     | Published | 2024-12-01 | 2024-12-25 |
    When the user attempts to unassign the database from market "UK"
    Then they should see an error dialog "Cannot unassign: 3 active campaigns depend on this database"
    And the dialog should list the affected campaigns
    And the dialog should show campaign names, IDs, and end dates
    And the unassignment should be blocked
    And no audit log entry should be created

  Scenario: Safety check shows campaign details
    Given integration "PMI-DB-UK-001" is assigned to market "UK"
    And there are active campaigns using this integration
    When the user attempts to unassign the database
    Then the error dialog should display:
      | Field        | Value                                           |
      | Title        | Cannot Unassign Database                        |
      | Message      | 3 active campaigns depend on this database      |
      | Campaign 1   | Summer Promo 2024 (CAMP-001) - Ends 31 Aug 2024 |
      | Campaign 2   | Welcome Campaign (CAMP-002) - Ends 31 Dec 2024  |
      | Campaign 3   | Holiday Special (CAMP-003) - Ends 25 Dec 2024   |
      | Action       | Please end these campaigns before unassigning   |

  Scenario: Unassignment allowed after campaigns end
    Given integration "PMI-DB-UK-001" is assigned to market "UK"
    And there were 3 active campaigns that have now ended
    When the user attempts to unassign the database
    Then the safety check should pass
    And they should see standard confirmation dialog
    And the unassignment should proceed successfully

  # Bulk Assignment Scenarios

  Scenario: Bulk assign database to multiple markets
    Given integration "PMI-DB-UK-001" is not assigned to any market
    And the user is on the bulk assignment page
    When they select integration "PMI-DB-UK-001"
    And they select markets "UK", "IE", and "AU"
    And they click "Bulk Assign"
    Then they should see confirmation dialog "Assign PMI-DB-UK-001 to 3 markets?"
    When they confirm
    Then the database should be assigned to all 3 markets
    And they should see success message "Database assigned to 3 markets successfully"
    And 3 separate audit log entries should be created

  Scenario: Bulk assignment with partial failure
    Given the user attempts to bulk assign "PMI-DB-UK-001" to 5 markets
    And market "UK" assignment succeeds
    And market "IE" assignment succeeds
    And market "DE" assignment fails due to validation error
    And market "JP" assignment succeeds
    And market "AU" assignment fails due to network error
    When the bulk operation completes
    Then they should see summary "3 of 5 assignments successful"
    And they should see detailed results:
      | Market | Status  | Message                    |
      | UK     | Success | Assigned successfully      |
      | IE     | Success | Assigned successfully      |
      | DE     | Failed  | Validation error: ...      |
      | JP     | Success | Assigned successfully      |
      | AU     | Failed  | Network error: ...         |
    And 3 audit log entries should be created for successful assignments

  Scenario: Bulk unassignment with safety checks
    Given integration "PMI-DB-UK-001" is assigned to markets "UK", "IE", "DE"
    And market "UK" has 2 active campaigns
    And markets "IE" and "DE" have no active campaigns
    When the user attempts to bulk unassign from all 3 markets
    Then they should see warning "Cannot unassign from UK: 2 active campaigns"
    And they should see option "Unassign from IE and DE only"
    When they proceed with partial unassignment
    Then the database should be unassigned from "IE" and "DE"
    And the database should remain assigned to "UK"
    And they should see message "Unassigned from 2 of 3 markets. UK skipped due to active campaigns."

  # Assignment Validation Scenarios

  Scenario: Prevent duplicate assignment
    Given integration "PMI-DB-UK-001" is already assigned to market "UK"
    When the user attempts to assign it to "UK" again
    Then they should see validation error "Database is already assigned to UK market"
    And the assignment should be blocked
    And no API call should be made

  Scenario: Validate market exists before assignment
    Given the user attempts to assign a database to market "INVALID"
    When the assignment is submitted
    Then they should see validation error "Market INVALID does not exist"
    And the assignment should be blocked

  Scenario: Validate integration exists before assignment
    Given the user attempts to assign non-existent integration
    When the assignment is submitted
    Then they should receive a 404 Not Found response
    And they should see error message "Integration not found"

  # Confirmation Dialog Scenarios

  Scenario: Assignment confirmation shows impact
    Given the user attempts to assign "PMI-DB-UK-001" to market "UK"
    When the confirmation dialog appears
    Then it should display "Assign PMI-DB-UK-001 to UK market?"
    And it should show "This database will be available for UK campaigns"
    And it should show "Default endpoint configuration will be applied"
    And it should have "Cancel" and "Confirm" buttons

  Scenario: Unassignment confirmation shows warning
    Given the user attempts to unassign database from market "UK"
    And there are no active campaigns
    When the confirmation dialog appears
    Then it should display "Unassign PMI-DB-UK-001 from UK market?"
    And it should show warning "UK campaigns will no longer be able to use this database"
    And it should show "This action can be reversed by reassigning"
    And it should have "Cancel" and "Confirm" buttons

  # Audit Logging Scenarios

  @audit
  Scenario: Database assignment is logged in audit trail
    Given the user assigns "PMI-DB-UK-001" to market "UK"
    When the assignment completes
    Then an audit log entry should be created with:
      | Field      | Value                                |
      | Action     | ASSIGN_MARKET                        |
      | EntityType | MarketIntegration                    |
      | EntityId   | market-integration-id                |
      | NewValue   | {"market":"UK","integrationId":"550e8400-e29b-41d4-a716-446655440000"} |
      | UserId     | admin@justscan.com                   |
      | UserRole   | IntegrationAdmin                     |
      | Timestamp  | 2024-12-19T14:22:00Z                 |
    And the audit log should be immutable

  @audit
  Scenario: Database unassignment is logged in audit trail
    Given the user unassigns "PMI-DB-UK-001" from market "UK"
    When the unassignment completes
    Then an audit log entry should be created with:
      | Field      | Value                                |
      | Action     | UNASSIGN_MARKET                      |
      | EntityType | MarketIntegration                    |
      | OldValue   | {"market":"UK","integrationId":"550e8400-e29b-41d4-a716-446655440000","isActive":true} |
      | NewValue   | {"market":"UK","integrationId":"550e8400-e29b-41d4-a716-446655440000","isActive":false} |
      | UserId     | admin@justscan.com                   |

  @audit
  Scenario: Blocked unassignment attempt is logged
    Given the user attempts to unassign database with active campaigns
    When the safety check blocks the operation
    Then an audit log entry should be created with action "UNASSIGN_MARKET_BLOCKED"
    And the log should include reason "Active campaigns exist"
    And the log should include count of active campaigns

  # UI/UX Scenarios

  Scenario: Drag-and-drop interface for assignment
    Given the user is on the database assignment page
    And they see a list of unassigned databases on the left
    And they see a list of markets on the right
    When they drag "PMI-DB-UK-001" to market "UK"
    Then they should see visual feedback during drag
    And they should see confirmation dialog on drop
    When they confirm
    Then the assignment should be created

  Scenario: Visual indicators for assignment status
    Given the user is viewing the database assignment page
    When they see integration "PMI-DB-UK-001"
    Then assigned markets should have a green checkmark
    And unassigned markets should have a grey circle
    And markets with active campaigns should have a lock icon

  Scenario: Filter markets by assignment status
    Given the user is on the database assignment page
    When they select filter "Assigned Markets Only"
    Then they should see only markets where the database is assigned
    When they select filter "Unassigned Markets Only"
    Then they should see only markets where the database is not assigned

  # Market Selector Scenarios

  Scenario: Market selector shows all available markets
    Given the user opens the market selector
    When the selector loads
    Then they should see all 5 markets listed
    And each market should show code and name
    And markets should be sorted alphabetically by code

  Scenario: Multi-select markets for bulk assignment
    Given the user opens the market selector for bulk assignment
    When they select "UK", "IE", and "DE" using checkboxes
    Then the selected count should show "3 markets selected"
    And the "Assign" button should be enabled
    And they should be able to deselect markets

  Scenario: Search markets in selector
    Given the user opens the market selector
    And there are 50 markets in the system
    When they type "United" in the search box
    Then they should see only "United Kingdom" and "United States"
    And other markets should be filtered out

  # Concurrent Modification Scenarios

  Scenario: Handle concurrent assignment by multiple users
    Given user "admin1@justscan.com" assigns "PMI-DB-UK-001" to market "UK"
    And user "admin2@justscan.com" simultaneously assigns the same database to "UK"
    When both requests are processed
    Then the first request should succeed
    And the second request should receive a 409 Conflict response
    And the second user should see message "Database already assigned to this market"

  Scenario: Handle concurrent unassignment
    Given integration "PMI-DB-UK-001" is assigned to market "UK"
    And user "admin1@justscan.com" unassigns it
    And user "admin2@justscan.com" simultaneously attempts to unassign it
    When both requests are processed
    Then the first request should succeed
    And the second request should receive a 404 Not Found response
    And the second user should see message "Assignment no longer exists"

  # Error Scenarios

  Scenario: Handle API error during assignment
    Given the user attempts to assign a database to a market
    When the API returns a 500 Internal Server Error
    Then they should see error message "Unable to assign database. Please try again."
    And they should see a "Retry" button
    And the error should be logged to Sentry
    And no audit log entry should be created

  Scenario: Handle network timeout during assignment
    Given the user attempts to assign a database to a market
    When the API request times out after 10 seconds
    Then they should see error message "Request timed out. Please check your connection."
    And they should see a "Retry" button
    And no partial assignment should be created

  # NFR: Performance

  @nfr @performance
  Scenario: Assignment operation completes quickly
    Given the user assigns a database to a market
    When the operation executes
    Then the database update should complete within 1 second
    And the UI should reflect the change immediately
    And the success message should appear within 2 seconds

  @nfr @performance
  Scenario: Bulk assignment completes efficiently
    Given the user bulk assigns a database to 10 markets
    When the operation executes
    Then all assignments should complete within 5 seconds
    And progress should be shown for each market
    And the UI should update as each assignment completes

  @nfr @performance
  Scenario: Safety check query performs efficiently
    Given there are 100 active campaigns in the system
    When the user attempts to unassign a database
    Then the active campaign check should complete within 500ms
    And the result should be cached for 1 minute
    And subsequent checks should use cached data

  # NFR: Usability

  @nfr @usability
  Scenario: Assignment interface is intuitive
    Given a new user accesses the database assignment page
    When they view the interface
    Then the purpose should be immediately clear
    And drag-and-drop targets should be visually distinct
    And helpful tooltips should be available
    And undo functionality should be available for recent assignments

  @nfr @usability
  Scenario: Mobile-friendly assignment interface
    Given the user is on a mobile device
    When they access the database assignment page
    Then drag-and-drop should be replaced with tap-to-select
    And market selector should be a full-screen modal
    And all touch targets should be at least 44x44 pixels

  # NFR: Accessibility

  @nfr @accessibility
  Scenario: Assignment interface is keyboard accessible
    Given the user navigates with keyboard only
    When they access the database assignment page
    Then they should be able to select databases using arrow keys
    And they should be able to select markets using Tab and Enter
    And they should be able to confirm assignments using keyboard
    And focus indicators should be clearly visible

  @nfr @accessibility
  Scenario: Screen reader announces assignment actions
    Given the user is using a screen reader
    When they assign a database to a market
    Then the screen reader should announce "PMI-DB-UK-001 assigned to United Kingdom"
    And confirmation dialogs should be properly announced
    And error messages should be announced immediately

  # Integration with Campaign System

  Scenario: Newly assigned database is available for campaigns
    Given integration "PMI-DB-UK-001" is assigned to market "UK"
    When a content manager creates a new campaign for "UK"
    Then "PMI-DB-UK-001" should appear in the database selection dropdown
    And all enabled endpoints should be available for use
    And the campaign should be able to use the database immediately

  Scenario: Unassigned database is removed from campaign options
    Given integration "PMI-DB-UK-001" was assigned to market "UK"
    And it has been unassigned
    When a content manager creates a new campaign for "UK"
    Then "PMI-DB-UK-001" should not appear in the database selection dropdown
    And existing campaigns using it should continue to work until they end
