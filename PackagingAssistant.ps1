####################################################################################################
<#
.SYNOPSIS
    This application assists Package Engineers by automating administrative tasks.
.DESCRIPTION
    This application performs tasks like creating an Application Intake, creating AppLocker files, creating an MECM Application, etc.
.EXAMPLE
    %windir%\sysnative\WindowsPowerShell\v1.0\powershell.exe -Executionpolicy Bypass -WindowStyle Normal -File "PackagingAssistant.ps1"
.EXAMPLE
    %windir%\sysnative\WindowsPowerShell\v1.0\powershell.exe -Executionpolicy Bypass -WindowStyle Normal -File "PackagingAssistant.ps1" -Verbose
.INPUTS
    This script has no input parameters.
.OUTPUTS
    This script returns no stream-output. All output is written to the host during runtime.
.NOTES
    Version         : See below at line 35: Version = [System.String]'x.y'
    Author          : Imraan Iotana
    Creation Date   : May 2023
    Last Update     : December 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

[CmdletBinding()]
param (
)

begin {
    ####################################################################################################
    ### MAIN OBJECT ###

    # Create the Global Application object
    [PSCustomObject]$Global:ApplicationObject = @{
        # Application
        Name                        = [System.String]'Packaging Assistant'
        Version                     = [System.String]'5.6'
        # Folder Handlers
        RootFolder                  = [System.String]$PSScriptRoot
        LogFolder                   = [System.String](Join-Path -Path $ENV:TEMP -ChildPath 'PALogs')
        DefaultOutputFolder         = [System.String](Join-Path -Path $ENV:USERPROFILE -ChildPath 'Downloads')
        WorkFolderLeafNames         = [System.Collections.Hashtable]@{
            MainApplication         = 'MainApplication'
            GraphicFunctions        = 'MainApplication\Graphic Functions'
            SharedFunctions         = 'MainApplication\Shared Functions'
            SharedModules           = 'MainApplication\Shared Modules'
            SharedAssets            = 'MainApplication\Shared Assets'
            Settings                = 'MainApplication\Settings'
            Modules                 = 'Modules'
        }
        # File Handlers
        SettingsFileName            = [System.String]'ApplicationSettings.psd1'
        CustomerSettingsFileName    = [System.String]'CustomerSettings.psd1'
        IconFileName                = [System.String]'KPN.ico'
    }
   
    ####################################################################################################
    ### MAIN PROPERTIES ###

    # End Handlers
    [System.Boolean]$LeaveHostOpen  = $false
    [System.String]$HostPromptText  = 'Press Enter to close this window...'

    ####################################################################################################
    ### SUPPORTING FUNCTION ###

    function Write-WelcomeMessage {
        # Write the copyright and welcome message
        Write-Line "Copyright (C) Iotana. All rights reserved."
        Write-Host "Welcome to the $($Global:ApplicationObject.Name) version $($Global:ApplicationObject.Version)."
    }

    function Add-WorkFoldersToMainObject { param([PSCustomObject]$Object = $Global:ApplicationObject)
        # Create a new empty WorkFolders hashtable
        Write-Host 'Setting workfolders...' -ForegroundColor DarkGray
        [System.Collections.Hashtable]$WorkFolders = @{}
        # Add the full paths to the new WorkFolders hashtable
        $Object.WorkFolderLeafNames.GetEnumerator() | ForEach-Object {
            [System.String]$FolderId    = $_.Name
            [System.String]$FullPath    = Join-Path -Path $Object.RootFolder -ChildPath $_.Value
            Write-Verbose ('Setting the full path of folder id ({0}) to: ({1})' -f $FolderId, $FullPath)
            $WorkFolders.$FolderId = $FullPath
        }
        # Add the new WorkFolders hashtable to the main object
        $Object | Add-Member -NotePropertyName WorkFolders -NotePropertyValue $WorkFolders
    }

    # Set the function to move the host to the top left
    function Move-HostToTopLeft {

        # Add the System.Runtime.InteropServices type
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;

        public class WindowPosition {
            [DllImport("user32.dll")]
            public static extern IntPtr GetForegroundWindow();

            [DllImport("user32.dll")]
            public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
        }
"@ # (When indenting this last line, the parsing goes wrong.)

        # Set the dimensions
        [System.Int32]$HostHandleX         = 0
        [System.Int32]$HostHandleY         = 0
        [System.Int32]$HostHandleWidth     = 950
        [System.Int32]$HostHandleHeight    = 550

        # Get the active window (PowerShell host)
        [System.IntPtr]$HostHandle = [WindowPosition]::GetForegroundWindow()
        # Move the window
        [WindowPosition]::MoveWindow($HostHandle,$HostHandleX,$HostHandleY,$HostHandleWidth,$HostHandleHeight, $true) | Out-Null
    }

    function New-LogFolder { param([PSCustomObject]$Object = $Global:ApplicationObject)
        # Create the LogFolder
        if (-Not(Test-Path -Path $Object.LogFolder)) { New-Item -Path $Object.LogFolder -ItemType Directory -Force | Out-Null }
    }

    function Add-SettingsToMainObject { param([PSCustomObject]$Object = $Global:ApplicationObject)
        # Import the Settings
        Write-Line 'Importing settings...'
        [System.String]$SettingsFilePath = Join-Path -Path $Object.WorkFolders.Settings -ChildPath $Object.SettingsFileName
        [System.Collections.Hashtable]$Settings = Import-PowerShellDataFile -Path $SettingsFilePath
        # Import the Customer Settings
        [System.String]$CustomerSettingsFilePath = Join-Path -Path $Object.WorkFolders.Settings -ChildPath $Object.CustomerSettingsFileName
        [System.Collections.Hashtable]$CustomerSettings = Import-PowerShellDataFile -Path $CustomerSettingsFilePath
        # Add the CustomerSettingsHashtable to the SettingsHashtable
        $CustomerSettings.Keys | ForEach-Object { $Settings[$_] = $CustomerSettings[$_] }
        # Add the Settings hashtable to the main object
        $Object | Add-Member -NotePropertyName Settings -NotePropertyValue $Settings
    }

    function Add-GraphicalPrerequisites { param([PSCustomObject]$Object = $Global:ApplicationObject)
        # Load the assemblies
        Write-Line 'Loading Graphical Prerequisites...'
        $Object.Settings.Assemblies | ForEach-Object { Write-Verbose ('Loading Assembly: ({0})' -f $_) ; Add-Type -AssemblyName $_ }
        # Add the fonts
        Write-Verbose 'Adding the fonts to the Settings...'
        [System.Drawing.Font]$MainFont = New-Object System.Drawing.Font($Object.Settings.MainFont.Name,$Object.Settings.MainFont.Size,[System.Drawing.FontStyle]::Bold)
        Add-Member -InputObject $Object.Settings -NotePropertyName MainFont -NotePropertyValue $MainFont
    }
        
    function Import-PAModules {
        # Add the Module Directory to the Environment Variable
        $ENV:PSModulePath += ";$($Global:ApplicationObject.WorkFolders.SharedModules)"
        # Import the PA Modules
        Import-Module -Name PASystemModule
        Import-Module -Name PAWriteModule
        Import-Module -Name PADSLManagementModule
        Import-Module -Name PAOmnissaDEMModule
        Import-Module -Name PAAppLockerModule
        Import-Module -Name PAShortcutModule
    }

    ####################################################################################################
}

