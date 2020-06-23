$CurrentLocation  = 'C:\current'
$PreviousLocation = 'C:\prev'
$DeltaLocation    = 'C:\delta'

$Current  = Get-ChildItem -LiteralPath $CurrentLocation -Recurse -File
$Previous = Get-ChildItem -LiteralPath $PreviousLocation -Recurse -File

ForEach ($File in $Current)
{
    If ($File.BaseName -in $Previous.BaseName)
    {
        If ($File.LastWriteTime -gt ($Previous | Where-Object { $_.BaseName -eq $File.BaseName }).LastWriteTime)
        {
            Write-Output "File has been updated: $($File.FullName)"
            Copy-Item -LiteralPath $File.FullName -Destination $DeltaLocation
        }
    }
    Else
    {
        Write-Output "New file detected: $($File.FullName)"
        Copy-Item -LiteralPath $File.FullName -Destination $DeltaLocation
    }
}

Copy-Item -Path "$DeltaLocation\*" -Destination $PreviousLocation -Force