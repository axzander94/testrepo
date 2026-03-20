Feature: Asset Upload and Management
  As a Market user
  I want to upload campaign assets and provide metadata
  So that EPAM has all necessary materials for campaign development

  Background:
    Given I am authenticated as a Market user
    And I have an active campaign brief in progress

  Scenario: Upload campaign assets with metadata
    Given I am on the asset upload section of my brief
    When I drag and drop files:
      | Filename | Type | Size |
      | logo.png | image/png | 2MB |
      | video.mp4 | video/mp4 | 15MB |
      | banner.jpg | image/jpeg | 1.5MB |
    And I provide metadata for each asset:
      | Asset | Description | Usage Context |
      | logo.png | Company logo | Header and footer |
      | video.mp4 | Product demo | Landing page hero |
      | banner.jpg | Campaign banner | Social media |
    And I click "Upload Assets"
    Then all assets should be uploaded successfully
    And I should see upload progress for each file
    And assets should appear in the asset list with metadata

  Scenario: Asset upload validation
    Given I am uploading campaign assets
    When I try to upload an invalid file:
      | Filename | Issue |
      | malware.exe | Unsupported file type |
      | huge_file.mp4 | File size exceeds 100MB limit |
      | corrupted.jpg | File is corrupted |
    Then the upload should be rejected
    And I should see appropriate error messages
    And valid files should still upload successfully

  Scenario: Asset metadata management
    Given I have uploaded assets to my brief
    When I click on an asset "logo.png"
    Then I should see the asset details modal
    And I should be able to edit the metadata:
      | Field | New Value |
      | Description | Updated company logo |
      | Usage Context | All campaign materials |
    When I save the changes
    Then the metadata should be updated
    And the changes should be reflected in the asset list

  Scenario: Remove uploaded asset
    Given I have uploaded multiple assets
    When I select asset "banner.jpg"
    And I click "Remove Asset"
    And I confirm the removal
    Then the asset should be removed from the brief
    And the file should be deleted from storage
    And the asset should no longer appear in the list

  Scenario: Asset download and preview
    Given I have uploaded assets to my brief
    When I click "Preview" on asset "video.mp4"
    Then I should see a preview of the video
    When I click "Download" on asset "logo.png"
    Then the file should be downloaded to my device

  Scenario: Bulk asset operations
    Given I have uploaded multiple assets
    When I select multiple assets using checkboxes
    And I click "Bulk Actions"
    Then I should see options for:
      | Action |
      | Download Selected |
      | Remove Selected |
      | Update Metadata |
    When I choose "Remove Selected"
    And I confirm the action
    Then all selected assets should be removed