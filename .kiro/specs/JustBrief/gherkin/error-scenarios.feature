@justbrief @error-scenarios
Feature: Error Handling and Resilience
  As a JustBrief user
  I want the system to handle errors gracefully
  So that I can recover from failures and complete my tasks

  Background:
    Given the JustBrief platform is running

  # ============================================================================
  # SIGA UNAVAILABILITY
  # ============================================================================

  @smoke @error-handling
  Scenario: SIGA authentication service is unavailable
    Given the SIGA RBAC system is unavailable
    When a user attempts to log in
    Then the login fails with status code 502
    And the error message is "Authentication service temporarily unavailable"
    And the user is advised to try again later
    And the error is logged for monitoring

  @regression @error-handling
  Scenario: SIGA service times out during authentication
    Given the SIGA RBAC system is slow to respond
    When a user attempts to log in
    And the SIGA API does not respond within 5 seconds
    Then the authentication times out
    And the error message is "Authentication service timeout"
    And the user can retry authentication

  @regression @error-handling
  Scenario: SIGA returns invalid response
    Given the SIGA RBAC system returns malformed data
    When a user attempts to authenticate
    Then the authentication fails
    And the error message is "Authentication error. Please contact support."
    And the error details are logged

  # ============================================================================
  # JIRA API FAILURES
  # ============================================================================

  @smoke @error-handling
  Scenario: Jira API is unavailable during ticket creation
    Given a market user submits a brief
    And the Jira API is unavailable
    When the system attempts to create a Jira ticket
    Then the ticket creation fails
    And the system retries 3 times with exponential backoff
    And the brief status is "Submitted - Pending Jira"
    And an alert is sent to administrators

  @regression @error-handling
  Scenario: Jira API returns authentication error
    Given a market user submits a brief
    And the Jira API credentials are invalid
    When the system attempts to create a Jira ticket
    Then the authentication fails
    And the error is logged with details
    And an alert is sent to administrators
    And the brief status is "Submitted - Jira Creation Failed"

  @regression @error-handling
  Scenario: Jira API returns validation error
    Given a market user submits a brief
    And the Jira API returns a 400 Bad Request
    When the ticket creation is attempted
    Then the system does not retry
    And the error details are logged
    And an alert is sent to administrators
    And the brief status is "Submitted - Jira Creation Failed"

  @regression @error-handling
  Scenario: Jira API times out
    Given a market user submits a brief
    And the Jira API is slow to respond
    When the ticket creation request times out after 30 seconds
    Then the system retries the request
    And if all retries timeout, the brief is marked "Submitted - Pending Jira"

  # ============================================================================
  # DATABASE FAILURES
  # ============================================================================

  @smoke @error-handling
  Scenario: PMI database is unavailable
    Given the PMI database is unavailable
    When a user attempts to create a pipeline
    Then the operation fails with status code 503
    And the error message is "Service temporarily unavailable"
    And the user is prompted to retry
    And the error is logged for monitoring

  @regression @error-handling
  Scenario: Database connection timeout
    Given the PMI database is slow to respond
    When a user attempts to save a brief
    And the database does not respond within 10 seconds
    Then the operation times out
    And the error message is "Operation timed out. Please try again."
    And the user's data is retained in the browser

  @regression @error-handling
  Scenario: Database transaction deadlock
    Given two users are updating the same pipeline simultaneously
    When a database deadlock occurs
    Then one transaction is rolled back
    And the affected user sees an error message
    And the user is prompted to retry
    And the other transaction completes successfully

  @regression @error-handling
  Scenario: Database constraint violation
    Given a user attempts to create a pipeline
    When a unique constraint is violated
    Then the operation fails with status code 409
    And the error message explains the conflict
    And the user can correct the issue and retry

  # ============================================================================
  # S3 STORAGE FAILURES
  # ============================================================================

  @smoke @error-handling
  Scenario: AWS S3 is unavailable during asset upload
    Given a market user attempts to upload an asset
    And AWS S3 is unavailable
    When the upload is processed
    Then the upload fails with status code 503
    And the error message is "Storage service temporarily unavailable"
    And the user is prompted to retry

  @regression @error-handling
  Scenario: S3 upload times out
    Given a market user is uploading a large file
    And the S3 upload is slow
    When the upload times out after 5 minutes
    Then the upload fails
    And the error message is "Upload timed out. Please try again."
    And the partial upload is cleaned up

  @regression @error-handling
  Scenario: S3 returns insufficient storage error
    Given a market user uploads an asset
    And the S3 bucket is full
    When the upload is attempted
    Then the upload fails
    And the error message is "Storage capacity exceeded"
    And an alert is sent to administrators

  @regression @error-handling
  Scenario: S3 presigned URL generation fails
    Given a user attempts to download an asset
    And S3 presigned URL generation fails
    When the download is requested
    Then the download fails gracefully
    And the error message is "Unable to generate download link"
    And the user can retry

  # ============================================================================
  # NETWORK FAILURES
  # ============================================================================

  @regression @error-handling
  Scenario: Network connection lost during brief submission
    Given a market user is submitting a brief
    When the network connection is lost
    Then the submission fails
    And the error message is "Network error. Please check your connection."
    And the user's data is retained in the browser
    And the user can retry when connection is restored

  @regression @error-handling
  Scenario: Network connection lost during asset upload
    Given a market user is uploading an asset
    And the upload is 50% complete
    When the network connection is lost
    Then the upload fails
    And the error message is "Upload failed due to network error"
    And the user can retry the upload

  @regression @error-handling
  Scenario: Slow network connection during page load
    Given a user has a slow network connection
    When the user loads the JustBrief interface
    Then the page loads progressively
    And critical content loads first
    And a loading indicator is displayed
    And the user can interact once core content is loaded

  # ============================================================================
  # VALIDATION ERRORS
  # ============================================================================

  @regression @error-handling
  Scenario: Client-side validation catches errors early
    Given a market user is filling a brief form
    When the user enters invalid data in a field
    Then client-side validation provides immediate feedback
    And the error is highlighted on the field
    And the user can correct the error before submission

  @regression @error-handling
  Scenario: Server-side validation catches errors missed by client
    Given a market user submits a brief
    When the client-side validation is bypassed
    And server-side validation detects an error
    Then the submission fails with status code 400
    And the validation errors are returned
    And the user can correct the errors and resubmit

  @regression @error-handling
  Scenario: Multiple validation errors are reported together
    Given a market user submits a brief
    When multiple validation errors exist
    Then all errors are returned in a single response
    And each error includes the field name and error message
    And the user can correct all errors at once

  # ============================================================================
  # CONCURRENT ACCESS ERRORS
  # ============================================================================

  @regression @error-handling
  Scenario: Two users edit the same draft simultaneously
    Given user A opens a draft brief for editing
    And user B opens the same draft brief
    When user A saves changes
    And user B attempts to save changes
    Then user B's save fails with status code 409
    And the error message is "This brief was modified by another user"
    And user B can reload the latest version

  @regression @error-handling
  Scenario: Pipeline is deleted while user is viewing it
    Given a user is viewing a pipeline
    When another user marks the pipeline as Cancelled
    And the first user attempts to interact with the pipeline
    Then the user is notified that the pipeline status changed
    And the user can refresh to see the updated status

  # ============================================================================
  # SESSION AND AUTHENTICATION ERRORS
  # ============================================================================

  @regression @error-handling
  Scenario: User session expires during work
    Given a user is editing a brief
    When the user's session expires
    And the user attempts to save
    Then the save fails with status code 401
    And the error message is "Your session has expired. Please log in again."
    And the user's work is retained in the browser
    And the user can log in and continue

  @regression @error-handling
  Scenario: User loses permissions during session
    Given a user is editing a brief
    When the user's permissions are revoked
    And the user attempts to save
    Then the save fails with status code 403
    And the error message is "You no longer have permission to perform this action"

  # ============================================================================
  # BROWSER AND CLIENT ERRORS
  # ============================================================================

  @regression @error-handling
  Scenario: Browser local storage is full
    Given a user is editing a large brief
    When the browser local storage is full
    And auto-save attempts to save
    Then the auto-save fails gracefully
    And the user is notified to save manually
    And the user can clear local storage and continue

  @regression @error-handling
  Scenario: Browser crashes during editing
    Given a user is editing a brief
    When the browser crashes
    And the user reopens the browser
    Then the last auto-saved version is recovered
    And the user can continue editing

  @regression @error-handling
  Scenario: JavaScript error occurs in the UI
    Given a user is using the JustBrief interface
    When a JavaScript error occurs
    Then the error is caught and logged
    And the error is sent to Sentry
    And the user sees a friendly error message
    And the user can refresh and continue

  # ============================================================================
  # RATE LIMITING AND THROTTLING
  # ============================================================================

  @regression @error-handling
  Scenario: User exceeds API rate limit
    Given a user makes many API requests in quick succession
    When the rate limit is exceeded
    Then subsequent requests fail with status code 429
    And the error message is "Too many requests. Please slow down."
    And the response includes a Retry-After header

  @regression @error-handling
  Scenario: System is under heavy load
    Given the JustBrief platform is under heavy load
    When a user attempts to perform an operation
    Then the operation may be throttled
    And the user sees a message "System is busy. Please try again."
    And the user can retry after a short delay

  # ============================================================================
  # DATA CORRUPTION ERRORS
  # ============================================================================

  @regression @error-handling
  Scenario: Corrupted brief data cannot be loaded
    Given a brief exists with corrupted data
    When a user attempts to load the brief
    Then the load fails gracefully
    And the error message is "Unable to load brief data"
    And an alert is sent to administrators
    And the user is offered to create a new brief

  @regression @error-handling
  Scenario: Corrupted flow data cannot be rendered
    Given a campaign flow exists with corrupted JSON
    When a user attempts to load the flow
    Then the flow builder shows an error
    And the error message is "Flow data is corrupted"
    And the user is offered to start a new flow

  # ============================================================================
  # NFR SCENARIOS
  # ============================================================================

  @nfr @reliability
  Scenario: System recovers from transient errors automatically
    Given a transient error occurs (e.g., network blip)
    When the system detects the error
    Then the system retries the operation automatically
    And the user is not impacted
    And the operation completes successfully

  @nfr @observability
  Scenario: All errors are logged for monitoring
    Given an error occurs in the system
    When the error is handled
    Then the error is logged with full context
    And the log includes user ID, timestamp, and error details
    And the log is sent to monitoring systems (Sentry, New Relic)

  @nfr @usability
  Scenario: Error messages are user-friendly
    Given an error occurs
    When the error message is displayed to the user
    Then the message is clear and non-technical
    And the message explains what went wrong
    And the message suggests how to resolve the issue
    And the message includes a support contact if needed
