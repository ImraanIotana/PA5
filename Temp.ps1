function Test-PA5Update {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$OutHost
    )

    begin {
        # Local version from your Global Application Object
        $LocalVersion = $Global:ApplicationObject.Version

        # Remote file URL
        $RemoteUrl = 'https://raw.githubusercontent.com/ImraanIotana/PA5/main/PackagingAssistant.ps1'

        # Operation descriptions
        $Operation = 'Check for PA5 updates'
        $Target    = "Remote PA5 version at $RemoteUrl"
    }

    process {
        if ($PSCmdlet.ShouldProcess($Target, $Operation)) {
            try {
                # Download remote PackagingAssistant.ps1
                $RemoteContent = Invoke-WebRequest -Uri $RemoteUrl -UseBasicParsing |
                                 Select-Object -ExpandProperty Content

                # Extract version line
                $RemoteVersion = ($RemoteContent -split "`n" |
                                  Where-Object { $_ -match "Version\s*=\s*'[\d\.]+'" }) `
                                  -replace "[^\d\.]", ""

                # Compare versions
                $IsUpToDate = ($LocalVersion -eq $RemoteVersion)

                if ($OutHost) {
                    if ($IsUpToDate) {
                        Write-Line "PA5 is up to date. Version $LocalVersion"
                    }
                    else {
                        Write-Line "Update available. Local: $LocalVersion, Remote: $RemoteVersion"
                    }
                }

                # Return boolean
                return $IsUpToDate
            }
            catch {
                Write-FullError
                return $false
            }
        }
    }
}
