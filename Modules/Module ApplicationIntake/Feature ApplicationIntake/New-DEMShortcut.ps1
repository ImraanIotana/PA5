####################################################################################################
<#
.SYNOPSIS
    This function imports the Module MECM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-ModuleDSLSynchronization
.INPUTS
    [System.String]
.OUTPUTS
    [Microsoft.ConfigurationManagement.PowerShell.Framework.DetectionClause]
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : July 2025
#>
####################################################################################################

function New-DEMShortcut {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Application to which this new Deployment Type will be added.')]
        [Alias('ApplicationName','Application')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,HelpMessage='The startmenu item that will be handled.')]
        [Alias('StartMenuPath','Path')]
        [AllowEmptyString()]
        [System.String]
        $StartMenuItemPath,

        [Parameter(Mandatory=$false,HelpMessage='Switch for asking the user for confirmation.')]
        [Alias('AskUserConfirmation','AskConfirmation')]
        [System.Management.Automation.SwitchParameter]
        $Confirm
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails         = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationID           = $ApplicationID
            StartMenuItemPath       = $StartMenuItemPath
            Confirm                 = $Confirm
            # Validation
            ValidationArray         = [System.Boolean[]]@()
            # Handlers
            SystemStartMenuFolder   = [System.String]'{0}\Microsoft\Windows\Start Menu\Programs' -f $ENV:ProgramData
            UserStartMenuFolder     = [System.String]'{0}\Microsoft\Windows\Start Menu\Programs' -f $ENV:APPDATA
            SystemStartMenuPrefix   = [System.String]'[SYSTEM]'
            UserStartMenuPrefix     = [System.String]'[USER]'
            # Confirmation Handlers
            ConfirmationTitle       = [System.String]'Create DEM Shortcuts'
            ConfirmationBody        = [System.String]'Would you like to create the Omnissa DEM Shortcuts?'
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value { Write-Message -Begin $this.FunctionDetails }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Get user confirmation
            if ($this.Confirm.IsPresent) { if (-Not(Get-UserConfirmation -Title $this.ConfirmationTitle -Body $this.ConfirmationBody)) { Return } }
            # Validate the input
            $this.ValidateInput()
            # If the validation failed, then return
            if ($this.ValidationArray -contains $false) { Write-Message -ValidationFailed ; Return }
            # Add the properties to the main object
            $this | Add-Member -NotePropertyName ActualStartMenuItemFullPath -NotePropertyValue $this.GetActualStartMenuItemFullPath($this.StartMenuItemPath)
            $this.CreateDEMShortcut($this.ActualStartMenuItemFullPath)
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the CreateDEMShortcut method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name CreateDEMShortcut -Value { param([System.String]$Path)
            try {
                # If the item is a folder, then get all shortcuts in the folder
                [System.String[]]$ShortcutPathsArray = if (Test-Path -Path $Path -PathType Container) { (Get-ChildItem -Path $Path -Recurse -File).FullName } else { $Path }
                # If no items were found, then return
                if ($ShortcutPathsArray.Count -eq 0) { Write-Host ('No shortcuts were found in the folder: ({0})' -f $Path) ; Return }
                # Handle each shortcut
                foreach ($ShortcutPath in $ShortcutPathsArray) {
                    # Write the message
                    Write-Host ('Getting the properties of the shortcut: ({0})' -f $ShortcutPath) -ForegroundColor DarkGray
                    # Create a WScript object
                    [System.__ComObject]$WScriptShellObject = New-Object -ComObject WScript.Shell
                    # Create a ShortcutPropertiesObject
                    [PSCustomObject]$ShortcutPropertiesObject = $WScriptShellObject.CreateShortcut($ShortcutPath)
                    # Set the needed properties
                    [System.String]$ShortcutBaseName    = (Get-Item -Path $ShortcutPath).BaseName
                    [System.String]$ShortcutTargetPath  = $ShortcutPropertiesObject.TargetPath
                    [System.String]$IconFilePath        = (($ShortcutPropertiesObject.IconLocation).Split(',')[0])
                    [System.String]$IconIndex           = (($ShortcutPropertiesObject.IconLocation).Split(',')[1])
                    # If the IconFilePath is empty then use the TargetPath
                    if (Test-Object -IsEmpty $IconFilePath) { $IconFilePath = $ShortcutTargetPath }

                    # Get the template xml
                    [System.String]$TemplateXMLPath = (Get-ChildItem -Path $PSScriptRoot -Recurse -File | Where-Object { $_.Name -eq 'DEMShortcutTemplate.xml' }).FullName
                    [System.Xml.XmlDocument]$NewXMLDocument = New-Object System.Xml.XmlDocument
                    $NewXMLDocument.Load($TemplateXMLPath)

                    # Set the properties in the XML
                    $NewXMLDocument.userEnvironmentSettings.conditions.path.p = $ShortcutTargetPath
                    $NewXMLDocument.userEnvironmentSettings.setting.path = $ShortcutTargetPath
                    $NewXMLDocument.userEnvironmentSettings.setting.startIn = $ShortcutPropertiesObject.WorkingDirectory
                    $NewXMLDocument.userEnvironmentSettings.setting.args = $ShortcutPropertiesObject.Arguments
                    $NewXMLDocument.userEnvironmentSettings.setting.lnk = $ShortcutBaseName
                    $NewXMLDocument.userEnvironmentSettings.setting.label = $this.ApplicationID
                    $NewXMLDocument.userEnvironmentSettings.setting.comment = $this.ApplicationID
                    $NewXMLDocument.userEnvironmentSettings.setting.iconPath = $IconFilePath
                    $NewXMLDocument.userEnvironmentSettings.setting.iconIndex = $IconIndex

                    # Set the output path
                    [System.String]$LocalShortcutOutputFolder   = $this.GetLocalShortcutOutputFolder()
                    [System.String]$ShortcutOutputPath          = Join-Path -Path $LocalShortcutOutputFolder -ChildPath "$ShortcutBaseName.xml"

                    # Save the new XML
                    $NewXMLDocument.Save($ShortcutOutputPath)
                }
            }
            catch { Write-FullError }
        }

        ####################################################################################################
        ### SUPPORTING METHODS ###

        # Add the ValidateInput method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name ValidateInput -Value {
            # Validate the input
            $this.ValidationArray += Confirm-Object -MandatoryString $this.ApplicationID
            $this.ValidationArray += Confirm-Object -MandatoryString $this.StartMenuItemPath
        }

        # Add the GetActualStartMenuItemFullPath method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name GetActualStartMenuItemFullPath -Value { param([System.String]$StartMenuItemPath)
            # Replace the prefixes if present
            if ($StartMenuItemPath.StartsWith($this.SystemStartMenuPrefix)) { $ActualStartMenuItemFullPath = $StartMenuItemPath.Replace($this.SystemStartMenuPrefix,$this.SystemStartMenuFolder) }
            if ($StartMenuItemPath.StartsWith($this.UserStartMenuPrefix)) { $ActualStartMenuItemFullPath = $StartMenuItemPath.Replace($this.UserStartMenuPrefix,$this.UserStartMenuFolder) }
            # Return the result
            $ActualStartMenuItemFullPath
        }

        # Add the GetLocalShortcutOutputFolder method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name GetLocalShortcutOutputFolder -Value { param([System.String]$StartMenuItemPath)
            # Set the LocalShortcutOutputFolder
            [System.String]$ApplicationName             = Get-ApplicationName
            [System.String]$LocalApplicationFolder      = Join-Path -Path (Get-SharedAssetPath -OutputFolder) -ChildPath $ApplicationName
            [System.String]$ScreenshotsSubFolder        = (Get-ApplicationSubfolders).ShortcutsFolder
            [System.String]$LocalShortcutOutputFolder   = Join-Path -Path $LocalApplicationFolder -ChildPath $ScreenshotsSubFolder
            # Return the result
            $LocalShortcutOutputFolder
        }

        ####################################################################################################

        $Local:MainObject.Begin()        
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
        $Local:MainObject.End()
    }
}

### END OF SCRIPT
####################################################################################################
