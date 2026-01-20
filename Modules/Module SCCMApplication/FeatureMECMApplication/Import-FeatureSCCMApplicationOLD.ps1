####################################################################################################
<#
.SYNOPSIS
    This function imports the feature SCCM Application. This function creates or removes an SCCM Application, UserCollection, DeploymentType and Deployment.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureMECMApplication
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no output.
.NOTES
    Version         : 4.8
    Author          : Imraan Iotana
    Creation Date   : June 2024
    Last Updated    : September 2024
#>
####################################################################################################

function Import-FeatureSCCMApplicationOLD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails             = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ParentTabPage               = $ParentTabPage
            # Groupbox Handlers
            GroupboxTitle               = [System.String]'Manage MECM Application'
            GroupboxColor               = [System.String]'DarkBlue'
            GroupboxNumberOfRows        = [System.Int32]7
            # Handlers
            AssetFolder                 = [System.String]$PSScriptRoot
            SCCMTenants                 = [System.String[]]@('Baseline','EW','ISRD','GeoInt')
            #DistributionPointGroupName  = [System.String]'Distribution points ODC'
            DistributionPointGroupNames = [System.String[]]@('Site PC1 - Distribution Point Group','Site PC2 - Distribution Point Group','Site PE1 - Distribution Point Group')
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Get the folder from the DSL
            [System.String[]]$DSLApplicationFolders = Get-SharedAssetPath -ApplicationFolders
            $this | Add-Member -NotePropertyName DSLApplicationFolders -NotePropertyValue $DSLApplicationFolders
            # Import the SCCM Module
            Invoke-SCCMConnectionAction -ImportPowerShellModule
            # Map the SCCM Drive
            Invoke-SCCMConnectionAction -MapDrive
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the GroupBox
            [System.Windows.Forms.GroupBox]$Global:SCCMApplicationGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $this.ParentTabPage -Title $this.GroupboxTitle -NumberOfRows $this.GroupboxNumberOfRows -Color $this.GroupboxColor
            # Create the ComboBoxes
            [System.Windows.Forms.ComboBox]$Global:SCASelectAssetIDComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Medium -Type Output -Label 'Select Application:' -ContentArray $this.DSLApplicationFolders -PropertyName 'SCASelectAssetIDComboBox'
            [System.Windows.Forms.ComboBox]$Global:SCASCCMTenantComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 2 -SizeType Medium -Type Output -Label 'Select Customer:' -ContentArray $this.SCCMTenants -PropertyName 'SCASCCMTenantComboBox'
            # Add the DistributionPointGroupNames to the SCASelectAssetIDComboBox, so it can be used in the button function
            Add-Member -InputObject $Global:SCASelectAssetIDComboBox -NotePropertyName DistributionPointGroupNames -NotePropertyValue $this.DistributionPointGroupNames
            # Create the TextBoxes
            [System.Windows.Forms.TextBox]$Global:SCAInstallFileTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Medium -Type Output -Label 'Install File (cmd/ps1):' -PropertyName 'SCAInstallFileTextBox'
            [System.Windows.Forms.TextBox]$Global:SCAUninstallFileTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 4 -SizeType Medium -Type Output -Label 'Uninstall File (cmd/ps1):' -PropertyName 'SCAUninstallFileTextBox'
            [System.Windows.Forms.TextBox]$Global:SCAIconFileTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 5 -SizeType Medium -Type Output -Label 'Image File (ico/jpg/png):' -PropertyName 'SCAIconFileTextBox'
            [System.Windows.Forms.TextBox]$Global:SCAMetadataFileTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 6 -SizeType Medium -Type Output -Label 'Metadata File (json):' -PropertyName 'SCAMetadataFileTextBox'
            #[System.Windows.Forms.TextBox]$Global:SCADetectionFileTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 9 -SizeType Medium -Type Input -Label 'Detection File:' -PropertyName 'SCADetectionFileTextBox'
            # Add the EventHandler that changes the boxes, based on the selected application
            $Global:SCASelectAssetIDComboBox.Add_SelectedIndexChanged([System.EventHandler]{
                # Set the customer
                [System.String]$ApplicationCustomer         = Get-SharedAssetPath -ApplicationCustomer -ApplicationID $Global:SCASelectAssetIDComboBox.Text
                $Global:SCASCCMTenantComboBox.ForeColor     = if ($ApplicationCustomer) { 'Green' } else { 'Red' }
                $Global:SCASCCMTenantComboBox.Text          = $ApplicationCustomer
                # Set the DeploymentScriptPath
                [System.String]$DeploymentScriptPath        = Get-SharedAssetPath -DeploymentScript -ApplicationID $Global:SCASelectAssetIDComboBox.Text
                $Global:SCAInstallFileTextBox.ForeColor     = if (Test-Path -Path $DeploymentScriptPath) { 'Green' } else { 'Red' }
                $Global:SCAInstallFileTextBox.Text          = $DeploymentScriptPath
                $Global:SCAUninstallFileTextBox.ForeColor   = if (Test-Path -Path $DeploymentScriptPath) { 'Green' } else { 'Red' }
                $Global:SCAUninstallFileTextBox.Text        = $DeploymentScriptPath
                # Set the SCCMImagePath
                [System.String]$SCCMImagePath               = Get-SharedAssetPath -SCCMImagePath -ApplicationID $Global:SCASelectAssetIDComboBox.Text
                $Global:SCAIconFileTextBox.ForeColor        = if (Test-Path -Path $SCCMImagePath) { 'Green' } else { 'Red' }
                $Global:SCAIconFileTextBox.Text             = $SCCMImagePath
                # Set the MetadataFilePath
                [System.String]$MetadataFilePath            = Get-SharedAssetPath -MetadataFilePath -ApplicationID $Global:SCASelectAssetIDComboBox.Text
                $Global:SCAMetadataFileTextBox.ForeColor    = if (Confirm-Object -MandatoryPath $MetadataFilePath) { 'Green' } else { 'Red' }
                $Global:SCAMetadataFileTextBox.Text         = $MetadataFilePath
            })
            # Create the Label
            #Invoke-Label -ParentGroupBox $ParentGroupBox -Text 'Optional:' -RowNumber 8
            # Create the Buttons
            Invoke-ButtonLine -ButtonPropertiesArray $this.InputBoxButtons() -ParentGroupBox $ParentGroupBox -ColumnNumber 5 -AssetFolder $this.AssetFolder
            Invoke-ButtonLine -ButtonPropertiesArray $this.ActionButtons() -ParentGroupBox $ParentGroupBox -RowNumber 7 -AssetFolder $this.AssetFolder
        }

        ####################################################################################################
        ### BUTTON METHODS ###

        # Add the InputBoxButtons method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name InputBoxButtons -Value {
            # Return the button properties
            @(
                @{
                    RowNumber   = 1
                    Text        = 'Open'
                    SizeType    = 'Small'
                    ToolTip     = 'Open the Applicationfolder on the DSL'
                    Function    = { Open-Folder -Path (Get-SharedAssetPath -ApplicationFolderPath -ApplicationID $Global:SCASelectAssetIDComboBox.Text) }
                }
                @{
                    RowNumber   = 3
                    Text        = 'Browse'
                    SizeType    = 'Small'
                    ToolTip     = 'Browse to the Install script'
                    Function    = {
                        # Select a file
                        [System.String]$InitialDirectory = Get-SharedAssetPath -SCCMFolderPath -ApplicationID $Global:SCASelectAssetIDComboBox.Text
                        [System.String]$FileName = Select-Item -ScriptFile -InitialDirectory $InitialDirectory ; if ($FileName) { $Global:SCAInstallFileTextBox.Text = $FileName }
                    }
                }
                @{
                    RowNumber   = 4
                    Text        = 'Browse'
                    SizeType    = 'Small'
                    ToolTip     = 'Browse to the Uninstall script'
                    Function    = {
                        # Select a file
                        [System.String]$InitialDirectory = Get-SharedAssetPath -SCCMFolderPath -ApplicationID $Global:SCASelectAssetIDComboBox.Text
                        [System.String]$FileName = Select-Item -ScriptFile -InitialDirectory $InitialDirectory ; if ($FileName) { $Global:SCAUninstallFileTextBox.Text = $FileName }
                    }
                }
                @{
                    RowNumber   = 5
                    Text        = 'Browse'
                    SizeType    = 'Small'
                    ToolTip     = 'Browse to the Image file'
                    Function    = {
                        # Select a file
                        [System.String]$InitialDirectory = Get-SharedAssetPath -SCCMImageFolderPath -ApplicationID $Global:SCASelectAssetIDComboBox.Text
                        [System.String]$FileName = Select-Item -IconFile -InitialDirectory $InitialDirectory ; if ($FileName) { $Global:SCAIconFileTextBox.Text = $FileName }
                    }
                }
                @{
                    RowNumber   = 6
                    Text        = 'Browse'
                    SizeType    = 'Small'
                    ToolTip     = 'Browse to the Metadata file'
                    Function    = {
                        # Select a file
                        [System.String]$InitialDirectory = Get-SharedAssetPath -MetadataFolderPath -ApplicationID $Global:SCASelectAssetIDComboBox.Text
                        [System.String]$FileName = Select-Item -File -InitialDirectory $InitialDirectory ; if ($FileName) { $Global:SCAMetadataFileTextBox.Text = $FileName }
                    }
                }
            )
        }

        # Add the ActionButtons method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ActionButtons -Value {
            # Return the button properties
            @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Check Application'
                    TextColor       = 'Blue'
                    Image           = 'magnifier.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Check if the application exists in SCCM'
                    Function        = { Show-SCCMApplicationInfo -ApplicationID $Global:SCASelectAssetIDComboBox.Text }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Create New Application'
                    TextColor       = 'DarkGreen'
                    Image           = 'package_add.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Create a new SCCM Application'
                    Function        = {
                        Write-NoAction
                        <# Validate the mandatory inputboxes
                        @($Global:SCASelectAssetIDComboBox, $Global:SCAInstallFileTextBox, $Global:SCAUninstallFileTextBox, $Global:SCASCCMTenantComboBox, $Global:SCAIconFileTextBox) | ForEach-Object {
                            if (Test-Object -IsEmpty $_.Text) { [System.Boolean]$MandatoryFieldIsEmpty = $true  }
                        }
                        if ($MandatoryFieldIsEmpty) { Write-Host 'A mandatory field is empty. No action has been taken.' -ForegroundColor DarkGray ; Return }#>

                        # Show the folder size
                        #[System.String]$SourceFolder = Split-Path -Path ($Global:SCAInstallFileTextBox.Text) -Parent
                        #Get-FolderSize -Path $SourceFolder
                        # Get user confirmation
                        #if (-Not(Get-UserConfirmation -Title 'Create MECM Application' -Body ("This will CREATE a new MECM Application:`n{0}`n`nAre you sure?" -f $Global:SCASelectAssetIDComboBox.Text))) { Return }
                        # Create the UserCollection
                        #New-SCCMUserCollection -Name $Global:SCASelectAssetIDComboBox.Text -Tennant $Global:SCASCCMTenantComboBox.Text
                        <# Set the properties
                        [System.Collections.Hashtable]$SCCMApplicationParameters = @{
                            ApplicationName             = $Global:SCASelectAssetIDComboBox.Text
                            InstallScriptPath           = $Global:SCAInstallFileTextBox.Text
                            UninstallScriptPath         = $Global:SCAUninstallFileTextBox.Text
                            Tennant                     = $Global:SCASCCMTenantComboBox.Text
                            DetectionFilePath           = $Global:SCADetectionFileTextBox.Text
                            IconFilePath                = $Global:SCAIconFileTextBox.Text
                            DistributionPointGroupNames = $Global:SCASelectAssetIDComboBox.DistributionPointGroupNames
                        }#>
                        # Create the Application
                        #New-MECMApplication @SCCMApplicationParameters
                    }
                }
                @{
                    ColumnNumber    = 5
                    Text            = 'Remove Application'
                    TextColor       = 'Red'
                    Image           = 'package_delete.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Remove the selected SCCM Application'
                    Function        = {
                        Write-NoAction
                        # Get user confirmation
                        #if (-Not(Get-UserConfirmation -Title 'Remove MECM Application' -Body ("This will REMOVE the MECM Application:`n{0}`n`nAre you sure?" -f $Global:SCASelectAssetIDComboBox.Text))) { Return }
                        # Switch to the SCCM Drive
                        #Invoke-SCCMConnectionAction -SwitchToDrive
                        # Remove the Application
                        #Remove-SCCMApplication -Name $Global:SCASelectAssetIDComboBox.Text
                        # Remove the UserCollection
                        #Remove-SCCMUserCollection -Name $Global:SCASelectAssetIDComboBox.Text
                        # Switch back
                        #Invoke-SCCMConnectionAction -SwitchBack
                    }
                }
            )
        }

        ####################################################################################################

        $Local:MainObject.Begin()
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
