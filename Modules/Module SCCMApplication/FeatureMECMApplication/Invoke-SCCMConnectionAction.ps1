####################################################################################################
<#
.SYNOPSIS
    This function performs connection related tasks concerning SCCM.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
    External classes    : -
    External functions  : Get-UserConfirmation, Write-FullError
    External variables  : -
.EXAMPLE
    Invoke-SCCMPackage
.INPUTS
    [System.Management.Automation.SwitchParameter],[System.String]
.OUTPUTS
    This function returns no output.
.NOTES
    Version         : 4.0
    Author          : Imraan Iotana
    Creation Date   : September 2024
    Last Updated    : September 2024
#>
####################################################################################################

function Invoke-SCCMConnectionAction {
    [CmdletBinding()]
    param (
        # Switch for importing the SCCM Module
        [Parameter(Mandatory=$true,ParameterSetName='ImportSCCMPowerShellModule')]
        [System.Management.Automation.SwitchParameter]
        $ImportPowerShellModule,

        # Switch for mapping the SCCM drive
        [Parameter(Mandatory=$true,ParameterSetName='MapSCCMDrive')]
        [System.Management.Automation.SwitchParameter]
        $MapDrive,

        # Switch for switching to the SCCM drive
        [Parameter(Mandatory=$true,ParameterSetName='SwitchToSCCMDrive')]
        [System.Management.Automation.SwitchParameter]
        $SwitchToDrive,

        # Switch for switching back
        [Parameter(Mandatory=$true,ParameterSetName='SwitchBack')]
        [System.Management.Automation.SwitchParameter]
        $SwitchBack
    )

    begin {
        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # SCCM Site Handlers
            SiteCode            = Get-SharedAssetPath -SCCMSiteCode
            ProviderMachineName = Get-SharedAssetPath -SCCMProviderMachineName
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Switch on the ParameterSetName
            switch ($this.FunctionDetails[1]) {
                'ImportSCCMPowerShellModule'    { $this.ImportSCCMPowerShellModuleMethod($this.InputParameters) }
                'MapSCCMDrive'                  { $this.MapSCCMDriveMethod($this.SiteCode,$this.ProviderMachineName) }
                'SwitchToSCCMDrive'             { $this.SwitchToSCCMDriveMethod($this.SiteCode) }
                'SwitchBack'                    { $this.SwitchBackMethod() }
            }
        }

        ####################################################################################################
        ### SCCM SITE METHODS ###

        # Add the ImportSCCMPowerShellModuleMethod method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ImportSCCMPowerShellModuleMethod -Value {
            try {
                # Import the ConfigurationManager.psd1 module 
                if ($null -eq (Get-Module -Name ConfigurationManager)) {
                    Write-Verbose 'The SCCM PowerShell Module is not installed. Importing it now. One moment please...'
                    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
                    if ($null -eq (Get-Module -Name ConfigurationManager)) {
                        Write-Host 'The SCCM Module has NOT been imported.' -ForegroundColor DarkGray
                    }
                    else {
                        Write-Verbose 'The SCCM Module has been imported.'
                    }
                } else {
                    Write-Verbose 'The SCCM Module is already installed.'
                }
            }
            catch {
                Write-FullError
            }
        }

        # Add the MapSCCMDriveMethod method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name MapSCCMDriveMethod -Value { param([System.String]$SCCMSiteCode,[System.String]$ProviderMachineName)
            try {
                # Connect to the site's drive if it is not already present
                if ($null -eq (Get-PSDrive -Name $SCCMSiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
                    Write-Verbose "Mapping a new drive named ($SCCMSiteCode) to the SCCM Provider ($ProviderMachineName)"
                    New-PSDrive -Name $SCCMSiteCode -PSProvider CMSite -Root $ProviderMachineName
                } else {
                    Write-Verbose "The drive named ($SCCMSiteCode) is already mapped."
                }
            }
            catch [System.Management.Automation.ParameterBindingException]{
                Write-Host ('The SCCM Sitecode or ProviderMachineName is empty. They will be filled with the default values. Respectively: ({0}) and ({1})' -f $Global:ApplicationObject.Settings.SCCMDefaultSiteCode, $Global:ApplicationObject.Settings.SCCMDefaultProviderMachineName)
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the SwitchToSCCMDriveMethod method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SwitchToSCCMDriveMethod -Value { param([System.String]$SCCMSiteCode)
            # Set the current location to be the sccm site code.
            [System.String]$SCCMPath = ('{0}:\' -f $SCCMSiteCode)
            Write-Verbose ('Switching to the SCCM Drive ({0})...' -f $SCCMPath)
            Push-Location -Path $SCCMPath
        }
    
        # Add the SwitchBackMethod method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SwitchBackMethod -Value {
            # Pop back
            Write-Verbose 'Switching back...'
            Pop-Location
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