process {
    # Start the Initialization
    Move-HostToTopLeft
    Add-WorkFoldersToMainObject

    # Unblock and dotsource the PS1 files
    [System.String[]]$FoldersToSearch = @($Global:ApplicationObject.WorkFolders.GraphicFunctions,$Global:ApplicationObject.WorkFolders.SharedFunctions,$Global:ApplicationObject.WorkFolders.Modules)
    [System.IO.FileSystemInfo[]]$AllPS1FileObjects = $FoldersToSearch | ForEach-Object { Get-ChildItem -Path $_ -Recurse -File -Include *.ps1 }
    $AllPS1FileObjects | ForEach-Object { if ($_) { Unblock-File -Path $_ ; . $_.FullName } }

    # Continue the Initialization (After dotsourcing, all functions have become available.)
    New-LogFolder
    Import-PAModules
    Add-SettingsToMainObject
    Add-GraphicalPrerequisites
    Invoke-UserSettings -Initialize
    
    # Build the Form
    try {
        # Build the Global Main Form (Name: $Global:MainForm)
        Invoke-MainForm -Create -ApplicationObject $Global:ApplicationObject
        # Add the dimensions of the graphical child objects to the Settings
        Add-GraphicalDimensionsToSettings -ApplicationObject $Global:ApplicationObject
        # Build the Global Main Tabcontrol (Name: $Global:MainTabControl)
        Invoke-MainTabControl -ParentForm $Global:MainForm

        # Check if the machine is an SCCM server
        [System.ComponentModel.Component[]]$SCCMServices = Get-Service | Where-Object { $_.Name.StartsWith('SMS') } -ErrorAction SilentlyContinue
        [System.Boolean]$IsSCCMServer = if ($SCCMServices) { $true } else { $false }
        Add-Member -InputObject $Global:ApplicationObject -NotePropertyName IsSCCMServer -NotePropertyValue $IsSCCMServer

        # Load the SCCM/MECM module only on an SCCM server
        if ($IsSCCMServer) {        
            Import-Module -Name PASCCMModule
            Import-ModuleSCCMApplication
        }
        # Import the modules, only if not an SCCM server
        if (-Not($IsSCCMServer)) {
            Import-ModuleApplicationIntake
            Import-ModuleIntakeExtras
        }
        # Import these modules, for all machines
        Import-ModuleApplicationManagement
        # Hide these modules on an SCCM server
        if (-Not($IsSCCMServer)) {
            Import-ModuleOmnissaDEMManagement
            Import-ModuleAppLockerImport
        }
        # Import these modules, for all machines
        Import-ModuleLauncher
        Import-ModuleApplicationSettings

        # Write the welcome message
        Write-WelcomeMessage

        # Show the Main Form
        Invoke-MainForm -Show
    }
    catch {
        Write-FullError
    }
}

end {
    # If LeaveHostOpen is set to true, leave the host open
    if ($LeaveHostOpen) { Read-Host -Prompt $HostPromptText }
}

### END OF SCRIPT
####################################################################################################
