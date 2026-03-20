Feature: Campaign Flow Definition
  As a Market user
  I want to visually define the campaign flow
  So that EPAM understands the campaign structure and logic

  Background:
    Given I am authenticated as a Market user
    And I have an active campaign brief with uploaded assets

  Scenario: Create basic campaign flow
    Given I am on the flow definition section
    When I start creating a new flow
    Then I should see a blank canvas
    And I should see available flow components:
      | Component Type |
      | Start Node |
      | Screen |
      | Decision |
      | Action |
      | End Node |

  Scenario: Build linear campaign flow
    Given I am on the flow builder canvas
    When I drag a "Start Node" onto the canvas
    And I connect it to a "Screen" node
    And I configure the screen with:
      | Property | Value |
      | Name | Welcome Screen |
      | Content | Welcome to our campaign |
      | Asset | banner.jpg |
    And I connect the screen to an "End Node"
    And I save the flow
    Then the flow should be saved successfully
    And I should see the flow structure in the summary

  Scenario: Build conditional campaign flow
    Given I am building a campaign flow
    When I create a flow with decision logic:
      | Node Type | Configuration |
      | Start | Entry point |
      | Screen | Age verification |
      | Decision | Age >= 21? |
      | Screen (Yes) | Campaign content |
      | Screen (No) | Age restriction message |
      | End | Exit point |
    And I define the decision conditions
    And I save the flow
    Then the conditional logic should be preserved
    And the flow should validate successfully

  Scenario: Validate flow completeness
    Given I am creating a campaign flow
    When I create a flow with missing connections
    And I try to save the flow
    Then I should see validation errors:
      | Error Type |
      | Disconnected nodes |
      | Missing end nodes |
      | Invalid connections |
    And the save should be prevented until errors are fixed

  Scenario: Use assets in flow nodes
    Given I have uploaded campaign assets
    And I am building a campaign flow
    When I add a "Screen" node
    And I configure it to use asset "video.mp4"
    Then the asset should be linked to the node
    And I should see the asset preview in the node configuration
    When I save the flow
    Then the asset-node relationship should be preserved

  Scenario: Flow versioning and history
    Given I have created and saved a campaign flow
    When I make changes to the flow structure
    And I save the updated flow
    Then a new version should be created
    And I should be able to view flow history
    And I should be able to revert to previous versions if needed

  Scenario: Export flow definition
    Given I have completed a campaign flow
    When I click "Export Flow"
    Then I should be able to download the flow as:
      | Format |
      | JSON |
      | PDF diagram |
      | PNG image |
    And the export should include all node configurations and connections