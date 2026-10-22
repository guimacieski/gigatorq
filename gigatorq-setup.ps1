# GigaTorq - complete site setup (pages, logo, favicon, Vercel config)
# Run from inside your gigatorq repo folder.
$ErrorActionPreference = "Stop"
$root = (Get-Location).Path
$utf8 = New-Object System.Text.UTF8Encoding $false
function Ensure-Dir([string]$path) { $dir = Split-Path $path -Parent; if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null } }
function Write-SiteFile([string]$rel, [string]$content) {
  $path = Join-Path $root $rel; Ensure-Dir $path
  [System.IO.File]::WriteAllText($path, ($content -replace "`r`n", "`n"), $utf8)
  Write-Host "  wrote $rel"
}
function Write-BinFile([string]$rel, [string]$b64) {
  $path = Join-Path $root $rel; Ensure-Dir $path
  [System.IO.File]::WriteAllBytes($path, [Convert]::FromBase64String($b64))
  Write-Host "  wrote $rel"
}

Write-SiteFile '404.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Page Not Found | GigaTorq</title>
<meta name="description" content="Page not found.">
<link rel="canonical" href="https://gigatorq.com/404.html">
<meta property="og:title" content="Page Not Found | GigaTorq">
<meta property="og:description" content="Page not found.">
<meta property="og:url" content="https://gigatorq.com/404.html">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/">Comparisons</a></li>
      <li><a href="/reviews/">Reviews</a></li>
      <li><a href="/how-we-test/">How We Test</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="section">
  <div class="container center">
    <span class="eyebrow">404</span>
    <h1>Stripped screw.</h1>
    <p class="muted">That page doesn't exist. Let's get you back on track.</p>
    <a class="btn" href="/">Back to home</a>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'README.md' @'
# GigaTorq

Static site for gigatorq.com - power tool comparisons and reviews for US buyers.

## Structure
- `index.html` - home page
- `compare/` - comparison hub and `cordless-drills/` template
- `reviews/` - review hub and `review-template/`
- `how-we-test/`, `about/`, `contact/`, `disclosure/`, `privacy/`
- `assets/css/style.css`, `assets/js/main.js`, `assets/img/`
- `vercel.json` - Vercel settings (trailing slashes, cache and security headers)

## New comparison or review
Copy the template folder, rename it (e.g. `compare/impact-drivers/`), replace the placeholder content, add the card to the hub page and the URL to `sitemap.xml`.

## Logo
Brand colors: black `#000000` and steel grey `#EEEFF0`. Amber `#e3a401` is the site accent.
- `assets/img/logo.svg` - steel grey logo (used on the dark site)
- `assets/img/logo-black.svg` - black logo for light backgrounds and print
- `assets/img/favicon.svg` / `favicon.png` / `apple-touch-icon.png` - bolt "o" icon
- `assets/img/og-image.png` - social share image

## Hosting
Deployed on Vercel from the `main` branch. Every push to `main` goes live automatically.
'@

Write-SiteFile 'about\index.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>About GigaTorq</title>
<meta name="description" content="Who we are and how GigaTorq tests and reviews power tools.">
<link rel="canonical" href="https://gigatorq.com/about/">
<meta property="og:title" content="About GigaTorq">
<meta property="og:description" content="Who we are and how GigaTorq tests and reviews power tools.">
<meta property="og:url" content="https://gigatorq.com/about/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/">Comparisons</a></li>
      <li><a href="/reviews/">Reviews</a></li>
      <li><a href="/how-we-test/">How We Test</a></li>
      <li><a href="/about/" class="active">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="section">
  <div class="container article">
    <span class="eyebrow">About</span>
    <h1>About GigaTorq</h1>
    <p>GigaTorq is an independent power tool comparison site for US buyers. We test tools head to head on real jobs and tell you which one to buy for the way you work.</p>
    <p class="placeholder">Add your story here: who runs the site, your experience with tools, and why you started GigaTorq.</p>
    <h2>Our promise</h2>
    <ul>
      <li>We test tools ourselves before recommending them.</li>
      <li>Brands can't pay for placement or scores.</li>
      <li>We tell you when a tool was loaned or given to us.</li>
      <li>We update pages when better tools come out.</li>
    </ul>
    <h2>How we make money</h2>
    <p>We earn affiliate commissions when you buy through some links on our site. That never changes our verdict. <a href="/disclosure/">Read our full disclosure</a>.</p>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'assets\css\style.css' @'
/* GigaTorq - main stylesheet */
:root {
  --bg: #0f1114;
  --bg-2: #171a1f;
  --bg-3: #20242b;
  --line: #2c313a;
  --text: #EEEFF0;
  --muted: #9aa3b2;
  --accent: #e3a401;
  --accent-2: #f5bd2a;
  --good: #4cc38a;
  --bad: #e0102e;
  --radius: 10px;
  --max: 1180px;
  --font-head: "Barlow Condensed", "Arial Narrow", sans-serif;
  --font-body: "Inter", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
}

* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
  margin: 0;
  background: var(--bg);
  color: var(--text);
  font-family: var(--font-body);
  font-size: 16px;
  line-height: 1.6;
}
img { max-width: 100%; display: block; }
a { color: var(--accent); text-decoration: none; }
a:hover { text-decoration: underline; }

h1, h2, h3, h4 {
  font-family: var(--font-head);
  font-weight: 700;
  letter-spacing: .01em;
  line-height: 1.1;
  margin: 0 0 .5em;
  text-transform: uppercase;
}
h1 { font-size: clamp(2.4rem, 6vw, 4.2rem); }
h2 { font-size: clamp(1.8rem, 3.5vw, 2.6rem); }
h3 { font-size: 1.4rem; }
p { margin: 0 0 1em; }

.container { max-width: var(--max); margin: 0 auto; padding: 0 16px; }
.section { padding: 64px 0; }
.section-alt { background: var(--bg-2); border-top: 1px solid var(--line); border-bottom: 1px solid var(--line); }
.eyebrow {
  display: inline-block;
  font-size: .75rem;
  font-weight: 700;
  letter-spacing: .14em;
  text-transform: uppercase;
  color: var(--accent);
  margin-bottom: .75em;
}
.muted { color: var(--muted); }
.center { text-align: center; }

/* Header */
.site-header {
  position: sticky; top: 0; z-index: 50;
  background: rgba(15,17,20,.92);
  backdrop-filter: blur(8px);
  border-bottom: 1px solid var(--line);
}
.nav { display: flex; align-items: center; justify-content: space-between; height: 64px; }
.logo {
  font-family: var(--font-head);
  font-size: 1.7rem;
  font-weight: 800;
  color: var(--text);
  letter-spacing: .02em;
  text-transform: uppercase;
}
.logo img { height: 40px; width: auto; display: block; }
.site-footer .logo img { height: 45px; }
.logo:hover { text-decoration: none; }
.nav-links { display: flex; gap: 28px; list-style: none; margin: 0; padding: 0; }
.nav-links a { color: var(--text); font-weight: 600; font-size: .95rem; }
.nav-links a:hover, .nav-links a.active { color: var(--accent); text-decoration: none; }
.nav-toggle {
  display: none; background: none; border: 1px solid var(--line);
  color: var(--text); border-radius: 8px; padding: 6px 10px; font-size: 1.2rem; cursor: pointer;
}

/* Buttons */
.btn {
  display: inline-block;
  padding: 12px 22px;
  border-radius: 8px;
  font-weight: 700;
  font-size: .95rem;
  border: 2px solid var(--accent);
  background: var(--accent);
  color: #111;
  cursor: pointer;
}
.btn:hover { background: var(--accent-2); border-color: var(--accent-2); text-decoration: none; }
.btn-ghost { background: transparent; color: var(--text); border-color: var(--line); }
.btn-ghost:hover { background: var(--bg-3); border-color: var(--accent); color: var(--text); }

/* Hero */
.hero {
  padding: 96px 0 80px;
  background:
    radial-gradient(circle at 85% 20%, rgba(227,164,1,.16), transparent 45%),
    linear-gradient(180deg, var(--bg) 0%, var(--bg-2) 100%);
  border-bottom: 1px solid var(--line);
}
.hero p.lead { font-size: 1.2rem; color: var(--muted); max-width: 640px; }
.hero-actions { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 28px; }
.hero-stats { display: flex; gap: 40px; flex-wrap: wrap; margin-top: 48px; }
.hero-stats div { font-family: var(--font-head); font-size: 2rem; font-weight: 800; color: var(--text); }
.hero-stats small { display: block; font-family: var(--font-body); font-size: .8rem; font-weight: 500; color: var(--muted); text-transform: uppercase; letter-spacing: .1em; }

/* Grids and cards */
.grid { display: grid; gap: 20px; }
.grid-2 { grid-template-columns: repeat(2, 1fr); }
.grid-3 { grid-template-columns: repeat(3, 1fr); }
.grid-4 { grid-template-columns: repeat(4, 1fr); }
.card {
  background: var(--bg-2);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 24px;
  transition: border-color .2s, transform .2s;
}
a.card { color: var(--text); display: block; }
a.card:hover { border-color: var(--accent); transform: translateY(-2px); text-decoration: none; }
.card .tag {
  display: inline-block; font-size: .7rem; font-weight: 700; text-transform: uppercase; letter-spacing: .1em;
  background: var(--bg-3); color: var(--accent); padding: 4px 8px; border-radius: 4px; margin-bottom: 12px;
}
.card h3 { margin-bottom: .3em; }
.card p { color: var(--muted); font-size: .95rem; margin: 0; }
.cat-card { text-align: center; padding: 28px 16px; }
.cat-card .icon { font-size: 2rem; margin-bottom: 8px; }
.cat-card h3 { font-size: 1.15rem; margin: 0; }

.vs {
  display: flex; align-items: center; justify-content: center; gap: 12px;
  font-family: var(--font-head); font-size: 1.2rem; font-weight: 700; text-transform: uppercase; margin: 8px 0 12px;
}
.vs b { color: var(--accent); font-size: 1rem; }

/* Steps */
.steps { counter-reset: step; }
.step { position: relative; padding-left: 64px; }
.step::before {
  counter-increment: step; content: counter(step);
  position: absolute; left: 0; top: 0; width: 44px; height: 44px; border-radius: 50%;
  background: var(--accent); color: #111; font-family: var(--font-head); font-weight: 800; font-size: 1.3rem;
  display: flex; align-items: center; justify-content: center;
}

/* Comparison table */
.table-wrap { overflow-x: auto; border: 1px solid var(--line); border-radius: var(--radius); }
table.compare { width: 100%; border-collapse: collapse; min-width: 640px; }
.compare th, .compare td { padding: 14px 16px; border-bottom: 1px solid var(--line); text-align: left; vertical-align: top; }
.compare thead th { background: var(--bg-3); font-family: var(--font-head); font-size: 1.1rem; text-transform: uppercase; }
.compare tbody th { color: var(--muted); font-weight: 600; width: 200px; }
.compare tr:last-child td, .compare tr:last-child th { border-bottom: none; }
.compare .winner { color: var(--good); font-weight: 700; }

/* Score badge */
.score {
  display: inline-flex; align-items: center; justify-content: center;
  width: 64px; height: 64px; border-radius: 12px;
  background: var(--accent); color: #111; font-family: var(--font-head); font-size: 1.8rem; font-weight: 800;
}
.score-row { display: flex; align-items: center; gap: 12px; margin: 6px 0; }
.bar { flex: 1; height: 8px; background: var(--bg-3); border-radius: 4px; overflow: hidden; }
.bar i { display: block; height: 100%; background: var(--accent); }
.score-row span { width: 150px; font-size: .9rem; color: var(--muted); }
.score-row b { width: 32px; text-align: right; }

/* Pros / cons */
.pros, .cons { list-style: none; padding: 0; margin: 0; }
.pros li, .cons li { padding-left: 26px; position: relative; margin-bottom: 8px; }
.pros li::before { content: "+"; position: absolute; left: 0; color: var(--good); font-weight: 800; }
.cons li::before { content: "-"; position: absolute; left: 4px; color: var(--bad); font-weight: 800; }

