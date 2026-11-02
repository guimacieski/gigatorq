"""The Compare (/compare/) and Reviews (/reviews/ and /reviews/<tool>/) pages.
Compare runs in the browser on assets/data/tools.json. Each tool review is a static page, so search engines can index it;
the search box on the Reviews pages uses the same JSON."""
import json, os
from layout import page, esc, asset_version, ROOT, SITE
import tools_data

UPDATED = '2026-11-02'
IMG = '/assets/img/illustrations/web/'


def singular(name):
    return name[:-2] if name.endswith(('ches', 'shes')) else name[:-1] if name.endswith('s') else name


def fmt(v):
    return f'{v:,.0f}' if float(v).is_integer() else f'{v:,.2f}'.rstrip('0').rstrip('.')


def band(v):
    if v < 50:
        return 'Under $50'
    step = 50 if v < 300 else 100
    lo = int(v // step * step)
    return f'${lo}&ndash;{lo + step}'


def title(t):
    return f"{t['b']} {t['m']}"


def crumbs_ld(items):
    return {'@type': 'BreadcrumbList', 'itemListElement': [
        {'@type': 'ListItem', 'position': i + 1, 'name': name, 'item': SITE + url} for i, (name, url) in enumerate(items)]}


def search_box(src, js):
    return f"""    <div class="tool-app" id="reviews-app" data-app="reviews" data-src="{src}">
      <div class="search-box">
        <input type="search" id="q" placeholder="Search a brand, model or type" autocomplete="off" aria-label="Search tools" aria-controls="q-results">
        <ul id="q-results" class="results" role="listbox" hidden></ul>
      </div>
    </div>"""


def platform(t):
    if t['power'] == 'corded':
        return 'Corded'
    p = esc(t['p'] or '')
    if t['v'] and f"{fmt(t['v'])}V" not in (t['p'] or ''):
        p += f' <small class="muted">({fmt(t["v"])}V)</small>'
    return p


def review_page(t, cats, peers, best_by_cat, src, js):
    c = cats[t['c']]
    kind = singular(c['name']).lower()
    name = title(t)

    # how it ranks against every tool of the same type
    bars = []
    for sp in c['specs']:
        v = t['nums'].get(sp['k'])
        txt = t['specs'].get(sp['k'])
        if v is None or sp['hib'] is None or not txt or ';' in txt:
            continue
        vals = [p['nums'][sp['k']] for p in peers if p['nums'].get(sp['k']) is not None]
        if len(vals) < 3:
            continue
        best = max(vals) if sp['hib'] else min(vals)
        rank = 1 + sum(1 for x in vals if (x > v if sp['hib'] else x < v))
        bars.append((sp['label'] + ('' if sp['hib'] else ' (lower is better)'), v / best if sp['hib'] else best / v, txt, rank, len(vals)))
    r = t['rating']
    if r and r['avg']:
        rs = [p['rating']['avg'] for p in peers if p['rating'] and p['rating']['avg']]
        if len(rs) >= 3:
            bars.append(('Owner rating', r['avg'] / 5, f"{r['avg']:.1f} / 5", 1 + sum(1 for x in rs if x > r['avg']), len(rs)))
    bar_html = ''.join(
        f'<div class="rbar"><span class="rbar-l">{esc(l)}</span><span class="mbar-t"><i style="width:{round(pct * 100)}%"></i></span>'
        f'<span class="rbar-v">{esc(v)} <small class="muted">#{rank} of {n}</small></span></div>' for l, pct, v, rank, n in bars)

    chips = [('Corded' if t['power'] == 'corded' else ((f"{fmt(t['v'])}V " if t['v'] and f"{fmt(t['v'])}V" not in (t['p'] or '') else '') + (t['p'] or ''))),
             (t['motor'] or '').title()]
    chips += [t['specs'][sp['k']] for sp in c['specs'] if sp['key'] and t['specs'].get(sp['k']) and ';' not in t['specs'][sp['k']]][:3]
    chip_html = ''.join(f'<span>{esc(x)}</span>' for x in chips if x)

    spec_rows = [('Battery platform', platform(t))] + ([('Motor', esc(t['motor'].title()))] if t['motor'] else [])
    spec_rows += [(esc(sp['label']), esc(t['specs'][sp['k']])) for sp in c['specs'] if t['specs'].get(sp['k'])]
    if t['w']:
        spec_rows.append(('Warranty', esc(t['w'])))
    spec_html = ''.join(f'<tr><th>{l}</th><td>{v}</td></tr>' for l, v in spec_rows)

    if t['likes'] or t['gripes']:
        owners = ((f'<h3>What owners like</h3><ul class="pros">{"".join(f"<li>{esc(x)}</li>" for x in t["likes"])}</ul>' if t['likes'] else '')
                  + (f'<h3>What owners complain about</h3><ul class="cons">{"".join(f"<li>{esc(x)}</li>" for x in t["gripes"])}</ul>' if t['gripes'] else '')
                  + (f'<p class="muted small">Summarized in our own words from {t["read"]} owner reviews we read at a major US retailer.</p>' if t['read'] else ''))
    else:
        owners = ("<p class=\"muted\">We haven't read enough owner reviews of this tool to sum up what owners say yet."
                  + (' Its star rating is shown above.' if r and r['avg'] else '') + '</p>')

    fig = ''
    if t['img']:
        b = IMG + t['img']
        fig = (f'<figure class="pick-figure"><img src="{b}.jpg" srcset="{b}-800.jpg 800w, {b}.jpg 1600w" sizes="(max-width: 760px) 100vw, 440px" '
               f'width="1600" height="900" style="width:100%;height:auto;aspect-ratio:16/9;object-fit:cover" alt="Illustration of the {esc(name)} {esc(kind)}" '
               f'onerror="this.parentNode.remove()"><figcaption>AI illustration of the {esc(name)}, made using photos of the real tool as a reference. '
               f'Not a photo of the actual product.</figcaption></figure>')

    price = (f'<p class="price-line">{band(t["price"]["usd"])} <small>{"kit with battery and charger" if t["price"]["what"] == "kit" else "tool only"}</small></p>'
             if t['price'] else '')
    rating = (f'<p>&#9733; <b>{r["avg"]:.1f}</b> / 5 <small class="muted">({r["count"]:,} reviews, checked {esc(r["on"])})</small></p>'
              if r and r['avg'] else '')
    pick = t['pick']
    best = best_by_cat.get(t['c'])
    buttons = f'<a class="btn" href="/compare/?a={t["s"]}">Compare with other {esc(c["name"].lower())}</a>'
    if pick:
        buttons += f'<a class="btn btn-ghost" href="{pick["url"]}">See it in {esc(pick["page"])}</a>'
    elif best:
        buttons += f'<a class="btn btn-ghost" href="{best["path"]}">See our {esc(best["h1"].lower())}</a>'
    fit = (f'<dl class="fit-list"><div><dt>Best for</dt><dd>{esc(pick["best_for"])}</dd></div>'
           f'<div><dt>Skip it if</dt><dd>{esc(pick["skip_if"])}</dd></div></dl>' if pick else '')
    others = [p for p in peers if p['s'] != t['s']]
    others_html = ''.join(f'<li><a href="/reviews/{p["s"]}/">{esc(title(p))}</a> <span class="muted">{esc(p["n"])}</span></li>' for p in others)

    body = f"""
<section class="section">
  <div class="container wide-article">
    <div class="breadcrumb"><a href="/">Home</a> / <a href="/reviews/">Reviews</a> / <a href="/reviews/#{t['c']}">{esc(c['name'])}</a> / {esc(name)}</div>
{search_box(src, js)}
    <article class="review">
      <div class="pick slim{' has-media' if fig else ''}" style="margin-top:8px;border-top:0;padding-top:0">
        <div class="pick-media">{fig}</div>
        <div class="pick-body">
          <span class="tag">{esc(pick['label'] if pick else singular(c['name']))}</span>
          <h1>{esc(name)} review</h1>
          <p class="lead-in">{esc(pick['headline'] if pick else t['n'])}</p>
          <div class="chips">{chip_html}</div>
          {price}
          {rating}
          <div class="buy-box">{buttons}</div>
        </div>
      </div>
      {fit}
      {f'<h2>How it ranks among the {len(peers)} {esc(c["name"].lower())} we track</h2><div class="rbars">{bar_html}</div><p class="muted small">Bars compare this {esc(kind)} with the best published figure of its type. Rank counts only tools whose brand publishes that number.</p>' if bar_html else ''}
      <h2>What owners say</h2>
      {owners}
      <h2>{esc(name)} specs</h2>
      <div class="table-wrap"><table class="compare spec-table"><tbody>{spec_html}</tbody></table></div>
      <p class="muted small">Full name: {esc(t['b'])} {esc(t['n'])} ({esc(t['m'])}). Specs come from {esc(t['b'])}'s published specs and major US retailers. Price ranges and ratings change often. We didn't test this tool ourselves (<a href="/how-we-choose/">how we choose</a>).</p>
      {f'<h2>Other {esc(c["name"].lower())} we track</h2><ul class="browse-list">{others_html}</ul>' if others_html else ''}
    </article>
  </div>
</section>
<script src="{js}" defer></script>
"""
    facts = [x for x in chips[2:]][:3]
    facts = [f for f in facts if len(f) <= 24][:2]
    desc = (f"{name} {kind} review" + (': ' + ', '.join(facts) if facts else '') + '. '
            + f"Full specs, how it ranks among the {len(peers)} {c['name'].lower()} we track, and what owners say.")
    ld = {'@context': 'https://schema.org', '@graph': [
        {'@type': 'WebPage', 'name': f'{name} review', 'description': desc, 'url': f"{SITE}/reviews/{t['s']}/", 'dateModified': UPDATED},
        crumbs_ld([('Home', '/'), ('Reviews', '/reviews/'), (c['name'], f"/reviews/#{t['c']}"), (name, f"/reviews/{t['s']}/")]),
    ]}
    page(f"/reviews/{t['s']}/", f'{name} Review: Specs and Rankings | GigaTorq', desc, body, '/reviews/', lastmod=UPDATED, jsonld=ld)


def build(db, best_pages):
    n = tools_data.export(db)
    data = json.load(open(os.path.join(ROOT, 'assets', 'data', 'tools.json'), encoding='utf-8'))
    cats, tools = data['categories'], data['tools']
    by_cat = {c: [t for t in tools if t['c'] == c] for c in cats}
    src = f"/assets/data/tools.json?v={asset_version('assets/data/tools.json')}"
    js = f"/assets/js/tools.js?v={asset_version('assets/js/tools.js')}"
    n_brands = len({t['b'] for t in tools})
    best_by_cat = {b['category']: b for b in best_pages}

    # ---------------- Compare ----------------
    groups = ''.join(
        f'<optgroup label="{esc(cats[c]["name"])}">' +
        ''.join(f'<option value="{t["s"]}">{esc(t["b"])} {esc(t["m"])}</option>' for t in ts) + '</optgroup>'
        for c, ts in by_cat.items() if ts)

    # Ready-made matchups from the best-list picks: the top pick against the next one, plus a three-way.
    name = {t['s']: title(t) for t in tools}
    matchups = []
    for b in best_pages:
        p = [x['tool'] for x in b['picks']]
        matchups.append((f'/compare/?a={p[0]}&amp;b={p[1]}', f'{name[p[0]]} vs {name[p[1]]}', b['tag']))
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
    page('/compare/', 'Compare Power Tools Side by Side | GigaTorq',
         f'Pick up to three drills, drivers, saws or grinders and compare published specs, price ranges, owner ratings and warranties side by side. {n} tools from {n_brands} brands.',
         compare, '/compare/', lastmod=UPDATED,
         jsonld={'@context': 'https://schema.org', **crumbs_ld([('Home', '/'), ('Comparisons', '/compare/')])})

    # ---------------- One static review page per tool ----------------
    for t in tools:
        review_page(t, cats, by_cat[t['c']], best_by_cat, src, js)

    # ---------------- Reviews hub ----------------
    top = [t for t in tools if t['pick'] and t['pick']['label'] == 'Best overall']
    pick_cards = '\n'.join(
        f'''        <a class="card pick-card" href="/reviews/{t['s']}/">
          {f'<img class="card-thumb" src="{IMG}{t["img"]}-800.jpg" width="800" height="450" alt="" loading="lazy" style="width:100%;height:auto;aspect-ratio:16/9;object-fit:cover" onerror="this.remove()">' if t['img'] else ''}
          <span class="tag">Best {esc(singular(cats[t['c']]['name']).lower())}</span>
          <h3>{esc(title(t))}</h3>
          <p>{esc(t['pick']['headline'])}</p>
        </a>''' for t in top)
    browse = '\n'.join(
        f'''      <section class="browse-cat" id="{c}">
        <h3>{esc(cats[c]['name'])} <small class="muted">({len(ts)})</small></h3>
        <ul class="browse-list">{''.join(f'<li><a href="/reviews/{t["s"]}/">{esc(title(t))}</a> <span class="muted">{esc(t["n"])}</span></li>' for t in ts)}</ul>
      </section>''' for c, ts in by_cat.items() if ts)

    reviews = f"""
<section class="section">
  <div class="container wide-article">
    <div class="breadcrumb"><a href="/">Home</a> / Reviews</div>
    <h1>Power tool reviews</h1>
    <p class="muted" style="max-width:680px">Search any of the {n} tools in our database by brand, model or type. Each review shows the published specs, how the tool ranks against others of its type and what owners report.</p>
{search_box(src, js)}
    <h2>Best overall in each category</h2>
    <div class="grid grid-3">
{pick_cards}
    </div>
    <h2>Browse by type</h2>
{browse}
  </div>
</section>
<script src="{js}" defer></script>
"""
    page('/reviews/', 'Power Tool Reviews: Specs and Rankings | GigaTorq',
         f'Search {n} drills, drivers, saws and grinders from {n_brands} brands. See published specs, how each tool ranks against its type, and what owners report.',
         reviews, '/reviews/', lastmod=UPDATED,
         jsonld={'@context': 'https://schema.org', **crumbs_ld([('Home', '/'), ('Reviews', '/reviews/')])})