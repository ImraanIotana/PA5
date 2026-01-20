####################################################################################################
<#
.SYNOPSIS
    This function opens a file/folder browser dialog window to select a file/folder.
.DESCRIPTION
    This function is self-contained and does not refer to functions or variables, that are in other files.
.EXAMPLE
    Select-File -File
.EXAMPLE
    Select-File -InstallerFile -OutputType ItemName
.INPUTS
    [System.Management.Automation.SwitchParameter]
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 2.1
    Author          : Imraan Noormohamed
    Creation Date   : October 2023
    Last Updated    : November 2023
#>
####################################################################################################

function Select-Item {
    [CmdletBinding()]
    param (
        # Switch for selecting a file
        [Parameter(Mandatory=$true,ParameterSetName='SelectAllFiles')]
        [System.Management.Automation.SwitchParameter]
        $File,

        # Switch for selecting a folder
        [Parameter(Mandatory=$true,ParameterSetName='SelectFolder')]
        [System.Management.Automation.SwitchParameter]
        $Folder,

        # Switch for selecting an installer file (msi/mst/msp/exe/ps1)
        [Parameter(Mandatory=$true,ParameterSetName='SelectInstallerFiles')]
        [System.Management.Automation.SwitchParameter]
        $InstallerFile,

        # Switch for selecting a script file (cmd/ps1)
        [Parameter(Mandatory=$true,ParameterSetName='SelectScriptFiles')]
        [System.Management.Automation.SwitchParameter]
        $ScriptFile,

        # Switch for selecting an icon file (ico)
        [Parameter(Mandatory=$true,ParameterSetName='SelectIconFiles')]
        [System.Management.Automation.SwitchParameter]
        $IconFile,

        # Switch for selecting an Intunwin file (.intunewin)
        [Parameter(Mandatory=$true,ParameterSetName='SelectIntunewinFile')]
        [System.Management.Automation.SwitchParameter]
        $IntunewinFile,

        # Switch for selecting an MSI file (only msi)
        [Parameter(Mandatory=$true,ParameterSetName='SelectMSIFile')]
        [System.Management.Automation.SwitchParameter]
        $MSIFile,

        # Switch for selecting an MSIX file (only msix)
        [Parameter(Mandatory=$true,ParameterSetName='SelectMSIXFile')]
        [System.Management.Automation.SwitchParameter]
        $MSIXFile,

        # Switch for selecting an bulk import file (txt/csv)
        [Parameter(Mandatory=$true,ParameterSetName='SelectBulkImportFile')]
        [System.Management.Automation.SwitchParameter]
        $BulkImportFile,

        # The output can be the full path of the selected file, or only the filename
        [Parameter(Mandatory=$false)]
        [ValidateSet('FullPath','ItemName')]
        [System.String]
        $OutputType = 'FullPath',

        # The Initial Directory of the dialog
        [Parameter(Mandatory=$false)]
        [System.String]
        $InitialDirectory
    )
    
    begin {
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionName            = [System.String]$MyInvocation.MyCommand
            FunctionArguments       = [System.String]$PSBoundParameters.GetEnumerator()
            ParameterSetName        = [System.String]$PSCmdlet.ParameterSetName
            FunctionCircumFix       = [System.String]'Function: [{0}] ParameterSetName: [{1}] Arguments: {2}'
            # Handlers
            ValidationIsSuccessful  = [System.Boolean]$true
            AssemblyName            = [System.String]'System.Windows.Forms'
            # Filters
            AllFiles                = [System.String]'All Files|*.*'
            InstallerFiles          = [System.String]'Installer Files|*.msi;*.mst;*.msp;*.exe;*.ps1'
            ScriptFiles             = [System.String]'Script Files|*.cmd;*.ps1'
            IconFiles               = [System.String]'Icon Files|*.ico;*.jpg;*.jpeg;*.png'
            IntunewinFilesFilter    = [System.String]'Intunewin Files|*.intunewin'
            MSIFilesFilter          = [System.String]'MSI Files|*.msi'
            MSIXFilesFilter         = [System.String]'MSIX/XML Files|*.msix;*.xml;*.manifest'
            BulkImportFilesFilter   = [System.String]'Import Files|*.txt;*.csv'
            # Input
            OutputType              = $OutputType
            InitialDirectory        = $InitialDirectory
            # Output
            OutputString            = [System.String]::New
        }

        ####################################################################################################
        # Main

        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Add the function details
            Add-Member -InputObject $this -NotePropertyName FunctionDetails -NotePropertyValue ($this.FunctionCircumFix -f $this.FunctionName, $this.ParameterSetName, $this.FunctionArguments)
            # Write the Begin message
            Write-Verbose ('+++ BEGIN {0}' -f $this.FunctionDetails)
            # Add the forms assembly
            Add-Type -AssemblyName $this.AssemblyName
            # Validate the input
            $this.ValidateInput()
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # If an outputbox was passed thru, set the output in the box
            if ($this.OutputBox) { $this.OutputBox.Text = $this.OutputString }
            # Write the End message
            Write-Verbose ('___ END {0}' -f $this.FunctionDetails)
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # If the validation was not successful then return
            if (-Not($this.ValidationIsSuccessful)) { Return }
            # Switch on the ParameterSetName
            switch ($this.ParameterSetName) {
                {$_ -in 'SelectFolder'} { $this.SelectFolder() }
                Default                 { $this.SelectFile() }
            }
        }

        ####################################################################################################
        # Validation

        # Add the ValidateInput method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ValidateInput -Value {
            # This function has no validation
            $this.ValidationIsSuccessful = $true
        }

        ####################################################################################################
        # Filtering

        # Add the GetExtensionsToFilter method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetExtensionsToFilter -Value {
            # Set the extensions to filter
            [System.String]$ExtensionsToFilter = switch ($this.ParameterSetName) {
                'SelectAllFiles'        { $this.AllFiles }
                'SelectInstallerFiles'  { $this.InstallerFiles }
                'SelectScriptFiles'     { $this.ScriptFiles }
                'SelectIconFiles'       { $this.IconFiles }
                'SelectIntunewinFile'   { $this.IntunewinFilesFilter }
                'SelectMSIFile'         { $this.MSIFilesFilter }
                'SelectMSIXFile'        { $this.MSIXFilesFilter }
                'SelectBulkImportFile'  { $this.BulkImportFilesFilter }
            }
            # Return the result
            $ExtensionsToFilter
        }

        ####################################################################################################
        # File and Folder Selection

        # Add the SelectFile method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SelectFile -Value {
            # Set the extensions to filter
            [System.String]$ExtensionsToFilter = $this.GetExtensionsToFilter()
            # Create a dialog object
            $DialogObject                       = New-Object System.Windows.Forms.OpenFileDialog
            # Set the extensions to filter
            $DialogObject.Filter                = $ExtensionsToFilter
            # Turn multi select off
            $DialogObject.Multiselect           = $false
            # Set the file browser initial directory
            $DialogObject.InitialDirectory      = $this.InitialDirectory
            # Show the file browser dialog
            [void]$DialogObject.ShowDialog()
            # Set the selected file
            [System.String]$SelectedFilePath    = $DialogObject.FileName
            # If the selected file is not empty, then get the filename
            if (-Not([System.String]::IsNullOrWhiteSpace($SelectedFilePath))) { [System.String]$SelectedFileName = Split-Path -Path $SelectedFilePath -Leaf }
            # Set the string to ouput
            $this.OutputString = switch ($this.OutputType) {
                'FullPath' { $SelectedFilePath }
                'ItemName' { $SelectedFileName }
            }
        }

        # Add the SelectFolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SelectFolder -Value {
            # Set the properties
            [System.String]$Description = 'Select folder...'
            [System.String]$RootFolder  = 'MyComputer'
            # Create a folder dialog object
            $DialogObject               = New-Object System.Windows.Forms.FolderBrowserDialog
            # Set the rootfolder
            $DialogObject.RootFolder    = $RootFolder
            # Set the initial path
            $DialogObject.SelectedPath  = $this.InitialDirectory
            # Set the description
            $DialogObject.Description   = $Description
            # Hide the new folder button
            $DialogObject.ShowNewFolderButton = $false
            # Get the selected path
            if($DialogObject.ShowDialog() -eq 'OK') { [System.String]$SelectedFullPath = $DialogObject.SelectedPath }
            # If the string is populated, then get the foldername
            if (-Not([System.String]::IsNullOrEmpty($SelectedFullPath))) { [System.String]$SelectedFolderName = Split-Path -Path $SelectedFullPath -Leaf }
            # Set the string to ouput
            $this.OutputString = switch ($this.OutputType) {
                'FullPath'  { $SelectedFullPath }
                'ItemName'  { $SelectedFolderName }
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
        # Return the output
        $Local:MainObject.OutputString
        #endregion END
    }
}



