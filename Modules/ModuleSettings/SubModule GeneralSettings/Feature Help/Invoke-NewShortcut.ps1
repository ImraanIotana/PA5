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
        [System.String]$ArgumentPreFix      = '-Executionpolicy Bypass -WindowStyle Normal -File "{0}"'
        [System.String]$PS1FilePath         = (Join-Path -Path $ApplicationObject.RootFolder -ChildPath 'PackagingAssistant.ps1')
        [System.String]$IconSourcePath      = (Get-SharedAssetPath -AssetName MainApplicationIcon)

        ####################################################################################################
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            ParameterSetName            = [System.String]$PSCmdlet.ParameterSetName
            FunctionDetails             = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Handlers
            ShortcutPropertiesObject    = [PSCustomObject]@{
                # Basic handlers
                ShortcutFileName        = [System.String]('{0}.lnk' -f $ApplicationObject.Name)
                UserDesktopFolder       = [System.String]([Environment]::GetFolderPath('Desktop'))
                UserStartMenuFolder     = [System.String](Join-Path -Path $ENV:APPDATA -ChildPath 'Microsoft\Windows\Start Menu\Programs')
                # Argument handlers
                PowershellPath          = [System.String](Join-Path -Path $ENV:SystemRoot -ChildPath 'System32\WindowsPowerShell\v1.0\powershell.exe')
                ArgumentPreFix          = [System.String]'-Executionpolicy Bypass -WindowStyle Normal -File "{0}"'
                PS1FilePath             = [System.String](Join-Path -Path $ApplicationObject.RootFolder -ChildPath 'PackagingAssistant.ps1')
                # Icon handlers
                IconSourcePath          = [System.String](Get-SharedAssetPath -AssetName MainApplicationIcon)
            }
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Add the calculated properties to the ShortcutPropertiesObject
            $CalculatedProperties = @{
                DesktopShortcutFullPath     = Join-Path -Path $this.ShortcutPropertiesObject.UserDesktopFolder -ChildPath $this.ShortcutPropertiesObject.ShortcutFileName
                StartMenuShortcutFullPath   = Join-Path -Path $this.ShortcutPropertiesObject.UserStartMenuFolder -ChildPath $this.ShortcutPropertiesObject.ShortcutFileName
                ShortcutArgument            = ($this.ShortcutPropertiesObject.ArgumentPreFix -f $this.ShortcutPropertiesObject.PS1FilePath)
                Location                    = switch ($this.FunctionDetails[1]) {
                    'CreateDesktopShortcut'     { 'Desktop' }
                    'CreateStartMenuShortcut'   { 'StartMenu' }
                }
            }
            $CalculatedProperties.GetEnumerator() | ForEach-Object { Add-Member -InputObject $this.ShortcutPropertiesObject -NotePropertyName $_.Name -NotePropertyValue $_.Value }
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get user confirmation
            if (-Not(Get-UserConfirmation -Title ('Create {0} Shortcut' -f $this.ShortcutPropertiesObject.Location) -Body ('This will create a {0} Shortcut. Are you sure?' -f $this.ShortcutPropertiesObject.Location))) { Return }
            # Copy the icon locally
            $this.AddIconToLocalAppData()
            # Create the shortcut
            $this.CreateShortcut($this.ShortcutPropertiesObject)
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the CreateShortcut method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateShortcut -Value { param([PSCustomObject]$ShortcutPropertiesObject)
            try {
                # Set the ShortcutFullPath based on the ParameterSetName
                [System.String]$ShortcutFullPath = switch ($this.FunctionDetails[1]) {
                    'CreateDesktopShortcut'     { $ShortcutPropertiesObject.DesktopShortcutFullPath }
                    'CreateStartMenuShortcut'   { $ShortcutPropertiesObject.StartMenuShortcutFullPath }
                }
                # Write the message
                Write-Host ('Creating the shortcut ({0})...' -f $ShortcutFullPath) -ForegroundColor DarkGray
                # Create a WScript object
                [System.__ComObject]$WScriptShellObject = New-Object -ComObject WScript.Shell
                # Create a new WScript shortcut object
                [System.__ComObject]$WScriptShortcutObject = $WScriptShellObject.CreateShortcut($ShortcutFullPath)
                # Add the targetpath
                $WScriptShortcutObject.TargetPath = $ShortcutPropertiesObject.PowershellPath
                # Add the argument
                $WScriptShortcutObject.Arguments = $ShortcutPropertiesObject.ShortcutArgument
                # Add the icon
                #$WScriptShortcutObject.IconLocation = $ShortcutPropertiesObject.IconSourcePath
                $WScriptShortcutObject.IconLocation = $ShortcutPropertiesObject.LocalIconPath
                # Save the new shortcut object
                $WScriptShortcutObject.Save()
                # Write the message
                Write-Host ('Succesfully created the shortcut ({0})...' -f $ShortcutFullPath) -ForegroundColor DarkGray
            }
            catch {
                Write-FullError
            }
        }

        # Add the AddIconToLocalAppData method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddIconToLocalAppData -Value {
            # Copy the icon to LocalAppData
            [System.String]$DestinationFolder = Join-Path -Path $ENV:LocalAppData -ChildPath 'PAicon'
            New-Item -Path $DestinationFolder -ItemType Directory -Force
            Copy-Item -Path $this.ShortcutPropertiesObject.IconSourcePath -Destination $DestinationFolder -Force
            # Add the LocalIconPath to the ShortcutPropertiesObject
            [System.String]$LocalIconPath = (Get-ChildItem -Path $DestinationFolder -File | Where-Object { $_.Extension -eq '.ico' } | Select-Object -First 1).FullName
            Add-Member -InputObject $this.ShortcutPropertiesObject -NotePropertyName LocalIconPath -NotePropertyValue $LocalIconPath

        }

        ####################################################################################################

        $Local:MainObject.Begin()
    } 
    
    process {
        #$Local:MainObject.Process()

        # Set the Destination Path based on the ParameterSetName
        [System.String]$DestinationFolder = switch ($ParameterSetName) {
            'CreateDesktopShortcut'     { $UserDesktopFolder }
            'CreateStartMenuShortcut'   { $UserStartMenuFolder }
        }
        # Set the Shortcut Full Path
        [System.String]$ShortcutFullPath = Join-Path -Path $DestinationFolder -ChildPath $ShortcutFileName
        # Get user confirmation
        if (-Not(Get-UserConfirmation -Title 'Create New Shortcut' -Body "This will create the following Shortcut.`n`n$ShortcutFullPath`n`nAre you sure?" )) { Return }
        # Copy the icon to LocalAppData
        [System.String]$IconDestinationFolder = Join-Path -Path $ENV:LocalAppData -ChildPath 'PAicon'
        New-Item -Path $IconDestinationFolder -ItemType Directory -Force
        Copy-Item -Path $IconSourcePath -Destination $IconDestinationFolder -Force
        [System.String]$IconFileName    = (Get-Item -Path $IconSourcePath).Name 
        [System.String]$LocalIconPath   = (Get-ChildItem -Path $IconDestinationFolder -File | Where-Object { $_.Name -eq $IconFileName }).FullName
        # Create the shortcut
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
