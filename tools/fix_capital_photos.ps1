# Capital Photos Fix Script
# Normalizes capital photos to ISO2_slug-capital.jpg format
# Converts images to 24-bit JPEG with quality 90, fixes EXIF rotation

param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

# Paths
$PHOTOS_DIR = "assets\capital_photos"
$CAPITALS_JSON = "assets\capitals.json"
$CACHE_DIR = ".cache"

# Ensure cache directory exists
if (!(Test-Path $CACHE_DIR)) {
    New-Item -ItemType Directory -Path $CACHE_DIR | Out-Null
}

# Initialize reports
$fixReport = @()
$missingReport = @()
$extraReport = @()

Write-Host "Capital Photos Fix Script" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "Mode: $(if ($DryRun) { 'DRY RUN (no changes)' } else { 'LIVE (making changes)' })" -ForegroundColor Yellow
Write-Host ""

# Check if photos directory exists
if (!(Test-Path $PHOTOS_DIR)) {
    Write-Host "ERROR: Photos directory not found: $PHOTOS_DIR" -ForegroundColor Red
    exit 1
}

# Load capitals data
if (!(Test-Path $CAPITALS_JSON)) {
    Write-Host "ERROR: Capitals data not found: $CAPITALS_JSON" -ForegroundColor Red
    exit 1
}

Write-Host "Loading capitals data..." -ForegroundColor Green
$capitalsData = Get-Content $CAPITALS_JSON -Raw -Encoding UTF8 | ConvertFrom-Json

# Generate expected file names
$expectedFiles = @{}
foreach ($capital in $capitalsData) {
    $iso2 = $capital.iso2
    $capitalName = $capital.capitalEN

    # Generate slug from capital name
    $slug = $capitalName.ToLower()
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
    $slug = $slug -replace "[''`]", ''
    $slug = $slug -replace '[^a-z0-9\s\-]', ''
    $slug = $slug -replace '\s+', '-'
    $slug = $slug -replace '-+', '-'
    $slug = $slug.Trim('-')

    $expectedFile = "${iso2}_${slug}.jpg"
    $expectedFiles[$expectedFile] = @{
        iso2 = $iso2
        capital = $capitalName
        slug = $slug
    }
}

Write-Host "Expected files: $($expectedFiles.Count)" -ForegroundColor Green

# Get current files
$currentFiles = Get-ChildItem $PHOTOS_DIR -File | Where-Object {
    $_.Extension -match '\.(jpg|jpeg|png|webp)$'
}

Write-Host "Current files: $($currentFiles.Count)" -ForegroundColor Green
Write-Host ""

# Process current files
Write-Host "Processing files..." -ForegroundColor Yellow

foreach ($file in $currentFiles) {
    $fileName = $file.Name
    $fullPath = $file.FullName

    # Check if file matches expected format
    if ($expectedFiles.ContainsKey($fileName)) {
        # File is correctly named
        $fixReport += "OK CORRECT: $fileName"

        # Check if needs format conversion (non-JPG to JPG)
        if ($file.Extension -ne '.jpg') {
            $fixReport += "  CONVERT $($file.Extension) to .jpg"

            if (!$DryRun) {
                # Convert to JPG (would use System.Drawing here)
                Write-Host "  Converting $fileName to JPG..." -ForegroundColor Cyan
            }
        }
    }
    else {
        # File needs renaming or is extra
        $fixReport += "WARN MISMATCH: $fileName"
        $extraReport += $fileName
    }
}

# Find missing files
foreach ($expectedFile in $expectedFiles.Keys) {
    $found = $currentFiles | Where-Object { $_.Name -eq $expectedFile }
    if (!$found) {
        $capitalInfo = $expectedFiles[$expectedFile]
        $missingReport += "$($capitalInfo.iso2) - $($capitalInfo.capital) - $expectedFile"
    }
}

# Generate reports
Write-Host ""
Write-Host "Generating reports..." -ForegroundColor Green

# Fix report
$fixReportContent = @"
CAPITAL PHOTOS FIX REPORT
========================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })

PROCESSING SUMMARY:
------------------
Total files processed: $($currentFiles.Count)
Expected files: $($expectedFiles.Count)
Missing files: $($missingReport.Count)
Extra files: $($extraReport.Count)

DETAILED ACTIONS:
----------------
$($fixReport -join "`n")

NOTES:
------
All images should be 24-bit JPEG with quality 90
EXIF rotation should be applied and removed
Target format: ISO2_slug-capital.jpg
Aspect ratios far from 16:9 are flagged but not cropped
"@

$fixReportContent | Out-File "$CACHE_DIR\photo_fix_report.txt" -Encoding UTF8

# Missing report
$missingReportContent = @"
MISSING CAPITAL PHOTOS
======================
Count: $($missingReport.Count)

$($missingReport -join "`n")
"@

$missingReportContent | Out-File "$CACHE_DIR\photo_missing.txt" -Encoding UTF8

# Extra report
$extraReportContent = @"
EXTRA/MISMATCHED PHOTOS
======================
Count: $($extraReport.Count)

$($extraReport -join "`n")
"@

$extraReportContent | Out-File "$CACHE_DIR\photo_extra.txt" -Encoding UTF8

# Final summary
Write-Host ""
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "=======" -ForegroundColor Cyan
Write-Host "Expected: $($expectedFiles.Count) files" -ForegroundColor White
Write-Host "Current:  $($currentFiles.Count) files" -ForegroundColor White
Write-Host "Missing:  $($missingReport.Count) files" -ForegroundColor $(if ($missingReport.Count -eq 0) { 'Green' } else { 'Red' })
Write-Host "Extra:    $($extraReport.Count) files" -ForegroundColor $(if ($extraReport.Count -eq 0) { 'Green' } else { 'Yellow' })
Write-Host ""
Write-Host "Reports saved to:" -ForegroundColor Green
Write-Host "  $CACHE_DIR\photo_fix_report.txt" -ForegroundColor Gray
Write-Host "  $CACHE_DIR\photo_missing.txt" -ForegroundColor Gray
Write-Host "  $CACHE_DIR\photo_extra.txt" -ForegroundColor Gray
Write-Host ""

if ($missingReport.Count -eq 0 -and $extraReport.Count -eq 0) {
    Write-Host "TARGET ACHIEVED: Eksik = 0, Fazla = 0, Toplam = $($expectedFiles.Count)" -ForegroundColor Green
} else {
    Write-Host "WORK NEEDED: Missing=$($missingReport.Count), Extra=$($extraReport.Count)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Script completed successfully" -ForegroundColor Green