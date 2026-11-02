# GigaTorq - make web-sized copies of the approved illustrations
#
# Usage (from C:\Projects\gigatorq):
#   .\tools\illustrations\resize.ps1
#
# Reads every approved image in assets\img\illustrations\ and writes two JPEG copies to
# assets\img\illustrations\web\: <name>.jpg (1600 px wide) and <name>-800.jpg (800 px wide).
# Only the web\ folder is committed and published; the large originals stay on your PC.

param([int]$Quality = 82)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$src = Join-Path $root 'assets\img\illustrations'
$out = Join-Path $src 'web'
New-Item -ItemType Directory -Force $out | Out-Null
$shots = Get-Content (Join-Path $PSScriptRoot 'shots.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$known = @{}; foreach ($s in $shots) { $known[$s.name] = $true }

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$params = New-Object System.Drawing.Imaging.EncoderParameters 1
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$Quality)

function Save-Resized($img, [int]$width, [string]$path) {
  $w = [math]::Min($width, $img.Width)
  $h = [int][math]::Round($img.Height * $w / $img.Width)
  $bmp = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $g.DrawImage($img, 0, 0, $w, $h)
  $bmp.Save($path, $codec, $params)
  $g.Dispose(); $bmp.Dispose()
}

$done = 0; $skipped = @(); $unknown = @(); $bytes = 0
foreach ($f in (Get-ChildItem $src -File | Where-Object { $_.Extension -match '^\.(png|jpe?g|webp)$' })) {
  $name = $f.BaseName
  if (-not $known[$name]) { $unknown += $f.Name }
  if ($f.Extension -eq '.webp') { $skipped += $f.Name; continue }
  try {
    $img = [System.Drawing.Image]::FromFile($f.FullName)
    Save-Resized $img 1600 (Join-Path $out "$name.jpg")
    Save-Resized $img 800 (Join-Path $out "$name-800.jpg")
    $img.Dispose()
    $bytes += (Get-Item (Join-Path $out "$name.jpg")).Length
    $done++
  } catch {
    $skipped += $f.Name
  }
}

$missing = $shots | Where-Object { -not (Test-Path (Join-Path $out "$($_.name).jpg")) } | ForEach-Object { $_.name }
Write-Host ("Resized {0} illustration(s) into assets\img\illustrations\web (average {1} KB at 1600 px)" -f $done, $(if ($done) { [math]::Round($bytes / $done / 1024) } else { 0 })) -ForegroundColor Green
if ($skipped) { Write-Host ("Could not read (convert these to JPG or PNG): {0}" -f ($skipped -join ', ')) -ForegroundColor Yellow }
if ($unknown) { Write-Host ("Files whose names are not in the shot list (resized anyway, but no page uses them): {0}" -f ($unknown -join ', ')) -ForegroundColor Yellow }
if ($missing) { Write-Host ("Shots still without an image: {0}" -f ($missing -join ', ')) }