@justbrief @campaign-flow-builder
Feature: Visual Campaign Flow Builder
  As a Market user
  I want to visually define the campaign flow
  So that EPAM understands the campaign logic and user journey

  Background:
    Given the JustBrief platform is running
    And the user is authenticated via SIGA as "market_user" for market "DE"
    And a draft brief exists for the user

  # ============================================================================
  # HAPPY PATH SCENARIOS - Flow Creation
  # ============================================================================

  @smoke @JSN-009
  Scenario: Market user creates a simple linear campaign flow
    Given the user is on the flow builder page
    When the user adds the following nodes in sequence:
      | Node Type  | Node Name        |
      | Screen     | Welcome Screen   |
      | Screen     | Age Gate         |
      | Screen     | Main Content     |
      | Screen     | Thank You        |
    And the user connects the nodes in order
    Then the flow is created successfully
    And the flow has 4 nodes
    And the flow has 3 connections
    And the flow can be saved

  @smoke @JSN-009
  Scenario: Market user creates a branching campaign flow
    Given the user is on the flow builder page
    When the user creates a flow with:
      | Node Type  | Node Name          | Connects To           |
      | Screen     | Welcome            | Age Gate              |
      | Decision   | Age Gate           | Adult Path, Minor Path|
      | Screen     | Adult Path         | Main Content          |
      | Screen     | Minor Path         | Exit Message          |
      | Screen     | Main Content       | Thank You             |
    Then the flow has 5 nodes
    And the flow has 2 branches from "Age Gate"
    And the flow structure is valid

  @smoke @JSN-009
  Scenario: Market user saves a campaign flow
    Given the user has created a campaign flow
    When the user clicks "Save Flow"
    Then the flow is saved successfully
    And the flow is stored as JSON in the database
    And the flow is linked to the brief
    And a success message is displayed "Flow saved successfully"

  # ============================================================================
  # FLOW NODE TYPES
  # ============================================================================

  @regression @JSN-009
  Scenario: Market user adds a Screen node
    Given the user is on the flow builder page
    When the user adds a "Screen" node
    And the user names it "Welcome Screen"
    Then the node is added to the canvas
    And the node type is "Screen"
    And the node can be configured with content

  @regression @JSN-009
  Scenario: Market user adds a Decision node
    Given the user is on the flow builder page
    When the user adds a "Decision" node
    And the user names it "Age Verification"
    Then the node is added to the canvas
    And the node type is "Decision"
    And the node supports multiple output connections

  @regression @JSN-009
  Scenario: Market user adds a Redirection node
    Given the user is on the flow builder page
    When the user adds a "Redirection" node
    And the user configures the redirect URL
    Then the node is added to the canvas
    And the node type is "Redirection"
    And the node is marked as a terminal node

  @regression @JSN-009
  Scenario: Market user adds an Instant Win node
    Given the user is on the flow builder page
    When the user adds an "Instant Win" node
    And the user names it "Spin the Wheel"
    Then the node is added to the canvas
    And the node type is "Instant Win"
    And the node supports win/lose branches

  @regression @JSN-009
  Scenario: Market user adds an API Call node
    Given the user is on the flow builder page
    When the user adds an "API Call" node
    And the user configures the API endpoint
    Then the node is added to the canvas
    And the node type is "API Call"
    And the node supports success/failure branches

  # ============================================================================
  # NODE CONNECTIONS
  # ============================================================================

  @regression @JSN-009
  Scenario: Market user connects two nodes
    Given the user has added two nodes "Welcome" and "Age Gate"
    When the user drags a connection from "Welcome" to "Age Gate"
    Then the connection is created
    And the connection is displayed as an arrow
    And the flow direction is from "Welcome" to "Age Gate"

  @regression @JSN-009
  Scenario: Market user creates multiple connections from a Decision node
    Given the user has added a "Decision" node named "Age Gate"
    And the user has added nodes "Adult Path" and "Minor Path"
    When the user connects "Age Gate" to "Adult Path" with label "Adult"
    And the user connects "Age Gate" to "Minor Path" with label "Minor"
    Then both connections are created
    And each connection has a label
    And the Decision node shows 2 output connections

  @regression @JSN-009
  Scenario: Market user deletes a connection
    Given the user has connected "Welcome" to "Age Gate"
    When the user clicks on the connection
    And the user presses "Delete"
    Then the connection is removed
    And the nodes remain on the canvas
    And the flow is updated

  @regression @JSN-009
  Scenario: Market user reconnects a node
    Given the user has connected "Welcome" to "Age Gate"
    When the user drags the connection endpoint to "Main Content"
    Then the connection is updated
    And "Welcome" is now connected to "Main Content"
    And the old connection to "Age Gate" is removed

  # ============================================================================
  # NODE CONFIGURATION
  # ============================================================================

  @regression @JSN-009
  Scenario: Market user configures a Screen node
    Given the user has added a "Screen" node
    When the user opens the node configuration
    And the user provides:
      | Field           | Value                    |
      | Screen Name     | Welcome Screen           |
      | Description     | Initial welcome message  |
      | Screen Type     | Landing Page             |
    Then the configuration is saved
    And the node displays the screen name

  @regression @JSN-009
  Scenario: Market user configures a Decision node
    Given the user has added a "Decision" node
    When the user opens the node configuration
    And the user defines decision criteria:
      | Condition      | Output Label |
      | age >= 18      | Adult        |
      | age < 18       | Minor        |
    Then the configuration is saved
    And the node shows the decision criteria

  @regression @JSN-009
  Scenario: Market user adds notes to a node
    Given the user has added a node
    When the user opens the node configuration
    And the user adds a note "This screen requires legal review"
    Then the note is saved with the node
    And a note indicator is displayed on the node

  # ============================================================================
  # FLOW VALIDATION
  # ============================================================================

  @regression @JSN-009
  Scenario: Flow validation detects disconnected nodes
    Given the user has created a flow
    And a node "Orphan Screen" is not connected to any other node
    When the user validates the flow
    Then a validation warning is displayed
    And the warning states "Node 'Orphan Screen' is not connected"
    And the disconnected node is highlighted

  @regression @JSN-009
  Scenario: Flow validation requires a start node
    Given the user has created a flow
    And no node is marked as the start node
    When the user attempts to save the flow
    Then the save is prevented
    And the error message is "Flow must have a start node"

  @regression @JSN-009
  Scenario: Flow validation detects circular references
    Given the user has created a flow
    And "Screen A" connects to "Screen B"
    And "Screen B" connects to "Screen C"
    And "Screen C" connects back to "Screen A"
    When the user validates the flow
    Then a validation warning is displayed
    And the warning states "Circular reference detected"
    And the circular path is highlighted

  @regression @JSN-009
  Scenario: Flow validation requires at least one terminal node
    Given the user has created a flow
    And no node is marked as terminal (end point)
    When the user validates the flow
    Then a validation warning is displayed
    And the warning states "Flow must have at least one end point"

  @regression @JSN-009
  Scenario: Valid flow passes all validation checks
    Given the user has created a complete flow
    And the flow has a start node
    And the flow has at least one terminal node
    And all nodes are connected
    And there are no circular references
    When the user validates the flow
    Then the validation passes
    And the message is "Flow is valid"

  # ============================================================================
  # FLOW EDITING
  # ============================================================================

  @regression @JSN-009
  Scenario: Market user moves a node on the canvas
    Given the user has added a node "Welcome"
    When the user drags the node to a new position
    Then the node position is updated
    And connected nodes remain connected
    And the connections are redrawn

  @regression @JSN-009
  Scenario: Market user deletes a node
    Given the user has added a node "Welcome"
    When the user selects the node
    And the user presses "Delete"
    Then the node is removed from the canvas
    And all connections to/from the node are removed
    And the flow is updated

  @regression @JSN-009
  Scenario: Market user duplicates a node
    Given the user has configured a node "Welcome Screen"
    When the user right-clicks the node
    And the user selects "Duplicate"
    Then a copy of the node is created
    And the copy has the same configuration
    And the copy is positioned near the original
    And the copy has a unique ID

  @regression @JSN-009
  Scenario: Market user renames a node
    Given the user has added a node "Screen 1"
    When the user double-clicks the node name
    And the user enters "Welcome Screen"
    Then the node name is updated
    And the new name is displayed on the canvas

  # ============================================================================
  # FLOW PERSISTENCE
  # ============================================================================

  @smoke @JSN-009
  Scenario: Campaign flow is persisted as JSON
    Given the user has created a campaign flow
    When the user saves the flow
    Then the flow is serialized to JSON
    And the JSON includes all nodes and connections
    And the JSON includes node configurations
    And the JSON is stored in the database

  @regression @JSN-009
  Scenario: Market user loads a saved flow
    Given a campaign flow has been saved
    When the user opens the flow builder
    Then the saved flow is loaded
    And all nodes are displayed on the canvas
    And all connections are displayed
    And node configurations are preserved

  @regression @JSN-009
  Scenario: Flow auto-saves periodically
    Given the user is editing a flow
    When the user makes changes
    And 30 seconds have passed since the last save
    Then the flow is automatically saved
    And a subtle notification indicates "Auto-saved"

  # ============================================================================
  # FLOW VISUALIZATION
  # ============================================================================

  @regression @JSN-009
  Scenario: Market user zooms in on the flow canvas
    Given the user has created a large flow
    When the user zooms in using the zoom controls
    Then the canvas zoom level increases
    And nodes are displayed larger
    And the user can see more detail

  @regression @JSN-009
  Scenario: Market user zooms out to see entire flow
    Given the user has created a large flow
    When the user clicks "Fit to Screen"
    Then the canvas zoom adjusts automatically
    And the entire flow is visible
    And all nodes are displayed

  @regression @JSN-009
  Scenario: Market user pans across the canvas
    Given the user has created a large flow
    When the user drags the canvas background
    Then the canvas pans in the drag direction
    And nodes move with the canvas
    And the user can view different areas of the flow

  @regression @JSN-009
  Scenario: Flow nodes are color-coded by type
    Given the user has added nodes of different types
    When the user views the flow
    Then Screen nodes are displayed in blue
    And Decision nodes are displayed in yellow
    And Instant Win nodes are displayed in green
    And Terminal nodes are displayed in red

  # ============================================================================
  # FLOW EXPORT AND PREVIEW
  # ============================================================================

  @regression @JSN-009
  Scenario: Market user exports flow as image
    Given the user has created a campaign flow
    When the user clicks "Export as Image"
    Then the flow is rendered as a PNG image
    And the image is downloaded
    And the image shows all nodes and connections

  @regression @JSN-009
  Scenario: Market user previews flow in read-only mode
    Given the user has created a campaign flow
    When the user clicks "Preview Flow"
    Then the flow is displayed in read-only mode
    And nodes cannot be edited
    And the user can navigate through the flow
    And the user can return to edit mode

  # ============================================================================
  # TEMPLATES AND REUSABILITY
  # ============================================================================

  @regression @JSN-009
  Scenario: Market user starts from a flow template
    Given flow templates exist for common campaign types
    When the user selects template "Standard Instant Win Flow"
    Then the template flow is loaded onto the canvas
    And the user can customize the template
    And the user can save the customized flow

  @regression @JSN-009
  Scenario: Market user saves a flow as a template
    Given the user has created a campaign flow
    When the user clicks "Save as Template"
    And the user names the template "Custom Engagement Flow"
    Then the flow is saved as a reusable template
    And the template is available for future briefs

  # ============================================================================
  # VALIDATION SCENARIOS
  # ============================================================================

  @regression @JSN-009
  Scenario: Flow cannot be saved without a name
    Given the user has created a flow
    And the flow has no name
    When the user attempts to save the flow
    Then the save is prevented
    And the error message is "Flow name is required"

  @regression @JSN-009
  Scenario: Decision node must have at least two output connections
    Given the user has added a "Decision" node
    And the node has only one output connection
    When the user validates the flow
    Then a validation error is displayed
    And the error states "Decision node must have at least 2 outputs"

  @regression @JSN-009
  Scenario: Terminal node cannot have output connections
    Given the user has added a "Redirection" node (terminal)
    When the user attempts to add an output connection
    Then the connection is prevented
    And the message is "Terminal nodes cannot have output connections"

  # ============================================================================
  # BOUNDARY SCENARIOS
  # ============================================================================

  @regression @boundary
  Scenario: Flow with maximum number of nodes is accepted
    Given the user creates a flow with 100 nodes
    When the user saves the flow
    Then the flow is saved successfully
    And all nodes are persisted

  @regression @boundary
  Scenario: Flow with deeply nested branches is accepted
    Given the user creates a flow with 10 levels of nested decisions
    When the user saves the flow
    Then the flow is saved successfully
    And the structure is preserved

  @regression @boundary
  Scenario: Node name at maximum length is accepted
    Given the user adds a node
    When the user names it with 255 characters
    Then the name is accepted
    And the full name is stored

  # ============================================================================
  # ERROR SCENARIOS
  # ============================================================================

  @regression @error-handling
  Scenario: Database unavailable during flow save
    Given the user has created a flow
    And the PMI database is unavailable
    When the user attempts to save the flow
    Then the save fails with status code 503
    And the error message is "Unable to save flow. Please try again."
    And the flow data is retained in the browser

  @regression @error-handling
  Scenario: Corrupted flow data cannot be loaded
    Given a flow exists with corrupted JSON data
    When the user attempts to load the flow
    Then the load fails gracefully
    And the error message is "Flow data is corrupted"
    And the user is offered to start a new flow

  @regression @error-handling
  Scenario: Browser crash recovery
    Given the user is editing a flow
    When the browser crashes unexpectedly
    And the user reopens the flow builder
    Then the last auto-saved version is recovered
    And the user can continue editing

  # ============================================================================
  # NFR SCENARIOS
  # ============================================================================

  @nfr @performance
  Scenario: Flow builder loads quickly
    Given the user opens the flow builder
    When the page loads
    Then the canvas is displayed within 1 second
    And the user can immediately start adding nodes

  @nfr @performance
  Scenario: Large flows render without performance degradation
    Given a flow has 100 nodes and 150 connections
    When the user views the flow
    Then the flow renders within 2 seconds
    And the canvas remains responsive
    And zoom and pan operations are smooth

  @nfr @usability
  Scenario: Flow builder provides helpful tooltips
    Given the user is on the flow builder page
    When the user hovers over a node type
    Then a tooltip explains the node type
    And the tooltip shows example use cases

  @nfr @usability
  Scenario: Flow builder supports keyboard shortcuts
    Given the user is editing a flow
    When the user presses "Ctrl+S"
    Then the flow is saved
    And when the user presses "Delete" with a node selected
    Then the node is deleted

  @nfr @usability
  Scenario: Flow builder is accessible
    Given the user is on the flow builder page
    When the user navigates using keyboard only
    Then all controls are accessible via keyboard
    And focus indicators are clearly visible
    And screen reader announcements are appropriate

  @nfr @security
  Scenario: Flow data is validated before persistence
    Given the user has created a flow
    When the user saves the flow
    Then the flow JSON is validated on the server
    And malicious content is rejected
    And only valid flow structures are persisted