/* Article */
.article { max-width: 780px; margin: 0 auto; }
.article h2 { margin-top: 1.6em; }
.article ul { padding-left: 1.2em; }
.breadcrumb { font-size: .85rem; color: var(--muted); margin-bottom: 16px; }
.breadcrumb a { color: var(--muted); }
.disclosure-note {
  font-size: .85rem; color: var(--muted); background: var(--bg-2);
  border-left: 3px solid var(--accent); padding: 10px 14px; border-radius: 4px; margin: 0 0 24px;
}
.placeholder {
  border: 1px dashed var(--accent); color: var(--accent-2); background: rgba(227,164,1,.06);
  padding: 10px 14px; border-radius: 6px; font-size: .9rem;
}
.buy-box { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 12px; }

/* Newsletter */
.newsletter { display: flex; gap: 10px; flex-wrap: wrap; max-width: 520px; margin: 24px auto 0; }
.newsletter input {
  flex: 1; min-width: 220px; padding: 12px 14px; border-radius: 8px;
  border: 1px solid var(--line); background: var(--bg); color: var(--text); font-size: 1rem;
}

/* Footer */
.site-footer { border-top: 1px solid var(--line); padding: 48px 0 32px; background: var(--bg); }
.footer-grid { display: grid; grid-template-columns: 2fr 1fr 1fr 1fr; gap: 32px; }
.site-footer h4 { font-size: 1rem; color: var(--text); }
.site-footer ul { list-style: none; padding: 0; margin: 0; }
.site-footer li { margin-bottom: 6px; }
.site-footer a { color: var(--muted); font-size: .9rem; }
.site-footer a:hover { color: var(--accent); }
.footer-bottom { margin-top: 32px; padding-top: 20px; border-top: 1px solid var(--line); font-size: .8rem; color: var(--muted); }

/* Responsive */
@media (max-width: 900px) {
  .grid-3, .grid-4 { grid-template-columns: repeat(2, 1fr); }
  .footer-grid { grid-template-columns: 1fr 1fr; }
}
@media (max-width: 680px) {
  .nav-toggle { display: block; }
  .nav-links {
    display: none; position: absolute; top: 64px; left: 0; right: 0;
    flex-direction: column; gap: 0; background: var(--bg-2); border-bottom: 1px solid var(--line);
  }
  .nav-links.open { display: flex; }
  .nav-links li a { display: block; padding: 14px 16px; border-top: 1px solid var(--line); }
  .grid-2, .grid-3, .grid-4 { grid-template-columns: 1fr; }
  .footer-grid { grid-template-columns: 1fr; }
  .section { padding: 48px 0; }
  .hero { padding: 64px 0 56px; }
  .score-row span { width: 110px; }
}
'@

Write-BinFile 'assets\img\apple-touch-icon.png' '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'

Write-BinFile 'assets\img\favicon.png' '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'

Write-SiteFile 'assets\img\favicon.svg' @'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="1174.9 18.5 508.6 508.6"><rect x="1174.9" y="18.5" width="508.6" height="508.6" rx="91.5" fill="#111111"/><path fill="#EEEFF0" fill-rule="evenodd" d="M1573.0 63.0 1571.7 64.0 1538.3 116.3 1457.0 249.3 1457.7 250.7 1506.0 250.7 1506.7 251.3 1506.0 252.7 1426.0 345.7 1376.3 402.3 1306.7 486.7 1306.0 488.3 1313.3 483.3 1340.0 462.3 1377.0 430.7 1380.0 428.7 1393.3 430.3 1408.3 430.7 1416.3 430.3 1431.3 428.3 1445.3 425.3 1461.3 420.3 1475.0 414.3 1484.7 409.3 1498.3 400.3 1510.7 390.3 1525.0 375.3 1538.0 357.7 1544.0 347.7 1549.0 337.7 1558.7 312.0 1562.7 298.3 1567.7 277.7 1572.3 250.3 1574.0 231.3 1574.0 215.7 1573.0 204.3 1571.0 194.3 1568.0 183.3 1563.3 171.0 1557.3 159.3 1546.7 142.3 1546.3 139.7 1554.3 113.3 1562.3 89.7ZM1563.3 57.3 1561.3 58.3 1545.0 72.0 1485.7 118.7 1475.0 116.0 1463.0 114.3 1451.7 114.0 1434.0 115.3 1422.3 117.3 1406.3 121.7 1389.7 128.0 1376.0 134.7 1359.7 145.3 1348.3 154.7 1338.3 164.7 1332.7 171.3 1319.7 189.7 1314.0 200.0 1307.3 215.3 1301.7 231.7 1296.3 249.7 1290.3 275.7 1287.3 294.3 1284.7 317.0 1284.3 333.3 1285.7 348.7 1288.3 361.7 1291.7 372.3 1297.7 385.3 1305.0 396.3 1317.7 409.7 1323.7 414.7 1323.3 417.3 1301.7 473.0 1298.7 482.3 1300.0 481.3 1326.3 440.0 1416.7 293.7 1416.7 292.3 1413.7 292.0 1371.3 292.3 1364.7 292.0 1364.3 290.7 1460.7 182.3 1530.0 99.3 1559.0 63.7Z"/></svg>
'@

