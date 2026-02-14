# Create UI Placeholder Images
param([switch]$DryRun = $false)

# Add System.Drawing for image creation
Add-Type -AssemblyName System.Drawing

$placeholders = @{
    "assets\ui_backgrounds\bg_worldmap.jpg" = @{
        width = 1920
        height = 1080
        color = [System.Drawing.Color]::FromArgb(25, 35, 45)  # Dark blue-gray
        text = "World Map Background"
    }
    "assets\ui_banners\banner_cities.jpg" = @{
        width = 800
        height = 300
        color = [System.Drawing.Color]::FromArgb(45, 85, 125)  # Blue
        text = "Cities Banner"
    }
    "assets\ui_banners\banner_food.jpg" = @{
        width = 800
        height = 300
        color = [System.Drawing.Color]::FromArgb(125, 85, 45)  # Orange-brown
        text = "Food Banner"
    }
}

Write-Host "Creating UI placeholder images..." -ForegroundColor Cyan

foreach ($path in $placeholders.Keys) {
    if ((Test-Path $path) -and !$DryRun) {
        Write-Host "Already exists: $path" -ForegroundColor Yellow
        continue
    }

    $info = $placeholders[$path]
    Write-Host "Creating: $path ($($info.width)x$($info.height))" -ForegroundColor Green

    if (!$DryRun) {
        try {
            # Create bitmap
            $bitmap = New-Object System.Drawing.Bitmap $info.width, $info.height
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

            # Fill background
            $brush = New-Object System.Drawing.SolidBrush $info.color
            $graphics.FillRectangle($brush, 0, 0, $info.width, $info.height)

            # Add text
            $font = New-Object System.Drawing.Font("Arial", 24, [System.Drawing.FontStyle]::Bold)
            $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
            $textSize = $graphics.MeasureString($info.text, $font)
            $x = ($info.width - $textSize.Width) / 2
            $y = ($info.height - $textSize.Height) / 2
            $graphics.DrawString($info.text, $font, $textBrush, $x, $y)

            # Save as JPEG
            $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
            $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 90L)

            $bitmap.Save($path, $jpegCodec, $encoderParams)

            # Cleanup
            $graphics.Dispose()
            $bitmap.Dispose()
            $brush.Dispose()
            $textBrush.Dispose()
            $font.Dispose()

            Write-Host "  ✓ Created successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "Done creating placeholder images" -ForegroundColor Green