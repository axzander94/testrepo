@justbrief @pipeline-management
Feature: Campaign Pipeline Management
  As a Regional SPOC or EPAM user
  I want to create and manage campaign pipelines
  So that markets can view available campaigns and submit briefs

  Background:
    Given the JustBrief platform is running
    And the user is authenticated via SIGA

  # ============================================================================
  # HAPPY PATH SCENARIOS - Pipeline Creation
  # ============================================================================

  @smoke @JSN-001
  Scenario: Regional SPOC creates a new campaign pipeline
    Given the user has role "regional_spoc"
    When the user creates a pipeline with the following details:
      | Field           | Value                          |
      | Name            | Summer Engagement 2026         |
      | Description     | Q3 consumer engagement campaign|
      | Campaign Type   | Instant Win                    |
      | Start Date      | 2026-07-01                     |
      | End Date        | 2026-09-30                     |
    Then the pipeline is created successfully
    And the pipeline status is "Draft"
    And the pipeline has a unique ID
    And the created date is recorded
    And the creator is recorded as the current user

  @smoke @JSN-001
  Scenario: EPAM admin creates a global campaign pipeline
    Given the user has role "epam_admin"
    When the user creates a pipeline with campaign type "Multi-Channel"
    And the user sets the pipeline as global
    Then the pipeline is created successfully
    And the pipeline is visible to all markets

  # ============================================================================
  # MARKET ASSIGNMENT
  # ============================================================================

  @smoke @JSN-002
  Scenario: Regional SPOC assigns specific markets to a pipeline
    Given the user has role "regional_spoc"
    And a pipeline exists with name "Summer Engagement 2026"
    When the user assigns markets "DE", "FR", "IT" to the pipeline
    Then the market assignment is saved successfully
    And only users from markets "DE", "FR", "IT" can see this pipeline

  @regression @JSN-002
  Scenario: Regional SPOC assigns multiple markets in one operation
    Given the user has role "regional_spoc"
    And a pipeline exists in "Draft" status
    When the user assigns markets "DE", "FR", "IT", "ES", "NL" to the pipeline
    Then all 5 markets are assigned successfully
    And the assignment is recorded in the audit log

  @regression @JSN-002
  Scenario: Regional SPOC updates market assignments
    Given the user has role "regional_spoc"
    And a pipeline exists assigned to markets "DE", "FR"
    When the user updates the assignment to markets "DE", "FR", "IT"
    Then the pipeline is now assigned to markets "DE", "FR", "IT"
    And users from market "IT" can now see the pipeline

  @regression @JSN-002
  Scenario: Regional SPOC removes a market from pipeline assignment
    Given the user has role "regional_spoc"
    And a pipeline exists assigned to markets "DE", "FR", "IT"
    When the user removes market "IT" from the assignment
    Then the pipeline is assigned to markets "DE", "FR" only
    And users from market "IT" can no longer see the pipeline

  # ============================================================================
  # PIPELINE STATUS MANAGEMENT
  # ============================================================================

  @smoke @JSN-003
  Scenario: Regional SPOC activates a draft pipeline
    Given the user has role "regional_spoc"
    And a pipeline exists with status "Draft"
    And the pipeline has markets assigned
    When the user changes the pipeline status to "Active"
    Then the pipeline status is updated to "Active"
    And the pipeline becomes visible to assigned market users
    And the status change is recorded in the audit log

  @smoke @JSN-003
  Scenario: Regional SPOC marks a pipeline as Cancelled
    Given the user has role "regional_spoc"
    And a pipeline exists with status "Active"
    When the user changes the pipeline status to "Cancelled"
    Then the pipeline status is updated to "Cancelled"
    And the pipeline remains in the system for traceability
    And the pipeline is no longer visible to market users
    And the cancellation reason is recorded

  @regression @JSN-003
  Scenario: EPAM admin marks a completed pipeline
    Given the user has role "epam_admin"
    And a pipeline exists with status "Active"
    And the pipeline end date has passed
    When the user changes the pipeline status to "Completed"
    Then the pipeline status is updated to "Completed"
    And the pipeline remains visible for historical reference
    And no new briefs can be submitted for this pipeline

  @regression @JSN-003
  Scenario: Pipeline cannot be permanently deleted
    Given the user has role "epam_admin"
    And a pipeline exists with status "Cancelled"
    When the user attempts to delete the pipeline
    Then the deletion is not permitted
    And the error message is "Pipelines cannot be deleted, only marked as Cancelled"
    And the pipeline remains in the system

  # ============================================================================
  # PIPELINE VISIBILITY
  # ============================================================================

  @regression @JSN-002 @JSN-005
  Scenario: Market user sees only pipelines assigned to their market
    Given the user has role "market_user" for market "DE"
    And pipelines exist with the following assignments:
      | Pipeline Name    | Assigned Markets |
      | Campaign A       | DE, FR           |
      | Campaign B       | IT, ES           |
      | Campaign C       | DE               |
    When the user views the pipeline list
    Then the user sees pipelines "Campaign A" and "Campaign C"
    And the user does not see pipeline "Campaign B"

  @regression @JSN-002
  Scenario: Regional SPOC sees all pipelines in their region
    Given the user has role "regional_spoc" for region "EU"
    And pipelines exist for EU markets and AP markets
    When the user views the pipeline list
    Then the user sees all EU market pipelines
    And the user does not see AP market pipelines

  @regression @JSN-002
  Scenario: EPAM admin sees all pipelines globally
    Given the user has role "epam_admin"
    And pipelines exist for multiple regions and markets
    When the user views the pipeline list
    Then the user sees all pipelines regardless of market or region

  # ============================================================================
  # PIPELINE UPDATES
  # ============================================================================

  @regression @JSN-001
  Scenario: Regional SPOC updates pipeline details
    Given the user has role "regional_spoc"
    And a pipeline exists with name "Summer Campaign"
    When the user updates the pipeline with:
      | Field       | Value                    |
      | Name        | Summer Engagement 2026   |
      | Description | Updated campaign details |
      | End Date    | 2026-10-31               |
    Then the pipeline is updated successfully
    And the changes are reflected immediately
    And the update is recorded in the audit log

  @regression @JSN-001
  Scenario: Pipeline dates can be extended
    Given the user has role "regional_spoc"
    And a pipeline exists with end date "2026-09-30"
    When the user updates the end date to "2026-10-31"
    Then the end date is updated successfully
    And active briefs remain valid

  @regression @JSN-001
  Scenario: Pipeline start date cannot be changed after activation
    Given the user has role "regional_spoc"
    And a pipeline exists with status "Active"
    And the pipeline start date is "2026-07-01"
    When the user attempts to change the start date to "2026-08-01"
    Then the update is rejected
    And the error message is "Cannot change start date of active pipeline"

  # ============================================================================
  # VALIDATION SCENARIOS
  # ============================================================================

  @regression @JSN-001
  Scenario: Pipeline creation requires mandatory fields
    Given the user has role "regional_spoc"
    When the user attempts to create a pipeline without a name
    Then the creation fails with status code 400
    And the error message is "Pipeline name is required"

  @regression @JSN-001
  Scenario: Pipeline end date must be after start date
    Given the user has role "regional_spoc"
    When the user creates a pipeline with:
      | Field      | Value      |
      | Start Date | 2026-09-30 |
      | End Date   | 2026-07-01 |
    Then the creation fails with status code 400
    And the error message is "End date must be after start date"

  @regression @JSN-002
  Scenario: Pipeline must have at least one market assigned before activation
    Given the user has role "regional_spoc"
    And a pipeline exists with status "Draft"
    And no markets are assigned to the pipeline
    When the user attempts to change status to "Active"
    Then the status change fails with status code 400
    And the error message is "At least one market must be assigned before activation"

  @regression @JSN-001
  Scenario: Pipeline name must be unique within a market
    Given the user has role "regional_spoc"
    And a pipeline exists with name "Summer Campaign" for market "DE"
    When the user creates a new pipeline with name "Summer Campaign" for market "DE"
    Then the creation fails with status code 409
    And the error message is "Pipeline name already exists for this market"

  # ============================================================================
  # BOUNDARY SCENARIOS
  # ============================================================================

  @regression @boundary
  Scenario: Pipeline name at maximum length is accepted
    Given the user has role "regional_spoc"
    When the user creates a pipeline with a name of 255 characters
    Then the pipeline is created successfully

  @regression @boundary
  Scenario: Pipeline name exceeding maximum length is rejected
    Given the user has role "regional_spoc"
    When the user creates a pipeline with a name of 256 characters
    Then the creation fails with status code 400
    And the error message is "Pipeline name must not exceed 255 characters"

  @regression @boundary
  Scenario: Pipeline can be assigned to maximum number of markets
    Given the user has role "epam_admin"
    And 50 markets exist in the system
    When the user assigns all 50 markets to a pipeline
    Then all markets are assigned successfully

  @regression @boundary
  Scenario: Pipeline with past start date is accepted
    Given the user has role "regional_spoc"
    When the user creates a pipeline with start date in the past
    Then the pipeline is created successfully
    And a warning is displayed "Start date is in the past"

  # ============================================================================
  # CONCURRENT ACCESS SCENARIOS
  # ============================================================================

  @regression @concurrency
  Scenario: Two users update the same pipeline simultaneously
    Given the user has role "regional_spoc"
    And another user has role "regional_spoc"
    And a pipeline exists with name "Campaign A"
    When both users update the pipeline name simultaneously
    Then only one update succeeds
    And the other update fails with status code 409
    And the error message is "Pipeline was modified by another user"

  @regression @concurrency
  Scenario: Pipeline status change is atomic
    Given the user has role "regional_spoc"
    And a pipeline exists with status "Draft"
    When multiple users attempt to change the status simultaneously
    Then only one status change succeeds
    And the final status is consistent

  # ============================================================================
  # AUDIT TRAIL
  # ============================================================================

  @regression @JSN-013
  Scenario: Pipeline creation is audited
    Given the user has role "regional_spoc"
    When the user creates a new pipeline
    Then an audit log entry is created
    And the entry contains the user ID, timestamp, and action "Pipeline Created"
    And the entry contains the pipeline ID and name

  @regression @JSN-013
  Scenario: Pipeline status changes are audited
    Given the user has role "regional_spoc"
    And a pipeline exists with status "Draft"
    When the user changes the status to "Active"
    Then an audit log entry is created
    And the entry contains the old status "Draft" and new status "Active"
    And the entry contains the user ID and timestamp

  @regression @JSN-013
  Scenario: Market assignment changes are audited
    Given the user has role "regional_spoc"
    And a pipeline exists assigned to markets "DE", "FR"
    When the user updates the assignment to "DE", "FR", "IT"
    Then an audit log entry is created
    And the entry shows market "IT" was added
    And the entry contains the user ID and timestamp

  # ============================================================================
  # ERROR SCENARIOS
  # ============================================================================

  @regression @error-handling
  Scenario: Database unavailable during pipeline creation
    Given the user has role "regional_spoc"
    And the PMI database is unavailable
    When the user attempts to create a pipeline
    Then the creation fails with status code 503
    And the error message is "Service temporarily unavailable"
    And the error is logged for monitoring

  @regression @error-handling
  Scenario: Invalid market code in assignment
    Given the user has role "regional_spoc"
    And a pipeline exists
    When the user assigns market "INVALID" to the pipeline
    Then the assignment fails with status code 400
    And the error message is "Invalid market code: INVALID"

  # ============================================================================
  # NFR SCENARIOS
  # ============================================================================

  @nfr @performance
  Scenario: Pipeline list loads within acceptable time
    Given the user has role "market_user"
    And 100 pipelines exist in the system
    When the user requests the pipeline list
    Then the response is returned within 2 seconds
    And only pipelines for the user's market are returned

  @nfr @performance
  Scenario: Pipeline creation completes quickly
    Given the user has role "regional_spoc"
    When the user creates a new pipeline
    Then the pipeline is created within 1 second
    And the response includes the pipeline ID

  @nfr @security
  Scenario: Pipeline data is isolated by market
    Given the user has role "market_user" for market "DE"
    When the user attempts to access a pipeline assigned to market "FR"
    Then the access is denied with status code 403
    And no pipeline data is returned
