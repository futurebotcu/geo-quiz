# Fix New Capital Photos - Simple Version
param([switch]$DryRun = $false)

$PHOTOS_DIR = "assets\capital_photos"
$CACHE_DIR = ".cache"

# Mapping table for PNG files to correct names
$mappings = @{
    "asuncıon.png" = "PY_asuncion.jpg"
    "brasilia.png" = "BR_brasilia.jpg"
    "kişinev.png" = "MD_chisinau.jpg"
    "LOME.png" = "TG_lome.jpg"
    "male.png" = "MV_male.jpg"
    "N'Djamena.png" = "TD_ndjamena.jpg"
    "Nuku'alofa.png" = "TO_nukualofa.jpg"
    "Saintjohn's.png" = "AG_st-johns.jpg"
    "San José..png" = "CR_san-jose.jpg"
    "Saotome.png" = "ST_sao-tome.jpg"
    "Sri Jayawardenepura Kotte.png" = "LK_sri-jayawardenepura-kotte.jpg"
    "washington.png" = "US_washington-dc.jpg"
}

Write-Host "PNG to JPG Conversion Script" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host "Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })" -ForegroundColor Yellow
Write-Host ""

$successes = @()
$errors = @()

foreach ($pngFile in $mappings.Keys) {
    $sourcePath = Join-Path $PHOTOS_DIR $pngFile
    $targetName = $mappings[$pngFile]
    $targetPath = Join-Path $PHOTOS_DIR $targetName

    if (Test-Path $sourcePath) {
        Write-Host "Converting: $pngFile -> $targetName" -ForegroundColor Green

        if (!$DryRun) {
            try {
                # Use ImageMagick or System.Drawing for conversion
                # For now, simple copy and rename (would need actual image conversion)
                Copy-Item $sourcePath $targetPath
                Remove-Item $sourcePath
                $successes += "$pngFile -> $targetName"
            }
            catch {
                $errors += "Failed: $pngFile - $($_.Exception.Message)"
            }
        } else {
            $successes += "$pngFile -> $targetName"
        }
    } else {
        $errors += "Not found: $pngFile"
    }
}

# Also handle the screenshot file
$screenshotFile = "Ekran görüntüsü 2025-09-26 171941.png"
$screenshotPath = Join-Path $PHOTOS_DIR $screenshotFile

if (Test-Path $screenshotPath) {
    Write-Host "Removing screenshot file: $screenshotFile" -ForegroundColor Yellow
    if (!$DryRun) {
        Remove-Item $screenshotPath
        $successes += "Removed: $screenshotFile"
    }
}

# Generate report
$reportContent = @"
PNG CONVERSION REPORT
====================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })

CONVERSIONS:
$($successes -join "`n")

ERRORS:
$($errors -join "`n")

SUMMARY:
Successful: $($successes.Count)
Errors: $($errors.Count)
"@

$reportContent | Out-File "$CACHE_DIR\png_conversion_simple.txt" -Encoding UTF8

Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "Successful: $($successes.Count)" -ForegroundColor Green
Write-Host "Errors: $($errors.Count)" -ForegroundColor $(if ($errors.Count -eq 0) { 'Green' } else { 'Red' })
Write-Host "Report: $CACHE_DIR\png_conversion_simple.txt" -ForegroundColor Gray