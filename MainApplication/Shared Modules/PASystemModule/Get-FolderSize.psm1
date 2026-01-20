####################################################################################################
<#
.SYNOPSIS
    This function measure the size of a folder, and returns the size in MB.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Get-FolderSize -path 'C:\Demo'
.INPUTS
    [System.String]
.OUTPUTS
    [System.Double]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : August 2025
#>
####################################################################################################

function Get-FolderSize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The path of the folder that will be measured.')]
        [Alias('FolderPath','Folder')]
        [System.String]
        $Path
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Input
        [System.String]$FolderToMeasure = $Path

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # Write the message
        Write-Verbose ('Getting the size of the folder: ({0})' -f $FolderToMeasure)
        # Get the folder size
        [System.Double]$FolderSizeInBytes   = (Get-ChildItem -Path $FolderToMeasure -Recurse | Measure-Object -Property Length -Sum).Sum
        [System.Double]$FolderSizeInkB      = [math]::Round($FolderSizeInBytes/1kB,2)
        [System.Double]$FolderSizeInMB      = [math]::Round($FolderSizeInBytes/1MB,2)
        [System.Double]$FolderSizeInGB      = [math]::Round($FolderSizeInBytes/1GB,2)
        # Write the results
        Write-Line ('Foldersize ({0} MB) / ({1} GB)' -f $FolderSizeInMB,$FolderSizeInGB)
        #Write-Line ('Foldersize in kB: ({0})' -f $FolderSizeInkB)
        #Write-Line ('Foldersize in MB: ({0})' -f $FolderSizeInMB)
        #Write-Line ('Foldersize in GB: ({0})' -f $FolderSizeInGB)
        # Set the output
        [System.Double]$OutputObject = $FolderSizeInMB
    }
    
    end {
        # Write the end message
        Write-Function -End $FunctionDetails
        # Return the output
        $OutputObject
    }
}

### END OF FUNCTION
####################################################################################################
