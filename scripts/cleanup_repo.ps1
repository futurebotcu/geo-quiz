# cleanup_repo.ps1
# Removes tool-generated junk files from the repo (cache/backup/report files).
# DRY RUN by default — pass -Apply to actually delete.
# Archives deleted files to _archive/junk_assets/<timestamp>/ before removing.
#
# Usage:
#   .\scripts\cleanup_repo.ps1            # dry run — shows what WOULD be deleted
#   .\scripts\cleanup_repo.ps1 -Apply     # actually delete (with archive)
#
# NEVER touches: *.jks *.keystore *.p12 key.properties *.json *.jpg *.png

param(
    [switch]$Apply
)

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmm'
$ArchiveDir = "_archive\junk_assets\$Timestamp"

# Patterns of files to remove (relative to repo root)
$Patterns = @(
    # Cache files with dotted prefix in asset directories
    'assets/capital_photos/.....cache*'
    'assets/capital_photos/*cleanup*.txt'
    'assets/flags/.....cache*'
    'assets/foods/.....cache*'
    # Data directory junk (NOT in pubspec, just repo hygiene)
    'data/*.backup'
    'data/backups'
    'data/mode_separation_report_*.txt'
    'data/review_log.csv'
    # General asset junk
    'assets/**/*.tmp'
    'assets/**/*.bak'
    'assets/**/*.cache'
    'assets/**/*.log'
    'assets/**/*.txt'
)

# Safety: extensions we absolutely refuse to touch
$SafeExtensions = @('.jks', '.keystore', '.p12', '.json', '.jpg', '.jpeg', '.png', '.webp', '.dart', '.gradle', '.kts', '.yaml', '.xml', '.plist')

function Should-Skip($Path) {
    $Ext = [System.IO.Path]::GetExtension($Path).ToLower()
    if ($Ext -in $SafeExtensions) { return $true }
    if ($Path -match 'key\.properties') { return $true }
    return $false
}

$ToDelete = [System.Collections.Generic.List[string]]::new()

foreach ($Pattern in $Patterns) {
    # Handle directory patterns (no wildcard, is a directory)
    if (-not ($Pattern -match '\*') -and (Test-Path $Pattern -PathType Container)) {
        Get-ChildItem -Path $Pattern -File -Recurse | ForEach-Object {
            if (-not (Should-Skip $_.FullName)) {
                $ToDelete.Add($_.FullName)
            }
        }
        continue
    }
    # File glob pattern
    $Dir  = Split-Path $Pattern -Parent
    $Glob = Split-Path $Pattern -Leaf
    if (Test-Path $Dir) {
        Get-ChildItem -Path $Dir -Filter $Glob -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            if (-not (Should-Skip $_.FullName)) {
                $ToDelete.Add($_.FullName)
            }
        }
    }
}

if ($ToDelete.Count -eq 0) {
    Write-Host "[CLEAN] No junk files found. Repository is clean." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Files to be removed ($($ToDelete.Count)):" -ForegroundColor Cyan
$ToDelete | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
Write-Host ""

if (-not $Apply) {
    Write-Host "[DRY RUN] No files were deleted. Run with -Apply to execute." -ForegroundColor Cyan
    exit 0
}

# Create archive directory
New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null
Write-Host "[ARCHIVE] Files will be moved to: $ArchiveDir" -ForegroundColor Cyan

foreach ($File in $ToDelete) {
    $RelPath  = (Resolve-Path -Relative $File) -replace '^\.\\', ''
    $DestPath = Join-Path $ArchiveDir $RelPath
    $DestDir  = Split-Path $DestPath -Parent
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    Move-Item -Path $File -Destination $DestPath -Force
    Write-Host "[REMOVED] $RelPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "[DONE] $($ToDelete.Count) file(s) archived to $ArchiveDir" -ForegroundColor Green
Write-Host "Run .\scripts\verify_assets.ps1 to confirm clean state." -ForegroundColor Cyan
