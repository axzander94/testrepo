@justbrief @asset-upload
Feature: Campaign Asset Upload and Management
  As a Market user
  I want to upload campaign assets with metadata
  So that EPAM has all necessary files for campaign development

  Background:
    Given the JustBrief platform is running
    And the user is authenticated via SIGA as "market_user" for market "DE"
    And a draft brief exists for the user

  # ============================================================================
  # HAPPY PATH SCENARIOS - Asset Upload
  # ============================================================================

  @smoke @JSN-008
  Scenario: Market user uploads a single asset
    Given the user is on the asset upload page
    When the user selects a file "campaign-banner.jpg" (2 MB)
    And the user provides asset metadata:
      | Field       | Value                    |
      | Name        | Campaign Banner          |
      | Description | Main campaign banner     |
      | Usage       | Homepage hero image      |
    And the user uploads the asset
    Then the asset is uploaded successfully to S3
    And the asset metadata is stored in the database
    And the asset is linked to the brief
    And a success message is displayed "Asset uploaded successfully"

  @smoke @JSN-008
  Scenario: Market user uploads multiple assets
    Given the user is on the asset upload page
    When the user selects 3 files:
      | Filename           | Size  |
      | banner.jpg         | 2 MB  |
      | video-intro.mp4    | 15 MB |
      | terms-conditions.pdf | 500 KB |
    And the user uploads all assets
    Then all 3 assets are uploaded successfully
    And each asset has a unique S3 key
    And all assets are linked to the brief
    And the asset count is updated to 3

  @smoke @JSN-008
  Scenario: Market user provides asset metadata
    Given the user has selected a file for upload
    When the user fills the metadata form:
      | Field           | Value                          |
      | Asset Name      | Campaign Video                 |
      | Description     | 30-second promotional video    |
      | Usage Context   | Landing page video player      |
      | Asset Type      | Video                          |
      | Language        | German                         |
    Then the metadata is captured
    And the metadata is stored with the asset

  # ============================================================================
  # DRAG AND DROP UPLOAD
  # ============================================================================

  @regression @JSN-008
  Scenario: Market user uploads assets via drag and drop
    Given the user is on the asset upload page
    When the user drags a file "banner.jpg" into the drop zone
    And the user drops the file
    Then the file is queued for upload
    And the metadata form is displayed
    And the user can provide metadata before uploading

  @regression @JSN-008
  Scenario: Market user drags multiple files at once
    Given the user is on the asset upload page
    When the user drags 5 files into the drop zone
    And the user drops the files
    Then all 5 files are queued for upload
    And the user can provide metadata for each file
    And the user can upload all files in batch

  # ============================================================================
  # UPLOAD PROGRESS
  # ============================================================================

  @regression @JSN-020
  Scenario: Market user sees upload progress for large files
    Given the user is uploading a file "video.mp4" (50 MB)
    When the upload is in progress
    Then a progress bar is displayed
    And the progress percentage is updated in real-time
    And the estimated time remaining is shown
    And the user can cancel the upload if needed

  @regression @JSN-020
  Scenario: Market user uploads multiple files with progress tracking
    Given the user is uploading 3 files simultaneously
    When the uploads are in progress
    Then each file shows its own progress bar
    And the overall upload progress is displayed
    And completed uploads are marked with a checkmark

  @regression @JSN-020
  Scenario: Market user can cancel an in-progress upload
    Given the user is uploading a file "large-video.mp4" (80 MB)
    And the upload is 30% complete
    When the user clicks "Cancel Upload"
    Then the upload is stopped
    And the partial file is not saved
    And the asset is not added to the brief

  # ============================================================================
  # FILE SIZE VALIDATION
  # ============================================================================

  @regression @JSN-020
  Scenario: Asset upload within size limit is accepted
    Given the user selects a file "banner.jpg" (50 MB)
    When the user uploads the file
    Then the upload is accepted
    And the file is uploaded to S3

  @regression @JSN-020
  Scenario: Asset exceeding size limit is rejected
    Given the user selects a file "large-video.mp4" (150 MB)
    When the user attempts to upload the file
    Then the upload is rejected
    And the error message is "File size exceeds maximum limit of 100 MB"
    And the file is not uploaded

  @regression @JSN-020
  Scenario: Multiple files with combined size exceeding limit
    Given the user selects 3 files totaling 250 MB
    When the user attempts to upload all files
    Then each file is validated individually
    And files under 100 MB are accepted
    And files over 100 MB are rejected
    And appropriate error messages are shown for rejected files

  # ============================================================================
  # FILE TYPE VALIDATION
  # ============================================================================

  @regression @JSN-008
  Scenario: Supported file types are accepted
    Given the user selects files with the following extensions:
      | Extension |
      | .jpg      |
      | .png      |
      | .pdf      |
      | .mp4      |
      | .zip      |
    When the user uploads the files
    Then all files are accepted
    And all files are uploaded successfully

  @regression @JSN-008
  Scenario: Unsupported file type is rejected
    Given the user selects a file "script.exe"
    When the user attempts to upload the file
    Then the upload is rejected
    And the error message is "File type .exe is not supported"
    And the file is not uploaded

  @regression @JSN-008
  Scenario: File with no extension is rejected
    Given the user selects a file "document" with no extension
    When the user attempts to upload the file
    Then the upload is rejected
    And the error message is "File must have a valid extension"

  # ============================================================================
  # ASSET METADATA MANAGEMENT
  # ============================================================================

  @regression @JSN-008
  Scenario: Market user edits asset metadata after upload
    Given an asset "banner.jpg" has been uploaded
    When the user edits the asset metadata
    And changes the description to "Updated banner description"
    And saves the changes
    Then the metadata is updated successfully
    And the updated metadata is stored in the database

  @regression @JSN-008
  Scenario: Asset metadata includes custom properties
    Given the user is providing asset metadata
    When the user adds custom properties:
      | Property Key    | Property Value |
      | Resolution      | 1920x1080      |
      | Color Profile   | sRGB           |
      | Aspect Ratio    | 16:9           |
    Then the custom properties are saved
    And the properties are stored as JSON in the database

  @regression @JSN-008
  Scenario: Mandatory metadata fields are validated
    Given the user has selected a file for upload
    When the user attempts to upload without providing "Asset Name"
    Then the upload is prevented
    And the error message is "Asset name is required"

  # ============================================================================
  # ASSET LIST AND MANAGEMENT
  # ============================================================================

  @regression @JSN-008
  Scenario: Market user views all uploaded assets for a brief
    Given 5 assets have been uploaded for the brief
    When the user views the asset list
    Then all 5 assets are displayed
    And each asset shows:
      | Field        |
      | Filename     |
      | File size    |
      | Upload date  |
      | Uploaded by  |
      | Description  |

  @regression @JSN-008
  Scenario: Market user downloads an uploaded asset
    Given an asset "banner.jpg" has been uploaded
    When the user clicks "Download" for the asset
    Then a presigned S3 URL is generated
    And the file download begins
    And the file is downloaded successfully

  @regression @JSN-008
  Scenario: Market user deletes an asset from a draft brief
    Given an asset "old-banner.jpg" has been uploaded
    And the brief is in "Draft" status
    When the user clicks "Delete" for the asset
    And confirms the deletion
    Then the asset is removed from the brief
    And the asset metadata is deleted from the database
    And the file remains in S3 for audit purposes

  @regression @JSN-008
  Scenario: Market user cannot delete assets from submitted brief
    Given an asset has been uploaded
    And the brief status is "Submitted"
    When the user attempts to delete the asset
    Then the deletion is prevented
    And the message is "Assets cannot be deleted from submitted briefs"

  # ============================================================================
  # S3 STORAGE
  # ============================================================================

  @regression @JSN-020
  Scenario: Asset is stored in S3 with unique key
    Given the user uploads a file "banner.jpg"
    When the upload completes
    Then the file is stored in S3
    And the S3 key follows the pattern "briefs/{briefId}/assets/{assetId}/{filename}"
    And the S3 key is unique
    And the S3 key is stored in the database

  @regression @JSN-020
  Scenario: Asset download uses presigned S3 URL
    Given an asset is stored in S3
    When the user requests to download the asset
    Then a presigned URL is generated with 1-hour expiry
    And the URL is returned to the user
    And the user can download the file using the URL

  @regression @JSN-020
  Scenario: Presigned URL expires after time limit
    Given an asset download URL was generated 2 hours ago
    When the user attempts to use the expired URL
    Then the download fails
    And the error message is "Download link has expired"
    And the user can request a new download link

  # ============================================================================
  # BOUNDARY SCENARIOS
  # ============================================================================

  @regression @boundary
  Scenario: Asset at exactly 100 MB is accepted
    Given the user selects a file "video.mp4" (exactly 100 MB)
    When the user uploads the file
    Then the upload is accepted
    And the file is uploaded successfully

  @regression @boundary
  Scenario: Asset at 100.1 MB is rejected
    Given the user selects a file "video.mp4" (100.1 MB)
    When the user attempts to upload the file
    Then the upload is rejected
    And the error message is "File size exceeds maximum limit of 100 MB"

  @regression @boundary
  Scenario: Brief with maximum number of assets is accepted
    Given the user has uploaded 50 assets
    When the user attempts to upload one more asset
    Then the upload is accepted
    And the brief now has 51 assets

  @regression @boundary
  Scenario: Asset filename at maximum length is accepted
    Given the user selects a file with a 255-character filename
    When the user uploads the file
    Then the upload is accepted
    And the full filename is preserved

  # ============================================================================
  # CONCURRENT UPLOAD SCENARIOS
  # ============================================================================

  @regression @concurrency
  Scenario: Multiple users upload assets to different briefs simultaneously
    Given user A is uploading assets to brief 1
    And user B is uploading assets to brief 2
    When both uploads occur simultaneously
    Then both uploads complete successfully
    And assets are correctly associated with their respective briefs

  @regression @concurrency
  Scenario: User uploads multiple files concurrently
    Given the user selects 10 files for upload
    When the user uploads all files
    Then up to 3 files are uploaded concurrently
    And remaining files are queued
    And all files complete successfully

  # ============================================================================
  # ERROR SCENARIOS
  # ============================================================================

  @regression @error-handling
  Scenario: S3 service unavailable during upload
    Given the user attempts to upload a file
    And AWS S3 is unavailable
    When the upload is processed
    Then the upload fails with status code 503
    And the error message is "Storage service temporarily unavailable"
    And the user is prompted to retry

  @regression @error-handling
  Scenario: Network interruption during upload
    Given the user is uploading a file "video.mp4" (50 MB)
    And the upload is 50% complete
    When the network connection is lost
    Then the upload fails
    And the error message is "Upload failed due to network error"
    And the user can retry the upload

  @regression @error-handling
  Scenario: Database failure during metadata save
    Given the user uploads a file successfully to S3
    When the metadata save to database fails
    Then the upload is rolled back
    And the S3 file is marked for cleanup
    And the error message is "Failed to save asset metadata"
    And the user can retry the upload

  @regression @error-handling
  Scenario: Corrupted file upload is detected
    Given the user uploads a file "image.jpg"
    When the file is corrupted or incomplete
    Then the upload is rejected
    And the error message is "File appears to be corrupted"
    And the file is not saved

  @regression @error-handling
  Scenario: Virus detected in uploaded file
    Given the user uploads a file "document.pdf"
    When the file contains malicious content
    Then the upload is rejected
    And the error message is "File failed security scan"
    And the file is not saved
    And the incident is logged for security review

  # ============================================================================
  # NFR SCENARIOS
  # ============================================================================

  @nfr @performance @JSN-020
  Scenario: Asset upload completes within acceptable time
    Given the user uploads a file "video.mp4" (50 MB)
    And the user has a standard internet connection (10 Mbps)
    When the upload is processed
    Then the upload completes within 5 minutes
    And progress is shown throughout

  @nfr @performance
  Scenario: Asset list loads quickly
    Given a brief has 50 assets
    When the user views the asset list
    Then the list loads within 2 seconds
    And thumbnails are lazy-loaded

  @nfr @performance
  Scenario: Multiple concurrent uploads do not degrade performance
    Given 10 users are uploading assets simultaneously
    When all uploads are in progress
    Then each upload maintains acceptable speed
    And the system remains responsive

  @nfr @security
  Scenario: Asset files are encrypted at rest in S3
    Given the user uploads a file
    When the file is stored in S3
    Then the file is encrypted using AES-256
    And the encryption is verified

  @nfr @security
  Scenario: Asset download URLs are secure and time-limited
    Given an asset is stored in S3
    When a download URL is generated
    Then the URL is a presigned URL with 1-hour expiry
    And the URL cannot be guessed or enumerated
    And the URL is unique per request

  @nfr @security
  Scenario: Asset access is restricted by market
    Given user A from market "DE" uploads an asset
    When user B from market "FR" attempts to access the asset
    Then the access is denied with status code 403
    And no asset data is returned

  @nfr @usability
  Scenario: Asset upload interface is intuitive
    Given the user is on the asset upload page
    When the user views the interface
    Then clear instructions are displayed
    And supported file types are listed
    And file size limits are shown
    And drag-and-drop zone is clearly marked

  @nfr @usability
  Scenario: Upload errors provide actionable guidance
    Given the user attempts to upload an invalid file
    When the upload fails
    Then the error message explains the problem
    And the message suggests how to fix the issue
    And the user can easily retry with a corrected file
