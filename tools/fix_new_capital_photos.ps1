# Fix New Capital Photos Script
# Converts PNG to JPG, fixes naming issues, and maps to correct ISO2 format

param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

# Paths
$PHOTOS_DIR = "assets\capital_photos"
$CAPITALS_JSON = "assets\capitals.json"
$CACHE_DIR = ".cache"

# Load required .NET assemblies for image processing
Add-Type -AssemblyName System.Drawing

Write-Host "Fix New Capital Photos Script" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host "Mode: $(if ($DryRun) { 'DRY RUN (no changes)' } else { 'LIVE (making changes)' })" -ForegroundColor Yellow
Write-Host ""

# Load capitals data
$capitalsData = Get-Content $CAPITALS_JSON -Raw -Encoding UTF8 | ConvertFrom-Json

# Create lookup maps
$capitalNameToISO2 = @{}
$expectedFiles = @{}

foreach ($capital in $capitalsData) {
    $iso2 = $capital.iso2
    $capitalEN = $capital.capitalEN
    $capitalTR = if ($capital.capitalTR) { $capital.capitalTR } else { $capitalEN }

    # Generate expected filename
    $slug = $capitalEN.ToLower()
    $slug = $slug -replace '[àáâãäå]', 'a'
    $slug = $slug -replace '[èéêë]', 'e'
    $slug = $slug -replace '[ìíîï]', 'i'
    $slug = $slug -replace '[òóôõö]', 'o'
    $slug = $slug -replace '[ùúûü]', 'u'
    $slug = $slug -replace '[ç]', 'c'
    $slug = $slug -replace '[ñ]', 'n'
    $slug = $slug -replace '[ș]', 's'
    $slug = $slug -replace '[ț]', 't'
    $slug = $slug -replace '[ý]', 'y'
    $slug = $slug -replace "[''`.]", ''
    $slug = $slug -replace '[^a-z0-9\s\-]', ''
    $slug = $slug -replace '\s+', '-'
    $slug = $slug -replace '-+', '-'
    $slug = $slug.Trim('-')

    $expectedFile = "${iso2}_${slug}.jpg"
    $expectedFiles[$expectedFile] = @{
        iso2 = $iso2
        capitalEN = $capitalEN
        capitalTR = $capitalTR
        slug = $slug
    }

    # Create various lookup keys for matching
    $capitalNameToISO2[$capitalEN.ToLower()] = $iso2
    $capitalNameToISO2[$capitalTR.ToLower()] = $iso2

    # Add variations
    if ($capitalEN -eq "Washington, D.C.") {
        $capitalNameToISO2["washington"] = $iso2
        $capitalNameToISO2["washington dc"] = $iso2
    }
    if ($capitalEN -eq "N'Djamena") {
        $capitalNameToISO2["ndjamena"] = $iso2
        $capitalNameToISO2["n'djamena"] = $iso2
    }
    if ($capitalEN -eq "Chișinău") {
        $capitalNameToISO2["chisinau"] = $iso2
        $capitalNameToISO2["kişinev"] = $iso2
        $capitalNameToISO2["kishinev"] = $iso2
    }
    if ($capitalEN -eq "São Tomé") {
        $capitalNameToISO2["sao tome"] = $iso2
        $capitalNameToISO2["saotome"] = $iso2
    }
    if ($capitalEN -eq "Asunción") {
        $capitalNameToISO2["asuncion"] = $iso2
        $capitalNameToISO2["asuncıon"] = $iso2
    }
    if ($capitalEN -eq "San José") {
        $capitalNameToISO2["san jose"] = $iso2
        $capitalNameToISO2["san josé"] = $iso2
    }
    if ($capitalEN -eq "Malé") {
        $capitalNameToISO2["male"] = $iso2
    }
    if ($capitalEN -eq "Brasília") {
        $capitalNameToISO2["brasilia"] = $iso2
    }
    if ($capitalEN -eq "Lomé") {
        $capitalNameToISO2["lome"] = $iso2
    }
    if ($capitalEN -eq "St. John's") {
        $capitalNameToISO2["saint johns"] = $iso2
        $capitalNameToISO2["saintjohns"] = $iso2
        $capitalNameToISO2["st johns"] = $iso2
    }
    if ($capitalEN -eq "Nuku'alofa") {
        $capitalNameToISO2["nukualofa"] = $iso2
        $capitalNameToISO2["nuku'alofa"] = $iso2
    }
    if ($capitalEN -eq "Sri Jayawardenepura Kotte") {
        $capitalNameToISO2["sri jayawardenepura kotte"] = $iso2
        $capitalNameToISO2["colombo"] = $iso2  # Alternative name
    }
}

