####################################################################################################
<#
.SYNOPSIS
    This function creates a new SCCM User Collection, adds a Query Rule, and moves it to a subfolder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
    External classes    : -
    External functions  : Test-SCCMUserCollection, Write-FullError
    External variables  : -
.EXAMPLE
    New-SCCMUserCollection -Name 'Vendor_Notepad_1.0' -Tennant 'TENANT01'
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 4.8
    Author          : Imraan Iotana
    Creation Date   : September 2024
    Last Updated    : September 2024
#>
####################################################################################################

function New-SCCMUserCollection {
    [CmdletBinding()]
    param (
        # The name of the User Collection
        [Parameter(Mandatory=$true)]
        [Alias('UserCollection','UserCollectionName')]
        [System.String]
        $Name,

        # The Tennant of the User Collection
        [Parameter(Mandatory=$true)]
        [Alias('TennantName')]
        [System.String]
        $Tennant
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionName            = [System.String]$MyInvocation.MyCommand
            FunctionArguments       = [System.String]$PSBoundParameters.GetEnumerator()
            ParameterSetName        = [System.String]$PSCmdlet.ParameterSetName
            FunctionCircumFix       = [System.String]'Function: [{0}] ParameterSetName: [{1}] Arguments: {2}'
            # Handlers
            LimitingCollectionName  = [System.String]'All Users and User Groups'
            QueryExpressionPreFix   = [System.String]'select SMS_R_USERGROUP.ResourceID,SMS_R_USERGROUP.ResourceType,SMS_R_USERGROUP.Name,SMS_R_USERGROUP.UniqueUsergroupName,SMS_R_USERGROUP.WindowsNTDomain from SMS_R_UserGroup where SMS_R_UserGroup.Name like "%DL-AP-{0}"'
            # Input
            UserCollectionName      = $Name
            TennantName             = $Tennant
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Add the function details
            Add-Member -InputObject $this -NotePropertyName FunctionDetails -NotePropertyValue ($this.FunctionCircumFix -f $this.FunctionName, $this.ParameterSetName, $this.FunctionArguments)
            # Write the Begin message
            Write-Verbose ('+++ BEGIN {0}' -f $this.FunctionDetails)
            # Switch to the SCCM Drive
            Invoke-SCCMConnectionAction -SwitchToDrive
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Switch back
            Invoke-SCCMConnectionAction -SwitchBack
            # Write the End message
            Write-Verbose ('___ END {0}' -f $this.FunctionDetails)
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the UserCollection
            $this.CreateSCCMUserCollection($this.UserCollectionName)
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the CreateSCCMUserCollection method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateSCCMUserCollection -Value { param([System.String]$UserCollectionName)
            # If the UserCollection already exists, write the message and return
            if (Test-SCCMUserCollection -Name $UserCollectionName) {
                Write-Host ('The User Collection already exists. No action has been taken. ({0})' -f $UserCollectionName)
                Return
            }
            try {
                # Create the UserCollection
                Write-Host ('Creating the User Collection. One moment please... ({0})' -f $UserCollectionName) -ForegroundColor DarkGray
                New-CMUserCollection -Name $UserCollectionName -LimitingCollectionName $this.LimitingCollectionName
                # Move the UserCollection
                $this.MoveUserCollectionToSubfolder($UserCollectionName,$this.TennantName)
                # Add the Query Rule
                $this.AddQueryRuleToUserCollection($UserCollectionName)
                # Write the message
                Write-Host ('The User Collection has been created. ({0})' -f $UserCollectionName) -ForegroundColor Green
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                # Write the message
                Write-Host ('The SCCM PowerShell Module is not installed.')
            }
            catch [System.InvalidOperationException] {
                # Write the message
                Write-Host ('You are not connected to the SCCM Drive. Or the location you are trying to reach does not exist.')
            }
            catch {
                # Write the error
                Write-FullError
            }
        }

        # Add the MoveUserCollectionToSubfolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name MoveUserCollectionToSubfolder -Value { param([System.String]$UserCollectionName,[System.String]$TennantToMoveTo)
            try {
                # Move the UserCollection
                Write-Host ('Moving the User Collection to the folder ({0}\DEV)...' -f $TennantToMoveTo) -ForegroundColor DarkGray
                [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject]$SCCMUserCollectionObject = Get-CMUserCollection -Name $UserCollectionName
                Move-CMObject -InputObject $SCCMUserCollectionObject -FolderPath ('C01:\UserCollection\{0}\DEV' -f $TennantToMoveTo)
                # Write the message
                Write-Host ('The  User Collection has been moved to the folder ({0}\DEV).' -f $TennantToMoveTo) -ForegroundColor DarkGray
            }
            catch {
                # Write the error
                Write-FullError
            }
        }

        # Add the AddQueryRuleToUserCollection method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddQueryRuleToUserCollection -Value { param([System.String]$UserCollectionName)
            try {
                # Add the Query Rule
                Write-Host ('Adding the Query Rule to the User Collection... ({0})' -f $UserCollectionName) -ForegroundColor DarkGray
                [System.String]$QueryRuleName   = ('DL-AP-{0}' -f $UserCollectionName)
                [System.String]$QueryExpression = ($this.QueryExpressionPreFix -f $UserCollectionName)
                Add-CMUserCollectionQueryMembershipRule -CollectionName $UserCollectionName -QueryExpression $QueryExpression -RuleName $QueryRuleName
                # Write the message
                Write-Host ('The Query Rule has been added to the User Collection. ({0})' -f $UserCollectionName) -ForegroundColor DarkGray
            }
            catch {
                # Write the error
                Write-FullError
            }
        }

        ####################################################################################################

        #region BEGIN
        $Local:MainObject.Begin()
        #endregion BEGIN
    }
    
    process {
        #region PROCESS
        $Local:MainObject.Process()
        #endregion PROCESS
    }

    end {
        #region END
        $Local:MainObject.End()
        #endregion END
    }
}

### END OF SCRIPT
####################################################################################################
