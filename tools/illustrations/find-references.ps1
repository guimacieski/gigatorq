# GigaTorq - find reference photos of the real model for each shot (Brave image search)
#
# Usage (from C:\Projects\gigatorq):
#   .\tools\illustrations\find-references.ps1 -Only "*hammer-drills*"
#   .\tools\illustrations\find-references.ps1 -Limit 20 -Count 2
#
# Saves up to -Count photos per shot in assets\img\illustrations\_refs\<shot-name>\ with a sources.txt
# listing where each came from. These are private design references for generate.ps1: they are never
# published or committed. Needs a Brave Search API key in the BRAVE_SEARCH_API_KEY environment variable.

param(
  [string]$Only = '*',
  [int]$Limit = 20,
  [int]$Count = 2,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$refsRoot = Join-Path $root 'assets\img\illustrations\_refs'
$key = $env:BRAVE_SEARCH_API_KEY
if (-not $key) {
  Write-Host 'BRAVE_SEARCH_API_KEY is not set. Get a key at https://api-dashboard.search.brave.com, then run:' -ForegroundColor Yellow
  Write-Host '  setx BRAVE_SEARCH_API_KEY "your-key-here"   (then open a new PowerShell window)'
  exit 1
}

$shots = Get-Content (Join-Path $PSScriptRoot 'shots.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$todo = $shots | Where-Object { $_.name -like $Only } | Where-Object {
  $Force -or -not (Get-ChildItem (Join-Path $refsRoot $_.name) -File -Filter 'ref*' -ErrorAction SilentlyContinue)
} | Select-Object -First $Limit
if (-not $todo) { Write-Host 'Nothing to do: every matching shot already has reference photos (use -Force to search again).'; exit 0 }

$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'

foreach ($s in $todo) {
  $dir = Join-Path $refsRoot $s.name
  New-Item -ItemType Directory -Force $dir | Out-Null
  Get-ChildItem $dir -File -ErrorAction SilentlyContinue | Remove-Item
  $q = [uri]::EscapeDataString($s.query)
  try {
    $r = Invoke-RestMethod -Uri "https://api.search.brave.com/res/v1/images/search?q=$q&count=20&safesearch=strict&country=us" `
         -Headers @{ 'X-Subscription-Token' = $key; 'Accept' = 'application/json' } -TimeoutSec 60
  } catch {
    Write-Host ("{0}: search failed - {1}" -f $s.name, $_.Exception.Message) -ForegroundColor Red
    if ($_.Exception.Message -match '401|403|402') { exit 1 }
    continue
  }
  $saved = 0
  $log = @("Search: $($s.query)")
  foreach ($res in $r.results) {
    if ($saved -ge $Count) { break }
    $urls = @()
    if ($res.properties.url) { $urls += $res.properties.url }
    if ($res.thumbnail.src) { $urls += $res.thumbnail.src }
    foreach ($u in $urls) {
      try {
        $tmp = Join-Path $dir 'download.tmp'
        Invoke-WebRequest -Uri $u -OutFile $tmp -UserAgent $ua -TimeoutSec 30 -UseBasicParsing
        $len = (Get-Item $tmp).Length
        $head = [System.IO.File]::ReadAllBytes($tmp)[0..11]
        $ext = $null
        if ($head[0] -eq 0xFF -and $head[1] -eq 0xD8) { $ext = '.jpg' }
        elseif ($head[0] -eq 0x89 -and $head[1] -eq 0x50) { $ext = '.png' }
        elseif ($head[8] -eq 0x57 -and $head[9] -eq 0x45 -and $head[10] -eq 0x42 -and $head[11] -eq 0x50) { $ext = '.webp' }
        if (-not $ext -or $len -lt 8000) { Remove-Item $tmp; continue }
        $saved++
        Move-Item $tmp (Join-Path $dir ("ref{0}{1}" -f $saved, $ext)) -Force
        $log += ("ref{0}{1}: {2} (from {3})" -f $saved, $ext, $res.title, $res.url)
        break
      } catch {
        Remove-Item (Join-Path $dir 'download.tmp') -ErrorAction SilentlyContinue
      }
    }
  }
  Set-Content (Join-Path $dir 'sources.txt') $log -Encoding UTF8
  if ($saved) { Write-Host ("{0}: saved {1} reference photo(s)" -f $s.name, $saved) }
  else { Write-Host ("{0}: no usable photos found" -f $s.name) -ForegroundColor Yellow }
}

& (Join-Path $PSScriptRoot 'contact-sheet.ps1')
Write-Host 'Check the reference photos in the contact sheet (assets\img\illustrations\_review\index.html).' -ForegroundColor Green
Write-Host 'If one shows the wrong tool, delete it from assets\img\illustrations\_refs\<shot-name>\ before generating.'