####################################################################################################
<#
.SYNOPSIS
    This function gets the folders and the shortcuts from the Start Menu.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Get-StartMenuItems
.EXAMPLE
    Get-StartMenuItems -AsComboboxList
.INPUTS
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
    [System.String[]]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Get-StartMenuItems {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='Switch for getting the shortcuts shortened for the Combobox')]
        [System.Management.Automation.SwitchParameter]
        $AsComboboxList
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails       = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Output
        [System.String[]]$OutputObject          = @()
        # SystemStartMenu Handlers
        [System.String]$SYSTEMStartMenuFolder   = ('{0}\Microsoft\Windows\Start Menu\Programs' -f $ENV:PROGRAMDATA)
        [System.String]$SYSTEMStartMenuPrefix   = '[SYSTEM]'
        # UserStartMenu Handlers
        [System.String]$USERStartMenuFolder     = ('{0}\Microsoft\Windows\Start Menu\Programs' -f $ENV:APPDATA)
        [System.String]$USERStartMenuPrefix     = '[USER]'

        ####################################################################################################
        ### SUPPORTING FUNCTIONS ###
    
        # Add the Get-SystemStartMenuItems function
        function Get-SystemStartMenuItems {
            try {
                # Get the full paths of the SYSTEM StartMenu FOLDERS (recursively)
                [System.String[]]$SYSTEMStartMenuFOLDERSFULLPaths   = (Get-ChildItem -Path $SYSTEMStartMenuFolder -Directory -Recurse -ErrorAction SilentlyContinue).FullName | Sort-Object
                [System.String[]]$SYSTEMStartMenuFOLDERSSHORTPaths  = $SYSTEMStartMenuFOLDERSFULLPaths | ForEach-Object { $_.Replace($SYSTEMStartMenuFolder,$SYSTEMStartMenuPrefix) } | Sort-Object
                # Get the full paths of the SYSTEM StartMenu FILES (only in the root)
                [System.String[]]$SYSTEMStartMenuFILESFULLPaths     = (Get-ChildItem -Path $SYSTEMStartMenuFolder -File -ErrorAction SilentlyContinue).FullName
                [System.String[]]$SYSTEMStartMenuFILESSHORTPaths    = $SYSTEMStartMenuFILESFULLPaths | ForEach-Object { $_.Replace($SYSTEMStartMenuFolder,$SYSTEMStartMenuPrefix) } | Sort-Object
                # Set the StartMenu items Full Paths
                [System.String[]]$SYSTEMStartMenuItemsFULLPaths     = $SYSTEMStartMenuFOLDERSFULLPaths  + $SYSTEMStartMenuFILESFULLPaths
                # Set the StartMenu items Short Paths
                [System.String[]]$SYSTEMStartMenuItemsSHORTPaths    = $SYSTEMStartMenuFOLDERSSHORTPaths + $SYSTEMStartMenuFILESSHORTPaths
                # Return the result
                if ($AsComboboxList) { $SYSTEMStartMenuItemsSHORTPaths } else { $SYSTEMStartMenuItemsFULLPaths }
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the Get-UserStartMenuItems function
        function Get-UserStartMenuItems {
            try {
                # Get the full paths of the USER StartMenu FOLDERS (recursively)
                [System.String[]]$USERStartMenuFOLDERSFULLPaths   = (Get-ChildItem -Path $USERStartMenuFolder -Directory -Recurse -ErrorAction SilentlyContinue).FullName | Sort-Object
                [System.String[]]$USERStartMenuFOLDERSSHORTPaths  = $USERStartMenuFOLDERSFULLPaths | ForEach-Object { $_.Replace($USERStartMenuFolder,$USERStartMenuPrefix) } | Sort-Object
                # Get the full paths of the USER StartMenu FILES (only in the root)
                [System.String[]]$USERStartMenuFILESFULLPaths     = (Get-ChildItem -Path $USERStartMenuFolder -File -ErrorAction SilentlyContinue).FullName
                [System.String[]]$USERStartMenuFILESSHORTPaths    = $USERStartMenuFILESFULLPaths | ForEach-Object { $_.Replace($USERStartMenuFolder,$USERStartMenuPrefix) } | Sort-Object
                # Set the StartMenu items Full Paths
                [System.String[]]$USERStartMenuItemsFULLPaths     = $USERStartMenuFOLDERSFULLPaths  + $USERStartMenuFILESFULLPaths
                # Set the StartMenu items Short Paths
                [System.String[]]$USERStartMenuItemsSHORTPaths    = $USERStartMenuFOLDERSSHORTPaths + $USERStartMenuFILESSHORTPaths
                # Return the result
                if ($AsComboboxList) { $USERStartMenuItemsSHORTPaths } else { $USERStartMenuItemsFULLPaths }
            }
            catch {
                Write-FullError
            }
        }

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        [System.String[]]$SYSTEMStartMenuItems  = Get-SystemStartMenuItems
        [System.String[]]$USERStartMenuItems    = Get-UserStartMenuItems
        $OutputObject = $SYSTEMStartMenuItems + $USERStartMenuItems
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
        # Return the output
        $OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
