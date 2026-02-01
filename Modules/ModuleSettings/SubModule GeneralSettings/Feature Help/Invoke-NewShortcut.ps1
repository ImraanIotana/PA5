####################################################################################################
<#
.SYNOPSIS
    This function creates a new Shortcut for the Packaging Assistant.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Invoke-NewShortcut -Desktop
.INPUTS
    [PSCustomObject]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : March 2025
    Last Update     : January 2026
#>
####################################################################################################

function Invoke-NewShortcut {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The ApplicationObject containing the Settings.')]
        [PSCustomObject]$ApplicationObject = $Global:ApplicationObject,

        [Parameter(Mandatory=$true,ParameterSetName='CreateDesktopShortcut',HelpMessage='Switch for creating a Desktop shortcut.')]
        [System.Management.Automation.SwitchParameter]$Desktop,

        [Parameter(Mandatory=$true,ParameterSetName='CreateStartMenuShortcut',HelpMessage='Switch for creating a StartMenu shortcut.')]
        [System.Management.Automation.SwitchParameter]$StartMenu
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String]$ParameterSetName    = $PSCmdlet.ParameterSetName

        # User Folder Handlers
        [System.String]$UserDesktopFolder   = $ApplicationObject.UserDesktopFolder
        [System.String]$UserStartMenuFolder = $ApplicationObject.UserStartMenuFolder

        # Shortcut Handlers
        [System.String]$PowershellPath      = (Join-Path -Path $ApplicationObject.WindowsFolder -ChildPath 'System32\WindowsPowerShell\v1.0\powershell.exe')
        [System.String]$ShortcutFileName    = "$($ApplicationObject.Name).lnk"
        [System.String]$IconSourcePath      = (Get-SharedAssetPath -AssetName MainApplicationIcon)

        # Argument Handlers
        [System.String]$PS1FilePath         = (Join-Path -Path $ApplicationObject.RootFolder -ChildPath 'PackagingAssistant.ps1')
        [System.String]$ShortcutArgument    = ('-Executionpolicy Bypass -WindowStyle Normal -File "{0}"' -f $PS1FilePath)

        ####################################################################################################
    }
    
    process {
        try {
            # PROPERTIES
            # Set the Destination Path based on the ParameterSetName
            [System.String]$DestinationFolder = switch ($ParameterSetName) {
                'CreateDesktopShortcut'     { $UserDesktopFolder }
                'CreateStartMenuShortcut'   { $UserStartMenuFolder }
            }
            # Set the Shortcut Full Path
            [System.String]$ShortcutFullPath = Join-Path -Path $DestinationFolder -ChildPath $ShortcutFileName

            # CONFIRMATION
            # Get user confirmation
            if (-Not(Get-UserConfirmation -Title 'Create New Shortcut' -Body "This will create the following Shortcut.`n`n$ShortcutFullPath`n`nAre you sure?" )) { Return }

            # ICON
            # Copy the icon to LocalAppData
            [System.String]$IconDestinationFolder = Join-Path -Path $ENV:LocalAppData -ChildPath 'PAicon'
            New-Item -Path $IconDestinationFolder -ItemType Directory -Force
            Copy-Item -Path $IconSourcePath -Destination $IconDestinationFolder -Force
            [System.String]$IconFileName    = (Get-Item -Path $IconSourcePath).Name 
            [System.String]$LocalIconPath   = (Get-ChildItem -Path $IconDestinationFolder -File | Where-Object { $_.Name -eq $IconFileName }).FullName

            # SHORTCUT CREATION
            # Create the Shortcut
            Write-Line "Creating the Shortcut ($ShortcutFullPath)..."
            # Create a new WScript Shortcut object
            [System.__ComObject]$WScriptShellObject     = New-Object -ComObject WScript.Shell
            [System.__ComObject]$WScriptShortcutObject  = $WScriptShellObject.CreateShortcut($ShortcutFullPath)
            $WScriptShortcutObject.TargetPath           = $PowershellPath
            $WScriptShortcutObject.Arguments            = $ShortcutArgument
            $WScriptShortcutObject.IconLocation         = $LocalIconPath
            # Save the new object
            $WScriptShortcutObject.Save()
            # Write the message
            Write-Line "Succesfully created the Shortcut ($ShortcutFullPath)..."
        }
        catch {
            Write-FullError
        }
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