Write-SiteFile 'assets\img\logo-black.svg' @'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2118.0 542.3" role="img" aria-label="GigaTorq"><path fill="#000000" fill-rule="evenodd" d="M494.3 120.7 404.0 120.3 402.7 121.3 369.7 263.3 345.0 374.0 340.7 391.0 333.7 422.7 333.7 425.7 424.0 426.0 425.0 425.3 455.3 291.7 465.7 249.0 482.3 174.0 494.3 124.3ZM805.3 120.7 715.7 120.7 714.7 122.3 706.7 155.3 705.7 156.0 701.3 147.7 694.3 138.0 685.3 129.3 672.7 121.7 662.7 118.0 651.7 115.7 635.0 115.0 623.7 116.0 611.7 118.3 599.7 121.7 579.7 130.3 573.3 134.0 562.0 142.0 555.7 147.3 545.7 157.3 535.7 170.0 529.0 180.0 516.7 203.0 507.3 225.7 498.3 254.7 490.3 295.7 488.3 311.0 487.7 322.7 488.0 340.3 489.0 350.3 490.7 359.7 494.7 373.7 499.7 384.3 505.0 392.0 510.7 398.0 521.0 406.0 530.7 411.3 543.7 416.0 553.7 418.3 567.3 419.7 577.0 419.7 590.3 418.3 602.7 415.3 615.0 410.7 623.7 406.3 633.0 400.3 642.3 393.0 653.7 381.7 654.3 381.7 654.7 384.0 646.7 420.0 644.0 429.7 641.0 436.7 635.3 445.3 629.7 451.3 622.0 457.0 615.7 460.3 605.3 464.0 593.0 466.3 585.3 467.0 571.0 467.0 555.7 465.7 542.7 463.3 515.3 455.7 501.7 450.7 484.7 443.0 483.0 445.7 460.0 510.7 460.7 512.3 475.7 518.3 494.0 524.3 514.3 529.3 530.7 532.3 554.7 535.3 573.0 536.3 590.0 536.3 604.7 535.3 629.3 531.3 645.7 527.0 659.7 521.7 673.3 514.7 683.7 508.0 694.0 499.7 703.0 490.7 713.0 477.7 722.3 461.3 731.0 442.0 736.7 424.3 754.0 351.0 762.3 312.3 787.0 206.0 805.3 124.3ZM665.0 190.7 672.7 195.0 677.3 199.7 679.7 203.0 682.3 208.3 684.0 213.7 685.7 225.3 685.0 242.3 682.0 263.7 677.0 285.0 672.3 298.7 664.3 315.7 660.0 322.3 653.7 330.0 645.0 337.3 635.3 342.7 625.3 345.7 614.3 346.3 605.0 344.7 600.0 342.3 596.7 340.0 592.0 335.3 589.7 332.0 586.7 324.7 585.0 314.3 585.3 300.3 588.0 283.7 595.3 254.0 601.0 237.3 605.0 228.0 612.3 214.3 619.3 205.0 627.7 197.3 636.0 192.7 646.3 189.3 658.3 189.0ZM351.3 120.7 263.3 120.3 262.0 121.3 254.0 155.3 252.7 156.0 247.7 147.0 241.0 138.0 231.0 128.7 219.7 121.7 210.7 118.3 195.0 115.3 183.7 115.0 168.0 116.3 155.0 119.0 144.7 122.0 134.0 126.3 125.3 130.7 115.3 137.0 106.0 144.3 90.0 160.0 81.7 170.3 73.7 182.3 66.3 195.3 60.3 207.7 55.0 220.7 49.3 237.3 40.0 273.7 37.0 288.7 34.3 307.3 33.7 316.7 33.7 337.7 34.7 349.0 36.3 358.7 42.3 377.0 46.0 384.0 51.0 391.0 59.3 399.7 64.0 403.3 73.3 409.0 83.0 413.3 92.3 416.3 101.7 418.3 111.0 419.3 128.0 419.0 139.3 417.3 156.0 412.3 166.0 407.7 177.3 400.3 187.3 392.3 197.7 381.7 198.7 381.3 199.0 384.0 195.3 401.7 186.3 433.3 183.3 440.0 176.7 449.3 169.3 455.7 161.0 460.3 152.0 463.7 143.0 465.7 129.3 467.0 112.7 466.7 94.3 464.3 82.0 461.7 66.3 457.3 48.3 451.0 31.7 443.3 30.3 443.3 6.3 508.7 6.0 511.7 15.3 515.7 39.0 523.7 55.7 528.0 72.7 531.3 94.0 534.3 116.0 536.0 137.7 536.0 148.0 535.3 164.0 533.3 182.0 529.7 189.3 527.7 204.0 522.3 216.0 516.3 228.7 508.3 241.3 497.7 248.0 490.7 256.0 480.7 266.7 463.0 276.0 442.0 282.0 423.3 308.7 307.3 315.0 282.0 339.0 175.3 351.7 122.7ZM210.7 190.3 215.3 192.7 219.0 195.3 224.3 201.3 228.7 209.7 231.0 220.0 231.0 235.0 228.3 255.0 223.3 278.7 217.3 296.7 212.7 307.7 205.3 320.7 198.3 329.7 189.7 337.3 180.7 342.3 170.0 345.3 158.7 345.7 150.7 344.0 143.0 339.7 137.0 333.0 133.3 324.7 132.0 318.7 131.3 311.0 132.0 296.3 135.0 279.0 140.0 257.7 146.0 238.3 151.0 226.3 157.7 214.7 163.3 207.0 174.3 196.7 182.3 192.0 192.0 189.0 200.7 188.3ZM1918.7 117.3 1903.0 121.7 1888.0 128.7 1874.7 136.7 1862.0 146.3 1850.7 157.3 1844.3 164.7 1832.7 181.0 1824.7 195.3 1813.7 222.0 1804.3 252.0 1799.0 274.7 1793.3 303.0 1790.3 325.0 1790.0 339.7 1791.3 359.0 1794.0 373.3 1797.0 383.0 1801.7 392.7 1808.7 402.3 1817.3 411.3 1827.3 419.0 1839.3 425.3 1852.3 429.3 1863.0 431.0 1880.3 431.3 1889.0 430.3 1903.7 427.3 1914.0 423.7 1923.7 418.7 1934.0 411.3 1946.0 400.0 1954.7 389.7 1955.7 389.7 1956.0 391.0 1946.0 436.7 1937.0 474.0 1924.3 531.0 1925.3 531.7 2018.0 531.3 2052.0 382.7 2058.0 359.0 2068.0 311.7 2085.0 240.7 2112.0 121.0 2111.3 120.3 2023.7 120.3 2022.3 122.3 2015.3 154.0 2014.3 154.7 2006.3 143.0 1998.7 134.7 1986.3 125.0 1975.7 119.7 1961.3 115.7 1948.0 114.3 1931.7 115.0ZM1966.0 189.3 1971.3 191.3 1975.7 194.0 1982.7 201.0 1986.0 206.0 1989.0 212.7 1991.0 222.3 1991.0 233.7 1988.3 252.0 1980.3 285.3 1974.3 304.7 1967.0 321.0 1962.0 329.0 1954.3 338.3 1947.3 344.7 1941.3 348.7 1936.0 351.3 1928.0 354.0 1919.3 355.0 1913.7 354.3 1908.0 352.7 1903.7 350.7 1899.3 347.7 1895.0 343.3 1892.7 340.0 1889.7 332.7 1888.0 322.3 1888.7 306.3 1892.3 286.0 1897.3 265.0 1906.0 236.3 1912.0 222.0 1918.3 211.3 1924.3 204.0 1933.0 196.3 1939.3 192.3 1948.7 189.0 1960.3 188.3ZM1820.0 115.0 1813.3 114.0 1805.3 114.0 1790.3 115.7 1778.0 118.7 1762.7 124.7 1746.3 134.0 1734.0 143.3 1721.7 155.3 1713.0 165.7 1712.7 163.3 1718.7 137.7 1721.7 122.7 1721.3 120.7 1639.0 120.3 1637.7 121.0 1626.7 165.7 1626.3 169.0 1613.3 224.0 1602.3 274.0 1593.3 311.3 1573.3 401.0 1567.7 424.0 1568.0 425.7 1660.0 426.0 1661.3 425.3 1672.0 374.7 1692.0 286.3 1698.0 262.3 1703.0 249.3 1710.0 237.3 1717.3 229.0 1723.7 223.0 1731.3 217.0 1744.3 209.7 1755.7 206.0 1772.7 203.3 1786.3 203.3 1795.0 204.3 1800.7 205.7 1802.3 205.0 1810.0 165.3 1820.7 117.7 1820.7 115.7ZM1047.7 134.7 1037.3 128.0 1027.3 123.0 1016.0 119.0 1002.3 115.7 979.3 113.3 959.0 113.3 942.3 114.7 928.3 117.0 915.3 120.0 903.7 123.7 891.0 129.0 880.3 134.7 867.3 143.7 853.3 157.3 842.7 172.0 835.0 186.7 829.7 201.7 827.7 212.3 828.3 213.0 912.0 213.0 913.0 212.0 915.7 204.0 919.7 196.7 923.0 192.3 929.0 187.0 937.0 182.7 944.7 180.3 950.3 179.7 959.7 179.7 967.0 181.0 973.0 183.7 978.0 188.3 979.7 190.7 982.3 197.0 983.3 203.0 982.0 216.7 978.3 233.0 976.7 235.0 955.3 235.7 925.7 238.7 901.7 243.0 876.0 249.7 859.7 255.7 849.3 260.3 839.0 266.0 823.0 277.7 810.3 290.3 801.0 303.0 795.3 313.7 791.7 322.7 787.0 339.7 785.7 348.7 785.0 359.7 785.3 370.0 786.3 378.3 789.7 391.3 792.3 397.7 797.7 406.3 806.3 415.7 812.7 420.3 820.0 424.3 829.7 428.0 838.7 430.3 853.3 432.0 864.7 432.0 877.3 431.0 895.7 427.3 912.7 421.3 924.3 415.3 934.3 409.0 942.0 403.0 949.0 396.0 949.7 396.0 950.3 397.3 949.0 404.3 948.0 418.0 948.0 425.0 949.3 426.0 1037.7 425.7 1038.0 424.3 1036.3 417.7 1035.0 407.0 1035.0 400.0 1036.0 391.3 1056.3 298.0 1069.0 244.0 1072.0 227.7 1074.7 204.3 1074.3 182.3 1073.0 174.7 1070.3 165.3 1066.0 155.7 1062.0 149.3 1057.3 143.7ZM968.7 287.7 969.0 289.0 964.7 312.0 962.0 322.0 959.3 329.0 951.3 343.0 947.0 348.7 941.7 354.0 934.7 359.0 927.7 362.7 921.0 365.0 912.3 366.7 901.3 366.7 893.3 365.0 888.7 363.0 883.3 358.3 880.3 353.3 878.7 347.7 878.3 337.0 880.7 327.7 884.3 320.0 889.3 313.3 893.7 309.0 900.3 304.0 910.3 298.7 926.3 293.3 948.3 289.0 963.7 287.3ZM1573.0 63.0 1571.7 64.0 1538.3 116.3 1457.0 249.3 1457.7 250.7 1506.0 250.7 1506.7 251.3 1506.0 252.7 1426.0 345.7 1376.3 402.3 1306.7 486.7 1306.0 488.3 1313.3 483.3 1340.0 462.3 1377.0 430.7 1380.0 428.7 1393.3 430.3 1408.3 430.7 1416.3 430.3 1431.3 428.3 1445.3 425.3 1461.3 420.3 1475.0 414.3 1484.7 409.3 1498.3 400.3 1510.7 390.3 1525.0 375.3 1538.0 357.7 1544.0 347.7 1549.0 337.7 1558.7 312.0 1562.7 298.3 1567.7 277.7 1572.3 250.3 1574.0 231.3 1574.0 215.7 1573.0 204.3 1571.0 194.3 1568.0 183.3 1563.3 171.0 1557.3 159.3 1546.7 142.3 1546.3 139.7 1554.3 113.3 1562.3 89.7ZM1563.3 57.3 1561.3 58.3 1545.0 72.0 1485.7 118.7 1475.0 116.0 1463.0 114.3 1451.7 114.0 1434.0 115.3 1422.3 117.3 1406.3 121.7 1389.7 128.0 1376.0 134.7 1359.7 145.3 1348.3 154.7 1338.3 164.7 1332.7 171.3 1319.7 189.7 1314.0 200.0 1307.3 215.3 1301.7 231.7 1296.3 249.7 1290.3 275.7 1287.3 294.3 1284.7 317.0 1284.3 333.3 1285.7 348.7 1288.3 361.7 1291.7 372.3 1297.7 385.3 1305.0 396.3 1317.7 409.7 1323.7 414.7 1323.3 417.3 1301.7 473.0 1298.7 482.3 1300.0 481.3 1326.3 440.0 1416.7 293.7 1416.7 292.3 1413.7 292.0 1371.3 292.3 1364.7 292.0 1364.3 290.7 1460.7 182.3 1530.0 99.3 1559.0 63.7ZM1267.0 41.0 1177.3 41.7 1158.0 119.3 1157.0 120.3 1116.3 120.3 1115.3 120.7 1114.7 122.0 1099.7 187.0 1100.3 188.0 1140.7 188.0 1142.0 189.0 1142.0 190.7 1123.7 271.7 1112.3 315.3 1106.3 342.3 1104.0 361.3 1103.7 369.0 1104.3 379.7 1106.3 389.0 1108.3 394.7 1110.7 399.3 1116.3 407.0 1122.0 412.3 1130.3 418.0 1141.3 423.3 1150.0 426.3 1163.0 429.3 1173.0 430.7 1197.7 431.0 1214.0 429.3 1228.3 426.7 1243.0 422.7 1244.0 421.0 1246.0 406.7 1254.7 363.7 1255.7 356.3 1255.0 355.7 1235.0 357.3 1224.0 357.3 1217.3 356.7 1211.0 355.0 1207.3 353.0 1204.0 349.7 1202.0 344.7 1201.7 336.3 1204.3 319.7 1234.0 189.0 1235.3 188.0 1293.0 188.0 1293.7 187.3 1308.0 121.0 1307.3 120.3 1251.7 120.3 1251.0 119.7 1251.0 117.7 1261.3 70.0 1268.0 43.3 1268.0 41.7ZM428.3 6.3 426.7 11.3 409.3 84.0 410.0 84.7 502.7 84.7 503.3 84.0 510.0 54.7 521.7 8.7 521.7 6.3Z"/></svg>
'@

