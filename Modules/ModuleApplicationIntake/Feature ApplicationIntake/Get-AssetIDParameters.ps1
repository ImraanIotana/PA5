####################################################################################################
<#
.SYNOPSIS
    This function gets the values if the textboxes, that contain the application properties.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Get-AssetIDParameters
.INPUTS
    -
.OUTPUTS
    [System.Collections.Hashtable]
.NOTES
    Version         : 5.4.7
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : July 2025
#>
####################################################################################################

function Get-AssetIDParameters {
    [CmdletBinding()]
    param (
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Output
            OutputObject    = [System.Collections.Hashtable]@{}
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Message -FunctionEnd -Details $this.FunctionDetails
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get the parameters
            $this.OutputObject = $this.GetAssetIDParameters()
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the GetAssetIDParameters method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetAssetIDParameters -Value {
            # Get the values of the textboxes
            [System.Collections.Hashtable]$Parameters = @{
                VendorNameFull          = $Global:AIVendorNameFullTextBox.Text
                VendorNameShort         = $Global:AIVendorNameShortTextBox.Text
                ApplicationNameFull     = $Global:AIApplicationNameFullTextBox.Text
                ApplicationNameShort    = $Global:AIApplicationNameShortTextBox.Text
                ApplicationVersionFull  = $Global:AIApplicationVersionFullTextBox.Text
                ApplicationVersionShort = $Global:AIApplicationVersionShortTextBox.Text
                CustomerDepartment      = $Global:AICustomerDepartmentComboBox.Text
                ADGroupName             = $Global:AIADGroupNameTextBox.Text
                ADGroupSID              = $Global:AIADGroupSIDTextBox.Text
                InstallLocation         = $Global:AIInstallLocationTextBox.Text
                #ApplicationBitVersion   = $Global:AIApplicationBitVersionComboBox.Text # Temporarily not used.
            }
            # Return the result
            $Parameters
        }

        ####################################################################################################

        $Local:MainObject.Begin()
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
        $Local:MainObject.End()
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
