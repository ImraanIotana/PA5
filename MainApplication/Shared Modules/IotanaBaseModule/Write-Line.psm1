####################################################################################################
<#
.SYNOPSIS
    This function writes a line to the host in several colors.
.DESCRIPTION
    This function is part of the Iotana Base Module. It is self-contained and does not refer to functions or variables, that are in other files.
.EXAMPLE
    Write-Line "Hello World!"
.EXAMPLE
    Write-Line "Hello World!" -Type Busy
.EXAMPLE
    Write-Line -Type NoAction
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.6
    Author          : Imraan Iotana
    Creation Date   : December 2025
    Last Update     : December 2025
#>
####################################################################################################

function Write-Line {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,Position=0,HelpMessage='The message that will be written to the host.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Message,

        [Parameter(Mandatory=$false,Position=1,HelpMessage='Type for deciding the colors and prefixes.')]
        [ValidateSet('Normal','Busy','NoAction','Success','SuccessNoAction','ValidationSuccess','Fail','ActionFail','ValidationFail','Special','Seperation','DoubleSeperation')]
        [System.String]
        $Type
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Input
        [System.String]$InputMessage    = $Message
        [System.String]$MessageType     = $Type

        # Test if this is the Universal Deployment Script
        [System.Boolean]$IsUniversalDeploymentScript = ($Global:DeploymentObject.Name -eq 'Universal Deployment Script')

        # Get the name of the calling function
        [System.String]$CallingFunction = ((Get-PSCallStack).Command[1])

        # Get the TimeStamp
        [System.DateTime]$UTCTimeStamp  = [DateTime]::UtcNow
        [System.String]$LogDate         = $UTCTimeStamp.ToString('yyyy-MM-dd')
        [System.String]$LogTime         = $UTCTimeStamp.ToString('HH:mm:ss.fff')
        [System.String]$FullTimeStamp   = "$LogDate $LogTime"


        ####################################################################################################


        # Set the FullMessage
        [System.String]$FullMessage = switch ($MessageType) {
            'NoAction'          { 'No action has been taken.' }
            'SuccessNoAction'   { 
                if ($IsUniversalDeploymentScript) {
                    "[$($FullTimeStamp)] [$($CallingFunction)]: The $($Global:DeploymentObject.Action)-process is considered successful. No action has been taken."
                } else {
                    'No action has been taken.'
                }
            }
            'Seperation'        { "[$($FullTimeStamp)] " + ('-' * 100) }
            'DoubleSeperation'  { "[$($FullTimeStamp)] " + ('=' * 100) }
            'ValidationSuccess' { "[$($FullTimeStamp)] [$($CallingFunction)]: The validation is successful. The process will now start." }
            'ValidationFail'    { "[$($FullTimeStamp)] [$($CallingFunction)]: The validation failed. The process will NOT start." }
            Default             {
                if ($IsUniversalDeploymentScript -and -not $InputMessage.StartsWith('[')) {
                    "[$($FullTimeStamp)] [$($CallingFunction)]: $InputMessage"
                } elseif ($IsUniversalDeploymentScript) {
                    "[$($FullTimeStamp)] $InputMessage"
                } else {
                    $InputMessage
                }
            }
        }
        

        # Set the ForegroundColor
        [System.String]$ForegroundColor = switch ($MessageType) {
            'Busy'              { 'Yellow'  }
            'Success'           { 'Green'   }
            'Fail'              { 'Red'     }
            'Normal'            { 'White'   }
            'Special'           { 'Cyan'    }
            'SuccessNoAction'   { 'Green'   }
            'Seperation'        { 'White'   }
            'DoubleSeperation'  { 'White'   }
            'ValidationFail'    { 'White'   }
            Default             { 'DarkGray'}
        }

        # Set the BackgroundColor
        [System.String]$BackgroundColor = switch ($MessageType) {
            'ActionFail'        { 'DarkRed' }
            'ValidationFail'    { 'DarkRed' }
            Default             { ''        }
        }
    }
    
    process {
        # VALIDATION
        # Validate the Global Objects
        if (($null -eq $Global:ApplicationObject) -and ($null -eq $Global:DeploymentObject)) {
            Write-Host "Write-Line: ERROR: Neither ApplicationObject nor DeploymentObject is initialized" -ForegroundColor Red
            return
        }

        # EXECUTION
        # Set the Write-Host parameters
        [System.Collections.Hashtable]$WriteHostParams = @{
            'Object'            = $FullMessage
            'ForegroundColor'   = $ForegroundColor
        }
        # Add BackgroundColor if specified
        if (-not [System.String]::IsNullOrEmpty($BackgroundColor)) {
            $WriteHostParams['BackgroundColor'] = $BackgroundColor
        }

        # Write the message
        Write-Host @WriteHostParams
    }
    
    end {
    }
}


<####################################################################################################
# EVENT VIEWER PROPERTIES # IN DEVELOPMENT FOR THE UDS #

# Add the EventViewerEntryType property
$MessageObject | Add-Member -MemberType ScriptProperty EventViewerEntryType -Value {
    switch ($MessageType) {
        'ValidationFail'    { 'Error' }
        'Fail'              { 'Error' }
        Default             { 'Information' }
    }
}

# Add the EventViewerEventID property
$MessageObject | Add-Member -MemberType ScriptProperty EventViewerEventID -Value {
    switch ($MessageType) {
        'ValidationFail'    { '5000' }
        'Fail'              { '6000' }
        'ValidationSuccess' { '7000' }
        'SuccessNoAction'   { '8000' }
        'Success'           { '9000' }
        Default             { '1000' }
    }
}

# WRITE EVENTVIEWER METHOD
# Add the WriteEventViewerMessage method
$MessageObject | Add-Member -MemberType ScriptMethod WriteEventViewerMessage -Value {
    # Write the Event Viewer Log entry
    #Write-EventLog -LogName "Application Installation/$ApplicationID" -Source $ApplicationID -EntryType $this.EventViewerEntryType -EventId $this.EventViewerEventID -Message $this.FullMessage
}

#####################################################################################################>

### END OF FUNCTION
####################################################################################################
