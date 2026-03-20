@justbrief @pipeline-visibility
Feature: Campaign Pipeline Visibility for Market Users
  As a Market user
  I want to view campaigns available to my market
  So that I can select a campaign and submit a brief

  Background:
    Given the JustBrief platform is running
    And the user is authenticated via SIGA

  # ============================================================================
  # HAPPY PATH SCENARIOS
  # ============================================================================

  @smoke @JSN-005
  Scenario: Market user views campaigns assigned to their market
    Given the user has role "market_user" for market "DE"
    And the following pipelines exist:
      | Name         | Status | Assigned Markets |
      | Campaign A   | Active | DE, FR           |
      | Campaign B   | Active | IT, ES           |
      | Campaign C   | Active | DE               |
    When the user views available campaigns
    Then the user sees campaigns "Campaign A" and "Campaign C"
    And the user does not see campaign "Campaign B"
    And each campaign shows its name, description, and dates

  @smoke @JSN-005
  Scenario: Market user views only Active campaigns
    Given the user has role "market_user" for market "DE"
    And the following pipelines exist for market "DE":
      | Name       | Status    |
      | Campaign A | Active    |
      | Campaign B | Draft     |
      | Campaign C | Cancelled |
      | Campaign D | Completed |
    When the user views available campaigns
    Then the user sees only "Campaign A"
    And campaigns with other statuses are not displayed

  @smoke @JSN-006
  Scenario: Market user selects a campaign to start briefing
    Given the user has role "market_user" for market "DE"
    And an active pipeline "Summer Engagement 2026" is assigned to market "DE"
    When the user selects the campaign "Summer Engagement 2026"
    Then the briefing interface opens
    And the campaign context is pre-populated
    And the campaign name is displayed in the brief form
    And the pipeline ID is associated with the new brief

  # ============================================================================
  # MARKET SCOPING
  # ============================================================================

  @regression @JSN-005
  Scenario: Market user from DE sees only DE-assigned campaigns
    Given the user has role "market_user" for market "DE"
    And pipelines exist assigned to markets "DE", "FR", "IT"
    When the user views available campaigns
    Then only campaigns assigned to market "DE" are visible
    And the campaign count reflects only DE campaigns

  @regression @JSN-005
  Scenario: Market user from FR sees only FR-assigned campaigns
    Given the user has role "market_user" for market "FR"
    And pipelines exist assigned to markets "DE", "FR", "IT"
    When the user views available campaigns
    Then only campaigns assigned to market "FR" are visible
    And campaigns from other markets are not accessible

  @regression @JSN-005
  Scenario: Market user sees global campaigns
    Given the user has role "market_user" for market "DE"
    And a global pipeline exists with status "Active"
    And market-specific pipelines exist for market "DE"
    When the user views available campaigns
    Then the user sees both global and DE-specific campaigns
    And global campaigns are marked as "Global"

  @regression @JSN-005
  Scenario: Market user with multiple market assignments sees all assigned campaigns
    Given the user has role "market_user" for markets "DE" and "FR"
    And pipelines exist assigned to markets "DE", "FR", "IT"
    When the user views available campaigns
    Then the user sees campaigns from both "DE" and "FR"
    And the user does not see campaigns from "IT"

  # ============================================================================
  # CAMPAIGN FILTERING
  # ============================================================================

  @regression @JSN-005
  Scenario: Market user filters campaigns by campaign type
    Given the user has role "market_user" for market "DE"
    And the following campaigns exist for market "DE":
      | Name       | Campaign Type |
      | Campaign A | Instant Win   |
      | Campaign B | Multi-Channel |
      | Campaign C | Instant Win   |
    When the user filters by campaign type "Instant Win"
    Then the user sees campaigns "Campaign A" and "Campaign C"
    And campaign "Campaign B" is not displayed

  @regression @JSN-005
  Scenario: Market user filters campaigns by date range
    Given the user has role "market_user" for market "DE"
    And the following campaigns exist for market "DE":
      | Name       | Start Date | End Date   |
      | Campaign A | 2026-07-01 | 2026-09-30 |
      | Campaign B | 2026-10-01 | 2026-12-31 |
      | Campaign C | 2026-07-15 | 2026-08-31 |
    When the user filters campaigns starting in "July 2026"
    Then the user sees campaigns "Campaign A" and "Campaign C"
    And campaign "Campaign B" is not displayed

  @regression @JSN-005
  Scenario: Market user searches campaigns by name
    Given the user has role "market_user" for market "DE"
    And campaigns exist with names "Summer Engagement", "Winter Promo", "Summer Sale"
    When the user searches for "Summer"
    Then the user sees campaigns "Summer Engagement" and "Summer Sale"
    And campaign "Winter Promo" is not displayed

  # ============================================================================
  # CAMPAIGN DETAILS
  # ============================================================================

  @regression @JSN-006
  Scenario: Market user views campaign details before selection
    Given the user has role "market_user" for market "DE"
    And an active campaign "Summer Engagement 2026" exists for market "DE"
    When the user views the campaign details
    Then the following information is displayed:
      | Field          | Value                          |
      | Name           | Summer Engagement 2026         |
      | Description    | Q3 consumer engagement campaign|
      | Campaign Type  | Instant Win                    |
      | Start Date     | 2026-07-01                     |
      | End Date       | 2026-09-30                     |
      | Assigned Markets | DE, FR, IT                   |

  @regression @JSN-006
  Scenario: Market user sees if they have already submitted a brief for a campaign
    Given the user has role "market_user" for market "DE"
    And an active campaign "Summer Engagement 2026" exists for market "DE"
    And the user has already submitted a brief for this campaign
    When the user views available campaigns
    Then the campaign "Summer Engagement 2026" is marked as "Brief Submitted"
    And the submission date is displayed
    And the brief status is shown

  @regression @JSN-006
  Scenario: Market user sees if a draft brief exists for a campaign
    Given the user has role "market_user" for market "DE"
    And an active campaign "Summer Engagement 2026" exists for market "DE"
    And the user has a draft brief for this campaign
    When the user views available campaigns
    Then the campaign "Summer Engagement 2026" is marked as "Draft in Progress"
    And a "Continue Draft" button is displayed

  # ============================================================================
  # CAMPAIGN SELECTION
  # ============================================================================

  @smoke @JSN-006
  Scenario: Market user starts a new brief from campaign selection
    Given the user has role "market_user" for market "DE"
    And an active campaign "Summer Engagement 2026" exists for market "DE"
    And no brief exists for this campaign and market
    When the user clicks "Start Brief" for the campaign
    Then a new draft brief is created
    And the brief is linked to the pipeline
    And the brief is linked to market "DE"
    And the user is redirected to the brief form

  @regression @JSN-006
  Scenario: Market user continues an existing draft brief
    Given the user has role "market_user" for market "DE"
    And an active campaign "Summer Engagement 2026" exists for market "DE"
    And a draft brief exists for this campaign and market
    When the user clicks "Continue Draft" for the campaign
    Then the existing draft brief is loaded
    And the user is redirected to the brief form
    And previously entered data is pre-populated

  @regression @JSN-006
  Scenario: Market user cannot start a new brief if one is already submitted
    Given the user has role "market_user" for market "DE"
    And an active campaign "Summer Engagement 2026" exists for market "DE"
    And a submitted brief exists for this campaign and market
    When the user attempts to start a new brief for the campaign
    Then the action is prevented
    And the message is "A brief has already been submitted for this campaign"
    And the user can view the submitted brief

  # ============================================================================
  # EMPTY STATES
  # ============================================================================

  @regression @JSN-005
  Scenario: Market user sees message when no campaigns are available
    Given the user has role "market_user" for market "DE"
    And no active campaigns are assigned to market "DE"
    When the user views available campaigns
    Then the message "No campaigns available for your market" is displayed
    And guidance text suggests checking back later

  @regression @JSN-005
  Scenario: Market user sees message when all campaigns have been briefed
    Given the user has role "market_user" for market "DE"
    And active campaigns exist for market "DE"
    And the user has submitted briefs for all available campaigns
    When the user views available campaigns
    Then the message "You have submitted briefs for all available campaigns" is displayed
    And the list shows all campaigns with "Brief Submitted" status

  # ============================================================================
  # SORTING AND PAGINATION
  # ============================================================================

  @regression @JSN-005
  Scenario: Market user sorts campaigns by start date
    Given the user has role "market_user" for market "DE"
    And multiple campaigns exist for market "DE" with different start dates
    When the user sorts campaigns by "Start Date Ascending"
    Then campaigns are displayed in chronological order by start date

  @regression @JSN-005
  Scenario: Market user sorts campaigns by name
    Given the user has role "market_user" for market "DE"
    And multiple campaigns exist for market "DE"
    When the user sorts campaigns by "Name A-Z"
    Then campaigns are displayed in alphabetical order

  @regression @JSN-005
  Scenario: Campaign list is paginated when many campaigns exist
    Given the user has role "market_user" for market "DE"
    And 50 active campaigns exist for market "DE"
    When the user views available campaigns
    Then 20 campaigns are displayed per page
    And pagination controls are shown
    And the user can navigate to additional pages

  # ============================================================================
  # VALIDATION SCENARIOS
  # ============================================================================

  @regression @JSN-005
  Scenario: Market user cannot access campaigns from unauthorized markets
    Given the user has role "market_user" for market "DE"
    And a campaign exists assigned to market "FR" only
    When the user attempts to access the campaign directly via URL
    Then the access is denied with status code 403
    And the error message is "Campaign not available for your market"

  @regression @JSN-006
  Scenario: Market user cannot select a cancelled campaign
    Given the user has role "market_user" for market "DE"
    And a campaign exists with status "Cancelled" for market "DE"
    When the user attempts to select the campaign
    Then the selection is prevented
    And the message is "This campaign is no longer available"

  @regression @JSN-006
  Scenario: Market user cannot select a completed campaign
    Given the user has role "market_user" for market "DE"
    And a campaign exists with status "Completed" for market "DE"
    When the user attempts to select the campaign
    Then the selection is prevented
    And the message is "This campaign has ended"

  # ============================================================================
  # REAL-TIME UPDATES
  # ============================================================================

  @regression @JSN-005
  Scenario: Campaign list updates when new campaigns are assigned
    Given the user has role "market_user" for market "DE"
    And the user is viewing available campaigns
    When a Regional SPOC assigns a new campaign to market "DE"
    And the user refreshes the campaign list
    Then the new campaign appears in the list

  @regression @JSN-005
  Scenario: Campaign disappears when status changes to Cancelled
    Given the user has role "market_user" for market "DE"
    And the user is viewing available campaigns
    And a campaign "Summer Engagement 2026" is displayed
    When a Regional SPOC changes the campaign status to "Cancelled"
    And the user refreshes the campaign list
    Then the campaign "Summer Engagement 2026" is no longer displayed

  # ============================================================================
  # ERROR SCENARIOS
  # ============================================================================

  @regression @error-handling
  Scenario: Database unavailable when loading campaigns
    Given the user has role "market_user" for market "DE"
    And the PMI database is unavailable
    When the user attempts to view available campaigns
    Then an error message is displayed
    And the message is "Unable to load campaigns. Please try again later."
    And the error is logged for monitoring

  @regression @error-handling
  Scenario: Network timeout when loading campaigns
    Given the user has role "market_user" for market "DE"
    And the network connection is slow
    When the user views available campaigns
    And the request takes longer than 10 seconds
    Then a timeout error is displayed
    And the user is prompted to retry

  # ============================================================================
  # NFR SCENARIOS
  # ============================================================================

  @nfr @performance
  Scenario: Campaign list loads quickly for market users
    Given the user has role "market_user" for market "DE"
    And 100 campaigns exist in the system
    And 10 campaigns are assigned to market "DE"
    When the user views available campaigns
    Then the campaign list loads within 2 seconds
    And only the 10 DE campaigns are returned

  @nfr @performance
  Scenario: Campaign filtering is responsive
    Given the user has role "market_user" for market "DE"
    And 50 campaigns are displayed
    When the user applies a filter
    Then the filtered results appear within 500ms

  @nfr @usability
  Scenario: Campaign list is mobile-responsive
    Given the user has role "market_user" for market "DE"
    And the user is accessing JustBrief on a mobile device
    When the user views available campaigns
    Then the campaign list is displayed in a mobile-friendly layout
    And all campaign details are readable
    And action buttons are easily tappable

  @nfr @security
  Scenario: Campaign data is not leaked across markets
    Given the user has role "market_user" for market "DE"
    When the user views available campaigns
    Then the API response contains only DE campaigns
    And no data from other markets is included in the response
    And the response is validated for data isolation
