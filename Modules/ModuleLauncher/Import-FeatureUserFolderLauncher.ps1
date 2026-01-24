####################################################################################################
<#
.SYNOPSIS
    This function imports the feature Settings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Invoke-Groupbox, Invoke-TextBox, Invoke-Label, Invoke-ButtonLine, Invoke-RegistrySettings, Select-Item, Invoke-ClipBoard, Get-UserConfirmation
    External variables  : $Global:SettingsTabPage, $Global:GeneralSettingsGroupBox, $Global:OutputFolderTextBox, $Global:DSLFolderTextBox
.EXAMPLE
    Import-FeatureTEMP
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : February 2025
#>
####################################################################################################

function Import-FeatureUserFolderLauncher {
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
            # Function
            FunctionDetails         = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ParentTabPage           = $ParentTabPage
            # Groupbox Handlers
            GroupboxTitle           = [System.String]'User Folders'
            GroupboxColor           = [System.String]'LightCyan'
            GroupboxNumberOfRows    = [System.Int32]2
            GroupBoxAbove           = $Global:SystemFolderLauncherGroupBox
            # Handlers
            AssetFolder             = [System.String]$PSScriptRoot
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the GroupBox (This groupbox must be global to relate to the second groupbox)
            [System.Windows.Forms.GroupBox]$Global:UserFolderLauncherGroupBox = Invoke-Groupbox -ParentTabPage $this.ParentTabPage -Title $this.GroupboxTitle -NumberOfRows $this.GroupboxNumberOfRows -Color $this.GroupboxColor -GroupBoxAbove $this.GroupBoxAbove
            [System.Windows.Forms.GroupBox]$ParentGroupBox = $Global:UserFolderLauncherGroupBox
            # Create the Buttons
            Invoke-ButtonLine -ButtonPropertiesArray $this.UserFolderButtons() -ParentGroupBox $ParentGroupBox -RowNumber 1 -AssetFolder $this.AssetFolder
        }

        ####################################################################################################

        # Add the UserFolderButtons method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name UserFolderButtons -Value {
            # Return the button properties
            @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Roaming Profile'
                    SizeType        = 'Large'
                    Image           = 'folder_user.png'
                    Function        = { Open-Folder -Path $ENV:APPDATA }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'Local AppData'
                    SizeType        = 'Large'
                    Image           = 'folder_page.png'
                    Function        = { Open-Folder -Path $ENV:LOCALAPPDATA }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'ProgramData'
                    SizeType        = 'Large'
                    Image           = 'folder_brick.png'
                    Function        = { Open-Folder -Path $ENV:ALLUSERSPROFILE }
                }
                @{
                    ColumnNumber    = 4
                    Text            = 'Downloads'
                    SizeType        = 'Large'
                    Image           = 'inbox_download.png'
                    Function        = { Open-Folder -Path (Join-Path -Path $ENV:USERPROFILE -ChildPath 'Downloads') }
                }
                @{
                    ColumnNumber    = 5
                    Text            = 'Temp'
                    SizeType        = 'Large'
                    Image           = 'folder_torn.png'
                    Function        = { Open-Folder -Path $ENV:TEMP }
                }
            )
        }

        ####################################################################################################
    } 
    
    process {
        #region PROCESS
        $Local:MainObject.Process()
        #endregion PROCESS
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