Write-SiteFile 'assets\img\logo.svg' @'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2118.0 542.3" role="img" aria-label="GigaTorq"><path fill="#EEEFF0" fill-rule="evenodd" d="M494.3 120.7 404.0 120.3 402.7 121.3 369.7 263.3 345.0 374.0 340.7 391.0 333.7 422.7 333.7 425.7 424.0 426.0 425.0 425.3 455.3 291.7 465.7 249.0 482.3 174.0 494.3 124.3ZM805.3 120.7 715.7 120.7 714.7 122.3 706.7 155.3 705.7 156.0 701.3 147.7 694.3 138.0 685.3 129.3 672.7 121.7 662.7 118.0 651.7 115.7 635.0 115.0 623.7 116.0 611.7 118.3 599.7 121.7 579.7 130.3 573.3 134.0 562.0 142.0 555.7 147.3 545.7 157.3 535.7 170.0 529.0 180.0 516.7 203.0 507.3 225.7 498.3 254.7 490.3 295.7 488.3 311.0 487.7 322.7 488.0 340.3 489.0 350.3 490.7 359.7 494.7 373.7 499.7 384.3 505.0 392.0 510.7 398.0 521.0 406.0 530.7 411.3 543.7 416.0 553.7 418.3 567.3 419.7 577.0 419.7 590.3 418.3 602.7 415.3 615.0 410.7 623.7 406.3 633.0 400.3 642.3 393.0 653.7 381.7 654.3 381.7 654.7 384.0 646.7 420.0 644.0 429.7 641.0 436.7 635.3 445.3 629.7 451.3 622.0 457.0 615.7 460.3 605.3 464.0 593.0 466.3 585.3 467.0 571.0 467.0 555.7 465.7 542.7 463.3 515.3 455.7 501.7 450.7 484.7 443.0 483.0 445.7 460.0 510.7 460.7 512.3 475.7 518.3 494.0 524.3 514.3 529.3 530.7 532.3 554.7 535.3 573.0 536.3 590.0 536.3 604.7 535.3 629.3 531.3 645.7 527.0 659.7 521.7 673.3 514.7 683.7 508.0 694.0 499.7 703.0 490.7 713.0 477.7 722.3 461.3 731.0 442.0 736.7 424.3 754.0 351.0 762.3 312.3 787.0 206.0 805.3 124.3ZM665.0 190.7 672.7 195.0 677.3 199.7 679.7 203.0 682.3 208.3 684.0 213.7 685.7 225.3 685.0 242.3 682.0 263.7 677.0 285.0 672.3 298.7 664.3 315.7 660.0 322.3 653.7 330.0 645.0 337.3 635.3 342.7 625.3 345.7 614.3 346.3 605.0 344.7 600.0 342.3 596.7 340.0 592.0 335.3 589.7 332.0 586.7 324.7 585.0 314.3 585.3 300.3 588.0 283.7 595.3 254.0 601.0 237.3 605.0 228.0 612.3 214.3 619.3 205.0 627.7 197.3 636.0 192.7 646.3 189.3 658.3 189.0ZM351.3 120.7 263.3 120.3 262.0 121.3 254.0 155.3 252.7 156.0 247.7 147.0 241.0 138.0 231.0 128.7 219.7 121.7 210.7 118.3 195.0 115.3 183.7 115.0 168.0 116.3 155.0 119.0 144.7 122.0 134.0 126.3 125.3 130.7 115.3 137.0 106.0 144.3 90.0 160.0 81.7 170.3 73.7 182.3 66.3 195.3 60.3 207.7 55.0 220.7 49.3 237.3 40.0 273.7 37.0 288.7 34.3 307.3 33.7 316.7 33.7 337.7 34.7 349.0 36.3 358.7 42.3 377.0 46.0 384.0 51.0 391.0 59.3 399.7 64.0 403.3 73.3 409.0 83.0 413.3 92.3 416.3 101.7 418.3 111.0 419.3 128.0 419.0 139.3 417.3 156.0 412.3 166.0 407.7 177.3 400.3 187.3 392.3 197.7 381.7 198.7 381.3 199.0 384.0 195.3 401.7 186.3 433.3 183.3 440.0 176.7 449.3 169.3 455.7 161.0 460.3 152.0 463.7 143.0 465.7 129.3 467.0 112.7 466.7 94.3 464.3 82.0 461.7 66.3 457.3 48.3 451.0 31.7 443.3 30.3 443.3 6.3 508.7 6.0 511.7 15.3 515.7 39.0 523.7 55.7 528.0 72.7 531.3 94.0 534.3 116.0 536.0 137.7 536.0 148.0 535.3 164.0 533.3 182.0 529.7 189.3 527.7 204.0 522.3 216.0 516.3 228.7 508.3 241.3 497.7 248.0 490.7 256.0 480.7 266.7 463.0 276.0 442.0 282.0 423.3 308.7 307.3 315.0 282.0 339.0 175.3 351.7 122.7ZM210.7 190.3 215.3 192.7 219.0 195.3 224.3 201.3 228.7 209.7 231.0 220.0 231.0 235.0 228.3 255.0 223.3 278.7 217.3 296.7 212.7 307.7 205.3 320.7 198.3 329.7 189.7 337.3 180.7 342.3 170.0 345.3 158.7 345.7 150.7 344.0 143.0 339.7 137.0 333.0 133.3 324.7 132.0 318.7 131.3 311.0 132.0 296.3 135.0 279.0 140.0 257.7 146.0 238.3 151.0 226.3 157.7 214.7 163.3 207.0 174.3 196.7 182.3 192.0 192.0 189.0 200.7 188.3ZM1918.7 117.3 1903.0 121.7 1888.0 128.7 1874.7 136.7 1862.0 146.3 1850.7 157.3 1844.3 164.7 1832.7 181.0 1824.7 195.3 1813.7 222.0 1804.3 252.0 1799.0 274.7 1793.3 303.0 1790.3 325.0 1790.0 339.7 1791.3 359.0 1794.0 373.3 1797.0 383.0 1801.7 392.7 1808.7 402.3 1817.3 411.3 1827.3 419.0 1839.3 425.3 1852.3 429.3 1863.0 431.0 1880.3 431.3 1889.0 430.3 1903.7 427.3 1914.0 423.7 1923.7 418.7 1934.0 411.3 1946.0 400.0 1954.7 389.7 1955.7 389.7 1956.0 391.0 1946.0 436.7 1937.0 474.0 1924.3 531.0 1925.3 531.7 2018.0 531.3 2052.0 382.7 2058.0 359.0 2068.0 311.7 2085.0 240.7 2112.0 121.0 2111.3 120.3 2023.7 120.3 2022.3 122.3 2015.3 154.0 2014.3 154.7 2006.3 143.0 1998.7 134.7 1986.3 125.0 1975.7 119.7 1961.3 115.7 1948.0 114.3 1931.7 115.0ZM1966.0 189.3 1971.3 191.3 1975.7 194.0 1982.7 201.0 1986.0 206.0 1989.0 212.7 1991.0 222.3 1991.0 233.7 1988.3 252.0 1980.3 285.3 1974.3 304.7 1967.0 321.0 1962.0 329.0 1954.3 338.3 1947.3 344.7 1941.3 348.7 1936.0 351.3 1928.0 354.0 1919.3 355.0 1913.7 354.3 1908.0 352.7 1903.7 350.7 1899.3 347.7 1895.0 343.3 1892.7 340.0 1889.7 332.7 1888.0 322.3 1888.7 306.3 1892.3 286.0 1897.3 265.0 1906.0 236.3 1912.0 222.0 1918.3 211.3 1924.3 204.0 1933.0 196.3 1939.3 192.3 1948.7 189.0 1960.3 188.3ZM1820.0 115.0 1813.3 114.0 1805.3 114.0 1790.3 115.7 1778.0 118.7 1762.7 124.7 1746.3 134.0 1734.0 143.3 1721.7 155.3 1713.0 165.7 1712.7 163.3 1718.7 137.7 1721.7 122.7 1721.3 120.7 1639.0 120.3 1637.7 121.0 1626.7 165.7 1626.3 169.0 1613.3 224.0 1602.3 274.0 1593.3 311.3 1573.3 401.0 1567.7 424.0 1568.0 425.7 1660.0 426.0 1661.3 425.3 1672.0 374.7 1692.0 286.3 1698.0 262.3 1703.0 249.3 1710.0 237.3 1717.3 229.0 1723.7 223.0 1731.3 217.0 1744.3 209.7 1755.7 206.0 1772.7 203.3 1786.3 203.3 1795.0 204.3 1800.7 205.7 1802.3 205.0 1810.0 165.3 1820.7 117.7 1820.7 115.7ZM1047.7 134.7 1037.3 128.0 1027.3 123.0 1016.0 119.0 1002.3 115.7 979.3 113.3 959.0 113.3 942.3 114.7 928.3 117.0 915.3 120.0 903.7 123.7 891.0 129.0 880.3 134.7 867.3 143.7 853.3 157.3 842.7 172.0 835.0 186.7 829.7 201.7 827.7 212.3 828.3 213.0 912.0 213.0 913.0 212.0 915.7 204.0 919.7 196.7 923.0 192.3 929.0 187.0 937.0 182.7 944.7 180.3 950.3 179.7 959.7 179.7 967.0 181.0 973.0 183.7 978.0 188.3 979.7 190.7 982.3 197.0 983.3 203.0 982.0 216.7 978.3 233.0 976.7 235.0 955.3 235.7 925.7 238.7 901.7 243.0 876.0 249.7 859.7 255.7 849.3 260.3 839.0 266.0 823.0 277.7 810.3 290.3 801.0 303.0 795.3 313.7 791.7 322.7 787.0 339.7 785.7 348.7 785.0 359.7 785.3 370.0 786.3 378.3 789.7 391.3 792.3 397.7 797.7 406.3 806.3 415.7 812.7 420.3 820.0 424.3 829.7 428.0 838.7 430.3 853.3 432.0 864.7 432.0 877.3 431.0 895.7 427.3 912.7 421.3 924.3 415.3 934.3 409.0 942.0 403.0 949.0 396.0 949.7 396.0 950.3 397.3 949.0 404.3 948.0 418.0 948.0 425.0 949.3 426.0 1037.7 425.7 1038.0 424.3 1036.3 417.7 1035.0 407.0 1035.0 400.0 1036.0 391.3 1056.3 298.0 1069.0 244.0 1072.0 227.7 1074.7 204.3 1074.3 182.3 1073.0 174.7 1070.3 165.3 1066.0 155.7 1062.0 149.3 1057.3 143.7ZM968.7 287.7 969.0 289.0 964.7 312.0 962.0 322.0 959.3 329.0 951.3 343.0 947.0 348.7 941.7 354.0 934.7 359.0 927.7 362.7 921.0 365.0 912.3 366.7 901.3 366.7 893.3 365.0 888.7 363.0 883.3 358.3 880.3 353.3 878.7 347.7 878.3 337.0 880.7 327.7 884.3 320.0 889.3 313.3 893.7 309.0 900.3 304.0 910.3 298.7 926.3 293.3 948.3 289.0 963.7 287.3ZM1573.0 63.0 1571.7 64.0 1538.3 116.3 1457.0 249.3 1457.7 250.7 1506.0 250.7 1506.7 251.3 1506.0 252.7 1426.0 345.7 1376.3 402.3 1306.7 486.7 1306.0 488.3 1313.3 483.3 1340.0 462.3 1377.0 430.7 1380.0 428.7 1393.3 430.3 1408.3 430.7 1416.3 430.3 1431.3 428.3 1445.3 425.3 1461.3 420.3 1475.0 414.3 1484.7 409.3 1498.3 400.3 1510.7 390.3 1525.0 375.3 1538.0 357.7 1544.0 347.7 1549.0 337.7 1558.7 312.0 1562.7 298.3 1567.7 277.7 1572.3 250.3 1574.0 231.3 1574.0 215.7 1573.0 204.3 1571.0 194.3 1568.0 183.3 1563.3 171.0 1557.3 159.3 1546.7 142.3 1546.3 139.7 1554.3 113.3 1562.3 89.7ZM1563.3 57.3 1561.3 58.3 1545.0 72.0 1485.7 118.7 1475.0 116.0 1463.0 114.3 1451.7 114.0 1434.0 115.3 1422.3 117.3 1406.3 121.7 1389.7 128.0 1376.0 134.7 1359.7 145.3 1348.3 154.7 1338.3 164.7 1332.7 171.3 1319.7 189.7 1314.0 200.0 1307.3 215.3 1301.7 231.7 1296.3 249.7 1290.3 275.7 1287.3 294.3 1284.7 317.0 1284.3 333.3 1285.7 348.7 1288.3 361.7 1291.7 372.3 1297.7 385.3 1305.0 396.3 1317.7 409.7 1323.7 414.7 1323.3 417.3 1301.7 473.0 1298.7 482.3 1300.0 481.3 1326.3 440.0 1416.7 293.7 1416.7 292.3 1413.7 292.0 1371.3 292.3 1364.7 292.0 1364.3 290.7 1460.7 182.3 1530.0 99.3 1559.0 63.7ZM1267.0 41.0 1177.3 41.7 1158.0 119.3 1157.0 120.3 1116.3 120.3 1115.3 120.7 1114.7 122.0 1099.7 187.0 1100.3 188.0 1140.7 188.0 1142.0 189.0 1142.0 190.7 1123.7 271.7 1112.3 315.3 1106.3 342.3 1104.0 361.3 1103.7 369.0 1104.3 379.7 1106.3 389.0 1108.3 394.7 1110.7 399.3 1116.3 407.0 1122.0 412.3 1130.3 418.0 1141.3 423.3 1150.0 426.3 1163.0 429.3 1173.0 430.7 1197.7 431.0 1214.0 429.3 1228.3 426.7 1243.0 422.7 1244.0 421.0 1246.0 406.7 1254.7 363.7 1255.7 356.3 1255.0 355.7 1235.0 357.3 1224.0 357.3 1217.3 356.7 1211.0 355.0 1207.3 353.0 1204.0 349.7 1202.0 344.7 1201.7 336.3 1204.3 319.7 1234.0 189.0 1235.3 188.0 1293.0 188.0 1293.7 187.3 1308.0 121.0 1307.3 120.3 1251.7 120.3 1251.0 119.7 1251.0 117.7 1261.3 70.0 1268.0 43.3 1268.0 41.7ZM428.3 6.3 426.7 11.3 409.3 84.0 410.0 84.7 502.7 84.7 503.3 84.0 510.0 54.7 521.7 8.7 521.7 6.3Z"/></svg>
'@

