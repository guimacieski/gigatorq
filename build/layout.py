"""Shared layout, page writer and database loader for the GigaTorq site generator."""
import glob, html, json, os, sqlite3

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_DIR = os.path.join(ROOT, 'db')
SITE = 'https://gigatorq.com'
WRITTEN = []  # (path, lastmod, indexable) for the sitemap

NAV = [('/best/', 'Best Picks'), ('/compare/', 'Comparisons'), ('/reviews/', 'Reviews'),
       ('/how-we-choose/', 'How We Choose'), ('/about/', 'About')]

DISCLOSURE = ''  # no affiliate links yet; add a disclosure note here when the first affiliate program is live

HEAD = """<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="{desc}">
<link rel="canonical" href="https://gigatorq.com{path}">{robots}
<meta property="og:title" content="{title}">
<meta property="og:description" content="{desc}">
<meta property="og:url" content="https://gigatorq.com{path}">
<meta property="og:type" content="{og_type}">
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
<link rel="stylesheet" href="/assets/css/style.css">{jsonld}
</head>
<body>
<header class="site-header">
  <div class="container nav">
    <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="156" height="40"></a>
    <button class="nav-toggle" aria-label="Menu" aria-expanded="false">&#9776;</button>
    <ul class="nav-links">
{nav}
    </ul>
  </div>
</header>
<main>
"""

FOOT = """</main>
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div>
        <a href="/" class="logo"><img src="/assets/img/logo.svg" alt="GigaTorq" width="176" height="45" loading="lazy"></a>
        <p class="muted" style="margin-top:10px;max-width:320px">Gigabytes of information to help you make the best choice.</p>
      </div>
      <div>
        <h4>Best Picks</h4>
        <ul>
{tools}
        </ul>
      </div>
      <div>
        <h4>GigaTorq</h4>
        <ul>
          <li><a href="/about/">About</a></li>
          <li><a href="/how-we-choose/">How We Choose</a></li>
          <li><a href="/contact/">Contact</a></li>
        </ul>
      </div>
      <div>
        <h4>Legal</h4>
        <ul>
          <li><a href="/disclosure/">Disclosure</a></li>
          <li><a href="/privacy/">Privacy Policy</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      &copy; <span id="year">2026</span> GigaTorq. All rights reserved.
    </div>
  </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
"""

FOOTER_LINKS = []  # filled by build.py with the published best-list pages


def esc(s):
    return html.escape(str(s), quote=True)


def page(path, title, desc, body, active=None, noindex=False, lastmod='2026-10-21', jsonld=None, og_type='website'):
    act = ' class="active"'
    nav = '\n'.join('      <li><a href="%s"%s>%s</a></li>' % (href, act if href == active else '', label)
                    for href, label in NAV)
    tools = '\n'.join(f'          <li><a href="{href}">{esc(label)}</a></li>' for href, label in FOOTER_LINKS) \
        or '          <li><a href="/best/">All best picks</a></li>'
    ld = ''
    if jsonld:
        ld = '\n<script type="application/ld+json">' + json.dumps(jsonld, ensure_ascii=False).replace('</', '<\\/') + '</script>'
    out_html = HEAD.format(title=esc(title), desc=esc(desc), path=path, nav=nav, og_type=og_type,
                           robots='\n<meta name="robots" content="noindex, follow">' if noindex else '',
                           jsonld=ld) + body + FOOT.format(tools=tools)
    if path.endswith('.html'):
        out = os.path.join(ROOT, path.strip('/'))
    else:
        out = os.path.join(ROOT, path.strip('/'), 'index.html') if path != '/' else os.path.join(ROOT, 'index.html')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, 'w', encoding='utf-8', newline='\n') as f:
        f.write(out_html)
    if not path.endswith('.html'):
        WRITTEN.append((path, lastmod, not noindex))


def load_db():
    """Load schema + every seed file into an in-memory SQLite database."""
    c = sqlite3.connect(':memory:')
    c.row_factory = sqlite3.Row
    c.executescript(open(os.path.join(DB_DIR, 'schema.sql'), encoding='utf-8').read())
    for f in sorted(glob.glob(os.path.join(DB_DIR, 'seed', '*.sql'))):
        c.executescript(open(f, encoding='utf-8').read())
    return c


def write_sitemap():
    rows = [f'  <url><loc>{SITE}{p}</loc><lastmod>{d}</lastmod></url>' for p, d, ok in WRITTEN if ok]
    xml = ('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
           + '\n'.join(rows) + '\n</urlset>\n')
    open(os.path.join(ROOT, 'sitemap.xml'), 'w', encoding='utf-8', newline='\n').write(xml)