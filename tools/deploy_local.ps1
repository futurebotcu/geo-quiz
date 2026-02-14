# Local Deployment Script for World Geo Quiz
# Opens the built web app in Microsoft Edge browser

param(
    [switch]$OpenInEdge = $false
)

$ErrorActionPreference = "Stop"

# Paths
$BUILD_DIR = "build\web"
$INDEX_FILE = "$BUILD_DIR\index.html"

Write-Host "World Geo Quiz - Local Deployment" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if build directory exists
if (!(Test-Path $BUILD_DIR)) {
    Write-Host "ERROR: Build directory not found: $BUILD_DIR" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run the build first:" -ForegroundColor Yellow
    Write-Host "  flutter build web --release" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Check if index.html exists
if (!(Test-Path $INDEX_FILE)) {
    Write-Host "ERROR: index.html not found: $INDEX_FILE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Build may be incomplete. Please run:" -ForegroundColor Yellow
    Write-Host "  flutter build web --release" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Get absolute path
$AbsolutePath = Resolve-Path $INDEX_FILE

Write-Host "Build found at:" -ForegroundColor Green
Write-Host "  $AbsolutePath" -ForegroundColor Gray
Write-Host ""

# Open in Edge if requested
if ($OpenInEdge) {
    Write-Host "Opening in Microsoft Edge..." -ForegroundColor Yellow

    try {
        Start-Process "msedge.exe" -ArgumentList $AbsolutePath
        Write-Host "SUCCESS: Application opened in Edge" -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: Could not launch Microsoft Edge" -ForegroundColor Red
        Write-Host "Error details: $_" -ForegroundColor Gray
        Write-Host ""
        Write-Host "You can manually open the file at:" -ForegroundColor Yellow
        Write-Host "  $AbsolutePath" -ForegroundColor White
        exit 1
    }
}
else {
    Write-Host "TIP: Add -OpenInEdge parameter to automatically open in Edge" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Cyan
    Write-Host "  .\tools\deploy_local.ps1 -OpenInEdge" -ForegroundColor White
    Write-Host ""
    Write-Host "Or manually open:" -ForegroundColor Cyan
    Write-Host "  $AbsolutePath" -ForegroundColor White
}

Write-Host ""
Write-Host "For production deployment, use:" -ForegroundColor Cyan
Write-Host "  .\tools\deploy_gh_pages.ps1" -ForegroundColor White
Write-Host ""
