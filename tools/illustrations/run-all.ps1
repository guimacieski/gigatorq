# GigaTorq - run the whole illustration set in one go
#
# Usage (from C:\Projects\gigatorq):
#   .\tools\illustrations\run-all.ps1 -Wipe              # delete ALL illustrations, references and candidates, then redo everything
#   .\tools\illustrations\run-all.ps1                    # only fill in shots that have no image yet
#   .\tools\illustrations\run-all.ps1 -Variants 3
#
# Steps: 1) find reference photos of each real model, 2) generate new versions with Gemini, 3) build the
# comparison page. Every Gemini request is independent: nothing from one shot carries over to the next.
# Then review assets\img\illustrations\_review\index.html and approve one version per shot.

param(
  [int]$Variants = 2,
  [string]$Model = 'gemini-3.1-flash-image',
  [switch]$Wipe,
  [switch]$SkipReferences
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$final = Join-Path $root 'assets\img\illustrations'
$shots = Get-Content (Join-Path $PSScriptRoot 'shots.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$n = @($shots).Count
$cost = [math]::Round($n * $Variants * 0.07, 2)

Write-Host "Shots in the list: $n  |  versions per shot: $Variants  |  model: $Model"
Write-Host ("Estimated Gemini cost if every shot is generated: about US$ {0} (plus about {1} image searches)" -f $cost, $n)
if ($Wipe) {
  $existing = @(Get-ChildItem $final -File -ErrorAction SilentlyContinue).Count
  Write-Host ''
  Write-Host "-Wipe will permanently delete $existing approved illustration(s), all candidates and all reference photos." -ForegroundColor Yellow
}
$answer = Read-Host 'Type YES to continue'
if ($answer -ne 'YES') { Write-Host 'Cancelled. Nothing was changed.'; exit 0 }

if ($Wipe) {
  Get-ChildItem $final -File -ErrorAction SilentlyContinue | Remove-Item
  Remove-Item (Join-Path $final '_review') -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item (Join-Path $final '_refs') -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force (Join-Path $final '_review') | Out-Null
  Write-Host 'Wiped all illustrations, candidates and reference photos.' -ForegroundColor Green
}

$started = Get-Date
if (-not $SkipReferences) {
  Write-Host ''
  Write-Host 'Step 1 of 2: finding reference photos of each model...' -ForegroundColor Cyan
  & (Join-Path $PSScriptRoot 'find-references.ps1') -Limit 9999 -Count 2
  if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { Write-Host 'Stopped: the reference photo search failed (see the message above).' -ForegroundColor Red; exit 1 }
}

Write-Host ''
Write-Host 'Step 2 of 2: generating new versions with Gemini...' -ForegroundColor Cyan
& (Join-Path $PSScriptRoot 'generate.ps1') -Limit 9999 -Variants $Variants -Model $Model

$mins = [math]::Round(((Get-Date) - $started).TotalMinutes, 0)
Write-Host ''
Write-Host "Done in about $mins minutes. Review and approve on the comparison page:" -ForegroundColor Green
Write-Host '  start .\assets\img\illustrations\_review\index.html'