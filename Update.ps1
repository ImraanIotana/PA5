$ZipFileOnGithub = 'https://github.com/ImraanIotana/PA5/archive/refs/heads/main.zip'
$DownloadedFile = 'C:\Users\iotan500\Downloads\PA5.zip'


Invoke-WebRequest $ZipFileOnGithub -OutFile $DownloadedFile
Expand-Archive -Path $DownloadedFile -DestinationPath C:\Users\iotan500\Downloads -Force
#Rename-Item .\plinqo-main .\plinqo
#Remove-Item .\plinqo.zip