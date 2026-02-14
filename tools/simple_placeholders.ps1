# Simple Placeholder Creator
Add-Type -AssemblyName System.Drawing

$files = @(
    "assets\ui_backgrounds\bg_worldmap.jpg",
    "assets\ui_banners\banner_cities.jpg",
    "assets\ui_banners\banner_food.jpg"
)

foreach ($file in $files) {
    if (!(Test-Path $file)) {
        Write-Host "Creating: $file"

        # Create 800x600 colored image
        $bitmap = New-Object System.Drawing.Bitmap 800, 600
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

        # Fill with color
        $color = [System.Drawing.Color]::FromArgb(50, 70, 90)
        $brush = New-Object System.Drawing.SolidBrush $color
        $graphics.FillRectangle($brush, 0, 0, 800, 600)

        # Save as JPG
        $bitmap.Save($file, [System.Drawing.Imaging.ImageFormat]::Jpeg)

        # Cleanup
        $graphics.Dispose()
        $bitmap.Dispose()
        $brush.Dispose()

        Write-Host "Created: $file"
    } else {
        Write-Host "Exists: $file"
    }
}

Write-Host "Done"