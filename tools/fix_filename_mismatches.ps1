# Fix Filename Mismatches
$renames = @{
    "BR_brasilia.jpg" = "BR_braslia.jpg"
    "CR_san-jose.jpg" = "CR_san-jos.jpg"
    "MD_chisinau.jpg" = "MD_chiinu.jpg"
    "MV_male.jpg" = "MV_mal.jpg"
    "CM_yaounde.jpg" = "CM_yaound.jpg"
    "CO_bogota.jpg" = "CO_bogot.jpg"
    "GD_st-george-s.jpg" = "GD_st-georges.jpg"
}

$PHOTOS_DIR = "assets\capital_photos"

Write-Host "Fixing filename mismatches..." -ForegroundColor Cyan

foreach ($oldName in $renames.Keys) {
    $newName = $renames[$oldName]
    $oldPath = Join-Path $PHOTOS_DIR $oldName
    $newPath = Join-Path $PHOTOS_DIR $newName

    if (Test-Path $oldPath) {
        Write-Host "Renaming: $oldName -> $newName" -ForegroundColor Green
        Rename-Item $oldPath $newPath
    } else {
        Write-Host "Not found: $oldName" -ForegroundColor Red
    }
}

Write-Host "Done!" -ForegroundColor Green