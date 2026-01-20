####################################################################################################
<#
.SYNOPSIS
    This function exports the image of shortcut.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Function-Template -Initialize
.EXAMPLE
    Export-ShortcutImage -InputObject $ShortcutPropertiesObject -OutputFolder C:\Demo -PNG
.INPUTS
    [System.__ComObject]
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Export-ShortcutImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The object containing the needed properties.')]
        [System.__ComObject]
        $InputObject,

        [Parameter(Mandatory=$true,HelpMessage='The folder where the output will be placed.')]
        [System.String]
        $OutputFolder,

        [Parameter(Mandatory=$false,HelpMessage='Switch for creating a PNG file.')]
        [System.Management.Automation.SwitchParameter]
        $PNG,

        [Parameter(Mandatory=$false,HelpMessage='Switch for creating a ICO file.')]
        [System.Management.Automation.SwitchParameter]
        $ICO,

        [Parameter(Mandatory=$false,HelpMessage='Switch for opening the output folder.')]
        [System.Management.Automation.SwitchParameter]
        $OpenOutputFolder
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Input
        [System.__ComObject]$ShortcutPropertiesObject = $InputObject
        [System.String]$Extension = if ($ICO) { 'ico' } else { 'png' }


        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # Set the properties
        [System.String]$OutputFileName = ('{0}.{1}' -f $ShortcutPropertiesObject.BaseName,$Extension)
        [System.String]$OutputFilePath = Join-Path -Path $OutputFolder -ChildPath $OutputFileName
        # Create a new image file
        try {
            [System.Drawing.Icon]::ExtractAssociatedIcon($ShortcutPropertiesObject.IconFilePath).ToBitmap().Save($OutputFilePath)
        }
        catch {
            try {
                [System.Drawing.Icon]::ExtractAssociatedIcon($ShortcutPropertiesObject.TargetPath).ToBitmap().Save($OutputFilePath)
            }
            catch [System.Management.Automation.MethodInvocationException] {
                Write-Warning ('The {0} file could not be extracted. (The name may contain invalid characters.)' -f $Extension)
            }
            catch {
                Write-FullError
            }
        }
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
