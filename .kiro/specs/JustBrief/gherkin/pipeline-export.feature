@justbrief @pipeline-export
Feature: Pipeline Data Export
  As a Regional SPOC or EPAM admin
  I want to export pipeline data to CSV
  So that I can analyze and report on campaign pipelines

  Background:
    Given the JustBrief platform is running
    And the user is authenticated via SIGA

  # ============================================================================
  # HAPPY PATH SCENARIOS
  # ============================================================================

  @smoke @JSN-004
  Scenario: Regional SPOC exports all pipelines to CSV
    Given the user has role "regional_spoc"
    And 10 pipelines exist in the system
    When the user clicks "Export to CSV"
    Then a CSV file is generated
    And the file is downloaded automatically
    And the filename includes the current date
    And the CSV contains 10 pipeline records

  @smoke @JSN-004
  Scenario: CSV export includes all pipeline fields
    Given the user has role "regional_spoc"
    And pipelines exist in the system
    When the user exports pipelines to CSV
    Then the CSV contains the following columns:
      | Column Name       |
      | Pipeline ID       |
      | Name              |
      | Description       |
      | Status            |
      | Campaign Type     |
      | Created Date      |
      | Start Date        |
      | End Date          |
      | Created By        |
      | Assigned Markets  |
      | Brief Count       |

  @smoke @JSN-004
  Scenario: EPAM admin exports pipelines with brief information
    Given the user has role "epam_admin"
    And pipelines exist with submitted briefs
    When the user exports pipelines to CSV
    Then the CSV includes brief-related columns:
      | Column Name           |
      | Total Briefs          |
      | Submitted Briefs      |
      | Draft Briefs          |
      | Approved Briefs       |

  # ============================================================================
  # FILTERING SCENARIOS
  # ============================================================================

  @regression @JSN-004
  Scenario: Regional SPOC exports pipelines filtered by status
    Given the user has role "regional_spoc"
    And pipelines exist with various statuses:
      | Status    | Count |
      | Active    | 5     |
      | Draft     | 3     |
      | Cancelled | 2     |
      | Completed | 4     |
    When the user filters by status "Active"
    And exports to CSV
    Then the CSV contains only 5 Active pipelines
    And pipelines with other statuses are excluded

  @regression @JSN-004
  Scenario: Regional SPOC exports pipelines filtered by market
    Given the user has role "regional_spoc"
    And pipelines exist assigned to markets "DE", "FR", "IT"
    When the user filters by market "DE"
    And exports to CSV
    Then the CSV contains only pipelines assigned to market "DE"
    And pipelines assigned to other markets are excluded

  @regression @JSN-004
  Scenario: Regional SPOC exports pipelines filtered by campaign type
    Given the user has role "regional_spoc"
    And pipelines exist with campaign types:
      | Campaign Type | Count |
      | Instant Win   | 6     |
      | Multi-Channel | 4     |
    When the user filters by campaign type "Instant Win"
    And exports to CSV
    Then the CSV contains only 6 Instant Win pipelines

  @regression @JSN-004
  Scenario: Regional SPOC exports pipelines filtered by date range
    Given the user has role "regional_spoc"
    And pipelines exist with various start dates
    When the user filters by start date range "2026-07-01" to "2026-09-30"
    And exports to CSV
    Then the CSV contains only pipelines starting within that date range

  @regression @JSN-004
  Scenario: Regional SPOC applies multiple filters
    Given the user has role "regional_spoc"
    And pipelines exist with various attributes
    When the user filters by:
      | Filter         | Value       |
      | Status         | Active      |
      | Market         | DE          |
      | Campaign Type  | Instant Win |
    And exports to CSV
    Then the CSV contains only pipelines matching all filter criteria

  # ============================================================================
  # CSV FORMAT AND ENCODING
  # ============================================================================

  @regression @JSN-004
  Scenario: CSV export uses proper formatting
    Given the user exports pipelines to CSV
    When the CSV file is generated
    Then the CSV uses comma as delimiter
    And text fields are enclosed in double quotes
    And the first row contains column headers
    And date fields are formatted as "YYYY-MM-DD"

  @regression @JSN-004
  Scenario: CSV export handles special characters
    Given a pipeline exists with name "Campaign "Summer" 2026"
    And the pipeline description contains commas and newlines
    When the user exports to CSV
    Then special characters are properly escaped
    And the CSV can be opened in Excel without errors

  @regression @JSN-004
  Scenario: CSV export uses UTF-8 encoding
    Given pipelines exist with names in German, French, and Italian
    When the user exports to CSV
    Then the CSV file uses UTF-8 encoding
    And all special characters are preserved correctly
    And the file can be opened in Excel with proper encoding

  @regression @JSN-004
  Scenario: CSV export handles multi-value fields
    Given a pipeline is assigned to markets "DE", "FR", "IT"
    When the user exports to CSV
    Then the "Assigned Markets" column contains "DE; FR; IT"
    And markets are separated by semicolons

  # ============================================================================
  # EXPORT PERMISSIONS
  # ============================================================================

  @regression @JSN-004
  Scenario: Regional SPOC can export pipelines in their region
    Given the user has role "regional_spoc" for region "EU"
    And pipelines exist for EU and AP regions
    When the user exports to CSV
    Then the CSV contains only EU region pipelines
    And AP region pipelines are excluded

  @regression @JSN-004
  Scenario: EPAM admin can export all pipelines globally
    Given the user has role "epam_admin"
    And pipelines exist for multiple regions
    When the user exports to CSV
    Then the CSV contains pipelines from all regions

  @regression @JSN-004
  Scenario: Market user cannot export pipelines
    Given the user has role "market_user"
    When the user attempts to export pipelines
    Then the export is denied with status code 403
    And the error message is "Insufficient permissions to export pipelines"

  # ============================================================================
  # LARGE DATASET EXPORT
  # ============================================================================

  @regression @JSN-004
  Scenario: Export handles large number of pipelines
    Given the user has role "epam_admin"
    And 1000 pipelines exist in the system
    When the user exports all pipelines to CSV
    Then the CSV is generated successfully
    And all 1000 pipelines are included
    And the export completes within 30 seconds

  @regression @JSN-004
  Scenario: Export with pagination for very large datasets
    Given the user has role "epam_admin"
    And 5000 pipelines exist in the system
    When the user exports all pipelines
    Then the export is processed in batches
    And a single CSV file is generated
    And all 5000 pipelines are included

  # ============================================================================
  # EXPORT CUSTOMIZATION
  # ============================================================================

  @regression @JSN-004
  Scenario: User selects specific columns to export
    Given the user has role "regional_spoc"
    When the user opens export options
    And the user selects columns:
      | Column Name      |
      | Name             |
      | Status           |
      | Assigned Markets |
      | Start Date       |
    And exports to CSV
    Then the CSV contains only the selected columns
    And other columns are excluded

  @regression @JSN-004
  Scenario: User saves export configuration as preset
    Given the user has role "regional_spoc"
    When the user configures export filters and columns
    And the user saves the configuration as "Monthly Report"
    Then the preset is saved
    And the user can load the preset for future exports

  # ============================================================================
  # FILENAME AND METADATA
  # ============================================================================

  @regression @JSN-004
  Scenario: CSV filename includes timestamp
    Given the user exports pipelines on "2026-03-20 14:30:00"
    When the CSV is generated
    Then the filename is "JustBrief_Pipelines_20260320_143000.csv"

  @regression @JSN-004
  Scenario: CSV filename includes filter information
    Given the user filters by status "Active" and market "DE"
    When the user exports to CSV
    Then the filename is "JustBrief_Pipelines_Active_DE_20260320_143000.csv"

  # ============================================================================
  # VALIDATION SCENARIOS
  # ============================================================================

  @regression @JSN-004
  Scenario: Export fails gracefully when no pipelines match filters
    Given the user has role "regional_spoc"
    And the user filters by status "Active" and market "XX"
    And no pipelines match the criteria
    When the user attempts to export
    Then the export is prevented
    And the message is "No pipelines match the selected filters"

  @regression @JSN-004
  Scenario: Export validates date range filters
    Given the user has role "regional_spoc"
    When the user sets start date "2026-09-30" and end date "2026-07-01"
    And attempts to export
    Then the export is prevented
    And the error message is "End date must be after start date"

  # ============================================================================
  # AUDIT AND TRACKING
  # ============================================================================

  @regression @JSN-004
  Scenario: Pipeline export is logged in audit trail
    Given the user has role "regional_spoc"
    When the user exports pipelines to CSV
    Then an audit log entry is created
    And the entry contains:
      | Field           | Value                    |
      | Action          | Pipeline Export          |
      | User ID         | [user ID]                |
      | Timestamp       | [export timestamp]       |
      | Filters Applied | [filter details]         |
      | Record Count    | [number of pipelines]    |

  @regression @JSN-004
  Scenario: Export includes data as of export time
    Given pipelines exist in the system
    And the user exports at "2026-03-20 14:30:00"
    When the CSV is generated
    Then the data reflects the state at "2026-03-20 14:30:00"
    And subsequent changes are not included

  # ============================================================================
  # ERROR SCENARIOS
  # ============================================================================

  @regression @error-handling
  Scenario: Database unavailable during export
    Given the user has role "regional_spoc"
    And the PMI database is unavailable
    When the user attempts to export pipelines
    Then the export fails with status code 503
    And the error message is "Unable to export data. Please try again later."

  @regression @error-handling
  Scenario: Export timeout for very large dataset
    Given the user has role "epam_admin"
    And 10000 pipelines exist
    When the user exports all pipelines
    And the export takes longer than 60 seconds
    Then the export times out
    And the error message is "Export timed out. Please apply filters to reduce dataset size."

  @regression @error-handling
  Scenario: Disk space insufficient for export
    Given the user exports a large dataset
    When the server disk space is insufficient
    Then the export fails gracefully
    And the error message is "Export failed due to server storage issue"
    And an alert is sent to administrators

  # ============================================================================
  # ALTERNATIVE EXPORT FORMATS
  # ============================================================================

  @regression @JSN-004
  Scenario: User exports pipelines to Excel format
    Given the user has role "regional_spoc"
    When the user selects "Export to Excel"
    Then an Excel file (.xlsx) is generated
    And the file contains a worksheet with pipeline data
    And columns are properly formatted

  @regression @JSN-004
  Scenario: User exports pipelines to JSON format
    Given the user has role "epam_admin"
    When the user selects "Export to JSON"
    Then a JSON file is generated
    And the JSON contains an array of pipeline objects
    And all fields are included with proper data types

  # ============================================================================
  # NFR SCENARIOS
  # ============================================================================

  @nfr @performance
  Scenario: CSV export completes quickly for typical dataset
    Given the user has role "regional_spoc"
    And 100 pipelines exist
    When the user exports to CSV
    Then the export completes within 5 seconds
    And the file download begins immediately

  @nfr @performance
  Scenario: Export does not impact system performance
    Given 5 users are exporting pipelines simultaneously
    When all exports are in progress
    Then the system remains responsive
    And other users can continue using JustBrief
    And all exports complete successfully

  @nfr @usability
  Scenario: Export interface is intuitive
    Given the user has role "regional_spoc"
    When the user accesses the export feature
    Then the interface clearly shows available filters
    And the interface shows a preview of record count
    And the interface provides helpful tooltips

  @nfr @security
  Scenario: Exported CSV contains only authorized data
    Given the user has role "regional_spoc" for region "EU"
    When the user exports pipelines
    Then the CSV contains only EU region data
    And no unauthorized data is included
    And the export is validated before download

  @nfr @security
  Scenario: Export files are not cached or stored permanently
    Given the user exports pipelines to CSV
    When the export completes
    Then the CSV is generated on-demand
    And the file is streamed directly to the user
    And no copy is stored on the server
    And the file is not cached in CDN
