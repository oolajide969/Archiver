$logFilePaths = Get-Content "FilePaths"
$limit = (Get-Date).AddHours(-24)
$monthlylimit = (Get-Date).AddMonths(-1)
$Day = Get-Date -Format "MM-dd-yyyy"


#path format doesnt end with \

foreach ($path in $logFilePaths) {
  Write-Host $path

  $result = $path.Split("\")
  $foldername = $result[-1]

  $dest = "$($path)\$($foldername)_$($Day.ToString()).zip"
  $fileNames = (gci -Path "$($path)\*"  -File | where { $_.Extension -ne ".zip" -and ($_.LastWriteTime -lt $limit) }).FullName
  Write-Host $dest

  if ($fileNames.length -ne 0) {
    Write-host "Compressing..."
    $fileNames | Compress-Archive -CompressionLevel Fastest -DestinationPath $dest
  }
 
  Get-ChildItem -Path $path -Recurse -File | Where-Object { $_.LastWriteTime -lt $limit -and $_.Extension -ne '.zip' } | Remove-Item -Force     
}
Write-Host "Done for the previous day."

if ((get-date).day -eq 1 ) {
  Write-Host "Happy new month."
  foreach ($path in $logFilePaths) {
    Write-Host $path

    $result = $path.Split("\")
    $foldername = $result[-1]
    $drive = $result[0]
    $destpath = "$($drive)\BackUp\$($foldername)"
    $month = ((Get-Date).AddMonths(-1)).ToString("MMMMyyyy")
    $fileNames = (gci -Path "$($path)\*"  -File | where { $_.Extension -eq ".zip" -and ($_.LastWriteTime -lt $monthlylimit) }).FullName

    if ((Test-Path $destpath) -eq $false) {
      Write-host "Creating BackUp Folder"
      New-Item -Path "$($drive)\BackUp\" -Name $foldername -ItemType "directory" -Force -ErrorAction Stop
    
    }
    
    $dest = "$($destpath)\$($month).zip"
    Write-Host $dest
    if ($fileNames.length -ne 0) {
      Write-host "Compressing..."
      $fileNames | Compress-Archive -CompressionLevel Fastest -DestinationPath $dest
    }

    Get-ChildItem -Path $path -Recurse -File | Where-Object { $_.LastWriteTime -lt $monthlylimit -and $_.Extension -eq '.zip' } | Remove-Item -Force     
  }

}  

