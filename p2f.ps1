if ($args.Count -eq 0) {
    Write-Error "No playlist file specified."
    exit
}
$playlistFile = $args[0]
$targetDir = "$($playlistFile -replace '\.xspf$', '')-files"

$content = Get-Content $playlistFile

$locations = $content | Select-String "<location>" | ForEach-Object {
    $line = $_.Line
    $start = $line.IndexOf('>') + 1
    $end = $line.LastIndexOf('<') - $start
    $filePath = $line.Substring($start, $end)
    $filePath = $filePath -replace 'file:///', ''
    $filePath = $filePath -replace '%20', ' '
    $filePath
}

$locations | Out-File "playlist.tmp"

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir
}

foreach ($file in $locations) {
    if (Test-Path $file) {
        Copy-Item -Path $file -Destination $targetDir
    }
}

Write-Host "Files copied to $targetDir."
