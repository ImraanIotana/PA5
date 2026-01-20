####################################################################################################
<#
.SYNOPSIS
    This function adds a log entry to the logfile of the application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Add-LogEntry -Message 'Succesfully created the backup.' -ApplicationID 'Adobe_Reader_12.4' -Type Success
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Add-LogEntry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The ID of the application that will be handled.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,HelpMessage='The message that will be added to the log.')]
        [System.String]
        $Message,

        [Parameter(Mandatory=$false,HelpMessage='The message type.')]
        [ValidateSet('Info','Warning','Success','Fail','Error')]
        [System.String]
        $Type = 'Info'
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Logfile Handlers
        [System.String]$ApplicationLogFilePath  = Get-Path -ApplicationID $ApplicationID -LogFilePath

        # Timestamp Handlers
        [System.DateTime]$UTCTimeStamp          = [DateTime]::UtcNow
        [System.String]$LogDate                 = $UTCTimeStamp.ToString('yyyy-MM-dd')
        [System.String]$LogTime                 = $UTCTimeStamp.ToString('HH:mm:ss.fff')
        [System.String]$FullTimeStamp           = $UTCTimeStamp.ToString('yyyy-MM-dd HH:mm:ss.fff')
        
        # Other Handlers
        [System.String]$FirstCallingFunction    = ((Get-PSCallStack).Command[1])
        [System.String]$CallingFunction         = if ($FirstCallingFunction.StartsWith('Write-')) { ((Get-PSCallStack).Command[2]) } else { $FirstCallingFunction }
        [System.String]$UserName                = ('{0}\{1}' -f $ENV:USERDOMAIN,$ENV:USERNAME)

        # Set the messageprefix
        [System.Char]$PrefixSymbol              = switch ($Type) {
            'Info'      {}
            'Warning'   { 0x2757 } # ❗
            'Success'   { 0x2705 } # ✅
            'Fail'      { 0x274C } # ❌
            'Error'     { 0x26A0 } # ⚠
        }

        # Set the full message
        [System.String]$MessageWithSymbol = if ($PrefixSymbol) { "$PrefixSymbol $Message" } else { $Message }

        # Set the message
        $FullLogMessage = [PSCustomObject]@{
            'Timestap (UTC)'    = $FullTimeStamp
            Type                = $Type.ToUpper()
            Message             = $MessageWithSymbol
            'Calling Function'  = $CallingFunction
            User                = $UserName
            Date                = $LogDate
            Time                = $LogTime
        }

        ####################################################################################################
    }
    
    process {
        # EXECUTION
        if (-Not(Test-Path -Path $ApplicationLogFilePath)) { New-Item -Path $ApplicationLogFilePath -Type File -Force | Out-Null }
        $FullLogMessage | Export-Csv -Path $ApplicationLogFilePath -Append -NoTypeInformation -Encoding UTF8
    }
    
    end {
        # TESTING
        #Import-Csv -Path $ApplicationLogFilePath | Out-GridView
        #Open-Folder -Path (Split-Path -Path $ApplicationLogFilePath -Parent)
    }
}

### END OF SCRIPT
####################################################################################################
