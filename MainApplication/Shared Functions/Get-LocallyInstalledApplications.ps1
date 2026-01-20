####################################################################################################
<#
.SYNOPSIS
    This function get the names of all locally installed appliction from the Registry.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Write-Message, Test-Object
    External variables  : -
.EXAMPLE
    Get-LocallyInstalledApplications
.EXAMPLE
    Get-LocallyInstalledApplications -Displaynames
.INPUTS
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.String[]]
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : September 2024
    Last Update     : May 2025
#>
####################################################################################################

function Get-LocallyInstalledApplications {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='ReturnDisplayNames',HelpMessage='Switch for returning only the displaynames.')]
        [System.Management.Automation.SwitchParameter]
        $DisplaynamesOnly,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnApplicationObjectFromDisplayName',HelpMessage='Switch for returning an object containing multiple properties.')]
        [System.Management.Automation.SwitchParameter]
        $ReturnApplicationObject,

        [Parameter(Mandatory=$true,ParameterSetName='ExportPropertiesFromDisplayName',HelpMessage='Switch for exporting a file containing properties.')]
        [System.Management.Automation.SwitchParameter]
        $ExportProperties,

        <#[Parameter(Mandatory=$false,ParameterSetName='ExportPropertiesFromDisplayName',HelpMessage='Switch for using a different output folder.')]
        [System.Management.Automation.SwitchParameter]
        $ExportToApplicationFolder,#> #Not yet in use

        [Parameter(Mandatory=$true,ParameterSetName='ReturnApplicationObjectFromDisplayName',HelpMessage='Switch for returning an object containing multiple properties.')]
        [Parameter(Mandatory=$true,ParameterSetName='ExportPropertiesFromDisplayName',HelpMessage='Switch for exporting a file containing properties.')]
        [System.String]
        $DisplayName,

        [Parameter(Mandatory=$false,HelpMessage='The folder where the output will be placed.')]
        [System.String]
        $OutputFolder = (Get-Path -OutputFolder)
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            ParameterSetName        = $PSCmdlet.ParameterSetName
            # Input
            DisplaynamesOnly        = $DisplaynamesOnly
            #ReturnApplicationObject = $ReturnApplicationObject
            DisplayName             = $DisplayName
            # Handlers
            RegistryKey64bitsApps   = [System.String]'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
            RegistryKey32bitsApps   = [System.String]'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
            ItemPropertyPostFix     = '{0}\*'
            # Output Handlers
            #OutputFolder            = Get-SharedAssetPath -OutputFolder
            OutputFolder            = $OutputFolder
            OutputStringArray       = [System.String[]]@()
            OutputCustomObject      = [PSCustomObject]@{}
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get the properties based on the ParameterSetName
            switch ($this.ParameterSetName) {
                'ReturnApplicationObjectFromDisplayName'    { $this.OutputCustomObject = $this.GetLocalApplicationsObjectFromRegistry($this.DisplayName) }
                'ExportPropertiesFromDisplayName'           { $this.ExportPropertiesFromDisplayNameToOutputFile($this.DisplayName) }
                'ReturnDisplayNames'                        { $this.OutputStringArray = $this.GetAllApplicationNamesFromRegistry() }
            }
            # Add the OutputObject to the main object, based on the ParameterSetName
            $OutputObject = switch ($this.ParameterSetName) {
                'ReturnApplicationObjectFromDisplayName'    { $this.OutputCustomObject }
                'ReturnDisplayNames'                        { $this.OutputStringArray }
            }
            Add-Member -InputObject $this -NotePropertyName OutputObject -NotePropertyValue $OutputObject
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the GetAllApplicationNamesFromRegistry method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetAllApplicationNamesFromRegistry -Value {
            # Get the Names of all locally installed applications
            if ($this.DisplaynamesOnly.IsPresent) {
                # Get the DisplayNames of all locally installed applications
                [System.String[]]$All64bitsApplicationDisplayNames = (Get-ItemProperty -Path ($this.ItemPropertyPostFix -f $this.RegistryKey64bitsApps) | Select-Object DisplayName).DisplayName
                [System.String[]]$All32bitsApplicationDisplayNames = (Get-ItemProperty -Path ($this.ItemPropertyPostFix -f $this.RegistryKey32bitsApps) | Select-Object DisplayName).DisplayName
                [System.String[]]$AllApplicationDisplayNames       = $All64bitsApplicationDisplayNames + $All32bitsApplicationDisplayNames
                # Clean up the results
                $CleanedUpArray = $AllApplicationDisplayNames | Where-Object { Test-Object -IsPopulated $_ } | Get-Unique | Sort-Object
                # Return the result
                $CleanedUpArray
            } else {
                [System.String[]]$All64bitsApplicationNames = (Get-ChildItem -Path $this.RegistryKey64bitsApps).PSChildName
                [System.String[]]$All32bitsApplicationNames = (Get-ChildItem -Path $this.RegistryKey32bitsApps).PSChildName
                [System.String[]]$AllApplicationNames       = $All64bitsApplicationNames + $All32bitsApplicationNames
                # Return the result
                $AllApplicationNames
            }
        }

        # Add the GetLocalApplicationsObjectFromRegistry method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetLocalApplicationsObjectFromRegistry -Value { param([System.String]$DisplayName)
            try {
                # Create the output object as a hashtable (For some reason merging PSCustomObjects does not work. So this workaround is needed)
                [System.Collections.Hashtable]$OutputHashTable = @{}
                # Set the bitverion initially to 64bit
                [System.String]$BitVersion = '64bit'
                # Get all properties from the key where the displaynames match.
                [PSCustomObject]$NewCustomObject = (Get-ItemProperty -Path ($this.ItemPropertyPostFix -f $this.RegistryKey64bitsApps)) | Where-Object { $_.DisplayName -eq $DisplayName }
                # If the application is not found in the 64bit key, then search the 32bit key
                if ($null -eq $NewCustomObject) {
                    [PSCustomObject]$NewCustomObject = (Get-ItemProperty -Path ($this.ItemPropertyPostFix -f $this.RegistryKey32bitsApps)) | Where-Object { $_.DisplayName -eq $DisplayName }
                    # Set the bitverion to 32bit
                    $BitVersion = '32bit'
                }
                # Add the bitverion to the hasthtable
                $OutputHashTable.Add('BitVersion',$BitVersion)
                # Add the full path to the hasthtable
                [System.String]$FullPath = Join-Path -Path $NewCustomObject.PSParentPath -ChildPath $NewCustomObject.PSChildName
                $OutputHashTable.Add('FullPath',$FullPath)
                # Add the properties to the hashtable
                $NewCustomObject.PSObject.Properties | ForEach-Object { $OutputHashTable.Add($_.Name,$_.Value) }
                # Convert the hashtable to a custom object
                [PSCustomObject]$OutputObject = $OutputHashTable
                # Return the result
                $OutputObject
            }
            catch {
                Write-FullError
            }
        }

        # Add the ExportPropertiesFromDisplayNameToOutputFile method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ExportPropertiesFromDisplayNameToOutputFile -Value { param([System.String]$DisplayName)
            try {
                # Get all properties from the key where the displaynames match
                [PSCustomObject]$NewCustomObject = $this.GetLocalApplicationsObjectFromRegistry($DisplayName)
                # Set the properties to leave out
                [System.String[]]$PropertiesToLeaveOut = @('AuthorizedCDFPrefix','FullPath','PSProvider','PSParentPath','PSChildName','PSDrive')
                # Sort and filter the object
                [PSCustomObject]$SortedCustomObject = $NewCustomObject.GetEnumerator() | Where-Object { -Not($_.Name -in $PropertiesToLeaveOut) } | Sort-Object -Property Name
                # Set the output file path
                [System.String]$ApplicationID       = Get-ApplicationName
                [System.String]$ArchiveFolder       = (Get-ApplicationSubfolders).ArchiveFolder
                [System.String]$SubFolder           = Join-Path -Path $ApplicationID -ChildPath $ArchiveFolder
                [System.String]$PrimaryOutputFolder = Join-Path -Path $this.OutputFolder -ChildPath $SubFolder
                [System.String]$ActualOutputFolder  = if (Test-Path -Path $PrimaryOutputFolder) { $PrimaryOutputFolder } else { $this.OutputFolder }
                [System.String]$OutputFilePath      = Join-Path -Path $ActualOutputFolder -ChildPath ('ARP {0}.txt' -f $DisplayName)
                # Write the object to the output file
                $SortedCustomObject | Out-File -FilePath $OutputFilePath -Width 300
                # Open the output folder
                #Open-Folder -Path $ActualOutputFolder
            }
            catch {
                Write-FullError
            }
        }
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