Write-BinFile 'assets\img\og-image.png' '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J06YIIYKu69f72JRolWr/hG4xBMHCCW68GZC3Hx19uxZd865qa8d9OWXYoWdO3aMHzfusZfVb9Cgd2+HVhH1i4qKUrcka4/eBQYZeF8Sz1TitdzEiROuXLkiCdzy5ctMLXVavl0IvoFAaGs3b958tXOn06dPSwKhllZebvtSzNto9oCATJkyiV6RR4+eOHFC3BBUrlyiRIlELzXq8tD22kOHDvX/4H1JUD7s3//777+L+dhI5QaXAyHnZ1zmudi28NdfJaHZHOHuzsDvvvvWhcJIj+r3fr/HXhMSUn7UqNHilQ4cOPBc0yaWT7cFBhp4X7p48eL+/fvF66npjIS+SLh+/brOnToZibV37tzZYMUrF76HQGh36gbw4gst1TuseL1p075v1erF+42/yppYZ3O/c0M5My3pPbhFZNasWWrBTRICNZevbsPqiXT/ESPfDjUaEJcsXbo0QbxUvZAlhR9jtWjRQklotmx1saLMg3r1ek/cM+Onnx4bpQoWLDghejHfC61cubJx40b79u0TqwUFGXhfiohIMG3fR44coeYiJWFS08rqNhQQkEP/jLayc+cON6viwVcRCCHqftayxfPePNBUIbDb66+phR21pHn/wdKlE2QgNLJH0dOHyNWC2xdffC7eTS2TNmxQ/8FihmqpVv+uY3dWa2/duvXzzJmS8Kkh0bChDjWds4R6Azl//rx4hhqYLlq0SBKUiHALhv5qMvHjjz4SV505c2bgwC/ivyZLliyTp0zxT5tWvMzdu3e//np0+3avXIqKEqulSJGiRIkSop0Lla5MUZFGDQm8vCBqrK5evdqufTu1GGtkc4rc22bFAULEjkCIe1QmfKFli+PHvbGn1p49e5o0brR48eKHHi9T1kAgdL8lfRkzC5se3yIyccKEXu/1FG/1w/Tp9evXO3LkyIMPFitWLGXKlKLXeveeQpMmTUy4zdBjREZGvvBCyz179LW98fQ7m1qvkATFkhVCid44OmTwYHHJwC8eU+A3TZo0U6ZOzZEjp3gZNabv1LHj0K++Es9Qc52JExsYm3l/RZkHbd26ddTIkZKgqHmEt958c090xy8jbUXEiklt+CoCIf5j7969av1klZf1OpsyZXKjZxvGuidH/wrhtWvXduxwq45c0aLF/P39Ra9z585Z1Rorfr/88kvjRs+6ecbScmrQ+VrXLh/EdtDRyL4sN89vqHUVq+p5GHEvDUZ37i5RsqTo4uniDbt37fJcPLDc6dOnHanq6aAxY74ZNcrpcfnG0NDZs2fFc4FKRN+MGVusWHHxMuHh4epG+ccfK8RjTK0dJYiKMg8aPXqUJ6pne07PHj3ub1ExckxUqCiDuBEI8f9Ucmj7UpsBAz71hhJe0QPHlgM+/TTW/e6BQUGpUqUSvdRQ3s2OzEHlDOwX1bA8eN+WLVvUaMl72hypCY66dWovWbIk1s8a+XasXbNG3DN9+rSdOywrcK/T9u3bYtKg+rhIkSKii+WN1B/19dejV69eLQnBZquPig0fNmzsmDFOfcljzx/2//DDqlWrije5devWiBHDn2/e7MCBA+JJ5UPKi3aRR48mxK42nTt19PS3wxI3b97s2KHDnDmzY36ZNGnSkhpnxO5TY7zDhw8LEBsCIR42ZfLkOnVq//XXX2LO9GnTnq5bJ57aGzVr1hTt3K+qZ2RSUHNJsbNnz6ox04Tx48XokWa+AAAQAElEQVQotTD4yccfqwmOeEY5+jftHDly5OTJk+K297x4d25cZvz0U8MGDe4Xd8mSJav4lnffeVuNt8Trbd5ife/QwYMHTZo40cGLVXiOvxDLi61aeVvLwf379zdt0njkiBG3b98WT0qUKFFIeQOBMDzhVJR5kLrdqDmmh84CeJvLly+/8nLbB1eVS5UunSxZMtFunXtNs+DbCISIxfFjx9q98vIbb3SL9FhpvrioWfaWLVr07/9B/KuU1avXEO3c32tRrlywaLdpo4FNNQMHfvFktaq/LligYXHmISoBDh40qFrVKt9+OzWeyzJkyJAnTx7Ry/0zqDHUSmy3bq/r/7t1zbVr13p079637//0kdPZdzutlqokKuqrCQjvz4T793mktcDnn382deqUx16m7ilfj46vh0TFihUHDPhMvIZ6lX333bcN6tfT03CyePHifn5+ol0CqijzEPWG37Jli8jISPFKampSRdY1/7sxpGxZAy2Uhf2iiBeBEHFatHBh9epPvv5a17Vr3d3k9ljqprtkyZImjRu1ad3qsYNmNZQ0st3CzeMK6dOn159AlM2bzUz9qrWgt95689mGDVb++adosXPHjg/796/+ZLWxY8c8tvKKkQOEa9euFYssXrRILYGK11NTPHVq176/V+o+9XIQXXLkyCFaqMzQ7Lmm+ufRnHLosKfq9X/6ySePra/Tt1/feKre58yZ85sxY8VrqLuSegf7+KOPtFXqL29ieVDuVZRJYAcIH6SmsF98oaUXZsJjx44937zZo1MJgWVNHSCkxCjilFSAuN25c+e3aIWLFGndunWjRo0tn2tfv37dn3/8+dtvix0/CVCrVi3RTr2n32+B6Jrg4BDRToVYs02Htm/f3r59u2zZsjVt+lzjJk0KFy4sVrtw4cKCBfN/njlTrZs5/lVmGkJaWuFNLVxkyZrltddeF6+kpsYHfPrJrFmx1w7RuQySNGnSrFmzWrJZ97EOHjzYvHmzLwZ+Wb16dfFKBz155mrE8OFqXD5wYOx1jxYuXPh33IcR0qRJM3HS5HTp0olpt2/f/vXXBaNHjfJEj8H4la9QUbRTN/rw8IS6QhjjyJEjDRvUHzlqtPccPVVzYW90ez3WLQNGDo/cunUrQcd+eBqBEA7ZtXOnWnv5bMCAuk8/3axZc/We605dbDWDvnLlyr/+Wvnv6tUu9HGqUdNAIHR/s5+Re8BG76gxfeLECbVqp36opV01rVCjZs0CBQqIe9SzSM13rlixYt68ueI8/RVl1Mhgz549YqmvhgxJlzZd6zZtxMvMnj1r4BdfnDlzJtbPqngmegXkyKEnEEr0s719u1caN27yQf/+GTJkEG+iUrqnN7WqqZmyZcq+8OKLDz2uJtQ+G/BpPF84avTXhQoVEqPU7NKMn3767vvvjhlabjKyQrhn9+5r165JAqe+dy+3femNN9588623jPTtuE9Fr6FDvxo3Nva1bvWeEKBrz8KDIsLDPX0CFgkagRBOuHHjxq8LFqgfana/WLHiivqpYMGCuXPnzpQpUzxfqJbX1MT5vn179+7Zu237tt27dokbqlWrJtq5X5qlXLCJJSkvOzOwJdrnn3+mnjAhISHlK1RQz6IsWbKqX8bfkOPKlStnz549cfz4zp07V69ZHbphg5v9LUqVKi16rV9vzQHCh/Tv/4GaXhnw2Wf6U1as5s+bN2LE8PgX/PU3X8mbJ2+Y3gr1ap5i5co/3323u1fFdT0daIrH1lddTV7E85rt3buP2TXVnTt2qBw4Z/Zsg1sqihQpqnMr9X1hCXx58EGjRo1cu3atmn008jcp0TOVXbt2iWe7SoUKFcQE9osifgRCuOLSpUvr1697sApoypQpc+XOrRYrbty4fu369WtXr6rb6tXon629v5YvX8HImXv330xLliwl2nltF1q1dhSzG/nBBwMCcmTKlDF16tT3H7lx8+aZ06fVxW7u131IqVKl9LekX7fOsgOED1m+fNm6det69uxpMHvcuXNn0cKFKgo6sssucZIkopeaepg7d47odf78eRXXR48e1anzqy+88MKDT2xTNBSdz5cvX+nSD8+2qLj1/fffxfUlajW1U+fOYoJ6Y1m69PdZv/zy77//imlqjkxMSLgVZWKl3mmfqlXztde7dejQQTQ6ffr0+PHjpk+bFv9ya2CggXZHQkUZPA6BENZQ74Burvs5yEjDiePHj7u5g6hQ4cL6GyceOXIkYbWWiow8qn6I5z35pIG1iA2eWSGMERV1UWWPb7+d2u/9DzSvtGzdunXhwl/nz5/v+Gvk7p07olc1cyeLTp48+dmAT0ePGtm586utW7f211Ly9FFqjX3NmtVjx3wjHhbrrETv3r3uxPFNLxsYOHTYMNHr4sWLK1YsX7xosVrFvXnzpniH8obWjnzvaJmai/n8swFTpkzu3r27mm7w9A5StSo4fvz4GTN+unHjxmMvNlVi1MKSZvBJBEIkMDVq1BDtli9bJu5JltTAa+2fv/8WxEb/5rSoqKjNm63v//aQvXv3tm/3SsWKFV944cU6det6dBVU/bcWzJ+/YMF8FxpDnzt3To3I02qMRkYO7TzowoULgwcPGjlyRIMGDVu1bq3tRLGK63//9dfff//1UOF7z2nSpOlDj6i1wYg42txlDwiYMMHRBobuO3PmzD///L3w14VqUV28Tw4Tz1I1YaGno4Z+aoqqR/fuE8ZP6NGzR61aT4nV1Lv6smVL582d+7czt9pgE+vAhw8fViFZgLgl8rYj70A8nnjiiVX/rhbt2r7UZtWqVQKfoHLIpjDdW6TmzJmthiaiUerUqevUqdv0uecsPHOrVpk2b45Yv37970uWqKQhcFWhwoXV9yUwMEhRb2tinUuXLm3btjU8LDw8InztmjVnz54VjerVrz969NcPPnLq1KnaT9WKtQ2MmrCYNXt20aLFxGNUDg8LU38XYZuUjZvUQrrAlvz90z711FNPP/OMet25uVsn/J6wf/7+x4VphVKlSs2dN1+0mzt3Tvd33xUgbqwQIiGp9ZT1k3yPpZYySIO+xBNTxY/12+LfRC8V3ubNmxtTgrVy5cqVKlcODg7Oly9/lixZnPr3qKnlTRs33htObwx1qrEH4rF7167oPfaTJProbNnAsiWKl8iZM6cKhzly5syePbuD/x713Tl2LPL4seORkZFqzVal9J07d4g5zz/f4qFHBgz4NK6moEOHDY8nDYZu2DBmzBh/f/9MmTJmyJgxa9ZsmaNLT6VOkyZlNDXlEfPBuRhnz548derwoUMnT56I/K+46tzCbtRcgApF6keKFCmqV69evkKFQoUKFypUKFu2bPF/oXoKHdi/f+u2rdu3b98cEaF+FjcYO0AYSkUZPAaBEAmJkf2iS5f+LvAhrVq1Er0uX778999/iTn/Rov5WA2gc+bKlS1r1oCAADXITpL0gfoud+XKVRUkr1y+dPneT5cu7dy5U/MSkw3FHJ1dtHDhQ4/7+fklTZo0efLkSZMmS548WfIUKZLFfJQ02eXLl44fP+5t3xqVbB/ajK2m0n5dsCDWi995992nn35a4jB2zJjBgwcJYLXr16//Hi3ml2rlsGChgsmTJXv0ygsXLh48eODq1atiHSPdp8SLy8vBexAIkWCkS5eualUDDSd+X0Ig9B3FihUrFxwseq1cudJgLfuHXLt2bc/u3eqHwLvFtbDmtZo3b/7gL9Vzvm+f3rFeWa9+/W7d3oj1U7dv3+713ntz5swWwPPUyuEmjf0YgsoZ6D6l3vPNbhxAgkAgRILx4outUqRIIXqptZ1ly5YKfEXnzq+KdkuW6N4vCuj3UDN6tcp35MiRRy9TkzJffTU01n+DysCvdu6krf4NoFPGjBlz5swp2qnlwbt37woQLwIhEoZEiRK90q6daKfWdgS+IiSkfKPGjUWvGzduLFvKnAJ8XLVq1R48jnX48OGxY8c8elnWrFknTZ4S69Re5NGj7dq3Y+0avqpCxYpiAh0I4QgCIRKGTp07O1sMwxKs7fiMlClTDh06VLT766+V8fcpBnzAQ+Vk3uvZ89GebMmTJ1dpMNYyHps3b273ysvnzp0TwEeFmGg4IRwghGM826wTXqJ48eLfjBlb1tBpZvcVLVqsV6/eot3Zs2fjqohgN+op9PY772TMmFESrHe79zDSjG7atGkC+DR//7R1H6gQ88svv6xbF0sX7CFfDVXvJI8+vmLF8pYtnicNwreFhJQX7e7cuaPzkCQSLgKhLbRo2fLpp5+eNWv2tOk/JLhYmCJFipGjRokJ06czlP+PXr37vPHGm+s3hH7++Rf58+eXhKZmzVodOnQQ7Xbt2vX3XybriwIaNGvWLNl/6zSqXDfg008fvaZr19caNGjw6OPjx43r1LGj91RdAjwhTZo0RYsWFe127dqZ4MpTwQgCoe9LmjRp48ZNYj6uVKmSioXTf/ixQoUKkkD06t27QIECot2tW7e+/+47gcgT2bNXqVIl5uOWL7zw+9JlEydOUs8lSSDUvOw3Y8aICZMnTxLA17Vu0+b+xx999OGj/d+feqp29x49Hnrw9u3bPbp3//LLgQL4upDy5RMnNjDkDt3AflE4hEDo+6pXr5E2bdoHH6lYseIPP/40Y8bMak8+Kd7t9de7vfzyK2LCggXzaWoco1GjRokSJbr/S/VxzVq11GrzokWL1cpAypQpxYsFB4dMmTo1efLkot3p06d/njlTAJ9WunTp+7sG/vrrr0e32RcsVGjEyJEPvodIdEHRti+1ob0EbCIkmAOE8GoEQt/X9LnnYn08OCRk6tRv163f8Nlnn1erVs3I3FU81O9n8JAh73bvLoZMnDBREK1p09ifQkWKFh00eMjqNWs//XSAGhSK92nb9uXvp01LlSqVmMAKM+zgfjkZlfH6PNJ4UE1HTpk85aHX4LFjx5o1e472ErCPYO39b2OEhm4QwAGJMmTIIPBd/v7+YeERjlx58eLF5cuXLfx14R9/rBDT0qdPP2LkqKpVq4ohaqTSutWLApX6ihRdtHixI1fu3LFj+vTpy5YtPXHihJjm5+f35aDBzzzzjBhy9erVypUqqpeVAL4rRYoU6zeEpkmTRn388Ucffffdtw9+NmnSpNOn/xD8v8UVN2/e3LFDe7V+LoA9qJdJxOYt6uUgep07dy64XJAADqDthI9r0LChg1eqeVy1EKR+REVF/bVy5Z9//rl06dJHj4J4Wrp06bp2fe2ltm3NbkScMnmyIFqjRo0cvFItGH7y6afqx969e9esXr123drV//579uxZ0e75Fi1ef71brly5xJzZs2aRBuHz6tdvEJMGN27c+FAaVL4cNOihNLhixfJur79OCRnYSpkyZfWnQYme2hbAMQRCH9e0SVNxklpUVDEyJkmuW7d22bJlf/7xhxrii4ep4Xvr1m2MR0Hl6NEjaplLEM2FTu4FosXUmVDLhqtVOvx39dq1az09RU9I+QAAEABJREFUv6BmE1q0bNmuXftYG51pNmkSW47h+1q0vLdf9NatW+/1fLhmTLv27Zv87w1o4oQJX3zxuQA2Y64DIftF4SgCoS/LmTNnsHtvQ+XLV1A/+vbtd+DAAfXOsm3rtq1bt27fvs3aKsZqWbJZ8+beU7Vy0kQqQ/5HSEj5gIAAcYNaNlQ/Xnmlnfo4PDxcZcM1a9dsDA219imknjytWrepX7++eIe5c+ccPHhQAJ+WO3dudYNQH3zzzdf79+9/8FNVq1Z9//0PHnykT5/eM2fMEMB+gg0Fwo1UlIHDCIS+rInzy4NxyRutWbP//FINdvfs2X3kyJHDhw/f++fwvQ+dGuKXKFGiUuXKlStVLl+hgqmaH7Hat2/ft99OFURr7PzyYDzKRHu1SxeJXjncsGFDWFjYxo2harpBnJQ6derixUsUV0qUqFChghqYijcZPGiQAL6uZcsXJPo9c8w33zz4eL58+UaN/vr+L48dO/b6a13VfJAA9pMoUaLy5Q20pL927dqWLVsEcAyB0JepZTfxjDzRHnrwwoULhw4dUj9fv37t2tVr1/7z8/WrV6+kSpkqU+ZMGTNmypw5c8aMGZ944gnxVh+830/wX/VjayRtiZiVw/vty06cOHH+3Lmz56KdPXvu/Lnbt28/9CVp06ZVT5706dLnzpNHjTjFW40aNfL48eMC+DQ1zG3RsqX6oGfPHjdu3Lj/uJ+//5Sp397vdbR27ZquXbqo+4IAtlSyZEkjB2EiIsIfvY0CcSEQ+qzAoCDNyybp0qUrVaqUJGQLf/2VQ9j31alTR31PRYts0SThO3PmzLixYwXwdTVr1lITNNOnTQvbtOn+g4kTJx47dlxMPae7d++OHj1qxPDh6gMB7Co4hA6ESAAIhD6rqXX7RW3i6tWrn376ieC/GjVuInDS4EFfqieSAL6uRcsWp06d+vLLgQ8+2P/DD2NOg0ddvPj666+tWrVKAHsLCTGwX1QJ3UAghBMIhL4padKkzzrcLQAxhg79So1vBNHSpEmjVggFzti1a9fPP/8sgK/z8/OrXr1Gt9dfv3z58v0HW7Rs+dJLbdUHW7du7fLqq5GRRwWwPSMHCIUSo3BSYoEvqlWr1v0jHHDE3r17p06ZIvivevXqJUuWTOCMD/v3F8AGatV6avk9y+4/Ui44eMCAz9QHP0yf3uy5pqRBQKILLmTIkEG0U7OTNMKFU1gh9E1Nmj4ncEbv3r3u3Lkj+C/2izpr+rRp69atFcAGKlWu/NGH/z/9kTNnzgkTJt64caNvnz7z588TANECA4PEhE0bNwrgDAKhD1Jrg08//bTAYVOnTqFdz4OyZctWpUoVgcMiIiL69/9AAHtY+vvvp0+fjvnYz89v4qTJ586de61r1507dwiA/woKMhMI2S8KZ7Fl1Ac9+yynB50QFhb22YABggc0aNhQ4DA1FO7a5VUBbGPFiuX3Px4+fMTOHTsaN25EGgQeEmgsEDLHDeewQuiDmjRhs5+jTpw40aljBzaLPqQx+0Uddvfu3ddf60rjQdjTa6+9vmjRotmzZwmA/5UiRYqiRYuKdmqO8sCBAwI4g0Doa3LlyhVUrpzAAdevX+/Yof3Zs2cFD1BPoZIlSwocM2L48LVrOToIm5o7dy71Y4BYBQYGJk5sYCPehg3rBXASgdDXNH2OcjKO6tO797Zt2wT/q1nz5gLHLFu2dNSokQLYFWkQiIupijLsF4ULCIS+5rnnmgkc8NGHH86bN1fwiGbNCIQO+WPFite6dhUAAB4RVI5AiASDojI+pVxwcK5cuQSPM2Tw4O+//07wiKBy5QICAgSPs2TJkldf7Xz79m0BAOARISEGWtLfunUrPCxMACcRCH1KE2qBOGD4sGFjxnwjiE3jxo0Fj7Ng/vxur79GGgQAxCpv3rz+/v6inUqD3JvgAraM+o6kSZM2fPZZQdxu3LjR67336JscjwYNaDjxGJMmTvz8888EAIA4cIAQCQuB0HfUrl07bdq0gjicO3eufbtXIiIiBHGoWbNWhgwZBHG4fv16z549Fv76qwAAELfAwEAxgUAI1xAIfUeTpk0FcdizZ88rr7x8LDJSELdGjRoJ4hAZGdmpY8cdO7YLAADxMlVRhp4TcA1nCH2Ev79/jRo1BbH5559/nmvahDQYv9SpU9epW1cQm7Vr1zR6tiFpEADwWClSpChSxEBL+v37958/f14A57FC6COerF49WbJkgv917dq1IUMGT5k8WfA4derUTZUqleB/8RQCADilXLlyRlrSs18ULiMQ+ogzp0+fOnUqS5Ysgv9atWpV71696JvsoAsXLwj+1+bNm9995+19+/YJAACOMVdRZoMALmHLqI9Ys2ZN1SqV333nna1bt4rtXbx4sXev99q+1IY06Lg///ijbJnS/T/4YNfOnWJ79xYGBw9u0rgRaRAA4BRTFWU2skIIVyWiqKDvCSpXrmHDhs88Uy9btmxiP7Nnz/py4MDTp08LXFW2bNkWLV9o0KCBn5+f2MyNGzdmzpwxcsSIM2fOCAAATgoLj9DfhDAqKkrN6grgEgKhL1PD+qeffubpZ57JkyeP+Lpbt27NmTNn9KiRR44cEVghTZo0des+/Uy9Z2rXriP2MHPmzFEjR7KwDABwTf78+ZcuWy7a/bFiRceOHQRwCYHQFooWLaaG9SocFi5cWHyOWtL55eefx4wZwzjeQ1KnTl29Ro16z9SrUbOmSoniixb++uuwYUP3798vAAC4qlmzZoMGDxHtBg8aNHbsGAFcQiC0l7x58z7zTL1KlSsHBQWpUb4kcOHh4fPnKXPPnTsn0KJmzVoNGjZ48snqmTJlkoRvx47tv/zyy7y5c8+ePSsAALhnwIDPXmzVSrR7oWXL9evXCeASAqFNJU6cuHSZMhWU8hWCypXTv9ndHYcOHZo7d87cOXMOHjwoMKRgwYKV1NRClSoVK1ZMmzatJChqBmH+/HmzfvmFIkwAAAstWrS4SFHdTQhv3bpVulTJ69evC+ASAiHuKVOmTGBgUMlSJUuVKq0G+uJ9Ll26FBoaun7dujVr12zauFHgNRIlSlSqVCmVDVU+DA4O9tpmhpcvX96wYcO6tWvVU2hzRMTt27cFAADr+Pn5bQoL19+EMCwsrNlzTQVwFYEQD0uTJo0a35cpWzYmHBYqVEhMUAlw69YtW7du27pli/pp965dgoSgWLFihQoVLlJEzZAWVf9kz55dzDl58uT27duZRwAAaKCGT3PnzX/owatXr969e/dOtEQid6I/vvvAzzEfiPr47t1HH78b87Pc/e+v7ty/QGIulrtLfvttypQpAriKQIjHyx4QkDtXrtx58uTOrX7Kq+TKlcvaXYLXrl07eODA/gMH9u3bu2PHDhUCDxw4IEj4/P3TqnConjsBATly5sqVI5p6IokHnDp1as+ePTt2bN+3b9+unbt27twRFRUlAAAAiBuBEC5SC4np06fPlClTxkyZMqTPkDFTxuhfZs6YMUM8WVHNcV2+fEkN09UC4Pnz50+eOKli4P79BygQajdPZM+eM0fOgGjqKaSeM+nSpYv+Oe09/up/sT+Loi5ePHvu3OlTpy5cvHDmzNkzp09HRkbu2nUv/l28eFEAAADgDAIhAAAAANhUUgEAAAAA2BKBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAO9WU7AAAADWSURBVABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2BSBEAAAAABsikAIAAAAADZFIAQAAAAAmyIQAgAAAIBNEQgBAAAAwKYIhAAAAABgUwRCAAAAALApAiEAAAAA2NT/AQAA//9ktnnoAAAABklEQVQDAD93iGDxfI5XAAAAAElFTkSuQmCC'

