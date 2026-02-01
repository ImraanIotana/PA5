####################################################################################################
<#
.SYNOPSIS
    This function opens a folder in File Explorer, optionally highlighting a specific item.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions or variables, that are in other files.
.EXAMPLE
    Open-Folder -Path C:\Demo
.EXAMPLE
    Open-Folder -HighlightItem C:\Demo\NewFolder
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.5.3
    Author          : Imraan Iotana
    Creation Date   : December 2025
    Last Update     : December 2025
#>
####################################################################################################

function Open-Folder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='OpenTheFolder',HelpMessage='The path of the folder that will be opened.')]
        [Alias('Folder')]
        [AllowEmptyString()]
        [System.String]$Path,

        [Parameter(Mandatory=$true,ParameterSetName='HighlightTheItem',HelpMessage='The item that will be highlighted when the folder is opened.')]
        [Alias('Highlight','Select','SelectItem')]
        [AllowEmptyString()]
        [System.String]$HighlightItem
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String]$ParameterSetName    = [System.String]$PSCmdlet.ParameterSetName
        
        <# Set the Item to handle based on the Parameter Set
        [System.String]$ItemToHandle        = switch ($ParameterSetName) {
            'OpenTheFolder'    { $Path }
            'HighlightTheItem' { $HighlightItem }
        }#>


        # Input
        [System.String]$FolderToOpen        = $Path
        [System.String]$ItemToHighlight     = $HighlightItem

        # Handlers
        [System.String]$HighlightPrefix    = '/select,"{0}"'


        ####################################################################################################
    }
    
    process {
        # VALIDATION
        switch ($ParameterSetName) {
            'OpenTheFolder'    {
                # Validate the string
                if (Test-StringIsEmpty $FolderToOpen) { Write-Line "The Path string is empty." -Type Fail ; Return }
                # Validate the path
                if (-Not(Test-Path -Path $FolderToOpen)) { Write-Line "The Folder could not be reached. ($FolderToOpen)" -Type Fail ; Return }
            }
            'HighlightTheItem' {
                # Validate the string
                if (Test-StringIsEmpty $ItemToHighlight) { Write-Line "The SelectItem string is empty." -Type Fail ; Return }
                # Validate the path
                if (-Not(Test-Path -Path $ItemToHighlight)) {
                    Write-Line "The selected item could not be reached. ($ItemToHighlight)" -Type Fail
                    Open-Folder -Path (Split-Path -Path $ItemToHighlight -Parent) ; Return
                }
            }
        }

        # EXECUTION
        switch ($ParameterSetName) {
            'OpenTheFolder'    {
                # Open the folder
                try {
                    Write-Line "Opening folder... ($FolderToOpen)"
                    Invoke-Item -Path $FolderToOpen
                }
                catch {
                    Write-FullError
                }
            }
            'HighlightTheItem' {
                # Open the folder
                try {
                    Write-Line "Selecting item... ($ItemToHighlight)"
                    Start-Process explorer.exe -ArgumentList ($HighlightPrefix -f $ItemToHighlight)
                }
                catch {
                    Write-FullError
                }
            }
        }

    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
