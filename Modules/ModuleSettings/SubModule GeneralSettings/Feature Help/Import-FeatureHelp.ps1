####################################################################################################
<#
.SYNOPSIS
    This function imports the feature Help.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions and variables, that may be in other files.
    External classes    : -
    External functions  : Invoke-Groupbox, Invoke-ButtonLine
    External variables  : $Global:FolderSettingsGroupBox
.EXAMPLE
    Import-FeatureHelp -ParentTabPage $MyParentTabPage
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.2.2
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : May 2025
#>
####################################################################################################

function Import-FeatureHelp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'Help'
            Color           = [System.String]'Brown'
            NumberOfRows    = [System.Int32]1
            GroupBoxAbove   = [System.Windows.Forms.GroupBox]$Global:PersonalSettingsGroupBox
        }
        
        # Set the Button Properties Array
        [System.Object[][]]$ButtonPropertiesArray = @( (1,'Copy') , (2,'Paste') , (5,'Clear') )

        ####################################################################################################
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ParentTabPage           = $ParentTabPage
            # Handlers
            GroupBoxTitle           = [System.String]'Help'
            Color                   = [System.String]'Brown'
            NumberOfRows            = [System.Int32]1
            GroupBoxAbove           = [System.Windows.Forms.GroupBox]$Global:PersonalSettingsGroupBox
            AssetFolder             = [System.String](Join-Path -Path $PSScriptRoot -ChildPath 'Assets')
            #PDFManualFileName       = [System.String]'HelpFile Settings.pdf'
            VersionHistoryFileName  = [System.String]'Version History.txt'
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the GroupBox
            [System.Windows.Forms.GroupBox]$ParentGroupBox = Invoke-Groupbox -ParentTabPage $this.ParentTabPage -Title $this.GroupBoxTitle -NumberOfRows $this.NumberOfRows -Color $this.Color -GroupBoxAbove $this.GroupBoxAbove -OnSubTab
            # Create the Buttons
            Invoke-ButtonLine -ButtonPropertiesArray $this.GetHelpButtons() -ParentGroupBox $ParentGroupBox -RowNumber 1 -AssetFolder $this.AssetFolder
        }

        ####################################################################################################
        ### BUTTON METHODS ###

        # Set the GetHelpButtons
        [System.Collections.Hashtable[]]$ButtonPropertiesArray = 
            @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Desktop Shortcut'
                    SizeType        = 'Medium'
                    Image           = 'Desktop.png'
                    Function        = { Invoke-NewShortcut -Desktop }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'StartMenu Shortcut'
                    SizeType        = 'Medium'
                    Image           = 'Menu.png'
                    Function        = { Invoke-NewShortcut -StartMenu }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Open Logfolder'
                    SizeType        = 'Medium'
                    Image           = 'folder_page.png'
                    Function        = { Open-Folder -Path (Get-SharedAssetPath -LogFolder) }
                }
                @{
                    ColumnNumber    = 4
                    Text            = 'Reset All'
                    SizeType        = 'Medium'
                    Image           = 'arrow_rotate_clockwise.png'
                    Function        = { Invoke-RegistrySettings -ResetAll }
                }
                @{
                    ColumnNumber    = 5
                    Text            = 'Version History'
                    SizeType        = 'Medium'
                    Function        = { Start-Process -FilePath ((Get-Command -Name notepad).Source) -ArgumentList (Join-Path -Path $Global:ApplicationObject.RootFolder -ChildPath 'README.md') }
                }
            )

        # Add the GetHelpButtons method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetHelpButtons -Value {
            # Return the button properties
            @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Desktop Shortcut'
                    SizeType        = 'Medium'
                    Image           = 'Desktop.png'
                    Function        = { Invoke-NewShortcut -Desktop }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'StartMenu Shortcut'
                    SizeType        = 'Medium'
                    Image           = 'Menu.png'
                    Function        = { Invoke-NewShortcut -StartMenu }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Open Logfolder'
                    SizeType        = 'Medium'
                    Image           = 'folder_page.png'
                    Function        = { Open-Folder -Path (Get-SharedAssetPath -LogFolder) }
                }
                @{
                    ColumnNumber    = 4
                    Text            = 'Reset All'
                    SizeType        = 'Medium'
                    Image           = 'arrow_rotate_clockwise.png'
                    Function        = { Invoke-RegistrySettings -ResetAll }
                }
                @{
                    ColumnNumber    = 5
                    Text            = 'Version History'
                    SizeType        = 'Medium'
                    Function        = { Start-Process -FilePath ((Get-Command -Name notepad).Source) -ArgumentList (Join-Path -Path $Global:ApplicationObject.RootFolder -ChildPath 'README.md') }
                }
            )
        }
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove -OnSubTab
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ButtonPropertiesArray -ParentGroupBox $ParentGroupBox -RowNumber 1


        #$Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
