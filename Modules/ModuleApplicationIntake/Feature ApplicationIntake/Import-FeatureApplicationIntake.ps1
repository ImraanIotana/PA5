####################################################################################################
<#
.SYNOPSIS
    This function imports the feature Application Intake.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureApplicationIntake -ParentTabPage $Global:MyTabPage
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.4.5
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : July 2025
#>
####################################################################################################

function Import-FeatureApplicationIntake {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent object to which this feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ParentTabPage           = $ParentTabPage
            # Groupbox Handlers
            GroupboxTitle           = [System.String]'Application Intake'
            GroupboxColor           = [System.String]'LightCyan'
            GroupboxNumberOfRows    = [System.Int32]13
            # Handlers
            AssetFolder             = [System.String](Join-Path -Path $PSScriptRoot -ChildPath 'Assets')
            IntakeDocumentFileName  = [System.String]'KS Client Application Form.docx'
            HelpFileName            = [System.String]'HelpFile ModuleApplicationIntake.pdf'
            ZipFileName             = [System.String]'UniversalDeploymentScript.zip'
            CustomerDepartments     = [System.String[]]($Global:ApplicationObject.Settings.CustomerDepartments)
            StartMenuItemsTotal     = Get-StartMenuItems -AsComboboxList
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the GroupBox (This groupbox must be global to relate to the second groupbox, and for use in button functions)
            [System.Windows.Forms.GroupBox]$Global:ApplicationIntakeGroupBox = Invoke-Groupbox -ParentTabPage $this.ParentTabPage -Title $this.GroupboxTitle -NumberOfRows $this.GroupboxNumberOfRows -Color $this.GroupboxColor
            # Add the properties for the button function
            $Global:ApplicationIntakeGroupBox | Add-Member -NotePropertyName IntakeDocumentSourcePath -NotePropertyValue (Join-Path -Path $this.AssetFolder -ChildPath $this.IntakeDocumentFileName)
            $Global:ApplicationIntakeGroupBox | Add-Member -NotePropertyName HelpFilePath -NotePropertyValue (Join-Path -Path $this.AssetFolder -ChildPath $this.HelpFileName)
            $Global:ApplicationIntakeGroupBox | Add-Member -NotePropertyName ZipFileSourcePath -NotePropertyValue (Join-Path -Path $this.AssetFolder -ChildPath $this.ZipFileName)
            # Set the properties for the boxes
            [System.Windows.Forms.GroupBox]$ParentGroupBox = $Global:ApplicationIntakeGroupBox
            [System.String]$SizeType = 'Small'
            [System.Int32]$RowCounter = 3
            # Create the Applications ComboBox
            [System.Windows.Forms.ComboBox]$Global:AILocalApplicationsComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType $SizeType -Type Output -ContentArray (Get-LocallyInstalledApplications -DisplaynamesOnly) -Label 'Select from Registry:' -PropertyName 'AILocalApplicationsComboBox'
            # Create the VendorName TextBoxes
            [System.Windows.Forms.TextBox]$Global:AIVendorNameFullTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'Vendor Name (Formal):' -PropertyName 'AIVendorNameFullTextBox'
            [System.Windows.Forms.TextBox]$Global:AIVendorNameShortTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'Vendor Name (Custom):' -PropertyName 'AIVendorNameShortTextBox'
            # Create the ApplicationName TextBoxes
            [System.Windows.Forms.TextBox]$Global:AIApplicationNameFullTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'Application Name (Formal):' -PropertyName 'AIApplicationNameFullTextBox'
            [System.Windows.Forms.TextBox]$Global:AIApplicationNameShortTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'Application Name (Custom):' -PropertyName 'AIApplicationNameShortTextBox'
            # Create the ApplicationVersion TextBoxes
            [System.Windows.Forms.TextBox]$Global:AIApplicationVersionFullTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'Version (Formal):' -PropertyName 'AIApplicationVersionFullTextBox'
            [System.Windows.Forms.TextBox]$Global:AIApplicationVersionShortTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'Version (Custom):' -PropertyName 'AIApplicationVersionShortTextBox'
            # Create the Additional TextBoxes/ComboBoxes
            [System.Windows.Forms.TextBox]$Global:AIInstallLocationTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'Install Location:' -PropertyName 'AIInstallLocationTextBox'
            [System.Windows.Forms.TextBox]$Global:AIDetectionFileTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'Detection File:' -PropertyName 'AIDetectionFileTextBox'
            [System.Windows.Forms.ComboBox]$Global:AIStartMenuFolderComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Output -ContentArray $this.StartMenuItemsTotal -Label 'StartMenu Folder/File:' -PropertyName 'AIStartMenuFolderComboBox'
            #[System.Windows.Forms.TextBox]$Global:AIStartMenuFolderComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'StartMenu Folder/File:' -PropertyName 'AIStartMenuFolderComboBox'
            [System.Windows.Forms.TextBox]$Global:AIADGroupNameTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'AD Group Name:' -PropertyName 'AIADGroupNameTextBox'
            [System.Windows.Forms.TextBox]$Global:AIADGroupSIDTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -Label 'AD Group SID:' -PropertyName 'AIADGroupSIDTextBox'
            [System.Windows.Forms.ComboBox]$Global:AICustomerDepartmentComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Output -ContentArray $this.CustomerDepartments -Label 'Customer/Department:' -PropertyName 'AICustomerDepartmentComboBox'
            #[System.Windows.Forms.ComboBox]$Global:AIApplicationBitVersionComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber ($RowCounter++) -SizeType $SizeType -Type Input -ContentArray $('32bit','64bit') -Label 'Bit Version:' -PropertyName 'AIApplicationBitVersionComboBox'
            # Create the Output TextBox
            [System.Windows.Forms.TextBox]$Global:AIApplicationIDTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 16 -SizeType $SizeType -Type Output -Label 'Application Name:' -PropertyName 'AIApplicationIDTextBox'
            # Create the Buttons
            Invoke-ButtonLine -ButtonPropertiesArray $this.ApplicationIntakeButtons() -ParentGroupBox $ParentGroupBox -ColumnNumber 4 #-AssetFolder $PSScriptRoot
            #Invoke-ButtonLine -ButtonPropertiesArray $this.GetRegistryExportButtons() -ParentGroupBox $ParentGroupBox -ColumnNumber 5 -AssetFolder $this.AssetFolder
            Invoke-ButtonLine -ButtonPropertiesArray $this.SmallButtons -ParentGroupBox $ParentGroupBox -ColumnNumber 4 #-AssetFolder $PSScriptRoot
            Invoke-ButtonLine -ButtonPropertiesArray $this.GetEnterButtons() -ParentGroupBox $ParentGroupBox -ColumnNumber 2 #-AssetFolder $PSScriptRoot
            Invoke-ButtonLine -ButtonPropertiesArray $this.GetHelpButtons() -ParentGroupBox $ParentGroupBox -RowNumber 16 #-AssetFolder $PSScriptRoot
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        # Add the ApplicationIntakeButtons method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ApplicationIntakeButtons -Value {
            # Return the button properties
            @(
                @{
                    RowNumber       = 16
                    Text            = 'Create Folder'
                    SizeType        = 'Medium'
                    Image           = 'folder_add.png'
                    Function        = {
                        try {
                            # Get confirmation
                            [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title 'Create folder' -Body 'This will create a new Application Folder. Are you sure?'
                            if (-Not($UserConfirmed)) { Return }
                            if (-Not(Confirm-Object -MandatoryBox $Global:AIApplicationIDTextBox)) { Return }
                            # Create a new folder
                            New-ApplicationFolder
                            # Set the properties
                            [System.String]$ApplicationID = $Global:AIApplicationIDTextBox.Text
                            New-MetaDataFile -ApplicationID $ApplicationID
                            Format-WordDocument -IntakeDocumentSourcePath $Global:ApplicationIntakeGroupBox.IntakeDocumentSourcePath -Confirm
                            Expand-DeploymentScript -ZipFileSourcePath $Global:ApplicationIntakeGroupBox.ZipFileSourcePath -Confirm
                            # Set the new folders
                            [System.String]$NewLocalApplicationFolder = Join-Path -Path (Get-Path -OutputFolder) -ChildPath $ApplicationID
                            [System.String]$AppLockerFolder     = Join-Path -Path $NewLocalApplicationFolder -ChildPath (Get-ApplicationSubfolders).AppLockerFolder
                            [System.String]$ArchiveOtherFolder  = Join-Path -Path $NewLocalApplicationFolder -ChildPath (Get-ApplicationSubfolders).ArchiveOtherFolder
                            # Create the ARP file
                            if (Test-StringIsPopulated -String $Global:AILocalApplicationsComboBox.Text) {
                                Get-LocallyInstalledApplications -ExportProperties -DisplayName $Global:AILocalApplicationsComboBox.Text -OutputFolder $ArchiveOtherFolder
                            } else {
                                Write-Warning 'The "Select from Registry" field is empty. No Registry information will be obtained.'
                            }
                            # Export the shortcut information
                            if (Test-StringIsPopulated -String $Global:AIStartMenuFolderComboBox.Text) {
                                [System.String]$ConvertedShortcutPath = Convert-ShortcutPath -Path $Global:AIStartMenuFolderComboBox.Text
                                Export-ShortcutInformation -Path $ConvertedShortcutPath -ParentOutputFolder $ArchiveOtherFolder
                                New-DEMShortcut -ApplicationID $ApplicationID -StartMenuItemPath $Global:AIStartMenuFolderComboBox.Text -Confirm
                            } else {
                                Write-Warning 'The Shortcut field is empty. No shortcut information will be obtained.'
                            }
                            # Set the Applocker properties
                            New-AppLockerFile -Path $Global:AIInstallLocationTextBox.Text -ADGroupSID $Global:AIADGroupSIDTextBox.Text -OutputFolder $AppLockerFolder -ApplicationID $Global:AIApplicationIDTextBox.Text -AskUserConfirmation
                            Move-Screenshots -FromNetworkScreenshotsFolder -ToLocalApplicationFolder -Confirm
                        }
                        catch {
                            Write-FullError
                        }
                        finally {
                            Open-Folder -Path (Get-Path -OutputFolder)
                        }
                    }
                }
            )
        }

        # Add the GetRegistryExportButtons method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetRegistryExportButtons -Value {
            # Return the button properties
            @(
                @{
                    RowNumber       = 1
                    Text            = 'Export Details'
                    SizeType        = 'Medium'
                    Image           = 'layer_export.png'
                    Function        = {
                        if (-Not(Confirm-Object -MandatoryBox $Global:AILocalApplicationsComboBox)) { Return }
                        Get-LocallyInstalledApplications -ExportProperties -DisplayName $Global:AILocalApplicationsComboBox.Text
                    }
                }
            )
        }

        # Add the SmallButtons method
        $Local:MainObject | Add-Member -NotePropertyName SmallButtons -NotePropertyValue (
            # Return the button properties
            @(
                @{
                    RowNumber       = 1
                    Text            = 'Refresh'
                    SizeType        = 'Small'
                    Image           = 'arrow_refresh.png'
                    ToolTip         = 'Refresh the lists'
                    Function        = {
                        Update-ComboBox -ComboBox $Global:AILocalApplicationsComboBox -NewContent (Get-LocallyInstalledApplications -DisplaynamesOnly) -OutHost
                        Update-ComboBox -ComboBox $Global:AIStartMenuFolderComboBox -NewContent (Get-StartMenuItems -AsComboboxList) -OutHost
                    }
                }
                @{
                    RowNumber       = 9
                    Text            = 'Browse'
                    Image           = 'folders_explorer.png'
                    SizeType        = 'Small'
                    Function        = { [System.String]$FolderName = Select-Item -Folder ; if ($FolderName) { $Global:AIInstallLocationTextBox.Text = $FolderName } }
                }
                @{
                    RowNumber       = 10
                    Text            = 'Browse'
                    Image           = 'folders_explorer.png'
                    SizeType        = 'Small'
                    Function        = { [System.String]$FileName = Select-Item -File -InitialDirectory $Global:AIInstallLocationTextBox.Text ; if ($FileName) { $Global:AIDetectionFileTextBox.Text = $FileName } }
                }
                @{
                    RowNumber       = 12
                    Text            = 'Paste'
                    Image           = 'page_paste.png'
                    SizeType        = 'Small'
                    Function        = { Invoke-ClipBoard -PasteToBox $Global:AIADGroupNameTextBox }
                }
                @{
                    RowNumber       = 13
                    Text            = 'Paste'
                    Image           = 'page_paste.png'
                    SizeType        = 'Small'
                    Function        = { Invoke-ClipBoard -PasteToBox $Global:AIADGroupSIDTextBox }
                }
            )
        )

        # Add the GetEnterButtons method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetEnterButtons -Value {
            # Return the button properties
            @(
                @{
                    RowNumber       = 2
                    Text            = 'Import Details'
                    SizeType        = 'Medium'
                    Image           = 'download_for_windows.png'
                    Function        = {
                        # If the box is empty then return
                        if (-Not(Confirm-Object -MandatoryBox $Global:AILocalApplicationsComboBox)) { Return }
                        # Get the properties of the selected application
                        [PSCustomObject]$AppObject = Get-LocallyInstalledApplications -ReturnApplicationObject -DisplayName $Global:AILocalApplicationsComboBox.Text
                        #  Fill the textboxes
                        $Global:AIVendorNameFullTextBox.Text            = $AppObject.Publisher
                        $Global:AIVendorNameShortTextBox.Text           = $AppObject.Publisher
                        $Global:AIApplicationNameFullTextBox.Text       = $AppObject.DisplayName
                        $Global:AIApplicationNameShortTextBox.Text      = $AppObject.DisplayName
                        $Global:AIApplicationVersionFullTextBox.Text    = $AppObject.DisplayVersion
                        $Global:AIApplicationVersionShortTextBox.Text   = $AppObject.DisplayVersion
                        $Global:AIInstallLocationTextBox.Text           = $AppObject.InstallLocation
                        #$Global:AIApplicationBitVersionComboBox.Text    = $AppObject.BitVersion
                        #$Global:AIApplicationLanguageComboBox.Text      = ''
                    }
                }
                @{
                    RowNumber       = 15
                    Text            = 'Check Name'
                    SizeType        = 'Medium'
                    Image           = 'download_for_windows.png'
                    Function        = { $Global:AIApplicationIDTextBox.Text = Get-ApplicationName }
                }
            )
        }

        # Add the GetHelpButtons method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetHelpButtons -Value {
            # Return the button properties
            @(
                @{
                    ColumnNumber    = 6
                    Text            = 'Help'
                    SizeType        = 'Small'
                    Function        = { Invoke-Item -Path $Global:ApplicationIntakeGroupBox.HelpFilePath }
                }
            )
        }
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
