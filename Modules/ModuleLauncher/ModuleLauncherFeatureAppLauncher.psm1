####################################################################################################
<#
.SYNOPSIS
    This function imports the feature App Launcher.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-FeatureAppLauncher -ParentTabPage $Global:ParentTabPage
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

function Import-FeatureAppLauncher {
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
            Title           = [System.String]'App Launcher'
            Color           = [System.String]'Blue'
            NumberOfRows    = [System.Int32]4
            GroupBoxAbove   = $Global:UserFolderLauncherGroupBox
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        # Add the AppLauncherButtons method
        [System.Collections.Hashtable[]]$AppLauncherButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Add/Remove Programs'
                SizeType        = 'Large'
                Image           = 'application_view_icons.png'
                Function        = { appwiz.cpl }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Task Manager'
                SizeType        = 'Large'
                Image           = 'system_monitor.png'
                Function        = { Start-Process -FilePath "$ENV:windir\System32\Taskmgr.exe" -Verb RunAs }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Registry Editor'
                SizeType        = 'Large'
                Image           = 'Regedit.png'
                Function        = { Start-Process -FilePath "$ENV:windir\regedit.exe" -Verb RunAs }
            }
            @{
                ColumnNumber    = 4
                Text            = 'Services'
                SizeType        = 'Large'
                Image           = 'cog.png'
                Function        = { services.msc }
            }
            @{
                ColumnNumber    = 5
                Text            = 'PowerShell'
                SizeType        = 'Large'
                Image           = 'PowerShell.png'
                Function        = { Start-Process -FilePath "$ENV:windir\System32\WindowsPowerShell\v1.0\powershell_ise.exe" -Verb RunAs }
            }
        )
        

        # Add the AppLauncherButtons2 method
        [System.Collections.Hashtable[]]$AppLauncherButtons2 = @(
            @{
                ColumnNumber    = 1
                Text            = 'Omnissa DEM'
                Image           = 'omnissa_dem.png'
                SizeType        = 'Large'
                ToolTip         = 'Start the Omnissa DEM Management Console'
                Function        = {
                    [System.String]$Path = 'C:\Program Files\Omnissa\DEM\Flex+ Management Console.exe'
                    if (Test-Path -Path $Path) { Write-Line "Starting the Omnissa DEM Management Console" ; Start-Process -FilePath $Path } else { Write-Host ('The file could not be found: ({0})' -f $Path) }
                }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Event Viewer'
                SizeType        = 'Large'
                Image           = 'book.png'
                Function        = { Invoke-Item -Path "$ENV:windir\System32\eventvwr.msc" }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Certificates'
                SizeType        = 'Large'
                Image           = 'ssl_certificates.png'
                Function        = { certmgr.msc }
            }
            @{
                ColumnNumber    = 4
                Text            = 'Task Scheduler'
                SizeType        = 'Large'
                Image           = 'clock.png'
                Function        = { Invoke-Item -Path "$ENV:windir\System32\en-US\taskschd.msc" }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Cmd'
                SizeType        = 'Large'
                Image           = 'application_xp_terminal.png'
                Function        = { Invoke-Item -Path "$ENV:windir\System32\cmd.exe" }
            }
        )
        
        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$ParentGroupBox = $Global:AppLauncherGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $AppLauncherButtons  -ParentGroupBox $ParentGroupBox -RowNumber 1  -AssetFolder $PSScriptRoot
        Invoke-ButtonLine -ButtonPropertiesArray $AppLauncherButtons2 -ParentGroupBox $ParentGroupBox -RowNumber 3  -AssetFolder $PSScriptRoot
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
