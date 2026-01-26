####################################################################################################
<#
.SYNOPSIS
    This function obtains MSIX information by extracting the Manifest file, and reading the properties.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Export-ManifestFromMSIX, Test-MSIXManifestProperty, Write-FullError
    External variables  : $Global:MSIXUserSettingsTextBox, $Global:MSIXShortcutVisibilityTextBox, $Global:MSXICertificateEnvironmentTextBox, $Global:PackageDependencyTextBox
    External variables  : $Global:ChangeMSIXUserSettingsComboBox, $Global:ChangeMSIXShortcutVisibilityComboBox, $Global:ChangeMSXICertificateEnvironmentComboBox
.EXAMPLE
    Get-MSIXInformation -FilePath C:\Temp\Application.msix
.EXAMPLE
    Get-MSIXInformation -FilePath "C:\Temp\AppXManifest.xml"
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no output.
.NOTES
    Version         : 4.0
    Author          : Imraan Iotana
    Creation Date   : June 2024
    Last Updated    : June 2024
#>
####################################################################################################

function Invoke-ButtonLineORG  {
    [CmdletBinding()]
    param (
        # The array of hastables containing the button properties
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonRow')]
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonColumn')]
        [System.Collections.Hashtable[]]
        $ButtonPropertiesArray,
        
        # The groupbox to which the buttons will be added
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonRow')]
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonColumn')]
        [System.Windows.Forms.GroupBox]
        $ParentGroupBox,
        
        # The row number of the button
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonRow')]
        [System.Int32]
        $RowNumber,
        
        # The column number of the button
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonColumn')]
        [System.Int32]
        $ColumnNumber,
        
        # The folder containing the button images
        [Parameter(Mandatory=$false,ParameterSetName='CreateButtonRow')]
        [Parameter(Mandatory=$false,ParameterSetName='CreateButtonColumn')]
        [System.String]
        $AssetFolder
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