Write-SiteFile 'assets\js\main.js' @'
// GigaTorq - site scripts
(function () {
  // Mobile menu
  var toggle = document.querySelector(".nav-toggle");
  var links = document.querySelector(".nav-links");
  if (toggle && links) {
    toggle.addEventListener("click", function () {
      var open = links.classList.toggle("open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
  }

  // Footer year
  var y = document.getElementById("year");
  if (y) y.textContent = new Date().getFullYear();

  // Newsletter placeholder (wire to your email provider later)
  var form = document.querySelector(".newsletter");
  if (form) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      var btn = form.querySelector("button");
      if (btn) btn.textContent = "Thanks - you're on the list";
    });
  }
})();
'@

Write-SiteFile 'compare\cordless-drills\index.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Brand A vs Brand B: Best Cordless Drill | GigaTorq</title>
<meta name="description" content="Two cordless drills tested head to head: torque, runtime, speed and value.">
<link rel="canonical" href="https://gigatorq.com/compare/cordless-drills/">
<meta property="og:title" content="Brand A vs Brand B: Best Cordless Drill | GigaTorq">
<meta property="og:description" content="Two cordless drills tested head to head: torque, runtime, speed and value.">
<meta property="og:url" content="https://gigatorq.com/compare/cordless-drills/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/" class="active">Comparisons</a></li>
      <li><a href="/reviews/">Reviews</a></li>
      <li><a href="/how-we-test/">How We Test</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="section">
  <div class="container article">
    <div class="breadcrumb"><a href="/">Home</a> / <a href="/compare/">Comparisons</a> / Cordless Drills</div>
    <h1>Brand A vs Brand B: Best Cordless Drill</h1>
    <p class="muted">Updated <time datetime="2026-10-21">October 21, 2026</time> &middot; By the GigaTorq team</p>
    <p class="disclosure-note">GigaTorq is reader-supported. When you buy through links on this page, we may earn an affiliate commission at no extra cost to you. <a href="/disclosure/">Learn more</a>.</p>
    <p class="placeholder">TEMPLATE: replace "Brand A / Brand B", specs and test results with your real data before publishing.</p>

    <h2>Quick verdict</h2>
    <div class="grid grid-2">
      <div class="card"><span class="tag">Best overall</span><h3>Brand A Model X</h3><p>One-sentence reason it wins for most buyers.</p></div>
      <div class="card"><span class="tag">Best value</span><h3>Brand B Model Y</h3><p>One-sentence reason it wins on price.</p></div>
    </div>

    <h2>Specs side by side</h2>
    <div class="table-wrap">
      <table class="compare">
        <thead><tr><th></th><th>Brand A Model X</th><th>Brand B Model Y</th></tr></thead>
        <tbody>
          <tr><th>Voltage</th><td>-- V</td><td>-- V</td></tr>
          <tr><th>Max torque</th><td>-- in-lbs</td><td>-- in-lbs</td></tr>
          <tr><th>Speed (no load)</th><td>-- RPM</td><td>-- RPM</td></tr>
          <tr><th>Chuck size</th><td>-- in</td><td>-- in</td></tr>
          <tr><th>Weight (with battery)</th><td>-- lbs</td><td>-- lbs</td></tr>
          <tr><th>Battery included</th><td>-- Ah</td><td>-- Ah</td></tr>
          <tr><th>Warranty</th><td>-- years</td><td>-- years</td></tr>
          <tr><th>Price (kit)</th><td>$--</td><td>$--</td></tr>
        </tbody>
      </table>
    </div>

    <h2>Test results</h2>
    <div class="table-wrap">
      <table class="compare">
        <thead><tr><th>Test</th><th>Brand A Model X</th><th>Brand B Model Y</th></tr></thead>
        <tbody>
          <tr><th>1-in spade bit, 2x10 SPF (holes per charge)</th><td>--</td><td>--</td></tr>
          <tr><th>3-in deck screws driven (per charge)</th><td>--</td><td>--</td></tr>
          <tr><th>1/2-in hole in 1/4-in steel (seconds)</th><td>--</td><td>--</td></tr>
          <tr><th>Recharge time, 0 to 100% (minutes)</th><td>--</td><td>--</td></tr>
        </tbody>
      </table>
    </div>

    <h2>Scores</h2>
    <div class="grid grid-2">
      <div class="card">
        <h3>Brand A Model X</h3>
        <div class="score-row"><span>Power</span><div class="bar"><i style="width:0%"></i></div><b>--</b></div>
        <div class="score-row"><span>Runtime</span><div class="bar"><i style="width:0%"></i></div><b>--</b></div>
        <div class="score-row"><span>Ergonomics</span><div class="bar"><i style="width:0%"></i></div><b>--</b></div>
        <div class="score-row"><span>Value</span><div class="bar"><i style="width:0%"></i></div><b>--</b></div>
      </div>
      <div class="card">
        <h3>Brand B Model Y</h3>
        <div class="score-row"><span>Power</span><div class="bar"><i style="width:0%"></i></div><b>--</b></div>
        <div class="score-row"><span>Runtime</span><div class="bar"><i style="width:0%"></i></div><b>--</b></div>
        <div class="score-row"><span>Ergonomics</span><div class="bar"><i style="width:0%"></i></div><b>--</b></div>
        <div class="score-row"><span>Value</span><div class="bar"><i style="width:0%"></i></div><b>--</b></div>
      </div>
    </div>

    <h2>Which one should you buy?</h2>
    <p><strong>Buy Brand A if</strong> ... (who it's for).</p>
    <p><strong>Buy Brand B if</strong> ... (who it's for).</p>

    <h2>Where to buy</h2>
    <div class="grid grid-2">
      <div class="card"><h3>Brand A Model X</h3>
        <div class="buy-box"><a class="btn" href="#" rel="sponsored nofollow">Check price at Home Depot</a><a class="btn btn-ghost" href="#" rel="sponsored nofollow">Amazon</a></div></div>
      <div class="card"><h3>Brand B Model Y</h3>
        <div class="buy-box"><a class="btn" href="#" rel="sponsored nofollow">Check price at Lowe's</a><a class="btn btn-ghost" href="#" rel="sponsored nofollow">Amazon</a></div></div>
    </div>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'compare\index.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Power Tool Comparisons | GigaTorq</title>
<meta name="description" content="Side-by-side power tool comparisons with real test results.">
<link rel="canonical" href="https://gigatorq.com/compare/">
<meta property="og:title" content="Power Tool Comparisons | GigaTorq">
<meta property="og:description" content="Side-by-side power tool comparisons with real test results.">
<meta property="og:url" content="https://gigatorq.com/compare/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/" class="active">Comparisons</a></li>
      <li><a href="/reviews/">Reviews</a></li>
      <li><a href="/how-we-test/">How We Test</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="section">
  <div class="container">
    <span class="eyebrow">Comparisons</span>
    <h1>Head-to-head matchups</h1>
    <p class="muted" style="max-width:640px">Every comparison puts tools through the same tests on the same materials, then names a winner for each kind of buyer.</p>
    <div class="grid grid-3" style="margin-top:32px">
      <a class="card" href="/compare/cordless-drills/">
        <span class="tag">Cordless drills</span>
        <h3>Best cordless drill</h3>
        <p>Comparison template: duplicate this page for each new matchup.</p>
      </a>
    </div>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'contact\index.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Contact | GigaTorq</title>
<meta name="description" content="Contact the GigaTorq team.">
<link rel="canonical" href="https://gigatorq.com/contact/">
<meta property="og:title" content="Contact | GigaTorq">
<meta property="og:description" content="Contact the GigaTorq team.">
<meta property="og:url" content="https://gigatorq.com/contact/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/">Comparisons</a></li>
      <li><a href="/reviews/">Reviews</a></li>
      <li><a href="/how-we-test/">How We Test</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="section">
  <div class="container article">
    <span class="eyebrow">Contact</span>
    <h1>Get in touch</h1>
    <p>Questions, tool suggestions or corrections? Email us at <a href="mailto:hello@gigatorq.com">hello@gigatorq.com</a>.</p>
    <p>Brands and PR: <a href="mailto:reviews@gigatorq.com">reviews@gigatorq.com</a>. Sending us a tool doesn't guarantee coverage or a positive review.</p>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'disclosure\index.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Affiliate Disclosure | GigaTorq</title>
<meta name="description" content="How GigaTorq earns money through affiliate links.">
<link rel="canonical" href="https://gigatorq.com/disclosure/">
<meta property="og:title" content="Affiliate Disclosure | GigaTorq">
<meta property="og:description" content="How GigaTorq earns money through affiliate links.">
<meta property="og:url" content="https://gigatorq.com/disclosure/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/">Comparisons</a></li>
      <li><a href="/reviews/">Reviews</a></li>
      <li><a href="/how-we-test/">How We Test</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="section">
  <div class="container article">
    <span class="eyebrow">Legal</span>
    <h1>Affiliate disclosure</h1>
    <p class="muted">Last updated October 21, 2026</p>
    <p>GigaTorq is reader-supported. Some links on this site are affiliate links. If you click one and buy something, we may earn a commission at no extra cost to you.</p>
    <p>GigaTorq is a participant in the Amazon Services LLC Associates Program, an affiliate advertising program designed to provide a means for sites to earn advertising fees by advertising and linking to Amazon.com. As an Amazon Associate we earn from qualifying purchases. We may also participate in affiliate programs from other retailers.</p>
    <h2>Our independence</h2>
    <p>Affiliate relationships never affect our test results, scores or recommendations. Brands do not review our content before publication and cannot pay for placement.</p>
    <p>This disclosure is provided in line with the US Federal Trade Commission's guidance on endorsements and testimonials.</p>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'how-we-test\index.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>How We Test Power Tools | GigaTorq</title>
<meta name="description" content="Our testing method: same jobs, same materials, and scores for power, runtime, ergonomics and value.">
<link rel="canonical" href="https://gigatorq.com/how-we-test/">
<meta property="og:title" content="How We Test Power Tools | GigaTorq">
<meta property="og:description" content="Our testing method: same jobs, same materials, and scores for power, runtime, ergonomics and value.">
<meta property="og:url" content="https://gigatorq.com/how-we-test/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/">Comparisons</a></li>
      <li><a href="/reviews/">Reviews</a></li>
      <li><a href="/how-we-test/" class="active">How We Test</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="section">
  <div class="container article">
    <span class="eyebrow">Our method</span>
    <h1>How we test</h1>
    <p>Every GigaTorq comparison follows the same rules, so results are fair and repeatable.</p>
    <h2>Where our tools come from</h2>
    <p>We buy most tools at retail. When a manufacturer loans or gives us a tool, we say so in the review. Brands never see a review before it's published and can't pay for a better score.</p>
    <h2>Same jobs, same materials</h2>
    <ul>
      <li><strong>Drills:</strong> spade bits and auger bits in 2x10 SPF lumber, twist bits in mild steel.</li>
      <li><strong>Impact drivers:</strong> 3-in deck screws and 1/2-in x 6-in lag screws in pressure-treated lumber.</li>
      <li><strong>Saws:</strong> rip and cross cuts in 2x and 3/4-in plywood, cuts per charge.</li>
      <li><strong>Grinders:</strong> cutting rebar and grinding mild steel, timed.</li>
    </ul>
    <p>Batteries start fully charged, and we use the battery size that comes in the most common kit.</p>
    <h2>How we score</h2>
    <p>Each tool gets a score out of 10 in four areas:</p>
    <ul>
      <li><strong>Power</strong> - speed and torque in real tasks, not just spec-sheet numbers.</li>
      <li><strong>Runtime</strong> - work done per charge and recharge time.</li>
      <li><strong>Ergonomics</strong> - weight, balance, grip, vibration and controls.</li>
      <li><strong>Value</strong> - performance for the price, plus warranty and battery platform.</li>
    </ul>
    <h2>Keeping reviews current</h2>
    <p>Prices and models change. We update comparisons when a new model replaces an old one, and every page shows when it was last updated.</p>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'index.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>GigaTorq | Power Tool Comparisons and Reviews</title>
<meta name="description" content="Head-to-head power tool comparisons and hands-on reviews. We test drills, impact drivers, saws and grinders so you can buy the right tool.">
<link rel="canonical" href="https://gigatorq.com/">
<meta property="og:title" content="GigaTorq | Power Tool Comparisons and Reviews">
<meta property="og:description" content="Head-to-head power tool comparisons and hands-on reviews. We test drills, impact drivers, saws and grinders so you can buy the right tool.">
<meta property="og:url" content="https://gigatorq.com/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/">Comparisons</a></li>
      <li><a href="/reviews/">Reviews</a></li>
      <li><a href="/how-we-test/">How We Test</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="hero">
  <div class="container">
    <span class="eyebrow">Power tools, tested head to head</span>
    <h1>More torque.<br>Less guesswork.</h1>
    <p class="lead">We put drills, drivers, saws and grinders side by side and test them on real jobs, so you can buy the right tool the first time.</p>
    <div class="hero-actions">
      <a href="/compare/" class="btn">Browse comparisons</a>
      <a href="/how-we-test/" class="btn btn-ghost">How we test</a>
    </div>
    <div class="hero-stats">
      <div>0<small>Tools tested</small></div>
      <div>0<small>Head-to-heads</small></div>
      <div>0<small>Hours on the bench</small></div>
    </div>
  </div>
</section>

<section class="section">
  <div class="container">
    <span class="eyebrow">Featured matchups</span>
    <h2>Head-to-head comparisons</h2>
    <div class="grid grid-3" style="margin-top:28px">
      <a class="card" href="/compare/cordless-drills/">
        <span class="tag">Cordless drills</span>
        <div class="vs">Brand A <b>VS</b> Brand B</div>
        <p>Best 20V-class drill/driver for home and jobsite use.</p>
      </a>
      <a class="card" href="/compare/">
        <span class="tag">Impact drivers</span>
        <div class="vs">Brand A <b>VS</b> Brand C</div>
        <p>Which impact driver sinks lag screws fastest?</p>
      </a>
      <a class="card" href="/compare/">
        <span class="tag">Circular saws</span>
        <div class="vs">Brand B <b>VS</b> Brand D</div>
        <p>Cordless vs corded: cut speed, accuracy and runtime.</p>
      </a>
    </div>
  </div>
</section>

<section class="section section-alt">
  <div class="container">
    <span class="eyebrow">Shop by category</span>
    <h2>Find your tool</h2>
    <div class="grid grid-4" style="margin-top:28px">
      <a class="card cat-card" href="/compare/cordless-drills/"><div class="icon">&#128297;</div><h3>Drills</h3></a>
      <a class="card cat-card" href="/compare/"><div class="icon">&#9881;&#65039;</div><h3>Impact Drivers</h3></a>
      <a class="card cat-card" href="/compare/"><div class="icon">&#129690;</div><h3>Saws</h3></a>
      <a class="card cat-card" href="/compare/"><div class="icon">&#9889;</div><h3>Grinders</h3></a>
      <a class="card cat-card" href="/compare/"><div class="icon">&#128296;</div><h3>Rotary Hammers</h3></a>
      <a class="card cat-card" href="/compare/"><div class="icon">&#128267;</div><h3>Batteries</h3></a>
      <a class="card cat-card" href="/compare/"><div class="icon">&#128168;</div><h3>Nailers</h3></a>
      <a class="card cat-card" href="/compare/"><div class="icon">&#128736;&#65039;</div><h3>Combo Kits</h3></a>
    </div>
  </div>
</section>

<section class="section">
  <div class="container">
    <span class="eyebrow">Our method</span>
    <h2>How we test</h2>
    <div class="grid grid-3 steps" style="margin-top:28px">
      <div class="step"><h3>Buy or borrow</h3><p class="muted">We test retail units, not hand-picked samples, and say so whenever a brand loans us a tool.</p></div>
      <div class="step"><h3>Run the same jobs</h3><p class="muted">Every tool in a matchup does the same drilling, driving or cutting tasks on the same materials.</p></div>
      <div class="step"><h3>Score and compare</h3><p class="muted">Power, runtime, ergonomics and value get scored, then we pick a winner for each type of buyer.</p></div>
    </div>
    <p style="margin-top:24px"><a href="/how-we-test/">Read the full testing method &rarr;</a></p>
  </div>
</section>

<section class="section section-alt">
  <div class="container center">
    <span class="eyebrow">Newsletter</span>
    <h2>New tests, straight to your inbox</h2>
    <p class="muted">One email when a new comparison drops. No spam.</p>
    <form class="newsletter">
      <input type="email" placeholder="you@example.com" required aria-label="Email address">
      <button class="btn" type="submit">Subscribe</button>
    </form>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'privacy\index.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Privacy Policy | GigaTorq</title>
<meta name="description" content="GigaTorq privacy policy.">
<link rel="canonical" href="https://gigatorq.com/privacy/">
<meta property="og:title" content="Privacy Policy | GigaTorq">
<meta property="og:description" content="GigaTorq privacy policy.">
<meta property="og:url" content="https://gigatorq.com/privacy/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/">Comparisons</a></li>
      <li><a href="/reviews/">Reviews</a></li>
      <li><a href="/how-we-test/">How We Test</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="section">
  <div class="container article">
    <span class="eyebrow">Legal</span>
    <h1>Privacy policy</h1>
    <p class="muted">Last updated October 21, 2026</p>
    <p class="placeholder">STARTER TEXT: review and complete this policy before launch, especially once you add analytics, ads or a newsletter provider.</p>
    <h2>What we collect</h2>
    <p>If you subscribe to our newsletter, we collect your email address. Our hosting provider and any analytics tools may collect standard technical data such as IP address, browser type and pages visited.</p>
    <h2>Cookies and affiliate links</h2>
    <p>Retailers we link to (such as Amazon) may set cookies when you click an affiliate link so they can credit the referral to us.</p>
    <h2>Your choices</h2>
    <p>You can unsubscribe from emails at any time, and you can block or delete cookies in your browser settings.</p>
    <h2>Contact</h2>
    <p>Privacy questions: <a href="mailto:hello@gigatorq.com">hello@gigatorq.com</a>.</p>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'reviews\index.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Power Tool Reviews | GigaTorq</title>
<meta name="description" content="Hands-on power tool reviews with scores for power, runtime, ergonomics and value.">
<link rel="canonical" href="https://gigatorq.com/reviews/">
<meta property="og:title" content="Power Tool Reviews | GigaTorq">
<meta property="og:description" content="Hands-on power tool reviews with scores for power, runtime, ergonomics and value.">
<meta property="og:url" content="https://gigatorq.com/reviews/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/">Comparisons</a></li>
      <li><a href="/reviews/" class="active">Reviews</a></li>
      <li><a href="/how-we-test/">How We Test</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="section">
  <div class="container">
    <span class="eyebrow">Reviews</span>
    <h1>Hands-on reviews</h1>
    <p class="muted" style="max-width:640px">In-depth reviews of single tools, scored on the same scale we use in our comparisons.</p>
    <div class="grid grid-3" style="margin-top:32px">
      <a class="card" href="/reviews/review-template/">
        <span class="tag">Template</span>
        <h3>Review template</h3>
        <p>Duplicate this page for each new tool review.</p>
      </a>
    </div>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'reviews\review-template\index.html' @'
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Brand A Model X Review | GigaTorq</title>
<meta name="description" content="Hands-on review: power, runtime, ergonomics and value tested.">
<link rel="canonical" href="https://gigatorq.com/reviews/review-template/">
<meta property="og:title" content="Brand A Model X Review | GigaTorq">
<meta property="og:description" content="Hands-on review: power, runtime, ergonomics and value tested.">
<meta property="og:url" content="https://gigatorq.com/reviews/review-template/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="GigaTorq">
<link rel="icon" href="/assets/img/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/assets/img/favicon.png" type="image/png" sizes="256x256">
<link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png">
<meta property="og:image" content="https://gigatorq.com/assets/img/og-image.png">
<meta name="theme-color" content="#0f1114">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
      <li><a href="/compare/">Comparisons</a></li>
      <li><a href="/reviews/" class="active">Reviews</a></li>
      <li><a href="/how-we-test/">How We Test</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </div>
</header>
<main>

<section class="section">
  <div class="container article">
    <div class="breadcrumb"><a href="/">Home</a> / <a href="/reviews/">Reviews</a> / Brand A Model X</div>
    <h1>Brand A Model X Review</h1>
    <p class="muted">Updated <time datetime="2026-10-21">October 21, 2026</time> &middot; By the GigaTorq team</p>
    <p class="disclosure-note">GigaTorq is reader-supported. When you buy through links on this page, we may earn an affiliate commission at no extra cost to you. <a href="/disclosure/">Learn more</a>.</p>
    <p class="placeholder">TEMPLATE: replace the tool name, scores and findings with your real test results before publishing.</p>

    <div class="card" style="display:flex;gap:20px;align-items:center;flex-wrap:wrap">
      <div class="score">--</div>
      <div style="flex:1;min-width:220px">
        <h3 style="margin:0">The verdict</h3>
        <p>One or two sentences summing up who this tool is for and whether it's worth the money.</p>
      </div>
      <a class="btn" href="#" rel="sponsored nofollow">Check price</a>
    </div>

    <div class="grid grid-2" style="margin-top:20px">
      <div class="card"><h3>Pros</h3><ul class="pros"><li>Pro one</li><li>Pro two</li><li>Pro three</li></ul></div>
      <div class="card"><h3>Cons</h3><ul class="cons"><li>Con one</li><li>Con two</li></ul></div>
    </div>

    <h2>Specs</h2>
    <div class="table-wrap">
      <table class="compare">
        <tbody>
          <tr><th>Voltage</th><td>-- V</td></tr>
          <tr><th>Max torque</th><td>-- in-lbs</td></tr>
          <tr><th>Speed (no load)</th><td>-- RPM</td></tr>
          <tr><th>Weight (with battery)</th><td>-- lbs</td></tr>
          <tr><th>Warranty</th><td>-- years</td></tr>
        </tbody>
      </table>
    </div>

    <h2>Performance</h2>
    <p>What happened in each test, with numbers.</p>
    <h2>Ergonomics and build</h2>
    <p>Grip, balance, weight, controls, LED, belt clip.</p>
    <h2>Battery and runtime</h2>
    <p>Runtime per charge, recharge time, platform compatibility.</p>
    <h2>Who should buy it</h2>
    <p>Best for ... Skip it if ...</p>
  </div>
</section>
</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Head-to-head power tool comparisons and hands-on reviews for US buyers.</p>
      </div>
      <div>
        <h4>Tools</h4>
        <ul>
          <li><a href="/compare/cordless-drills/">Cordless Drills</a></li>
          <li><a href="/compare/">Impact Drivers</a></li>
          <li><a href="/compare/">Circular Saws</a></li>
          <li><a href="/compare/">Angle Grinders</a></li>
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-test/">How We Test</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Affiliate Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. As an Amazon Associate and member of other affiliate programs, we earn from qualifying purchases.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
'@

Write-SiteFile 'robots.txt' @'
User-agent: *
Allow: /

Sitemap: https://gigatorq.com/sitemap.xml
'@

Write-SiteFile 'sitemap.xml' @'
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://gigatorq.com/</loc><lastmod>2026-10-21</lastmod></url>
  <url><loc>https://gigatorq.com/compare/</loc><lastmod>2026-10-21</lastmod></url>
  <url><loc>https://gigatorq.com/compare/cordless-drills/</loc><lastmod>2026-10-21</lastmod></url>
  <url><loc>https://gigatorq.com/reviews/</loc><lastmod>2026-10-21</lastmod></url>
  <url><loc>https://gigatorq.com/reviews/review-template/</loc><lastmod>2026-10-21</lastmod></url>
  <url><loc>https://gigatorq.com/how-we-test/</loc><lastmod>2026-10-21</lastmod></url>
  <url><loc>https://gigatorq.com/about/</loc><lastmod>2026-10-21</lastmod></url>
  <url><loc>https://gigatorq.com/contact/</loc><lastmod>2026-10-21</lastmod></url>
  <url><loc>https://gigatorq.com/disclosure/</loc><lastmod>2026-10-21</lastmod></url>
  <url><loc>https://gigatorq.com/privacy/</loc><lastmod>2026-10-21</lastmod></url>
</urlset>
'@

Write-SiteFile 'vercel.json' @'
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "trailingSlash": true,
  "headers": [
    {
      "source": "/assets/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=86400" }
      ]
    },
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
        { "key": "X-Frame-Options", "value": "SAMEORIGIN" }
      ]
    }
  ]
}
'@

foreach ($old in @('CNAME','assets\img\logo.png')) { $p = Join-Path $root $old; if (Test-Path $p) { Remove-Item $p; Write-Host "  removed $old" } }
Write-Host "GigaTorq site ready in $root" -ForegroundColor Green
