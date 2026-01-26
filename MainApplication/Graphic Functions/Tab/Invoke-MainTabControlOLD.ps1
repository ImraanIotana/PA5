####################################################################################################
<#
.SYNOPSIS
    This function creates the MainTabControl.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Invoke-MainTabControl -ParentForm $Global:MainForm -ApplicationObject $Global:ApplicationObject
.INPUTS
    [System.Windows.Forms.Form]
    [PSCustomObject]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : January 2026
#>
####################################################################################################

function Invoke-MainTabControlOLD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent object to which this tabcontrol will be added.')]
        [System.Windows.Forms.Form]
        $ParentForm,

        [Parameter(Mandatory=$false,HelpMessage='The Global ApplicationObject containing the Settings.')]
        [PSCustomObject]
        $ApplicationObject = $Global:ApplicationObject
    )

    begin {
    }
    
    process {
        try {
            # Get the Dimensions
            [System.Int32[]]$Location   = @($ApplicationObject.Settings.MainTabControl.TopLeftX, $ApplicationObject.Settings.MainTabControl.TopLeftY)
            [System.Int32[]]$Size       = @($ApplicationObject.Settings.MainTabControl.Width, $ApplicationObject.Settings.MainTabControl.Height)

            # Create the MainTabControl
            [System.Windows.Forms.TabControl]$Global:MainTabControl = New-TabControl -ParentForm $ParentForm -Location $Location -Size $Size
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
