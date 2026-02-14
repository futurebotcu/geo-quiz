param(
  [string]$Dir = ".",
  [switch]$Apply,
  [switch]$Recurse   # alt klasörleri de tara istersen
)

function UrlUnescape([string]$s){ try { [System.Uri]::UnescapeDataString($s) } catch { $s } }
function RemoveDiacritics([string]$s){
  $s = $s -replace "ı","i" -replace "İ","I" -replace "ğ","g" -replace "Ğ","G" -replace "ş","s" -replace "Ş","S" -replace "ç","c" -replace "Ç","C" -replace "ö","o" -replace "Ö","O" -replace "ü","u" -replace "Ü","U"
  $norm = $s.Normalize([Text.NormalizationForm]::FormD)
  $sb = New-Object Text.StringBuilder
  foreach($ch in $norm.ToCharArray()){
    if([Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [Globalization.UnicodeCategory]::NonSpacingMark){
      [void]$sb.Append($ch)
    }
  }
  $sb.ToString().Normalize([Text.NormalizationForm]::FormC)
}
function ToSlug([string]$s){
  $s = RemoveDiacritics(($s -replace "[’'`´]", "")).ToLower()
  $s = $s -replace "[^a-z0-9\s\-]+"," "
  $s = $s -replace "[\s_]+","-"
  $s = $s -replace "-{2,}","-"
  $s = $s.Trim("-")
  if([string]::IsNullOrWhiteSpace($s)) { "unknown" } else { $s }
}
function ExtractIso2AtEnd([string]$nameNoExt){
  $raw = UrlUnescape($nameNoExt)
  $raw = $raw -replace "\(\d+\)","" -replace "\s+\d+$",""
  $raw = $raw.Trim()
  if($raw -match "^(?<dish>.*?)[\s_\-]+(?<iso>[A-Za-z]{2})$"){
    @{ dish=$Matches.dish; iso=$Matches.iso.ToLower() }
  } else { $null }
}

if(-not (Test-Path $Dir)) { Write-Error "Folder not found: $Dir"; exit 1 }

# 🔧 BURASI DÜZELTİLDİ: \* eklendi ve -Recurse opsiyonel
$gciParams = @{ Path = (Join-Path $Dir '*'); File = $true }
if($Recurse){ $gciParams.Recurse = $true }
$files = Get-ChildItem @gciParams | Where-Object { $_.Extension -match '^\.(jpg|jpeg|png)$' }

if(-not $files){ Write-Host "No images found under '$Dir'."; exit 0 }

$plan = @()
foreach($f in $files){
  $nameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
  $parsed = ExtractIso2AtEnd $nameNoExt
  if(-not $parsed){
    $plan += [pscustomobject]@{ Current=$f.FullName; NewName=$null; Note="ISO2 not detected at end (e.g. _US). Manual fix." }
    continue
  }
  $iso  = $parsed.iso
  $dish = UrlUnescape($parsed.dish) -replace "[\.\,]+$",""
  $slug = ToSlug $dish
  if([string]::IsNullOrWhiteSpace($slug)){ $slug = "unknown" }

  $newBase = "{0}_{1}.jpg" -f $iso, $slug
  $target  = Join-Path $f.DirectoryName $newBase

  $i = 1
  while((Test-Path $target) -and ($f.FullName -ne $target)){
    $newBase = "{0}_{1}({2}).jpg" -f $iso, $slug, $i
    $target  = Join-Path $f.DirectoryName $newBase
    $i++
  }

  $note = ""
  if($f.Extension -match "jpeg|png"){ $note = "Name normalized to .jpg (no format convert)" }

  $plan += [pscustomobject]@{
    Current = $f.FullName
    NewName = $target
    Note    = $note
  }
}

Write-Host "DRY-RUN plan:" -ForegroundColor Cyan
$plan | Select-Object Current,NewName,Note | Format-Table -AutoSize

if(-not $Apply){
  Write-Host "`nRun with -Apply to rename." -ForegroundColor Yellow
  Write-Host "Example:"
  Write-Host "  powershell -ExecutionPolicy Bypass -File .\rename_food_iso_suffix_to_prefix.ps1 -Dir `"C:\dev\geo_quiz\assets\food_photos`""
  Write-Host "  powershell -ExecutionPolicy Bypass -File .\rename_food_iso_suffix_to_prefix.ps1 -Dir `"C:\dev\geo_quiz\assets\food_photos`" -Apply"
  exit 0
}

$renamed = 0
foreach($row in $plan){
  if(-not $row.NewName){ continue }
  if($row.Current -ne $row.NewName){
    Rename-Item -LiteralPath $row.Current -NewName (Split-Path $row.NewName -Leaf)
    $renamed++
  }
}
Write-Host "Done. Renamed: $renamed" -ForegroundColor Green
