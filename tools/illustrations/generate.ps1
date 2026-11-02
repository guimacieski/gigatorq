# GigaTorq - generate illustration candidates with the Gemini API
#
# Usage (from C:\Projects\gigatorq):
#   .\tools\illustrations\generate.ps1 -ListModels                 # show the image models your key can use (default: gemini-3.1-flash-image)
#   .\tools\illustrations\generate.ps1 -Only "*circular-saws*"      # generate candidates for matching shots
#   .\tools\illustrations\generate.ps1 -Limit 5 -Variants 3          # next 5 shots without a final image, 3 versions each
#
# Candidates are saved in assets\img\illustrations\_review\ with a contact sheet (index.html) to compare them.
# Pick one with approve.ps1. Shots that already have a final image are skipped unless you pass -Force.
# Needs an API key from https://aistudio.google.com in the GEMINI_API_KEY environment variable.

param(
  [string]$Only = '*',
  [int]$Limit = 5,
  [int]$Variants = 3,
  [string]$Model = 'gemini-3.1-flash-image',
  [string]$AspectRatio = '16:9',
  [switch]$ListModels,
  [switch]$NoReferences,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$final = Join-Path $root 'assets\img\illustrations'
$review = Join-Path $final '_review'
$api = 'https://generativelanguage.googleapis.com/v1beta'

$key = $env:GEMINI_API_KEY
if (-not $key) {
  Write-Host 'GEMINI_API_KEY is not set. Get a key at https://aistudio.google.com, then run:' -ForegroundColor Yellow
  Write-Host '  setx GEMINI_API_KEY "your-key-here"   (then open a new PowerShell window)'
  exit 1
}
$headers = @{ 'x-goog-api-key' = $key }

if ($ListModels) {
  $r = Invoke-RestMethod -Uri "$api/models?pageSize=200" -Headers $headers
  $r.models | Where-Object { $_.name -like '*image*' } |
    ForEach-Object { '{0}  -  {1}' -f ($_.name -replace '^models/', ''), $_.displayName }
  exit 0
}

New-Item -ItemType Directory -Force $review | Out-Null
$shots = Get-Content (Join-Path $PSScriptRoot 'shots.json') -Raw -Encoding UTF8 | ConvertFrom-Json

function Has-File($dir, $name) {
  return [bool](Get-ChildItem $dir -File -ErrorAction SilentlyContinue | Where-Object { $_.BaseName -eq $name })
}

$todo = $shots | Where-Object { $_.name -like $Only } | Where-Object {
  $Force -or (-not (Has-File $final $_.name) -and -not (Has-File $review "$($_.name)-v1"))
} | Select-Object -First $Limit

if (-not $todo) { Write-Host 'Nothing to generate: every matching shot already has a final image or candidates.'; exit 0 }
Write-Host ("Generating {0} shot(s) x {1} version(s) with {2}" -f @($todo).Count, $Variants, $Model) -ForegroundColor Cyan

$refsRoot = Join-Path $final '_refs'
foreach ($s in $todo) {
  # Reference photos of the real model (from find-references.ps1), used only to learn the tool's design
  $parts = @()
  $refs = @()
  if (-not $NoReferences) {
    $refs = Get-ChildItem (Join-Path $refsRoot $s.name) -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^ref\d+\.(jpg|png|webp)$' } | Sort-Object Name | Select-Object -First 2
  }
  foreach ($f in $refs) {
    $mime = @{ '.jpg' = 'image/jpeg'; '.png' = 'image/png'; '.webp' = 'image/webp' }[$f.Extension.ToLower()]
    $parts += @{ inlineData = @{ mimeType = $mime; data = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($f.FullName)) } }
  }
  $text = $s.prompt
  if ($refs) {
    $text = "The attached photo(s) show the real $($s.query). Reproduce THIS EXACT MODEL faithfully: every visible design detail of the tool must " +
            "match the photos - its shape and proportions, chuck or nose, collars, buttons, switches, vents, grip pattern, handle, battery and color " +
            "layout. Only the scene is new: create an original photograph as described below, with a different camera angle, background, lighting " +
            "and composition. Do not copy the background, lighting, framing, props, watermarks or any text from the attached photos. If the attached " +
            "photos disagree with the written description of the tool, follow the photos. " + $s.prompt
    Write-Host ("  {0}: using {1} reference photo(s)" -f $s.name, @($refs).Count)
  }
  $parts += @{ text = $text }
  for ($v = 1; $v -le $Variants; $v++) {
    $body = @{
      contents = @(@{ parts = $parts })
      generationConfig = @{ responseModalities = @('IMAGE'); imageConfig = @{ aspectRatio = $AspectRatio } }
    } | ConvertTo-Json -Depth 8
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
    $tries = 0
    while ($true) {
      try {
        $r = Invoke-RestMethod -Method Post -Uri "$api/models/${Model}:generateContent" -Headers $headers `
             -ContentType 'application/json; charset=utf-8' -Body $bytes -TimeoutSec 180
        break
      } catch {
        $tries++
        $msg = $_.Exception.Message
        $detail = $_.ErrorDetails.Message
        if ($detail) { try { $detail = ($detail | ConvertFrom-Json).error.message } catch { } }
        if ($msg -match '429' -and $detail -match 'quota|billing|limit: 0|free_tier') {
          Write-Host ''
          Write-Host 'Stopped: Google says this key has no quota for image generation.' -ForegroundColor Red
          Write-Host "Google's message: $detail"
          Write-Host 'Turn on billing for the key''s Google Cloud project (AI Studio > API keys > Set up billing), then run this again.'
          exit 1
        }
        if ($msg -match '402') {
          Write-Host ''
          Write-Host 'Stopped: your Gemini prepaid credit is used up.' -ForegroundColor Red
          Write-Host 'Add credit at https://aistudio.google.com/billing (Pagamentos), then run this again.'
          exit 1
        }
        if ($tries -lt 3 -and $msg -match '429|500|503') { Write-Host "  busy, retrying in 30 s ($msg)"; Start-Sleep 30; continue }
        Write-Host ("  {0} v{1}: failed - {2} {3}" -f $s.name, $v, $msg, $detail) -ForegroundColor Red
        $r = $null; break
      }
    }
    if (-not $r) { continue }
    $part = $r.candidates[0].content.parts | Where-Object { $_.inlineData -or $_.inline_data } | Select-Object -First 1
    if (-not $part) { Write-Host ("  {0} v{1}: no image returned (the model may have refused or answered in text)" -f $s.name, $v) -ForegroundColor Red; continue }
    $data = if ($part.inlineData) { $part.inlineData } else { $part.inline_data }
    $mime = if ($data.mimeType) { $data.mimeType } else { $data.mime_type }
    $ext = if ($mime -match 'jpeg') { '.jpg' } elseif ($mime -match 'webp') { '.webp' } else { '.png' }
    $out = Join-Path $review ("{0}-v{1}{2}" -f $s.name, $v, $ext)
    [System.IO.File]::WriteAllBytes($out, [Convert]::FromBase64String($data.data))
    Write-Host ("  saved {0}" -f (Split-Path $out -Leaf))
  }
}

& (Join-Path $PSScriptRoot 'contact-sheet.ps1')
Write-Host "Open assets\img\illustrations\_review\index.html to compare, then approve with:" -ForegroundColor Green
Write-Host '  .\tools\illustrations\approve.ps1 -Name <shot-name> -Variant <number>'