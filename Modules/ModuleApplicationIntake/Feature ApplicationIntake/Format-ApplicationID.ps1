####################################################################################################
<#
.SYNOPSIS
    This function creates the Asset ID based on application properties.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Format-ApplicationID -VendorNameFull 'Adobe Inc.' -VendorNameShort 'Adobe' etc...
.INPUTS
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.4.1
    Author          : Imraan Iotana
    Creation Date   : March 2025
    Last Update     : June 2025
#>
####################################################################################################

function Format-ApplicationID {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The full name of the Vendor.')]
        [AllowEmptyString()]
        [System.String]
        $VendorNameFull,

        [Parameter(Mandatory=$true,HelpMessage='The short name of the Vendor.')]
        [AllowEmptyString()]
        [System.String]
        $VendorNameShort,

        [Parameter(Mandatory=$true,HelpMessage='The full name of the $Application.')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationNameFull,

        [Parameter(Mandatory=$true,HelpMessage='The short name of the Application.')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationNameShort,

        [Parameter(Mandatory=$true,HelpMessage='The full version of the Application.')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationVersionFull,

        [Parameter(Mandatory=$true,HelpMessage='The short version of the Application.')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationVersionShort,

        [Parameter(Mandatory=$true,HelpMessage='The name of the AD group.')]
        [AllowEmptyString()]
        [System.String]
        $ADGroupName,

        [Parameter(Mandatory=$true,HelpMessage='The SID of the AD group.')]
        [AllowEmptyString()]
        [System.String]
        $ADGroupSID,

        [Parameter(Mandatory=$true,HelpMessage='The customer of the Application.')]
        [AllowEmptyString()]
        [System.String]
        $CustomerDepartment,

        <#[Parameter(Mandatory=$true,HelpMessage='The bitversion of the Application.')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationBitVersion,#>

        [Parameter(Mandatory=$true,HelpMessage='The installation location of the Application.')]
        [AllowEmptyString()]
        [System.String]
        $InstallLocation
        )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ApplicationProperties   = [System.String[]]@($VendorNameFull,$VendorNameShort,$ApplicationNameFull,$ApplicationNameShort,$ApplicationVersionFull,$ApplicationVersionShort)
            #ApplicationProperties   = [System.String[]]@($VendorNameFull,$VendorNameShort,$ApplicationNameFull,$ApplicationNameShort,$ApplicationVersionFull,$ApplicationVersionShort,$ApplicationLanguage,$ApplicationBitVersion)
            # Output
            OutputObject            = [System.String]::Empty
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Validate the input
            if (-Not ($this.ValidateInput($this.ApplicationProperties))) { Write-Message -MandatoryField ; Return }
            # Create the Asset ID
            $this.OutputObject = $this.FormatApplicationID($this.ApplicationProperties)
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the ValidateInput method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ValidateInput -Value { param([System.String[]]$ApplicationProperties)
            # Check the array of input
            if ($ApplicationProperties.Contains('')) { $false } else { $true }
        }

        # Add the FormatApplicationID method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name FormatApplicationID -Value { param([System.String[]]$ApplicationProperties)
            # Get the needed values
            [System.String]$VendorNameShort         = $ApplicationProperties[1]
            [System.String]$ApplicationNameShort    = $ApplicationProperties[3]
            [System.String]$ApplicationVersionShort = $ApplicationProperties[5]
            # Remove the spaces
            [System.String]$VendorNameShortWithoutSpaces         = $VendorNameShort -Replace (" ","")
            [System.String]$ApplicationNameShortWithoutSpaces    = $ApplicationNameShort -Replace (" ","")
            [System.String]$ApplicationVersionShortWithoutSpaces = $ApplicationVersionShort -Replace (" ","")
            # Create the ApplicationID
            [System.String]$ApplicationID = ('{0}_{1}_{2}' -f $VendorNameShortWithoutSpaces,$ApplicationNameShortWithoutSpaces,$ApplicationVersionShortWithoutSpaces)
            # Return the result
            $ApplicationID
        }
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