Write-Host "Loaded $($capitalsData.Count) capital definitions" -ForegroundColor Green

# Get PNG files to process
$pngFiles = Get-ChildItem "$PHOTOS_DIR\*.png"
Write-Host "Found $($pngFiles.Count) PNG files to process" -ForegroundColor Yellow
Write-Host ""

$fixes = @()
$errors = @()

foreach ($pngFile in $pngFiles) {
    $originalName = $pngFile.BaseName
    $cleanName = $originalName.ToLower()

    # Clean up the name for matching
    $cleanName = $cleanName -replace '[^a-z0-9\s]', ' '
    $cleanName = $cleanName -replace '\s+', ' '
    $cleanName = $cleanName.Trim()

    Write-Host "Processing: $($pngFile.Name)" -ForegroundColor Cyan
    Write-Host "  Clean name: '$cleanName'" -ForegroundColor Gray

    # Find matching ISO2
    $matchedISO2 = $null

    # Direct lookup
    if ($capitalNameToISO2.ContainsKey($cleanName)) {
        $matchedISO2 = $capitalNameToISO2[$cleanName]
        Write-Host "  ✓ Direct match: $matchedISO2" -ForegroundColor Green
    }
    else {
        # Fuzzy matching
        foreach ($key in $capitalNameToISO2.Keys) {
            if ($cleanName -like "*$key*" -or $key -like "*$cleanName*") {
                $matchedISO2 = $capitalNameToISO2[$key]
                Write-Host "  ✓ Fuzzy match: $matchedISO2 (via '$key')" -ForegroundColor Green
                break
            }
        }
    }

    if ($matchedISO2) {
        # Generate target filename
        $capitalInfo = $expectedFiles.Values | Where-Object { $_.iso2 -eq $matchedISO2 } | Select-Object -First 1
        $targetFile = "${matchedISO2}_$($capitalInfo.slug).jpg"
        $targetPath = Join-Path $PHOTOS_DIR $targetFile

        Write-Host "  → Target: $targetFile" -ForegroundColor Green

        $fixes += @{
            source = $pngFile.FullName
            target = $targetPath
            iso2 = $matchedISO2
            capital = $capitalInfo.capitalEN
            action = "Convert PNG to JPG and rename"
        }

        if (!$DryRun) {
            try {
                # Load image and convert to JPG
                $image = [System.Drawing.Image]::FromFile($pngFile.FullName)

                # Create JPEG encoder with quality 90
                $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
                $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
                $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 90L)

                # Save as JPG
                $image.Save($targetPath, $jpegCodec, $encoderParams)
                $image.Dispose()

                # Remove original PNG
                Remove-Item $pngFile.FullName

                Write-Host "  ✓ Converted and renamed successfully" -ForegroundColor Green
            }
            catch {
                $errors += "Failed to convert $($pngFile.Name): $($_.Exception.Message)"
                Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    else {
        $errors += "Could not match '$originalName' to any capital"
        Write-Host "  ✗ No match found" -ForegroundColor Red
    }

    Write-Host ""
}

# Generate report
$reportContent = @"
CAPITAL PHOTOS FIX REPORT
========================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })

SUMMARY:
--------
PNG files found: $($pngFiles.Count)
Successful fixes: $($fixes.Count)
Errors: $($errors.Count)

FIXES APPLIED:
--------------
$($fixes | ForEach-Object { "$($_.iso2) - $($_.capital) ← $([System.IO.Path]::GetFileName($_.source))" } | Sort-Object)

ERRORS:
-------
$($errors -join "`n")

STATUS:
-------
$(if ($fixes.Count -eq $pngFiles.Count) { "✓ ALL PNG FILES PROCESSED SUCCESSFULLY" } else { "⚠ SOME FILES HAD ISSUES" })
"@

$reportContent | Out-File "$CACHE_DIR\photo_conversion_report.txt" -Encoding UTF8

Write-Host "CONVERSION SUMMARY" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host "PNG files processed: $($pngFiles.Count)" -ForegroundColor White
Write-Host "Successful conversions: $($fixes.Count)" -ForegroundColor $(if ($fixes.Count -eq $pngFiles.Count) { 'Green' } else { 'Yellow' })
Write-Host "Errors: $($errors.Count)" -ForegroundColor $(if ($errors.Count -eq 0) { 'Green' } else { 'Red' })
Write-Host ""
Write-Host "Report saved: $CACHE_DIR\photo_conversion_report.txt" -ForegroundColor Green

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "ERRORS:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  • $_" -ForegroundColor Red }
}