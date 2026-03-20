@justbrief @jira-integration
Feature: Automatic Jira Ticket Creation and Integration
  As an EPAM team member
  I want Jira tickets to be automatically created when briefs are submitted
  So that I can track and manage campaign development requests

  Background:
    Given the JustBrief platform is running
    And the Jira API is available
    And the user is authenticated via SIGA

  # ============================================================================
  # HAPPY PATH SCENARIOS - Ticket Creation
  # ============================================================================

  @smoke @JSN-011
  Scenario: Jira ticket is automatically created when brief is submitted
    Given a market user has completed a campaign brief
    And all mandatory fields are filled
    And assets are uploaded
    And the campaign flow is defined
    When the user submits the brief
    Then the brief status changes to "Submitted"
    And a Jira ticket is created automatically
    And the ticket is in project "JSN"
    And the ticket type is "Task"
    And the ticket summary includes the campaign name
    And the brief ID is stored in the database

  @smoke @JSN-011
  Scenario: Jira ticket contains all brief information
    Given a market user submits a brief with campaign name "Summer Engagement DE"
    When the Jira ticket is created
    Then the ticket summary is "Campaign Brief: Summer Engagement DE"
    And the ticket description contains:
      | Field                | Value                          |
      | Brief ID             | [auto-generated ID]            |
      | Market               | DE                             |
      | Campaign Objective   | Increase brand awareness       |
      | Target Audience      | Adults 25-45                   |
      | Expected Launch Date | 2026-07-15                     |
      | Budget Range         | 50000-100000 EUR               |
    And the ticket has label "justbrief"
    And the ticket has label "market-de"

  @smoke @JSN-011
  Scenario: Brief is linked to Jira ticket
    Given a brief is submitted
    When the Jira ticket is created with ID "JSN-12345"
    Then the brief record is updated with Jira ticket ID "JSN-12345"
    And the user can view the Jira ticket link in the brief details
    And clicking the link opens the Jira ticket

  # ============================================================================
  # TICKET CONTENT MAPPING
  # ============================================================================

  @regression @JSN-011
  Scenario: Jira ticket includes asset information
    Given a brief is submitted with 5 assets
    When the Jira ticket is created
    Then the ticket description includes an "Assets" section
    And the section lists all 5 assets with:
      | Field       |
      | Filename    |
      | File size   |
      | Description |
      | Download link |

  @regression @JSN-011
  Scenario: Jira ticket includes campaign flow information
    Given a brief is submitted with a defined campaign flow
    When the Jira ticket is created
    Then the ticket description includes a "Campaign Flow" section
    And the section includes a link to view the flow diagram
    And the section lists the number of screens and decision points

  @regression @JSN-011
  Scenario: Jira ticket includes custom fields
    Given a brief is submitted
    When the Jira ticket is created
    Then custom fields are populated:
      | Custom Field      | Value                    |
      | Market            | DE                       |
      | Campaign Type     | Instant Win              |
      | Brief ID          | [auto-generated ID]      |
      | Submission Date   | [current date]           |
      | Submitted By      | [user email]             |

  @regression @JSN-011
  Scenario: Jira ticket description is formatted for readability
    Given a brief is submitted
    When the Jira ticket is created
    Then the ticket description uses Jira markdown formatting
    And sections are clearly separated with headers
    And important information is highlighted
    And the description is easy to read and navigate

  # ============================================================================
  # NOTIFICATION SCENARIOS
  # ============================================================================

  @smoke @JSN-012
  Scenario: EPAM team is notified when Jira ticket is created
    Given a brief is submitted
    When the Jira ticket is created
    Then an email notification is sent to the EPAM team
    And the email subject is "New Campaign Brief: Summer Engagement DE"
    And the email contains the brief summary
    And the email contains a link to the Jira ticket
    And the email contains a link to the brief in JustBrief

  @regression @JSN-012
  Scenario: Notification includes market information
    Given a brief is submitted for market "DE"
    When the notification is sent
    Then the email clearly states "Market: DE"
    And the email is sent to the team responsible for DE market
    And the email includes market-specific context

  @regression @JSN-012
  Scenario: Notification includes priority information
    Given a brief is submitted with high priority
    When the notification is sent
    Then the email subject includes "[HIGH PRIORITY]"
    And the email highlights the urgency
    And the email is sent to additional stakeholders

  @regression @JSN-012
  Scenario: Multiple stakeholders are notified
    Given a brief is submitted
    When the Jira ticket is created
    Then notifications are sent to:
      | Recipient Role       |
      | EPAM Team Lead       |
      | Regional SPOC        |
      | Technical Architect  |
    And each recipient receives a personalized email

  # ============================================================================
  # TRACEABILITY
  # ============================================================================

  @smoke @JSN-013
  Scenario: Complete traceability from pipeline to Jira ticket
    Given a pipeline "Summer Engagement 2026" exists
    And a market user creates a brief for this pipeline
    And the user submits the brief
    When the Jira ticket is created
    Then the audit trail shows:
      | Step                  | ID/Reference        |
      | Pipeline              | Pipeline ID         |
      | Brief                 | Brief ID            |
      | Jira Ticket           | JSN-12345           |
    And each step is linked to the next
    And the complete chain is traceable

  @regression @JSN-013
  Scenario: Brief shows Jira ticket status
    Given a brief is submitted
    And a Jira ticket "JSN-12345" is created
    When the user views the brief details
    Then the Jira ticket ID is displayed
    And the current ticket status is shown
    And the ticket assignee is shown
    And the last update date is shown

  @regression @JSN-013
  Scenario: Audit log records Jira ticket creation
    Given a brief is submitted
    When the Jira ticket is created
    Then an audit log entry is created
    And the entry contains:
      | Field              | Value                    |
      | Action             | Jira Ticket Created      |
      | Brief ID           | [brief ID]               |
      | Jira Ticket ID     | JSN-12345                |
      | Timestamp          | [creation timestamp]     |
      | Created By         | System (automated)       |

  @regression @JSN-013
  Scenario: User can view Jira ticket from brief interface
    Given a brief is submitted
    And a Jira ticket "JSN-12345" is created
    When the user views the brief
    Then a "View Jira Ticket" button is displayed
    And clicking the button opens the Jira ticket in a new tab
    And the user can see the ticket details

  # ============================================================================
  # ERROR HANDLING
  # ============================================================================

  @regression @JSN-027 @error-handling
  Scenario: Jira API unavailable during ticket creation
    Given a brief is ready to be submitted
    And the Jira API is unavailable
    When the user submits the brief
    Then the brief status changes to "Submitted"
    And the system attempts to create the Jira ticket
    And the ticket creation fails
    And the system retries 3 times with exponential backoff
    And if all retries fail, the brief is marked "Submitted - Pending Jira"
    And an alert is sent to administrators

  @regression @JSN-027 @error-handling
  Scenario: Jira ticket creation fails with retry logic
    Given a brief is submitted
    And the Jira API returns a temporary error
    When the ticket creation is attempted
    Then the system retries after 5 seconds
    And if the retry succeeds, the ticket is created
    And the brief is updated with the ticket ID
    And no user intervention is required

  @regression @JSN-027 @error-handling
  Scenario: Jira ticket creation fails permanently
    Given a brief is submitted
    And the Jira API returns a permanent error (400 Bad Request)
    When the ticket creation is attempted
    Then the system does not retry
    And the brief status is "Submitted - Jira Creation Failed"
    And an error notification is sent to administrators
    And the error details are logged
    And the user sees a message "Brief submitted, but Jira ticket creation failed"

  @regression @JSN-027 @error-handling
  Scenario: Jira authentication failure
    Given a brief is submitted
    And the Jira API credentials are invalid
    When the ticket creation is attempted
    Then the authentication fails
    And the error is logged with details
    And an alert is sent to administrators
    And the brief status is "Submitted - Pending Jira"

  @regression @JSN-027 @error-handling
  Scenario: Jira API timeout
    Given a brief is submitted
    And the Jira API is slow to respond
    When the ticket creation request times out after 30 seconds
    Then the system retries the request
    And if the retry succeeds, the ticket is created
    And if all retries timeout, the brief is marked "Submitted - Pending Jira"

  # ============================================================================
  # MANUAL TICKET CREATION
  # ============================================================================

  @regression @JSN-027
  Scenario: Administrator manually creates Jira ticket for failed submission
    Given a brief is in status "Submitted - Jira Creation Failed"
    When an administrator clicks "Retry Jira Creation"
    Then the system attempts to create the Jira ticket again
    And if successful, the brief is updated with the ticket ID
    And the brief status changes to "Submitted"
    And the administrator is notified of success

  @regression @JSN-027
  Scenario: Administrator manually links existing Jira ticket
    Given a brief is in status "Submitted - Pending Jira"
    And an administrator has manually created a Jira ticket "JSN-12345"
    When the administrator enters the ticket ID in JustBrief
    And clicks "Link Ticket"
    Then the brief is updated with ticket ID "JSN-12345"
    And the brief status changes to "Submitted"
    And the link is verified by querying Jira API

  # ============================================================================
  # TICKET UPDATES
  # ============================================================================

  @regression @JSN-013
  Scenario: Jira ticket is updated when brief is modified
    Given a brief is submitted with Jira ticket "JSN-12345"
    And the brief status changes to "Under Review"
    When the status change occurs
    Then a comment is added to the Jira ticket
    And the comment states "Brief status changed to: Under Review"
    And the comment includes a timestamp

  @regression @JSN-013
  Scenario: Jira ticket is commented when assets are added post-submission
    Given a brief is submitted with Jira ticket "JSN-12345"
    When an administrator adds an additional asset to the brief
    Then a comment is added to the Jira ticket
    And the comment states "New asset added: [filename]"
    And the comment includes a download link

  # ============================================================================
  # VALIDATION SCENARIOS
  # ============================================================================

  @regression @JSN-011
  Scenario: Jira ticket creation validates required fields
    Given a brief is submitted
    When the Jira ticket creation is attempted
    Then all required Jira fields are validated
    And if any field is missing, the creation fails
    And the error is logged with details
    And the brief is marked "Submitted - Jira Creation Failed"

  @regression @JSN-011
  Scenario: Jira ticket summary has maximum length
    Given a brief is submitted with a very long campaign name (300 characters)
    When the Jira ticket is created
    Then the ticket summary is truncated to 255 characters
    And the full campaign name is included in the description

  @regression @JSN-011
  Scenario: Jira ticket description handles special characters
    Given a brief is submitted with special characters in the description
    When the Jira ticket is created
    Then special characters are properly escaped
    And the ticket description is formatted correctly
    And no Jira markdown errors occur

  # ============================================================================
  # BOUNDARY SCENARIOS
  # ============================================================================

  @regression @boundary
  Scenario: Brief with maximum number of assets creates valid Jira ticket
    Given a brief is submitted with 50 assets
    When the Jira ticket is created
    Then all 50 assets are listed in the description
    And the description does not exceed Jira's field limits

  @regression @boundary
  Scenario: Brief with complex flow creates valid Jira ticket
    Given a brief is submitted with a flow containing 100 nodes
    When the Jira ticket is created
    Then the flow information is summarized appropriately
    And a link to the full flow diagram is provided

  # ============================================================================
  # CONCURRENT SCENARIOS
  # ============================================================================

  @regression @concurrency
  Scenario: Multiple briefs submitted simultaneously create separate tickets
    Given 5 market users submit briefs simultaneously
    When all Jira tickets are created
    Then 5 unique Jira tickets are created
    And each ticket is linked to the correct brief
    And no ticket data is mixed between briefs

  @regression @concurrency
  Scenario: Jira ticket creation is thread-safe
    Given multiple briefs are submitted in quick succession
    When Jira tickets are created concurrently
    Then each ticket creation is independent
    And no race conditions occur
    And all tickets are created successfully

  # ============================================================================
  # NFR SCENARIOS
  # ============================================================================

  @nfr @performance @JSN-027
  Scenario: Jira ticket creation completes quickly
    Given a brief is submitted
    When the Jira ticket creation is triggered
    Then the ticket is created within 5 seconds
    And the brief is updated with the ticket ID
    And the user receives confirmation

  @nfr @performance
  Scenario: Jira ticket creation does not block brief submission
    Given a brief is ready to be submitted
    When the user submits the brief
    Then the brief status changes to "Submitted" immediately
    And the Jira ticket creation happens asynchronously
    And the user is not blocked waiting for Jira

  @nfr @reliability @JSN-027
  Scenario: Failed Jira ticket creation is retried automatically
    Given a brief is submitted
    And the Jira API returns a 503 error
    When the ticket creation fails
    Then the system retries after 5 seconds
    And then retries after 10 seconds
    And then retries after 20 seconds
    And if all retries fail, an alert is raised

  @nfr @security @JSN-027
  Scenario: Jira API credentials are stored securely
    Given the JustBrief platform integrates with Jira
    When Jira API calls are made
    Then credentials are retrieved from AWS Secrets Manager
    And credentials are never logged or exposed
    And credentials are rotated regularly

  @nfr @security
  Scenario: Jira ticket links are validated
    Given a brief displays a Jira ticket link
    When the user clicks the link
    Then the link is validated before opening
    And the link points to the correct Jira instance
    And the link cannot be manipulated

  @nfr @observability
  Scenario: Jira integration is monitored
    Given the JustBrief platform is running
    When Jira tickets are created
    Then success/failure metrics are recorded
    And the metrics include:
      | Metric                        |
      | Ticket creation success rate  |
      | Ticket creation duration      |
      | Retry attempts                |
      | Failure reasons               |
    And alerts are triggered if success rate drops below 95%

  @nfr @observability
  Scenario: Jira integration errors are logged
    Given a Jira ticket creation fails
    When the error occurs
    Then the error is logged with:
      | Field              |
      | Brief ID           |
      | Error message      |
      | Jira API response  |
      | Timestamp          |
      | Retry count        |
    And the log is sent to Sentry for monitoring
