####################################################################################################
<#
.SYNOPSIS
    This function imports the feature System Folder Launcher.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-FeatureSystemFolderLauncher -ParentTabPage $Global:ParentTabPage
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

function Import-FeatureSystemFolderLauncher {
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
            Title           = [System.String]'System Folders'
            Color           = [System.String]'Orange'
            NumberOfRows    = [System.Int32]2
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        # Add the SystemFolderButtons method
        [System.Collections.Hashtable[]]$SystemFolderButtons = @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Program Files'
                    SizeType        = 'Large'
                    Image           = '64_bit.png'
                    Function        = { Open-Folder -Path ${ENV:ProgramFiles} }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'Program Files (x86)'
                    SizeType        = 'Large'
                    Image           = '32_bit.png'
                    Function        = { Open-Folder -Path ${ENV:ProgramFiles(x86)} }
                }
                @{
                    ColumnNumber    = 5
                    Text            = 'Software Library'
                    SizeType        = 'Large'
                    Image           = 'CD.png'
                    Function        = { Open-Folder -Path (Get-Path -DSLFolder) }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Drivers'
                    SizeType        = 'Large'
                    Image           = 'printer.png'
                    Function        = { Open-Folder -Path "$ENV:SystemRoot\System32\DriverStore\FileRepository" }
                }
                @{
                    ColumnNumber    = 4
                    Text            = 'Fonts'
                    SizeType        = 'Large'
                    Image           = 'font_colors.png'
                    Function        = { Open-Folder -Path "$ENV:SystemRoot\Fonts" }
                }
            )

        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox (This groupbox must be global to relate to the second groupbox)
        [System.Windows.Forms.GroupBox]$Global:SystemFolderLauncherGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $SystemFolderButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
