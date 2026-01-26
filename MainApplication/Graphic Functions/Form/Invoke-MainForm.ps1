####################################################################################################
<#
.SYNOPSIS
    This function creates the Global Main Form, or shows it.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Write-FullError
    External variables  : $Global:MainForm
.EXAMPLE
    Invoke-MainForm -Create -ApplicationObject $Global:ApplicationObject
.EXAMPLE
    Invoke-MainForm -Show
.INPUTS
    [System.Management.Automation.SwitchParameter]
    [PSCustomObject]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : October 2024
    Last Update     : February 2025
#>
####################################################################################################

function Invoke-MainForm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='CreateForm',HelpMessage='Switch for creating the Main Form.')]
        [System.Management.Automation.SwitchParameter]
        $Create,
        
        [Parameter(Mandatory=$true,ParameterSetName='CreateForm',HelpMessage='ApplicationObject containing the Settings.')]
        [PSCustomObject]
        $ApplicationObject,

        [Parameter(Mandatory=$true,ParameterSetName='ShowForm',HelpMessage='Switch for showing the Main Form.')]
        [System.Management.Automation.SwitchParameter]
        $Show
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationObject   = $ApplicationObject
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Switch on the ParameterSetName
            switch ($this.FunctionDetails[1]) {
                'CreateForm'    { $this.CreateMainForm($this.ApplicationObject) }
                'ShowForm'      { $this.ShowForm($Global:MainForm) }
            }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
        
        # Add the CreateMainForm method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateMainForm -Value { param([PSCustomObject]$ApplicationObject)
            try {
                # Write the message
                Write-Host 'Building User Interface...' -ForegroundColor DarkGray
                # Set the properties
                [System.String]$FormTitle       = ('{0} {1}' -f $ApplicationObject.Name, $ApplicationObject.Version)
                [System.String]$FormIconPath    = Get-SharedAssetPath -AssetName MainApplicationIcon
                #[System.Int32[]]$FormSize       = Get-GraphicalDimension -Form -Size
                [System.Int32[]]$FormSize       = @($ApplicationObject.Settings.MainForm.Width, $ApplicationObject.Settings.MainForm.Height)
                # Create the Global Main Form
                Write-Verbose 'Creating the Global Main Form...'
                [System.Windows.Forms.Form]$Global:MainForm = New-Form -Title $FormTitle -IconPath $FormIconPath -Size $FormSize
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the ShowForm method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ShowForm -Value { param([System.Windows.Forms.Form]$Form)
            try {
                # Show the form
                Write-Verbose 'Showing Form...'
                $Form.Add_Shown({ $Form.Activate() })
                $Form.ShowDialog() | Out-Null
            }
            catch {
                Write-FullError
            }
        }

        ####################################################################################################

        #region BEGIN
        # Write the Begin message
        #Write-Message -FunctionBegin -Details $Local:MainObject.FunctionDetails
        #endregion BEGIN
    }
    
    process {
        #region PROCESS
        $Local:MainObject.Process()
        #endregion PROCESS
    }
    
    end {
        #region END
        # Write the End message
        #Write-Message -FunctionEnd -Details $Local:MainObject.FunctionDetails
        #endregion END
    }
}
