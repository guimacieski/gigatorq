# GigaTorq - approve one illustration candidate
#
# Usage (from C:\Projects\gigatorq):
#   .\tools\illustrations\approve.ps1 -Name dewalt-circular-saws -Variant 2
#   .\tools\illustrations\approve.ps1 -Name dewalt-circular-saws -Reject     # discard all candidates to generate again
#
# Copies the chosen version to assets\img\illustrations\<name>.<ext>, then removes that shot's candidates
# from the _review folder. An existing final image is only replaced with -Force.

param(
  [Parameter(Mandatory = $true)][string]$Name,
  [int]$Variant = 0,
  [switch]$Reject,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$final = Join-Path $root 'assets\img\illustrations'
$review = Join-Path $final '_review'
$candidates = Get-ChildItem $review -File -ErrorAction SilentlyContinue | Where-Object { $_.BaseName -match ('^' + [regex]::Escape($Name) + '-v\d+$') }

if (-not $candidates) { Write-Host "No candidates found for $Name in _review." -ForegroundColor Red; exit 1 }

if (-not $Reject) {
  $pick = $candidates | Where-Object { $_.BaseName -eq "$Name-v$Variant" } | Select-Object -First 1
  if (-not $pick) { Write-Host "Version $Variant of $Name not found. Available: $($candidates.Name -join ', ')" -ForegroundColor Red; exit 1 }
  $existing = Get-ChildItem $final -File | Where-Object { $_.BaseName -eq $Name }
  if ($existing -and -not $Force) { Write-Host "$Name already has a final image ($($existing.Name)). Add -Force to replace it." -ForegroundColor Yellow; exit 1 }
  $existing | Remove-Item
  Copy-Item $pick.FullName (Join-Path $final ($Name + $pick.Extension.ToLower()))
  Write-Host "Approved $($pick.Name) as $Name$($pick.Extension.ToLower())" -ForegroundColor Green
}

$candidates | Remove-Item
if ($Reject) { Write-Host "Discarded the candidates for $Name. Generate again with: .\tools\illustrations\generate.ps1 -Only $Name" }
& (Join-Path $PSScriptRoot 'contact-sheet.ps1')