####################################################################################################
<#
.SYNOPSIS
    This class contains methods that handle the TabPage, that is used for Modules.
.DESCRIPTION
    This class is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    $MyNewModuleClass = [ModuleHandler]::New()
.INPUTS
    -
.OUTPUTS
    -
.NOTES
    Version         : 5.7.1
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
#>
####################################################################################################

class ModuleHandler {
    [System.String]$TabTitle
    [System.String]$ModuleVersion
    [System.String]$BackGroundColor

    # INITIALIZATION
    ####################################################################################################
    ModuleHandler(
        [System.String]$TabTitle,
        [System.String]$ModuleVersion,
        [System.String]$BackGroundColor
    ){
        $this.TabTitle        = $TabTitle
        $this.ModuleVersion   = $ModuleVersion
        $this.BackGroundColor = $BackGroundColor
    }


    # INTERNAL PROPERTIES
    ####################################################################################################


    # PUBLIC METHODS
    ####################################################################################################

    # Add the WriteImportMessage
    [void]WriteImportMessage(){
        Write-Line "ModuleHandler: Importing Module $($this.TabTitle) $($this.ModuleVersion)"
    }

    ####################################################################################################

    # PRIVATE METHODS

    ####################################################################################################

}

# END OF CLASS
####################################################################################################

