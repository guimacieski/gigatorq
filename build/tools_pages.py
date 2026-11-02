"""The Compare (/compare/) and Reviews (/reviews/) pages. Both run in the browser on assets/data/tools.json;
the HTML here carries everything a search engine or a visitor without JavaScript needs (lists of tools and links)."""
import json, os
from layout import page, esc, asset_version, ROOT
import tools_data


def singular(name):
    return name[:-2] if name.endswith(('ches', 'shes')) else name[:-1] if name.endswith('s') else name


def build(db, best_pages):
    n = tools_data.export(db)
    data = json.load(open(os.path.join(ROOT, 'assets', 'data', 'tools.json'), encoding='utf-8'))
    cats, tools = data['categories'], data['tools']
    by_cat = {c: [t for t in tools if t['c'] == c] for c in cats}
    src = f"/assets/data/tools.json?v={asset_version('assets/data/tools.json')}"
    js = f"/assets/js/tools.js?v={asset_version('assets/js/tools.js')}"
    n_brands = len({t['b'] for t in tools})

    # ---------------- Compare ----------------
    groups = ''.join(
        f'<optgroup label="{esc(cats[c]["name"])}">' +
        ''.join(f'<option value="{t["s"]}">{esc(t["b"])} {esc(t["m"])}</option>' for t in ts) + '</optgroup>'
        for c, ts in by_cat.items() if ts)

    # Ready-made matchups from the best-list picks: the top pick against the next ones, plus a three-way.
    matchups = []
    for b in best_pages:
        p = [x['tool'] for x in b['picks']]
        name = {t['s']: f"{t['b']} {t['m']}" for t in tools}
        for other in p[1:2]:
            matchups.append((f'/compare/?a={p[0]}&amp;b={other}', f'{name[p[0]]} vs {name[other]}', b['tag']))
        if len(p) >= 3:
            matchups.append((f'/compare/?a={p[0]}&amp;b={p[1]}&amp;c={p[2]}', f'{name[p[0]]} vs {name[p[1]]} vs {name[p[2]]}', b['tag']))
    match_html = '\n'.join(f'        <a class="card match-card" href="{u}"><span class="tag">{esc(tag)}</span><h3>{esc(label)}</h3></a>'
                           for u, label, tag in matchups)

    compare = f"""
<section class="section">
  <div class="container wide-article">
    <div class="breadcrumb"><a href="/">Home</a> / Comparisons</div>
    <h1>Compare power tools side by side</h1>
    <p class="muted" style="max-width:680px">Pick up to three tools from the {n} in our database. After your first pick, the other two lists only show tools of the same type, so a drill is never lined up against a saw.</p>

    <div class="tool-app" id="compare-app" data-app="compare" data-src="{src}">
      <div class="picker">
        <label><span>First tool</span><select id="c1"><option value="">Choose a tool&hellip;</option>{groups}</select></label>
        <label><span>Second tool</span><select id="c2" disabled><option value="">Pick the first tool</option></select></label>
        <label><span>Third tool <small>(optional)</small></span><select id="c3" disabled><option value="">Pick the first tool</option></select></label>
      </div>
      <div id="compare-out" aria-live="polite"></div>
      <noscript><p class="placeholder">The comparison tool needs JavaScript. You can still browse every tool on the <a href="/reviews/">Reviews</a> page.</p></noscript>
    </div>

    <h2>Popular matchups</h2>
    <div class="grid grid-3 matchups">
{match_html}
    </div>
    <p class="muted small">Every number comes from the brand's published specs or a major US retailer. Green marks the best published spec in each row. A dash means the brand doesn't publish that spec. We didn't test these tools ourselves (<a href="/how-we-choose/">how we choose</a>).</p>
  </div>
</section>
<script src="{js}" defer></script>
"""
    page('/compare/', 'Compare Power Tools Side by Side: Specs, Prices and Ratings | GigaTorq',
         f'Pick up to three drills, drivers, saws or grinders and compare published specs, price ranges, owner ratings and warranties side by side. {n} tools from {n_brands} brands.',
         compare, '/compare/', lastmod='2026-11-02')

    # ---------------- Reviews ----------------
    picked = [t for t in tools if t['pick']]
    pick_cards = '\n'.join(
        f'''        <a class="card pick-card" href="/reviews/?tool={t['s']}">
          {f'<img class="card-thumb" src="/assets/img/illustrations/web/{t["img"]}-800.jpg" width="800" height="450" alt="" loading="lazy" style="width:100%;height:auto;aspect-ratio:16/9;object-fit:cover" onerror="this.remove()">' if t['img'] else ''}
          <span class="tag">{esc(t['pick']['label'])}</span>
          <h3>{esc(t['b'])} {esc(t['m'])}</h3>
          <p>{esc(t['pick']['headline'])}</p>
        </a>''' for t in picked)
    browse = '\n'.join(
        f'''      <section class="browse-cat" id="{c}">
        <h3>{esc(cats[c]['name'])} <small class="muted">({len(ts)})</small></h3>
        <ul class="browse-list">{''.join(f'<li><a href="/reviews/?tool={t["s"]}">{esc(t["b"])} {esc(t["m"])}</a> <span class="muted">{esc(t["n"])}</span></li>' for t in ts)}</ul>
      </section>''' for c, ts in by_cat.items() if ts)

    reviews = f"""
<section class="section">
  <div class="container wide-article">
    <div class="breadcrumb"><a href="/">Home</a> / Reviews</div>
    <div id="reviews-head">
      <h1>Power tool reviews</h1>
      <p class="muted" style="max-width:680px">Search any of the {n} tools in our database by brand, model or type. Each review shows the published specs, how the tool ranks against others of its type, its price range and what owners report.</p>
    </div>

    <div class="tool-app" id="reviews-app" data-app="reviews" data-src="{src}">
      <div class="search-box">
        <input type="search" id="q" placeholder="Search a brand, model or type" autocomplete="off" aria-label="Search tools" aria-controls="q-results">
        <ul id="q-results" class="results" role="listbox" hidden></ul>
      </div>
      <div id="review-out" aria-live="polite"></div>
    </div>

    <div id="review-browse">
      <h2>Our top picks</h2>
      <div class="grid grid-3">
{pick_cards}
      </div>
      <h2>Browse by type</h2>
{browse}
    </div>
  </div>
</section>
<script src="{js}" defer></script>
"""
    page('/reviews/', 'Power Tool Reviews: Specs, Rankings and Owner Ratings | GigaTorq',
         f'Search {n} drills, drivers, saws and grinders from {n_brands} brands. See published specs, how each tool ranks against its type, price ranges and what owners report.',
         reviews, '/reviews/', lastmod='2026-11-02')