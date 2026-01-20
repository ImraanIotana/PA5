####################################################################################################
<#
.SYNOPSIS
    This function get the details of a shortcut, and returns an object will properties.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    New-ShortcutPropertiesObject -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Acrobat Reader.lnk"
.INPUTS
    [System.String]
.OUTPUTS
    [System.__ComObject]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function New-ShortcutPropertiesObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The StartMenu shortcut or folder, from which the information will be obtained.')]
        [System.String]
        $Path
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Input
        [System.String]$ShortcutPath        = $Path
        # Other Handlers
        [System.String[]]$PropertiesToWrite = @('BaseName','TargetPath','WorkingDirectory','Arguments','StartMenuLocationShort','IconFilePath')
        # Start Menu Handlers
        [System.String]$SystemStartMenuFolder   = ('{0}\Microsoft\Windows\Start Menu\Programs' -f $ENV:PROGRAMDATA)
        [System.String]$UserStartMenuFolder     = ('{0}\Microsoft\Windows\Start Menu\Programs' -f $ENV:APPDATA)

        ####################################################################################################
        ### SUPPORTING FUNCTIONS ###
    
        function Add-StartMenuLocationShort {
            # Set the StartMenuLocationShort
            [System.String]$StartMenuLocationFull = $ShortcutPropertiesObject.StartMenuLocationFull
            [System.String]$StartMenuLocationShort = if ($StartMenuLocationFull.StartsWith(($SystemStartMenuFolder))) {
                $StartMenuLocationFull.Replace($SystemStartMenuFolder,'')
            } else {
                $StartMenuLocationFull.Replace($UserStartMenuFolder,'')
            }
            if (Test-Object -IsEmpty $StartMenuLocationShort) { $StartMenuLocationShort = 'In the root of the StartMenu'}
            # Add the properties to the object
            Add-Member -InputObject $ShortcutPropertiesObject -NotePropertyName StartMenuLocationShort -NotePropertyValue $StartMenuLocationShort
        }

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # Write the message
        Write-Line ('Getting the properties of the shortcut: ({0})' -f $ShortcutPath)
        # Create a WScript object
        [System.__ComObject]$WScriptShellObject = New-Object -ComObject WScript.Shell
        # Create a ShortcutPropertiesObject
        [System.__ComObject]$ShortcutPropertiesObject = $WScriptShellObject.CreateShortcut($ShortcutPath)
        # Set the IconFilePath
        [System.String]$IconFilePath = (($ShortcutPropertiesObject.IconLocation).Split(',')[0])
        # If the IconFilePath is empty then use the TargetPath
        if (Test-Object -IsEmpty $IconFilePath) { $IconFilePath = $ShortcutPropertiesObject.TargetPath }
        # Create a hashtable for the additional properties
        [System.Collections.Hashtable]$AdditionalProperties = @{
            #CounterTextLine         = ('* Shortcut {0} of {1}' -f ($ShortcutPathsArray.IndexOf($ShortcutPath) + 1),$ShortcutPathsArray.Count)
            IconFilePath            = $IconFilePath
            IconIndex               = (($ShortcutPropertiesObject.IconLocation).Split(',')[1])
            BaseName                = (Get-Item -Path $ShortcutPropertiesObject.FullName).BaseName
            StartMenuLocationFull   = (Split-Path -Path $ShortcutPropertiesObject.FullName)
            PropertiesToWrite       = $PropertiesToWrite
            TimeStampCreation       = Get-TimeStamp -Universal
        }
        # Add the additional properties to the object
        $AdditionalProperties.GetEnumerator() | ForEach-Object { Add-Member -InputObject $ShortcutPropertiesObject -NotePropertyName $_.Name -NotePropertyValue $_.Value }
        # Add StartMenuLocationShort to the object
        Add-StartMenuLocationShort $ShortcutPropertiesObject
        # Set the output
        [System.__ComObject]$OutputObject = $ShortcutPropertiesObject
        # OUTHOST FOR TESTING
        #$OutputObject | Out-Host
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
