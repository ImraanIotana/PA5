####################################################################################################
<#
.SYNOPSIS
    This function adds the dimensions for the graphic objects to the Settings, which are inside the Global Application Object.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions and variables, that may be in other files.
    External classes    : -
    External functions  : -
    External variables  : Write-Message
.EXAMPLE
    Add-GraphicalDimensionsToSettings -ApplicationObject $Global:ApplicationObject
.INPUTS
    [PSCustomObject]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : February 2025
    Last Update     : February 2025
#>
####################################################################################################

function Add-GraphicalDimensionsToSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Global ApplicationObject containing the Settings.')]
        [PSCustomObject]
        $ApplicationObject
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            Settings        = $ApplicationObject.Settings
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get the Global Settings
            [System.Collections.Hashtable]$Settings = $this.Settings

            # Add the dimensions to the Global Settings
            # TabControl
            $this.AddMainTabControlDimensionsToGlobalSettings($Settings)
            # GroupBox
            $this.AddGroupBoxWidthToGlobalSettings($Settings)
            $this.AddGroupBoxHeightToGlobalSettings($Settings)
            # TextBox
            $this.AddTextBoxWidthsToGlobalSettings($Settings)
            # Button
            $this.AddButtonWidthsToGlobalSettings($Settings)
            $this.AddButtonHeightsToGlobalSettings($Settings)
            # Column
            $this.AddColumnNumbersToGlobalSettings($Settings)
        }

        ####################################################################################################
        ### TABCONTROL
    
        # Add the AddMainTabControlDimensionsToGlobalSettings method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddMainTabControlDimensionsToGlobalSettings -Value { param([System.Collections.Hashtable]$Settings)
            # Write the message
            #Write-Verbose 'Adding the Main TabControl location and size to the Global Settings...'
            # Add the Main TabControl TopLeft Location to the global settings
            [System.Int32]$MainTabControlTopLeftX = $Settings.MainTabControl.LeftMargin
            [System.Int32]$MainTabControlTopLeftY = $Settings.MainTabControl.TopMargin
            $Settings.MainTabControl.Add('TopLeftX', $MainTabControlTopLeftX)
            $Settings.MainTabControl.Add('TopLeftY', $MainTabControlTopLeftY)
            # Add the Main TabControl Size to the global settings
            [System.Int32]$MainTabControlWidth = ($Settings.MainForm.Width - $Settings.MainTabControl.RightMargin)
            [System.Int32]$MainTabControlHeight = ($Settings.MainForm.Height - $Settings.MainTabControl.BottomMargin)
            $Settings.MainTabControl.Add('Width', $MainTabControlWidth)
            $Settings.MainTabControl.Add('Height', $MainTabControlHeight)
        }

        ####################################################################################################
        ### GROUPBOX
    
        # Add the AddGroupBoxWidthToGlobalSettings method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddGroupBoxWidthToGlobalSettings -Value { param([System.Collections.Hashtable]$Settings)
            # Write the message
            #Write-Verbose 'Adding the Groupbox widths to the Global Settings...'
            # Set the Widths of the groupbox
            [System.Int32]$GroupboxWidth        = $Settings.MainTabControl.Width - $Settings.GroupBox.RightMargin
            [System.Int32]$SubTabGroupboxWidth  = $Settings.MainTabControl.Width - $Settings.GroupBox.RightMargin - $Settings.GroupBox.SubTabMargin
            # Add the results to the global settings
            $Settings.GroupBox.Add('Width',$GroupboxWidth)
            $Settings.GroupBox.Add('SubTabGroupboxWidth',$SubTabGroupboxWidth)
        }
    
        # Add the AddGroupBoxHeightToGlobalSettings method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddGroupBoxHeightToGlobalSettings -Value { param([System.Collections.Hashtable]$Settings)
            # Write the message
            #Write-Verbose 'Adding the GroupboxHeightTable to the Global Settings...'
            # Create the GroupboxHeightTable
            [System.Collections.Hashtable]$GroupboxHeightTable =@{}
            # Add the Heights of the GroupBox to the GroupboxHeightTable
            [System.Int32[]]$NumberOfRowsArray = @(1..20)
            foreach ($NumberOfRows in $NumberOfRowsArray) {
                [System.Int32]$GroupboxHeight = if ($NumberOfRows -eq 1) { ($NumberOfRows * $Settings.GroupBox.RowHeight) + $Settings.GroupBox.OneRowMargin } else { $NumberOfRows * $Settings.GroupBox.RowHeight }
                Write-Verbose ('Adding the GroupboxHeight ({0}) for the number of rows ({1}) to the Global Settings...' -f $GroupboxHeight,$NumberOfRows)
                $GroupboxHeightTable.Add($NumberOfRows,$GroupboxHeight)
            }
            # Add the GroupboxHeightTable to the global settings
            $Settings.GroupBox.Add('HeightTable',$GroupboxHeightTable)
        }

        ####################################################################################################
        ### TEXTBOX

        # Add the AddTextBoxWidthsToGlobalSettings method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddTextBoxWidthsToGlobalSettings -Value { param([System.Collections.Hashtable]$Settings)
            # Write the message
            #Write-Verbose 'Adding the TextBox widths to the Global Settings...'
            # Set the width of the Large textbox
            [System.Int32]$TextBoxLargeWidth = $Settings.GroupBox.Width - $Settings.TextBox.LeftMargin - $Settings.TextBox.RightMargin
            # Set the width of the Medium textbox
            [System.Int32]$TextBoxMediumWidth = ($TextBoxLargeWidth * 0.8) - 3
            # Set the width of the Small textbox
            [System.Int32]$TextBoxSmallWidth = ($TextBoxLargeWidth * 0.6) - 3
            # Add the result to the global settings
            $Settings.TextBox.Add('LargeWidth',$TextBoxLargeWidth)
            $Settings.TextBox.Add('MediumWidth',$TextBoxMediumWidth)
            $Settings.TextBox.Add('SmallWidth',$TextBoxSmallWidth)
        }

        ####################################################################################################
        ### BUTTONS
    
        # Add the AddButtonWidthsToGlobalSettings method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddButtonWidthsToGlobalSettings -Value { param([System.Collections.Hashtable]$Settings)
            # Write the message
            #Write-Verbose 'Adding the Button width to the Global Settings...'
            # Set the width of the button
            [System.Int32]$ButtonLargeWidth     = $Settings.TextBox.LargeWidth / 5
            [System.Int32]$ButtonMediumWidth    = $ButtonLargeWidth
            [System.Int32]$ButtonSmallWidth     = $ButtonMediumWidth / 3
            # Add the result to the global settings
            $Settings.Button.Add('LargeWidth', $ButtonLargeWidth)
            $Settings.Button.Add('MediumWidth', $ButtonMediumWidth)
            $Settings.Button.Add('SmallWidth', $ButtonSmallWidth)
        }
    
        # Add the AddButtonHeightsToGlobalSettings method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddButtonHeightsToGlobalSettings -Value { param([System.Collections.Hashtable]$Settings)
            # Write the message
            #Write-Verbose 'Adding the Button height to the Global Settings...'
            [System.Int32]$TextBoxHeight    = $Settings.TextBox.Height
            # Set the height of the button
            [System.Int32]$ButtonLargeHeight    = $TextBoxHeight * 2
            [System.Int32]$ButtonMediumHeight   = $TextBoxHeight - 3
            [System.Int32]$ButtonSmallHeight    = $ButtonMediumHeight
            # Add the result to the global settings
            $Settings.Button.Add('LargeHeight', $ButtonLargeHeight)
            $Settings.Button.Add('MediumHeight', $ButtonMediumHeight)
            $Settings.Button.Add('SmallHeight', $ButtonSmallHeight)
        }

        ####################################################################################################
        ### COLUMNS
    
        # Add the AddColumnNumbersToGlobalSettings method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddColumnNumbersToGlobalSettings -Value { param([System.Collections.Hashtable]$Settings)
            # Write the message
            #Write-Verbose 'Adding the ColumnNumbers to the Global Settings...'
            # Get the values
            [System.Int32]$MainTabControlLocationX  = $Settings.MainTabControl.Location.X
            [System.Int32]$LabelLeftMargin          = $Settings.Label.LeftMargin
            [System.Int32]$TextBoxLeftMargin        = $Settings.TextBox.LeftMargin
            [System.Int32]$ButtonMediumWidth        = $Settings.Button.MediumWidth
            # Set the ColumnNumbers and their X location
            [System.Collections.ArrayList]$ColumnNumbersLocationXArray = New-Object System.Collections.ArrayList
            # Column 0 is the location underneath the Label
            [void]$ColumnNumbersLocationXArray.Add($LabelLeftMargin) # Column and Index 0
            # Column 1 is the first location underneath the TextBox
            [void]$ColumnNumbersLocationXArray.Add(($MainTabControlLocationX + $LabelLeftMargin + $TextBoxLeftMargin)) # Column and Index 1
            # Columns 2-5 are the following locations underneath the TextBox
            @(1..4) | ForEach-Object { [void]$ColumnNumbersLocationXArray.Add($ColumnNumbersLocationXArray[$_] + $ButtonMediumWidth) } # Column and Index 2-5
            # Column 6 is only used for the small buttons
            [void]$ColumnNumbersLocationXArray.Add($ColumnNumbersLocationXArray[5] + ($ButtonMediumWidth * 1/3 )) # Column and Index 6
            [void]$ColumnNumbersLocationXArray.Add($ColumnNumbersLocationXArray[6] + ($ButtonMediumWidth * 1/3 )) # Column and Index 7
            [void]$ColumnNumbersLocationXArray.Add($ColumnNumbersLocationXArray[7] + ($ButtonMediumWidth * 1/3 )) # Column and Index 8
            # Add the results to the Global Settings
            @(0..6) | ForEach-Object { $Settings.ColumnNumber.Add( $_ , $ColumnNumbersLocationXArray[$_]) }
        }

        ####################################################################################################

        # Write the Begin message
        #Write-Message -FunctionBegin -Details $Local:MainObject.FunctionDetails
    }
    
    process {
        #region PROCESS
        $Local:MainObject.Process()
        #endregion PROCESS
    }

    end {
        # Write the End message
        #Write-Message -FunctionEnd -Details $Local:MainObject.FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
