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

function Invoke-ButtonLineNEW  {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The array of hashtables containing the button properties.')]
        [System.Collections.Hashtable[]]$ButtonPropertiesArray,
        
        [Parameter(Mandatory=$true,HelpMessage='The groupbox to which the buttons will be added.')]
        [System.Windows.Forms.GroupBox]$ParentGroupBox,
        
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonRow',HelpMessage='The RowNumber of the buttons')]
        [System.Int32]$RowNumber,
        
        [Parameter(Mandatory=$true,ParameterSetName='CreateButtonColumn',HelpMessage='The ColumnNumber of the buttons')]
        [System.Int32]$ColumnNumber,
        
        [Parameter(Mandatory=$false,HelpMessage='The folder containing the button images')]
        [System.String]$AssetFolder = $Global:ApplicationObject.WorkFolders.SharedAssets
    )
    
    begin {
    }
    
    process {
        # Create the Buttons
        foreach ($ButtonObject in $ButtonPropertiesArray) {
            # Set the image filename
            [System.String]$ImageFileName = if ($ButtonObject.Image) { $ButtonObject.Image } else { "$($ButtonObject.Text).png" }
            # Get the image path
            [System.String]$ImagePath = (Get-ChildItem -Path $AssetFolder -File -Filter $ImageFileName -Recurse -ErrorAction SilentlyContinue).FullName
            # Set the general parameters
            [System.Collections.Hashtable]$InvokeButtonParameters = @{
                ParentGroupBox  = $ParentGroupBox
                PNGImagePath    = $ImagePath
                Text            = $ButtonObject.Text
                TextColor       = $ButtonObject.TextColor
                SizeType        = $ButtonObject.SizeType
                Function        = $ButtonObject.Function
                ToolTip         = $ButtonObject.ToolTip
            }
            # Add the RowNumber or ColumnNumber based on the ParameterSetName
            switch ($PSCmdlet.ParameterSetName) {
                'CreateButtonRow'       { $InvokeButtonParameters['RowNumber'] = $RowNumber ; $InvokeButtonParameters['ColumnNumber'] = $ButtonObject.ColumnNumber }
                'CreateButtonColumn'    { $InvokeButtonParameters['ColumnNumber'] = $ColumnNumber ; $InvokeButtonParameters['RowNumber'] = $ButtonObject.RowNumber }
            }
            # Invoke the Button
            Invoke-Button @InvokeButtonParameters
        }
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
