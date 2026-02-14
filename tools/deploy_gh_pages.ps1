# GitHub Pages Deployment Script for World Geo Quiz
# Deploys build/web to gh-pages branch

param(
    [string]$CommitMessage = "Deploy: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

$ErrorActionPreference = "Stop"

# Paths
$BUILD_DIR = "build\web"
$REPO_ROOT = Get-Location

Write-Host "World Geo Quiz - GitHub Pages Deployment" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is available
try {
    git --version | Out-Null
}
catch {
    Write-Host "ERROR: Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Git first:" -ForegroundColor Yellow
    Write-Host "  https://git-scm.com/downloads" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Check if this is a git repository
if (!(Test-Path ".git")) {
    Write-Host "ERROR: Not a git repository" -ForegroundColor Red
    Write-Host ""
    Write-Host "Initialize git first:" -ForegroundColor Yellow
    Write-Host "  git init" -ForegroundColor White
    Write-Host "  git remote add origin <your-repo-url>" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Check git config
$userName = git config user.name 2>$null
$userEmail = git config user.email 2>$null

if ([string]::IsNullOrWhiteSpace($userName) -or [string]::IsNullOrWhiteSpace($userEmail)) {
    Write-Host "ERROR: Git user name and/or email not configured" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please configure git first:" -ForegroundColor Yellow
    Write-Host "  git config user.name `"Your Name`"" -ForegroundColor White
    Write-Host "  git config user.email `"your.email@example.com`"" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "Git configuration:" -ForegroundColor Green
Write-Host "  User: $userName <$userEmail>" -ForegroundColor Gray
Write-Host ""

# Check if build exists
if (!(Test-Path $BUILD_DIR)) {
    Write-Host "ERROR: Build directory not found: $BUILD_DIR" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run the build first:" -ForegroundColor Yellow
    Write-Host "  flutter build web --release" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Check if build has content
$buildFiles = Get-ChildItem $BUILD_DIR -Recurse -File
if ($buildFiles.Count -eq 0) {
    Write-Host "ERROR: Build directory is empty" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run the build first:" -ForegroundColor Yellow
    Write-Host "  flutter build web --release" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "Build verification:" -ForegroundColor Green
Write-Host "  Files found: $($buildFiles.Count)" -ForegroundColor Gray
Write-Host "  Location: $BUILD_DIR" -ForegroundColor Gray
Write-Host ""

# Confirm deployment
Write-Host "Ready to deploy to GitHub Pages" -ForegroundColor Yellow
Write-Host ""
Write-Host "This will:" -ForegroundColor Cyan
Write-Host "  1. Create/update gh-pages branch" -ForegroundColor White
Write-Host "  2. Replace all content with build/web" -ForegroundColor White
Write-Host "  3. Force push to origin/gh-pages" -ForegroundColor White
Write-Host ""
Write-Host "Commit message: $CommitMessage" -ForegroundColor Gray
Write-Host ""

$confirmation = Read-Host "Continue? (y/N)"
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "Deployment cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting deployment..." -ForegroundColor Cyan
Write-Host ""

try {
    # Save current branch
    $currentBranch = git rev-parse --abbrev-ref HEAD

    Write-Host "[1/6] Checking out gh-pages branch..." -ForegroundColor Yellow

    # Check if gh-pages branch exists
    $ghPagesExists = git rev-parse --verify gh-pages 2>$null
    if ($ghPagesExists) {
        git checkout gh-pages
    }
    else {
        git checkout --orphan gh-pages
    }

    Write-Host "[2/6] Removing old files..." -ForegroundColor Yellow
    git rm -rf . 2>$null | Out-Null
    Remove-Item * -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "[3/6] Copying new build..." -ForegroundColor Yellow
    Copy-Item "$BUILD_DIR\*" . -Recurse -Force

    Write-Host "[4/6] Adding files to git..." -ForegroundColor Yellow
    git add -A

    Write-Host "[5/6] Creating commit..." -ForegroundColor Yellow
    git commit -m $CommitMessage

    Write-Host "[6/6] Pushing to GitHub..." -ForegroundColor Yellow
    git push origin gh-pages --force

    Write-Host ""
    Write-Host "SUCCESS: Deployment complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your site will be available at:" -ForegroundColor Cyan
    Write-Host "  https://<username>.github.io/<repo-name>/" -ForegroundColor White
    Write-Host ""
    Write-Host "Check GitHub Pages settings:" -ForegroundColor Yellow
    Write-Host "  Settings > Pages > Source: gh-pages branch" -ForegroundColor White
    Write-Host ""

    # Return to original branch
    Write-Host "Returning to $currentBranch branch..." -ForegroundColor Gray
    git checkout $currentBranch

}
catch {
    Write-Host ""
    Write-Host "ERROR: Deployment failed" -ForegroundColor Red
    Write-Host "Error details: $_" -ForegroundColor Gray
    Write-Host ""

    # Try to return to original branch
    try {
        git checkout $currentBranch
    }
    catch {
        Write-Host "WARNING: Could not return to original branch" -ForegroundColor Yellow
    }

    exit 1
}

Write-Host "Deployment script completed" -ForegroundColor Green
Write-Host ""
