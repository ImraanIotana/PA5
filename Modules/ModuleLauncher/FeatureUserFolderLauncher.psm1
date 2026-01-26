####################################################################################################
<#
.SYNOPSIS
    This function imports the feature User Folder Launcher.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-FeatureUserFolderLauncher -ParentTabPage $Global:ParentTabPage
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : January 2026
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
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'User Folders'
            Color           = [System.String]'White'
            NumberOfRows    = [System.Int32]2
            GroupBoxAbove   = $Global:SystemFolderLauncherGroupBox
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        # Add the UserFolderButtons method
        [System.Collections.Hashtable[]]$UserFolderButtons = @(
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
    

        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox (This groupbox must be global to relate to the second groupbox)
        [System.Windows.Forms.GroupBox]$Global:UserFolderLauncherGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color -GroupBoxAbove $Groupbox.GroupBoxAbove
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $UserFolderButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
