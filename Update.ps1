$ZipFileOnGithub = 'https://github.com/ImraanIotana/PA5/archive/refs/heads/main.zip'
$DownloadedFile = 'C:\Users\iotan500\Downloads\PA5.zip'

$ShortcutToStart = "C:\Users\iotan500\Downloads\PA5-main\Start Packaging Assistant.lnk"

$PathToRemove = 'C:\Users\iotan500\Downloads\PA5-main'
if (Test-Path $PathToRemove) {
    Remove-Item -Path $PathToRemove -Recurse -Force
}

Invoke-WebRequest $ZipFileOnGithub -OutFile $DownloadedFile
Expand-Archive -Path $DownloadedFile -DestinationPath C:\Users\iotan500\Downloads -Force

Remove-Item -Path $DownloadedFile -Force
Invoke-Item $ShortcutToStart