####################################################################################################
<#
.SYNOPSIS
    This function converts the path of a shortcut or folder, from long to short, and the other way.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Convert-ShortcutPath -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Acrobat Reader.lnk"
.EXAMPLE
    Convert-ShortcutPath -Path '[SYSTEM]\Acrobat Reader.lnk'
.INPUTS
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Convert-ShortcutPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The StartMenu shortcut or folder, that will be converted.')]
        [System.String]
        $Path
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails       = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # System StartMenu Handlers
        [System.String]$SYSTEMStartMenuFolder   = ('{0}\Microsoft\Windows\Start Menu\Programs' -f $ENV:PROGRAMDATA)
        [System.String]$SYSTEMStartMenuPrefix   = '[SYSTEM]'
        # User StartMenu Handlers
        [System.String]$USERStartMenuFolder     = ('{0}\Microsoft\Windows\Start Menu\Programs' -f $ENV:APPDATA)
        [System.String]$USERStartMenuPrefix     = '[USER]'
        # Output
        [System.String]$OutputObject            = [System.String]::Empty


        ####################################################################################################
        ### SUPPORTING FUNCTIONS ###

        function Invoke-ShortcutPathConversion { param([System.String]$InputPath)
            # Convert the path (system)
            if ($InputPath.StartsWith($SYSTEMStartMenuPrefix)) { Return $InputPath.Replace($SYSTEMStartMenuPrefix,$SYSTEMStartMenuFolder) }
            if ($InputPath.StartsWith($SYSTEMStartMenuFolder)) { Return $InputPath.Replace($SYSTEMStartMenuFolder,$SYSTEMStartMenuPrefix) }
            # Convert the path (user)
            if ($InputPath.StartsWith($USERStartMenuPrefix)) { Return $InputPath.Replace($USERStartMenuPrefix,$USERStartMenuFolder) }
            if ($InputPath.StartsWith($USERStartMenuFolder)) { Return $InputPath.Replace($USERStartMenuFolder,$USERStartMenuPrefix) }
        }

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # Set the output
        $OutputObject = Invoke-ShortcutPathConversion $Path
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
