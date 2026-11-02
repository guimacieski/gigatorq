# GigaTorq - rebuild the contact sheet (assets\img\illustrations\_review\index.html) for comparing candidates
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$review = Join-Path $root 'assets\img\illustrations\_review'
New-Item -ItemType Directory -Force $review | Out-Null
$shots = Get-Content (Join-Path $PSScriptRoot 'shots.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$files = Get-ChildItem $review -File | Where-Object { $_.Extension -match 'png|jpg|jpeg|webp' }

$html = New-Object System.Text.StringBuilder
[void]$html.Append('<!doctype html><html lang="en"><head><meta charset="utf-8"><title>GigaTorq illustration review</title>')
[void]$html.Append('<style>body{background:#0f1114;color:#eeeff0;font:15px system-ui,sans-serif;margin:24px}h1{font-size:22px}')
[void]$html.Append('section{margin:28px 0;border-top:1px solid #2c313a;padding-top:12px}h2{font-size:17px;margin:0 0 4px}')
[void]$html.Append('code{background:#20242b;padding:2px 6px;border-radius:4px;color:#e3a401}.row{display:grid;grid-template-columns:repeat(auto-fill,minmax(420px,1fr));gap:14px;margin-top:10px}')
[void]$html.Append('figure{margin:0}img{width:100%;border-radius:6px;border:1px solid #2c313a}figcaption{margin-top:6px;color:#9aa3b2}.refs{margin-top:8px;color:#9aa3b2;font-size:13px}.refs img{height:90px;width:auto;margin:4px 6px 0 0;vertical-align:middle;border:1px dashed #9aa3b2}</style></head><body>')
[void]$html.Append('<h1>Illustration candidates</h1><p>Check logo spelling, stray text, and that the tool is built and placed correctly. Approve one per shot with the command shown.</p>')

# Shots with candidates waiting, plus shots that only have reference photos so far
$byName = @{}
foreach ($f in $files) { $n = $f.BaseName -replace '-v\d+$', ''; if (-not $byName[$n]) { $byName[$n] = @() }; $byName[$n] += $f }
$refsRoot = Join-Path (Split-Path $review -Parent) '_refs'
foreach ($d in (Get-ChildItem $refsRoot -Directory -ErrorAction SilentlyContinue)) {
  if ((Get-ChildItem $d.FullName -File | Where-Object { $_.Name -match '^ref\d+\.' }) -and -not $byName[$d.Name]) { $byName[$d.Name] = @() }
}
$groups = $byName.Keys | Sort-Object | ForEach-Object { [pscustomobject]@{ Name = $_; Group = $byName[$_] } }
if (-not $groups) { [void]$html.Append('<p>No candidates or reference photos waiting for review.</p>') }
foreach ($g in $groups) {
  $shot = $shots | Where-Object { $_.name -eq $g.Name } | Select-Object -First 1
  $label = if ($shot) { "$($shot.brand) - $($shot.group)" + $(if ($shot.variant) { " ($($shot.variant))" } else { '' }) } else { $g.Name }
  $q = if ($shot -and $shot.query) { $shot.query } else { $g.Name }
  $gi = 'https://www.google.com/search?tbm=isch&q=' + [uri]::EscapeDataString($q)
  [void]$html.Append("<section><h2>$label</h2><div>$($g.Name) &middot; <a style=""color:#e3a401"" href=""$gi"" target=""_blank"">See real photos of the $q</a></div>")
  $refDir = Join-Path (Split-Path $review -Parent) ('_refs\' + $g.Name)
  $refImgs = Get-ChildItem $refDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^ref\d+\.' }
  if ($refImgs) {
    [void]$html.Append('<div class="refs">Reference photos used: ')
    foreach ($ri in $refImgs) { [void]$html.Append("<a href=""../_refs/$($g.Name)/$($ri.Name)""><img src=""../_refs/$($g.Name)/$($ri.Name)"" alt=""reference""></a>") }
    [void]$html.Append('</div>')
  }
  [void]$html.Append('<div class="row">')
  if (-not $g.Group) { [void]$html.Append('<p style="color:#9aa3b2">No versions generated yet. Delete any wrong reference photo, then run generate.ps1 for this shot.</p>') }
  foreach ($f in ($g.Group | Sort-Object Name)) {
    $n = $f.BaseName -replace '^.*-v', ''
    [void]$html.Append("<figure><a href=""$($f.Name)""><img src=""$($f.Name)"" alt=""$($f.Name)""></a><figcaption>Version $n &middot; <code>.\tools\illustrations\approve.ps1 -Name $($g.Name) -Variant $n</code></figcaption></figure>")
  }
  [void]$html.Append('</div>')
  if ($g.Group) { [void]$html.Append("<p><code>.\tools\illustrations\approve.ps1 -Name $($g.Name) -Reject</code> to discard all and try again</p>") }
  [void]$html.Append('</section>')
}
[void]$html.Append('</body></html>')
[System.IO.File]::WriteAllText((Join-Path $review 'index.html'), $html.ToString(), (New-Object System.Text.UTF8Encoding $false))