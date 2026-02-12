####################################################################################################
<#
.SYNOPSIS
    This function imports the Module MECM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-ModuleDSLSynchronization
.INPUTS
    [System.String]
.OUTPUTS
    [Microsoft.ConfigurationManagement.PowerShell.Framework.DetectionClause]
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : July 2025
#>
####################################################################################################

function New-MECMScriptDeploymentType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Application to which this new Deployment Type will be added.')]
        [Alias('ApplicationName','Application')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationID   = $ApplicationID
            # Validation
            ValidationArray = [System.Boolean[]]@()
            # Handlers
            SCCMRepository  = [System.String](Get-SharedAssetPath -SCCMRepository)
            SCCMSubfolders  = @{
                Baseline    = '01-Baseline Applications'
                EW          = '03-Applications\EW'
                ISRD        = '03-Applications\ISRD'
            }
            CustomerDepartment = (Get-ApplicationMetadata -ApplicationID $ApplicationID -PropertyName CustomerDepartment)
            # Confirmation Handlers
            ConfirmationTitle   = [System.String]'Confirm creation Deployment Type'
            ConfirmationBody    = [System.String]"This will CREATE the DEPLOYMENT TYPE named 'Install' for the application:`n`n{0}`n`nAre you sure?"
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -Begin $this.FunctionDetails
            # Validate the input
            $this.ValidationArray += Confirm-Object -MandatoryString $this.ApplicationID
            $this.ValidationArray += Confirm-Object -MandatoryString $this.CustomerDepartment
        }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Get user confirmation
            [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title $this.ConfirmationTitle -Body ($this.ConfirmationBody -f $ApplicationID)
            if (-Not($UserHasConfirmed)) { Return }
            # If the validation failed, then return
            if ($this.ValidationArray -contains $false) { Write-Message -ValidationFailed ; Return }
            # Add the needed properties to the main object
            $this | Add-Member -NotePropertyName SCCMContentLocation -NotePropertyValue $this.GetSCCMContentLocation($this.CustomerDepartment,$this.ApplicationID)
            $this | Add-Member -NotePropertyName DetectionClause -NotePropertyValue $this.GetDetectionClause($this.ApplicationID)
            # Switch to the SCCM Drive
            Invoke-SCCMConnectionAction -SwitchToDrive
            # Create the DeploymentType
            $this.CreateScriptDeploymentType($this.ApplicationID)
            # Switch back
            Invoke-SCCMConnectionAction -SwitchBack
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the CreateScriptDeploymentType method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateScriptDeploymentType -Value { param([System.String]$ApplicationID)
            try {
                # Write the message
                Write-Host ('Creating the DeploymentType. One moment please... ({0})' -f $ApplicationID) -ForegroundColor DarkGray
                # Set the properties
                [System.Collections.Hashtable]$DeploymentTypeParameters = @{
                    # General
                    ApplicationName             = $ApplicationID
                    DeploymentTypeName          = 'Install'
                    Comment                     = $ApplicationID
                    # Content
                    ContentLocation             = $this.SCCMContentLocation
                    UninstallOption             = 'SameAsInstall'
                    ContentFallback             = $false
                    SlowNetworkDeploymentMode   = 'DoNothing'
                    # Commands
                    InstallCommand              = 'Powershell.exe -ExecutionPolicy Bypass -File Deploy-Application.ps1 -Install -Verbose'
                    UninstallCommand            = 'Powershell.exe -ExecutionPolicy Bypass -File Deploy-Application.ps1 -Uninstall -Verbose'
                    # Detection
                    AddDetectionClause          = $this.DetectionClause
                    # Interaction
                    InstallationBehaviorType    = 'InstallForSystem'
                    LogonRequirementType        = 'WhetherOrNotUserLoggedOn'
                    UserInteractionMode         = 'Normal'
                    # Time
                    EstimatedRuntimeMins        = 5
                    MaximumRuntimeMins          = 15
                }
                # Create the Install DeploymentType
                Add-CMScriptDeploymentType @DeploymentTypeParameters
                # Write the message
                Write-Host ('The DeploymentType ({0}) has been created for application ({1}).' -f $DeploymentTypeParameters.DeploymentTypeName,$ApplicationID) -ForegroundColor Green

            }
            catch {
                # Write the error
                Write-FullError
            }
        }

        # Add the GetSCCMContentLocation method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name GetSCCMContentLocation -Value { param([System.String]$CustomerDepartment,[System.String]$ApplicationID)
            # Set the properties
            [System.String]$DepartmentSubFolder     = $this.SCCMSubfolders.($CustomerDepartment)
            [System.String]$SCCMDepartmentFolder    = Join-Path -Path $this.SCCMRepository -ChildPath $DepartmentSubFolder
            [System.String]$SCCMApplicationFolder   = Join-Path -Path $SCCMDepartmentFolder -ChildPath $ApplicationID
            Write-Host ('The SCCM Content location is: ({0})' -f $SCCMApplicationFolder) -ForegroundColor DarkGray
            # Return the result
            $SCCMApplicationFolder
        }

        # Add the GetDetectionClause method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name GetDetectionClause -Value { param([System.String]$ApplicationID)
            # Set the properties
            [System.String]$SCCMDetectionMethod = (Get-ApplicationMetadata -ApplicationID $ApplicationID -PropertyName SCCMDetectionMethod)
            Write-Host ('SCCMDetectionMethod = ({0})' -f $SCCMDetectionMethod)
            [Microsoft.ConfigurationManagement.PowerShell.Framework.DetectionClause]$DetectionClause = switch ($SCCMDetectionMethod) {
                'MSI' {
                    [System.String]$DetectionMSIProductCode = (Get-ApplicationMetadata -ApplicationID $ApplicationID -PropertyName DetectionMSIProductCode)
                    New-MECMDetectionClause -ProductCode $DetectionMSIProductCode
                }
                'File' {
                    [System.String]$DetectionFilePath = (Get-ApplicationMetadata -ApplicationID $ApplicationID -PropertyName DetectionFilePath)
                    [System.String]$DetectionFileVersionWithPeriods = (Get-ApplicationMetadata -ApplicationID $ApplicationID -PropertyName DetectionFileVersionWithPeriods)
                    New-MECMDetectionClause -DetectionFilePath $DetectionFilePath -DetectionFileVersion $DetectionFileVersionWithPeriods
                }
            }
            # Return the result
            $DetectionClause
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
