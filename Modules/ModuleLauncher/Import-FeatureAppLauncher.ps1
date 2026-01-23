####################################################################################################
<#
.SYNOPSIS
    This function imports the feature Settings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Invoke-Groupbox, Invoke-ButtonLine
    External variables  : $Global:AppLauncherGroupBox
.EXAMPLE
    Import-FeatureAppLauncher -ParentTabPage $Global:LauncherTabPage
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

function Import-FeatureAppLauncher {
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
            GroupboxTitle           = [System.String]'Apps'
            GroupboxColor           = [System.String]'DarkBlue'
            GroupboxNumberOfRows    = [System.Int32]4
            GroupBoxAbove           = $Global:UserFolderLauncherGroupBox
            # Handlers
            AssetFolder             = [System.String]$PSScriptRoot
            DefaultOutputFolder     = [System.String](Join-Path -Path $ENV:USERPROFILE -ChildPath 'Downloads')
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value { Write-Function -Begin $this.FunctionDetails }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Function -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Create the GroupBox (This groupbox must be global to relate to the second groupbox)
            [System.Windows.Forms.GroupBox]$Global:AppLauncherGroupBox = Invoke-Groupbox -ParentTabPage $this.ParentTabPage -Title $this.GroupboxTitle -NumberOfRows $this.GroupboxNumberOfRows -Color $this.GroupboxColor -GroupBoxAbove $this.GroupBoxAbove
            [System.Windows.Forms.GroupBox]$ParentGroupBox = $Global:AppLauncherGroupBox
            # Create the Buttons
            Invoke-ButtonLine -ButtonPropertiesArray $this.AppLauncherButtons() -ParentGroupBox $ParentGroupBox -RowNumber 1 -AssetFolder $this.AssetFolder
            Invoke-ButtonLine -ButtonPropertiesArray $this.AppLauncherButtons2() -ParentGroupBox $ParentGroupBox -RowNumber 3 -AssetFolder $this.AssetFolder
        }

        ####################################################################################################

        # Add the AppLauncherButtons method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name AppLauncherButtons -Value {
            # Return the button properties
            @(
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
                    Function        = { Invoke-Item -Path "$ENV:windir\System32\Taskmgr.exe" }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Registry Editor'
                    SizeType        = 'Large'
                    Image           = 'Regedit.png'
                    Function        = { Invoke-Item -Path "$ENV:windir\regedit.exe" }
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
        }

        # Add the AppLauncherButtons2 method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name AppLauncherButtons2 -Value {
            # Return the button properties
            @(
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
        }

        ####################################################################################################

        $Local:MainObject.Begin()
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
        $Local:MainObject.End()
    }
}

### END OF SCRIPT
####################################################################################################
