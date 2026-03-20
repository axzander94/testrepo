@justbrief @brief-submission
Feature: Campaign Brief Submission
  As a Market user
  I want to create and submit campaign briefs with structured forms
  So that EPAM can receive complete campaign information for assessment

  Background:
    Given the JustBrief platform is running
    And the user is authenticated via SIGA as "market_user" for market "DE"

  # ============================================================================
  # HAPPY PATH SCENARIOS - Brief Creation
  # ============================================================================

  @smoke @JSN-007 @JSN-010
  Scenario: Market user creates a new campaign brief
    Given an active campaign "Summer Engagement 2026" exists for market "DE"
    When the user creates a new brief for the campaign
    Then a draft brief is created successfully
    And the brief has a unique ID
    And the brief status is "Draft"
    And the brief is linked to the pipeline
    And the brief is linked to market "DE"
    And the created date is recorded

  @smoke @JSN-007
  Scenario: Market user fills mandatory brief fields
    Given a draft brief exists
    When the user fills the following mandatory fields:
      | Field                | Value                          |
      | Campaign Name        | Summer Engagement DE           |
      | Campaign Objective   | Increase brand awareness       |
      | Target Audience      | Adults 25-45                   |
      | Expected Launch Date | 2026-07-15                     |
      | Budget Range         | 50000-100000 EUR               |
    Then all mandatory fields are populated
    And the brief can proceed to submission

  @smoke @JSN-010
  Scenario: Market user submits a complete brief
    Given a draft brief exists with all mandatory fields completed
    And all required assets are uploaded
    And the campaign flow is defined
    When the user submits the brief
    Then the brief status changes to "Submitted"
    And the submission date is recorded
    And the submitted by user is recorded
    And a confirmation message is displayed
    And the brief becomes read-only

  # ============================================================================
  # DRAFT SAVING
  # ============================================================================

  @smoke @JSN-007
  Scenario: Market user saves a brief as draft
    Given a new brief is being created
    And the user has filled some fields
    When the user clicks "Save Draft"
    Then the brief is saved with status "Draft"
    And the user can return to edit it later
    And a success message is displayed "Draft saved successfully"

  @regression @JSN-007
  Scenario: Brief is auto-saved periodically
    Given a draft brief is being edited
    When the user makes changes to the brief content
    And 30 seconds have passed since the last save
    Then the brief is automatically saved
    And a subtle notification indicates "Auto-saved"

  @regression @JSN-007
  Scenario: Market user continues editing a saved draft
    Given a draft brief exists with partial data
    When the user opens the draft brief
    Then all previously entered data is pre-populated
    And the user can continue editing from where they left off

  @regression @JSN-007
  Scenario: Market user discards a draft brief
    Given a draft brief exists
    When the user clicks "Discard Draft"
    And confirms the discard action
    Then the draft brief is deleted
    And the user is returned to the campaign list

  # ============================================================================
  # MANDATORY FIELD VALIDATION
  # ============================================================================

  @regression @JSN-007
  Scenario: Brief submission fails when mandatory fields are missing
    Given a draft brief exists
    And the "Campaign Name" field is empty
    When the user attempts to submit the brief
    Then the submission is prevented
    And the error message highlights "Campaign Name is required"
    And the brief status remains "Draft"

  @regression @JSN-007
  Scenario: Multiple missing mandatory fields are highlighted
    Given a draft brief exists
    And the following mandatory fields are empty:
      | Campaign Name        |
      | Campaign Objective   |
      | Target Audience      |
    When the user attempts to submit the brief
    Then the submission is prevented
    And all 3 missing fields are highlighted in red
    And an error summary lists all missing fields

  @regression @JSN-007
  Scenario: Brief validation occurs before submission
    Given a draft brief exists with all fields filled
    When the user clicks "Submit Brief"
    Then the system validates all mandatory fields
    And the system validates all field formats
    And if validation passes, the brief is submitted
    And if validation fails, errors are displayed

  # ============================================================================
  # STRUCTURED FORM FIELDS
  # ============================================================================

  @regression @JSN-007
  Scenario: Market user fills campaign details section
    Given a draft brief exists
    When the user fills the campaign details section:
      | Field                | Value                          |
      | Campaign Name        | Summer Engagement DE           |
      | Campaign Objective   | Increase brand awareness       |
      | Campaign Description | Detailed campaign description  |
      | Target Audience      | Adults 25-45                   |
      | Expected Reach       | 100000 consumers               |
    Then all campaign details are saved
    And the section is marked as complete

  @regression @JSN-007
  Scenario: Market user fills technical requirements section
    Given a draft brief exists
    When the user fills the technical requirements section:
      | Field                  | Value                    |
      | Supported Devices      | Mobile, Tablet, Desktop  |
      | Age Verification Type  | Soft Age Gate            |
      | Expected Launch Date   | 2026-07-15               |
      | Campaign Duration      | 90 days                  |
    Then all technical requirements are saved
    And the section is marked as complete

  @regression @JSN-007
  Scenario: Market user fills budget and resources section
    Given a draft brief exists
    When the user fills the budget section:
      | Field                | Value            |
      | Budget Range         | 50000-100000 EUR |
      | Resource Allocation  | 2 developers     |
      | Timeline Expectation | 4 weeks          |
    Then all budget information is saved
    And the section is marked as complete

  # ============================================================================
  # FIELD VALIDATION
  # ============================================================================

  @regression @JSN-007
  Scenario: Campaign name has maximum length validation
    Given a draft brief exists
    When the user enters a campaign name with 256 characters
    Then a validation error is displayed
    And the error message is "Campaign name must not exceed 255 characters"

  @regression @JSN-007
  Scenario: Expected launch date must be in the future
    Given a draft brief exists
    When the user enters an expected launch date in the past
    Then a validation error is displayed
    And the error message is "Expected launch date must be in the future"

  @regression @JSN-007
  Scenario: Budget range must be a valid number
    Given a draft brief exists
    When the user enters "invalid" in the budget range field
    Then a validation error is displayed
    And the error message is "Budget range must be a valid number"

  @regression @JSN-007
  Scenario: Email addresses are validated
    Given a draft brief exists
    And the brief has a "Contact Email" field
    When the user enters "invalid-email"
    Then a validation error is displayed
    And the error message is "Please enter a valid email address"

  # ============================================================================
  # BRIEF PREVIEW
  # ============================================================================

  @regression @JSN-007
  Scenario: Market user previews brief before submission
    Given a draft brief exists with all fields completed
    When the user clicks "Preview Brief"
    Then a read-only preview of the brief is displayed
    And all sections are shown in a formatted view
    And the user can return to edit mode

  @regression @JSN-007
  Scenario: Brief preview shows validation status
    Given a draft brief exists
    When the user views the brief preview
    Then each section shows a completion status
    And incomplete sections are highlighted
    And a submission readiness indicator is displayed

  # ============================================================================
  # BRIEF EDITING AFTER CREATION
  # ============================================================================

  @regression @JSN-007
  Scenario: Market user edits a draft brief
    Given a draft brief exists with some data
    When the user updates the "Campaign Objective" field
    And the user saves the changes
    Then the brief is updated successfully
    And the last modified date is updated
    And the changes are reflected immediately

  @regression @JSN-007
  Scenario: Brief cannot be edited after submission
    Given a brief exists with status "Submitted"
    When the user attempts to edit the brief
    Then all fields are read-only
    And an information message states "Submitted briefs cannot be edited"

  @regression @JSN-007
  Scenario: Brief can be edited after rejection
    Given a brief exists with status "Rejected"
    When the user opens the brief
    Then all fields are editable
    And the rejection reason is displayed
    And the user can make changes and resubmit

  # ============================================================================
  # MULTI-STEP FORM NAVIGATION
  # ============================================================================

  @regression @JSN-007
  Scenario: Market user navigates through multi-step brief form
    Given a draft brief exists
    When the user completes "Step 1: Campaign Details"
    And clicks "Next"
    Then "Step 2: Technical Requirements" is displayed
    And the user can navigate back to Step 1
    And progress is saved at each step

  @regression @JSN-007
  Scenario: Form validation occurs at each step
    Given a draft brief exists
    And the user is on "Step 1: Campaign Details"
    When the user clicks "Next" without completing mandatory fields
    Then the navigation is prevented
    And missing fields in Step 1 are highlighted
    And the user remains on Step 1

  @regression @JSN-007
  Scenario: Market user can skip optional sections
    Given a draft brief exists
    And "Step 3: Additional Information" is optional
    When the user clicks "Skip" on Step 3
    Then the user proceeds to Step 4
    And Step 3 is marked as skipped

  # ============================================================================
  # BRIEF SUBMISSION CONFIRMATION
  # ============================================================================

  @smoke @JSN-010
  Scenario: Market user receives submission confirmation
    Given a draft brief exists with all required data
    When the user submits the brief
    Then a confirmation dialog is displayed
    And the dialog shows "Brief submitted successfully"
    And the dialog shows the brief ID
    And the dialog shows "A Jira ticket will be created shortly"

  @regression @JSN-010
  Scenario: Market user can view submitted brief
    Given a brief has been submitted
    When the user views the brief
    Then all submitted data is displayed in read-only mode
    And the submission date is shown
    And the Jira ticket ID is shown (once created)
    And the current status is displayed

  # ============================================================================
  # BOUNDARY SCENARIOS
  # ============================================================================

  @regression @boundary
  Scenario: Brief with maximum allowed text length is accepted
    Given a draft brief exists
    When the user enters 5000 characters in the "Campaign Description" field
    Then the text is accepted
    And the brief can be saved

  @regression @boundary
  Scenario: Brief with text exceeding maximum length is rejected
    Given a draft brief exists
    When the user enters 5001 characters in the "Campaign Description" field
    Then a validation error is displayed
    And the error message is "Description must not exceed 5000 characters"

  @regression @boundary
  Scenario: Brief with minimum required fields is accepted
    Given a draft brief exists
    When the user fills only the mandatory fields
    And the user submits the brief
    Then the brief is submitted successfully

  # ============================================================================
  # CONCURRENT EDITING
  # ============================================================================

  @regression @concurrency
  Scenario: Two users cannot edit the same draft simultaneously
    Given a draft brief exists
    And user A opens the brief for editing
    When user B attempts to open the same brief for editing
    Then user B sees a message "This brief is currently being edited by another user"
    And user B can view the brief in read-only mode

  @regression @concurrency
  Scenario: Brief lock is released when user closes the editor
    Given a draft brief is locked by user A
    When user A closes the brief editor
    Then the brief lock is released
    And other users can now edit the brief

  # ============================================================================
  # VALIDATION SCENARIOS
  # ============================================================================

  @regression @JSN-007
  Scenario: Brief cannot be submitted without campaign flow
    Given a draft brief exists with all fields completed
    And no campaign flow is defined
    When the user attempts to submit the brief
    Then the submission is prevented
    And the error message is "Campaign flow must be defined before submission"

  @regression @JSN-007
  Scenario: Brief cannot be submitted without assets
    Given a draft brief exists with all fields completed
    And no assets are uploaded
    When the user attempts to submit the brief
    Then the submission is prevented
    And the error message is "At least one asset must be uploaded before submission"

  @regression @JSN-010
  Scenario: Brief submission is idempotent
    Given a draft brief exists with all required data
    When the user submits the brief
    And the user attempts to submit again
    Then the second submission is prevented
    And the message is "This brief has already been submitted"

  # ============================================================================
  # ERROR SCENARIOS
  # ============================================================================

  @regression @error-handling
  Scenario: Database unavailable during brief creation
    Given the user attempts to create a new brief
    And the PMI database is unavailable
    When the creation request is processed
    Then the creation fails with status code 503
    And the error message is "Service temporarily unavailable"
    And the user is prompted to retry

  @regression @error-handling
  Scenario: Network failure during draft save
    Given a draft brief is being edited
    And the user makes changes
    When the user saves the draft
    And a network error occurs
    Then the save fails
    And the error message is "Failed to save draft. Please check your connection."
    And the user's changes are retained in the browser

  @regression @error-handling
  Scenario: Brief submission fails due to validation error
    Given a draft brief exists
    When the user submits the brief
    And server-side validation detects an error
    Then the submission fails with status code 400
    And the validation errors are displayed
    And the brief status remains "Draft"

  # ============================================================================
  # NFR SCENARIOS
  # ============================================================================

  @nfr @performance
  Scenario: Brief form loads quickly
    Given the user opens a draft brief
    When the brief form is loaded
    Then the form is displayed within 1 second
    And all field values are populated

  @nfr @performance
  Scenario: Draft auto-save does not impact user experience
    Given a draft brief is being edited
    When auto-save is triggered
    Then the save completes in the background
    And the user can continue editing without interruption

  @nfr @usability
  Scenario: Brief form provides helpful field descriptions
    Given a draft brief exists
    When the user hovers over a field label
    Then a tooltip with field description is displayed
    And the tooltip explains what information is expected

  @nfr @usability
  Scenario: Brief form is mobile-responsive
    Given the user accesses JustBrief on a mobile device
    When the user opens a brief form
    Then the form is displayed in a mobile-friendly layout
    And all fields are easily accessible
    And the keyboard opens appropriately for each field type

  @nfr @security
  Scenario: Brief data is validated on both client and server
    Given a draft brief exists
    When the user enters data in a field
    Then client-side validation provides immediate feedback
    And server-side validation occurs on save
    And both validations enforce the same rules

  @nfr @security
  Scenario: Brief data is isolated by market
    Given a user from market "DE" creates a brief
    When the brief is saved
    Then the brief is associated with market "DE"
    And users from other markets cannot access this brief
    And the market association cannot be changed
