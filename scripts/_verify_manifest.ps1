$manifest = Get-Content 'C:\dev\geo_quiz\data\assets_manifest.json' -Raw | ConvertFrom-Json
$mismatches = @()
foreach ($item in $manifest) {
  if ([string]::IsNullOrEmpty($item.path)) { continue }
  $disk = 'C:\dev\geo_quiz\' + $item.path.Replace('/', '\')
  if (-not (Test-Path $disk)) {
    $mismatches += [PSCustomObject]@{ iso2=$item.iso2; manifest_path=$item.path; disk_exists='MISSING' }
  }
}
if ($mismatches.Count -eq 0) {
  Write-Host 'ALL PATHS OK - no mismatches found'
} else {
  Write-Host "MISMATCHES FOUND: $($mismatches.Count)"
  $mismatches | Format-Table -AutoSize
}
