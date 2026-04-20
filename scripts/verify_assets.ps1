# verify_assets.ps1
# Verifies that asset directories contain only expected image types.
# Exits 1 (failure) if any disallowed files are found.
# Run from repo root: .\scripts\verify_assets.ps1

param(
    [switch]$Verbose
)

$ErrorCount = 0
$AllowedExtensions = @('.jpg', '.jpeg', '.png', '.webp', '.gif')

$AssetDirs = @(
    'assets/capital_photos',
    'assets/flags',
    'assets/foods',
    'assets/placeholders'
)

foreach ($Dir in $AssetDirs) {
    if (-not (Test-Path $Dir)) {
        if ($Verbose) { Write-Host "[SKIP] $Dir (does not exist)" -ForegroundColor Yellow }
        continue
    }

    $Files = Get-ChildItem -Path $Dir -File -Recurse
    foreach ($File in $Files) {
        $Ext = $File.Extension.ToLower()
        if ($Ext -notin $AllowedExtensions) {
            Write-Host "[FAIL] Non-image file in assets: $($File.FullName)" -ForegroundColor Red
            $ErrorCount++
        } elseif ($Verbose) {
            Write-Host "[OK]   $($File.Name)" -ForegroundColor Green
        }
    }
}

if ($ErrorCount -gt 0) {
    Write-Host ""
    Write-Host "$ErrorCount disallowed file(s) found in asset directories. Remove them before building." -ForegroundColor Red
    exit 1
} else {
    Write-Host "[PASS] All asset directories contain only image files." -ForegroundColor Green
    exit 0
}
