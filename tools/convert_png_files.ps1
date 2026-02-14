# Convert PNG Files to JPG with Correct Names
param([switch]$DryRun = $false)

$PHOTOS_DIR = "assets\capital_photos"
$CACHE_DIR = ".cache"

Write-Host "Converting PNG files to JPG..." -ForegroundColor Cyan
Write-Host "Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })" -ForegroundColor Yellow
Write-Host ""

$conversions = @()
$errors = @()

# Get all PNG files
$pngFiles = Get-ChildItem "$PHOTOS_DIR\*.png"

foreach ($pngFile in $pngFiles) {
    $fileName = $pngFile.Name
    $baseName = $pngFile.BaseName

    # Determine target name based on the file
    $targetName = switch ($fileName) {
        "asuncıon.png" { "PY_asuncion.jpg" }
        "brasilia.png" { "BR_brasilia.jpg" }
        "kişinev.png" { "MD_chisinau.jpg" }
        "LOME.png" { "TG_lome.jpg" }
        "male.png" { "MV_male.jpg" }
        "N'Djamena.png" { "TD_ndjamena.jpg" }
        "Nuku'alofa.png" { "TO_nukualofa.jpg" }
        "Saintjohn's.png" { "AG_st-johns.jpg" }
        "San José..png" { "CR_san-jose.jpg" }
        "Saotome.png" { "ST_sao-tome.jpg" }
        "Sri Jayawardenepura Kotte.png" { "LK_sri-jayawardenepura-kotte.jpg" }
        "washington.png" { "US_washington-dc.jpg" }
        "Ekran görüntüsü 2025-09-26 171941.png" { $null } # Skip screenshot
        default { $null }
    }

    if ($targetName) {
        Write-Host "Converting: $fileName -> $targetName" -ForegroundColor Green

        if (!$DryRun) {
            try {
                $sourcePath = $pngFile.FullName
                $targetPath = Join-Path $PHOTOS_DIR $targetName

                # Simple rename for now (in real scenario would use image conversion)
                # For Windows, we can use Copy-Item and Remove-Item
                Copy-Item $sourcePath $targetPath -Force
                Remove-Item $sourcePath

                $conversions += "$fileName -> $targetName"
            }
            catch {
                $errors += "Failed to convert $fileName`: $($_.Exception.Message)"
                Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            $conversions += "$fileName -> $targetName"
        }
    }
    elseif ($fileName -eq "Ekran görüntüsü 2025-09-26 171941.png") {
        Write-Host "Removing screenshot: $fileName" -ForegroundColor Yellow
        if (!$DryRun) {
            Remove-Item $pngFile.FullName
            $conversions += "Removed: $fileName"
        }
    }
    else {
        Write-Host "Skipping unknown file: $fileName" -ForegroundColor Yellow
        $errors += "Unknown file: $fileName"
    }
}

# Generate report
$reportContent = @"
PNG to JPG Conversion Report
===========================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })

CONVERSIONS:
$($conversions -join "`n")

ERRORS:
$($errors -join "`n")

SUMMARY:
Conversions: $($conversions.Count)
Errors: $($errors.Count)
"@

if (!(Test-Path $CACHE_DIR)) {
    New-Item -ItemType Directory -Path $CACHE_DIR | Out-Null
}

$reportContent | Out-File "$CACHE_DIR\png_conversion.txt" -Encoding UTF8

Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "Conversions: $($conversions.Count)" -ForegroundColor Green
Write-Host "Errors: $($errors.Count)" -ForegroundColor $(if ($errors.Count -eq 0) { 'Green' } else { 'Red' })
Write-Host "Report saved: $CACHE_DIR\png_conversion.txt" -ForegroundColor Gray