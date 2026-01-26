####################################################################################################
<#
.SYNOPSIS
    This function creates a line of Buttons.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Invoke-ButtonLine -ButtonPropertiesArray $MyRowOfActionButtons -ParentGroupBox $Global:ParentGroupBox -RowNumber 1
.EXAMPLE
    Invoke-ButtonLine -ButtonPropertiesArray $MyColumnOfActionButtons -ParentGroupBox $Global:ParentGroupBox -ColumnNumber 1
.INPUTS
    [System.Collections.Hashtable[]]
    [System.Windows.Forms.GroupBox]
    [System.Int32]
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : June 2024
    Last Update     : January 2026
#>
####################################################################################################

function Invoke-ButtonLine  {
    [CmdletBinding()]
    param (
        #[Parameter(Mandatory=$true,ParameterSetName='CreateButtonRow',HelpMessage='An array of hashtables containing the button properties.')]
        [Parameter(Mandatory=$true,HelpMessage='An array of hashtables containing the button properties.')]
        [System.Collections.Hashtable[]]$ButtonPropertiesArray,
        
        # The groupbox to which the buttons will be added
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonRow')]
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonColumn')]
        [System.Windows.Forms.GroupBox]$ParentGroupBox,
        
        # The row number of the button
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonRow')]
        [System.Int32]$RowNumber,
        
        # The column number of the button
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonColumn')]
        [System.Int32]$ColumnNumber,
        
        # The folder containing the button images
        [Parameter(Mandatory=$false,ParameterSetName='CreateButtonRow')]
        [Parameter(Mandatory=$false,ParameterSetName='CreateButtonColumn')]
        [System.String]$AssetFolder
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails         = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ButtonPropertiesArray   = $ButtonPropertiesArray
            ParentGroupBox          = $ParentGroupBox
            RowNumber               = $RowNumber
            ColumnNumber            = $ColumnNumber
            AssetFolder             = $AssetFolder
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Switch on the ParameterSetName
            switch ($this.FunctionDetails[1]) {
                'CreateButtonRow'       { $this.CreateButtonRowMethod($this.ButtonPropertiesArray, $this.ParentGroupBox, $this.RowNumber, $this.AssetFolder) }
                'CreateButtonColumn'    { $this.CreateButtonColumnMethod($this.ButtonPropertiesArray, $this.ParentGroupBox, $this.ColumnNumber, $this.AssetFolder) }
            }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the CreateButtonRowMethod method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateButtonRowMethod -Value {
            # Set the input parameters
            param([System.Collections.Hashtable[]]$ButtonPropertiesArray,[System.Windows.Forms.GroupBox]$ParentGroupBox,[System.Int32]$RowNumber,[System.String]$AssetFolder)
            # Create the Buttons
            $ButtonPropertiesArray | ForEach-Object {
                # Set the image filename
                [System.String]$ImageFileName = if ($_.Image) { $_.Image } else { '{0}.png' -f $_.Text }
                # Get the image path
                [System.String]$ImagePath = (Get-ChildItem -Path $AssetFolder -Filter $ImageFileName -Recurse -ErrorAction SilentlyContinue).FullName
                # If the image if not found in the provided folder, then search the Shared Assets folder.
                if (-Not($ImagePath)) {$ImagePath = (Get-ChildItem -Path $Global:ApplicationObject.WorkFolders.SharedAssets -Filter $ImageFileName -Recurse -ErrorAction SilentlyContinue).FullName}
                # Set the parameters
                [System.Collections.Hashtable]$Params = @{
                    ParentGroupBox  = $ParentGroupBox
                    Text            = $_.Text
                    TextColor       = $_.TextColor
                    RowNumber       = $RowNumber
                    ColumnNumber    = $_.ColumnNumber
                    SizeType        = $_.SizeType
                    PNGImagePath    = $ImagePath
                    Function        = $_.Function
                    ToolTip         = $_.ToolTip
                }
                Invoke-Button @Params
            }
        }
    
        # Add the CreateButtonColumnMethod method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateButtonColumnMethod -Value {
            # Set the input parameters
            param([System.Collections.Hashtable[]]$ButtonPropertiesArray,[System.Windows.Forms.GroupBox]$ParentGroupBox,[System.Int32]$ColumnNumber,[System.String]$AssetFolder)
            # Create the Buttons
            $ButtonPropertiesArray | ForEach-Object {
                # Set the image filename
                [System.String]$ImageFileName = if ($_.Image) { $_.Image } else { '{0}.png' -f $_.Text }
                # Get the image path
                [System.String]$ImagePath = (Get-ChildItem -Path $AssetFolder -Filter $ImageFileName -Recurse -ErrorAction SilentlyContinue).FullName
                # If the image if not found in the provided folder, then search the Shared Assets folder.
                if (-Not($ImagePath)) {$ImagePath = (Get-ChildItem -Path $Global:ApplicationObject.WorkFolders.SharedAssets -Filter $ImageFileName -Recurse -ErrorAction SilentlyContinue).FullName}
                # Set the parameters
                [System.Collections.Hashtable]$Params = @{
                    ParentGroupBox  = $ParentGroupBox
                    Text            = $_.Text
                    TextColor       = $_.TextColor
                    RowNumber       = $_.RowNumber
                    ColumnNumber    = $ColumnNumber
                    SizeType        = $_.SizeType
                    PNGImagePath    = $ImagePath
                    Function        = $_.Function
                    ToolTip         = $_.ToolTip
                }
                Invoke-Button @Params
            }
        }
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
