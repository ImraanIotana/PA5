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
    # INPUT PROPERTIES
    ####################################################################################################
    [System.Windows.Forms.TabControl]$ParentTabControl
    [System.String]$TabTitle
    [System.String]$ModuleVersion
    [System.String]$BackGroundColor

    # INITIALIZATION
    ####################################################################################################
    ModuleHandler(
        [System.Windows.Forms.TabControl]$ParentTabControl,
        [System.String]$TabTitle,
        [System.String]$ModuleVersion,
        [System.String]$BackGroundColor
    ){
        $this.ParentTabControl  = $ParentTabControl
        $this.TabTitle          = $TabTitle
        $this.ModuleVersion     = $ModuleVersion
        $this.BackGroundColor   = $BackGroundColor
    }


    # INTERNAL PROPERTIES
    ####################################################################################################


    # PUBLIC METHODS
    ####################################################################################################

    # Add the WriteImportMessage method
    [void]WriteImportMessage(){
        Write-Line "Importing Module $($this.TabTitle) $($this.ModuleVersion)"
    }

    # Add the CreateModuleTabPage method
    [System.Windows.Forms.TabPage]CreateModuleTabPage(){
        # Create the Module TabPage
        [System.Windows.Forms.TabPage]$ModuleTabPage = New-TabPage -Parent $this.ParentTabControl -Title $this.TabTitle -BackGroundColor $this.BackGroundColor
        return $ModuleTabPage
    }

    ####################################################################################################

    # PRIVATE METHODS

    ####################################################################################################

}

# END OF CLASS
####################################################################################################

