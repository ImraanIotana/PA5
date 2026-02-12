####################################################################################################
<#
.SYNOPSIS
    This function writes a line to the host in the default color.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    Write-Line "Hello World!"
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Write-LineOLD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,HelpMessage='The message that will be written to the host.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Message
    )

    begin {
    }
    
    process {
        # Write the message in the default color
        Write-Host $Message -ForegroundColor DarkGray
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    This function writes the Module Import message.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    Write-ModuleImport -Title 'Application Tab' -Version '5.5.1'
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Write-ModuleImport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='WithStrings',HelpMessage='The title of the module.')]
        [Alias('TabTitle','ModuleTitle')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Title,

        [Parameter(Mandatory=$true,ParameterSetName='WithStrings',HelpMessage='The version of the module.')]
        [Alias('TabVersion','ModuleVersion')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Version,

        [Parameter(Mandatory=$true,ParameterSetName='WithPSCustomObject',HelpMessage='The PSCustomObject containing the module information.')]
        [Alias('Object')]
        [AllowNull()]
        [PSCustomObject]
        $InputObject
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
    }
    
    process {
        try {
            # Set the properties based on the ParameterSetName
            $Title,$Version = switch ($FunctionDetails[1]) {
                'WithStrings'           { $Title,$Version }
                'WithPSCustomObject'    { $InputObject.TabTitle,$InputObject.ModuleVersion }
            }
            # Write the import message
            Write-Line "Importing Module $Title $Version"
        }
        catch { Write-FullError }
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    This function writes a default line.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Write-NoAction
.INPUTS
    -
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Write-NoAction {
    [CmdletBinding()]
    param (
    )

    begin {
    }
    
    process {
        Write-Line 'No action has been taken'
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    This function write a line to the host in the Green color.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    Write-Green "Hello World!"
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Write-Green {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,HelpMessage='The message that will be written to the host.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Message,

        [Parameter(Mandatory=$false,HelpMessage='Switch for writing the NoAction message.')]
        [System.Management.Automation.SwitchParameter]
        $NoAction
    )

    begin {
    }
    
    process {
        # Write the message
        Write-Host $Message -ForegroundColor Green
        # Write the NoAction message
        if ($NoAction) { Write-NoAction }
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    This function write a line to the host in the Blue color.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    Write-Blue "Hello World!"
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Write-Blue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,HelpMessage='The message that will be written to the host.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Message,

        [Parameter(Mandatory=$false,HelpMessage='Switch for writing the NoAction message.')]
        [System.Management.Automation.SwitchParameter]
        $NoAction
    )

    begin {
    }
    
    process {
        # Write the message
        Write-Host $Message -ForegroundColor Cyan
        # Write the NoAction message
        if ($NoAction) { Write-NoAction }
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    This function write a line to the host in the Yellow color.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    Write-Yellow "Hello World!"
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Write-Yellow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,HelpMessage='The message that will be written to the host.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Message,

        [Parameter(Mandatory=$false,HelpMessage='Switch for writing the NoAction message.')]
        [System.Management.Automation.SwitchParameter]
        $NoAction
    )

    begin {
    }
    
    process {
        # Write the message
        Write-Host $Message -ForegroundColor Yellow
        # Write the NoAction message
        if ($NoAction) { Write-NoAction }
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    This function write a line to the host in the Red color.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    Write-Red "Hello World!"
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Write-Red {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,HelpMessage='The message that will be written to the host.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Message,

        [Parameter(Mandatory=$false,HelpMessage='Switch for writing the NoAction message.')]
        [System.Management.Automation.SwitchParameter]
        $NoAction
    )

    begin {
    }
    
    process {
        # Write the message
        Write-Host $Message -ForegroundColor Red
        # Write the NoAction message
        if ($NoAction) { Write-NoAction }
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    This function write a line to the host, in the colors assigned to this action.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    Write-Special "Hello World!"
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
#>
####################################################################################################

function Write-Special {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,HelpMessage='The message that will be written to the host.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Message
    )

    begin {
    }
    
    process {
        # Write the message
        Write-Host $Message -ForegroundColor Magenta -BackgroundColor Cyan
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################
