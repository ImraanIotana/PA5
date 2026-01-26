####################################################################################################
<#
.SYNOPSIS
    This function creates the Global Main TabControl.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Write-FullError
    External variables  : $Global:MainTabControl
.EXAMPLE
    Invoke-MainTabControl -ParentForm $Global:MainForm -ApplicationObject $Global:ApplicationObject
.INPUTS
    [System.Windows.Forms.Form]
    [PSCustomObject]
.OUTPUTS
    This function returns no stream output. It creates the global variable named: $Global:MainTabControl
.NOTES
    Version         : 5.0.6
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : April 2025
#>
####################################################################################################

function Invoke-MainTabControl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent object to which this tabcontrol will be added.')]
        [System.Windows.Forms.Form]
        $ParentForm,

        [Parameter(Mandatory=$false,HelpMessage='The global ApplicationObject containing the Settings.')]
        [PSCustomObject]
        $ApplicationObject = $Global:ApplicationObject
    )

    begin {
    }
    
    process {
        try {
            # Get the Location
            [System.Int32[]]$Location   = @($ApplicationObject.Settings.MainTabControl.TopLeftX, $ApplicationObject.Settings.MainTabControl.TopLeftY)
            #[System.Int32[]]$Location   = Get-GraphicalDimension -MainTabControl -Location
            # Get the Size
            [System.Int32[]]$Size       = @($ApplicationObject.Settings.MainTabControl.Width, $ApplicationObject.Settings.MainTabControl.Height)
            #[System.Int32[]]$Size       = Get-GraphicalDimension -MainTabControl -Size

            # Create the global tabcontrol
            [System.Windows.Forms.TabControl]$Global:MainTabControl = New-TabControl -ParentForm $ParentForm -Location $Location -Size $Size

            # Add the WriteImportMessageOLD method to the global tabcontrol
            Add-Member -InputObject $Global:MainTabControl -MemberType ScriptMethod -Name WriteImportMessageOLD -Value { param([System.String]$TabTitle,[System.String]$ModuleVersion)
                Write-Host ('Importing Module {0} {1}' -f $TabTitle,$ModuleVersion) -ForegroundColor DarkGray
            }

            # Add the WriteImportMessage method to the global tabcontrol
            Add-Member -InputObject $Global:MainTabControl -MemberType ScriptMethod -Name WriteImportMessage -Value { param([PSCustomObject]$Object)
                Write-Host ('Importing Module {0} {1}' -f $Object.TabTitle,$Object.ModuleVersion) -ForegroundColor DarkGray
            }
        }
        catch {
            Write-FullError
        }
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
