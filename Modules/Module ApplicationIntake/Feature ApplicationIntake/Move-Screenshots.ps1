####################################################################################################
<#
.SYNOPSIS
    This function moves the screenshots from the your Screenshot-folder to the Application Folder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Move-Screenshots -ToLocalApplicationFolder
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.4.7
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : July 2025
#>
####################################################################################################

function Move-Screenshots {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='MoveFromNetworkToLocalApplicationFolder',HelpMessage='Switch for moving the screenshots FROM the NETWORK Screenshots folder.')]
        [Parameter(Mandatory=$true,ParameterSetName='MoveFromNetworkToNetworkApplicationFolder')]
        [System.Management.Automation.SwitchParameter]
        $FromNetworkScreenshotsFolder,

        [Parameter(Mandatory=$true,ParameterSetName='MoveFromLocalToLocalApplicationFolder',HelpMessage='Switch for moving the screenshots FROM the LOCAL Screenshots folder.')]
        [Parameter(Mandatory=$true,ParameterSetName='MoveFromLocalToNetworkApplicationFolder')]
        [System.Management.Automation.SwitchParameter]
        $FromLocalScreenshotsFolder,

        [Parameter(Mandatory=$true,ParameterSetName='MoveFromLocalToNetworkApplicationFolder',HelpMessage='Switch for moving the screenshots TO the NETWORK Application folder.')]
        [Parameter(Mandatory=$true,ParameterSetName='MoveFromNetworkToNetworkApplicationFolder')]
        [System.Management.Automation.SwitchParameter]
        $ToNetworkApplicationFolder,

        [Parameter(Mandatory=$true,ParameterSetName='MoveFromLocalToLocalApplicationFolder',HelpMessage='Switch for moving the screenshots TO the LOCAL Application folder.')]
        [Parameter(Mandatory=$true,ParameterSetName='MoveFromNetworkToLocalApplicationFolder')]
        [System.Management.Automation.SwitchParameter]
        $ToLocalApplicationFolder,

        [Parameter(Mandatory=$false,ParameterSetName='MoveFromLocalToLocalApplicationFolder',HelpMessage='The parent folder where the output will be placed.')]
        [Parameter(Mandatory=$false,ParameterSetName='MoveFromNetworkToLocalApplicationFolder')]
        [System.String]
        $ParentOutputFolder = (Get-Path -OutputFolder),

        [Parameter(Mandatory=$false,HelpMessage='Switch for asking the user for confirmation.')]
        [Alias('AskConfirmation')]
        [System.Management.Automation.SwitchParameter]
        $Confirm
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails             = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ParentOutputFolder          = $ParentOutputFolder
            Confirm                     = $Confirm
            # Handlers
            NetworkScreenshotsFolder    = [System.String]('\\ksmod.nl\ks-home\Home\{0}\Pictures\Screenshots' -f $ENV:USERNAME)
            LocalScreenshotsFolder      = [System.String]'To be determined...'
            # Confirmation Handlers
            ConfirmationTitle           = [System.String]'Move screenshots'
            ConfirmationBody            = [System.String]'Would you like to move your recent screenshots?'
            # Validation
            ValidationArray             = [System.Boolean[]]@()
            # Output
            OutputObject                = [System.String]::Empty
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
            # Validate the input
            $this.ValidateInput()
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Message -FunctionEnd -Details $this.FunctionDetails
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get user confirmation
            if ($this.Confirm.IsPresent) {
                [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title $this.ConfirmationTitle -Body $this.ConfirmationBody
                if (-Not($UserHasConfirmed)) { Return }
            }
            # If the validation failed, then return
            if ($this.ValidationSuccess -contains $false) { Write-Message -ValidationFailed ; Return }
            # Switch on the ParameterSetName
            switch ($this.FunctionDetails[1]) {
                'MoveFromNetworkToLocalApplicationFolder'   { $this.MoveScreenshotsFromNetworkToLocalApplicationFolder() }
            }
        }

        ####################################################################################################
        ### VALIDATION METHODS ###

        # Add the ValidateInput method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ValidateInput -Value {
            # Switch on the ParameterSetName
            switch ($this.FunctionDetails[1]) {
                'MoveFromNetworkToLocalApplicationFolder'   { $this.ValidationSuccess += Confirm-Object -MandatoryPath $this.NetworkScreenshotsFolder }
            }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
        
        # Add the MoveScreenshotsFromNetworkToLocalApplicationFolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name MoveScreenshotsFromNetworkToLocalApplicationFolder -Value {
            try {
                # Set the SourceFolder
                [System.String]$SourceFolder = $this.NetworkScreenshotsFolder
                # Test the amount of files
                [System.IO.FileSystemInfo[]]$ScreenshotObjects = Get-ChildItem -Path $SourceFolder -Recurse -File -ErrorAction SilentlyContinue
                if ($ScreenshotObjects.Count -eq 0) { Write-Warning ('No files were found in the Screenshots folder. No screenshots were moved. ({0})' -f $SourceFolder) ; Return }
                # Get the DestinationFolder
                [System.String]$DestinationFolder = $this.GetLocalScreenshotsFolder()
                # Confirm the DestinationFolder
                if (-Not(Confirm-Object -MandatoryPath $DestinationFolder)) { Return }
                # Move the screenshots
                foreach ($Item in $ScreenshotObjects) {
                    Write-Host ('Moving screenshot: ({0})' -f $Item.FullName) -ForegroundColor DarkGray
                    Move-Item -Path $Item.FullName -Destination $DestinationFolder
                }
                #Open-Folder -Path $DestinationFolder
            }
            catch {
                Write-FullError
            }
        }

        ####################################################################################################
        ### SUPPORTING METHODS ###

        # Add the GetLocalScreenshotsFolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetLocalScreenshotsFolder -Value {
            # Set the LocalScreenshotsFolder
            [System.String]$ApplicationName         = Get-ApplicationName
            [System.String]$LocalApplicationFolder  = Join-Path -Path $this.ParentOutputFolder -ChildPath $ApplicationName
            [System.String]$ScreenshotsSubFolder    = (Get-ApplicationSubfolders).ScreenshotsFolder
            [System.String]$LocalScreenshotsFolder  = Join-Path -Path $LocalApplicationFolder -ChildPath $ScreenshotsSubFolder
            # Return the result
            $LocalScreenshotsFolder
        }


        
        ####################################################################################################

        $Local:MainObject.Begin()
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
        $Local:MainObject.End()
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
