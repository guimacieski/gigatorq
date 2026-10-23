"""Best-list pages (/best/...): editorial picks from build/content/*.json, numbers from the database."""
import json
from datetime import date
from layout import page, esc, DISCLOSURE

# Store names and "Check price" buttons stay off the pages until affiliate programs are live.
# Set to True then (and add affiliate_url to the listings); store links still appear in Sources.
SHOW_STORES = False


def fmt_date(iso):
    d = date.fromisoformat(iso)
    return d.strftime('%B ') + str(d.day) + d.strftime(', %Y')


def num(v):
    if v is None:
        return None
    return f'{v:,.0f}' if float(v).is_integer() else f'{v:,.2f}'.rstrip('0').rstrip('.')


def inch(v):
    """1.5 -> 1-1/2 in., 0.375 -> 3/8 in. (sixteenths)."""
    whole, frac = int(v), round((v - int(v)) * 16)
    if frac == 16:
        whole, frac = whole + 1, 0
    if not frac:
        return f'{whole} in.'
    n, d = frac, 16
    while n % 2 == 0:
        n, d = n // 2, d // 2
    return f'{whole}-{n}/{d} in.' if whole else f'{n}/{d} in.'


class Tool:
    """Everything the page needs about one tool, read from the database."""

    def __init__(self, db, slug):
        self.db = db
        t = db.execute("""SELECT t.*, b.name AS brand, b.slug AS brand_slug, p.name AS platform, p.nominal_voltage_v AS nominal,
                                 p.marketing_voltage_v AS marketing, c.name AS category
                          FROM tool t JOIN brand b ON b.id = t.brand_id JOIN category c ON c.id = t.category_id
                          LEFT JOIN platform p ON p.id = t.platform_id WHERE t.slug = ?""", (slug,)).fetchone()
        if t is None:
            raise SystemExit(f'unknown tool {slug}')
        self.t = t
        self.specs = {}
        for r in db.execute("""SELECT sd.key, ts.qualifier, ts.value_num, ts.value_min, ts.value_max, ts.value_bool, ts.value_text,
                                      ts.source_url, ts.source_type FROM tool_spec ts JOIN spec_definition sd ON sd.id = ts.spec_id
                               WHERE ts.tool_id = ? ORDER BY ts.rowid""", (t['id'],)):
            r = dict(r)
            r['qualifier'] = r['qualifier'] or None  # older seed rows store '' for "no qualifier"
            self.specs.setdefault(r['key'], []).append(r)

    @property
    def name(self):
        return f"{self.t['brand']} {self.t['model']}"

    def one(self, key, qual=None):
        for r in self.specs.get(key, []):
            if r['qualifier'] == qual:
                return r
        return None

    def val(self, key, qual=None):
        r = self.one(key, qual)
        return None if r is None else r['value_num']

    def speeds(self):
        rows = [r for r in self.specs.get('no_load_speed', []) if r['qualifier'] in (None, 'speed:1', 'speed:2', 'speed:3')]
        vals = [r['value_num'] for r in sorted(rows, key=lambda r: r['qualifier'] or '')]
        return ' / '.join(num(v) for v in vals) if vals else None

    def weight(self):
        """(text, kind) preferring tool-only weight; falls back to weight with battery."""
        w = self.val('weight_tool_only')
        if w is not None:
            return f'{num(w)} lb', 'tool only'
        for r in self.specs.get('weight_with_battery', []):
            return f"{num(r['value_num'])} lb", 'with battery'
        return None, None

    def voltage(self):
        if self.t['nominal'] is None:
            return self.t['platform']
        return f"{num(self.t['nominal'])}V <span class=\"muted\">({esc(self.t['platform'])})</span>"

    def warranty(self):
        w = self.db.execute("""SELECT wp.* FROM tool_warranty tw JOIN warranty_policy wp ON wp.id = tw.warranty_policy_id
                               WHERE tw.tool_id = ?""", (self.t['id'],)).fetchone()
        if w is None:
            w = self.db.execute("""SELECT * FROM warranty_policy WHERE brand_id = ? AND applies_to IN ('tool','all')
                                   AND product_line_id IS NULL AND platform_id IS NULL ORDER BY id LIMIT 1""",
                                (self.t['brand_id'],)).fetchone()
        if w is None:
            return None
        if w['is_lifetime']:
            return 'Lifetime' + (' (with registration)' if w['requires_registration'] else '')
        return f"{num(w['years'])} years" + (' (with registration)' if w['requires_registration'] else '')

    def sku(self, model):
        return self.db.execute('SELECT * FROM sku WHERE model_number = ? AND brand_id = ?', (model, self.t['brand_id'])).fetchone()

    def skus(self):
        return self.db.execute("""SELECT DISTINCT s.* FROM sku s JOIN sku_item i ON i.sku_id = s.id
                                  WHERE i.tool_id = ? ORDER BY s.id""", (self.t['id'],)).fetchall()

    def price(self, sku_id):
        """Latest observed price for a SKU, cheapest across retailers."""
        return self.db.execute("""SELECT p.price_usd, p.observed_at, l.url, l.affiliate_url, r.name AS retailer
                                  FROM listing l JOIN price_observation p ON p.listing_id = l.id JOIN retailer r ON r.id = l.retailer_id
                                  WHERE l.sku_id = ? ORDER BY p.observed_at DESC, p.price_usd ASC LIMIT 1""", (sku_id,)).fetchone()

    def rating(self, sku_id):
        return self.db.execute("""SELECT rs.*, r.name AS retailer FROM rating_snapshot rs JOIN retailer r ON r.id = rs.retailer_id
                                  WHERE rs.sku_id = ? ORDER BY rs.observed_on DESC, rs.id DESC LIMIT 1""", (sku_id,)).fetchone()

    def best_rating(self):
        rows = [self.rating(s['id']) for s in self.skus()]
        rows = [r for r in rows if r is not None]
        return max(rows, key=lambda r: (r['review_count'] or 0)) if rows else None

    def items(self, sku_id):
        out = []
        for i in self.db.execute("""SELECT i.qty, i.item_text, t.slug, b.capacity_ah, b.model AS bmodel
                                    FROM sku_item i LEFT JOIN tool t ON t.id = i.tool_id LEFT JOIN battery b ON b.id = i.battery_id
                                    WHERE i.sku_id = ? ORDER BY i.id""", (sku_id,)):
            if i['slug'] == self.t['slug']:
                continue
            label = f"{num(i['capacity_ah'])}Ah battery" if i['bmodel'] else (i['item_text'] or i['slug'])
            out.append(f"{i['qty']}&times; {esc(label)}" if i['qty'] > 1 else esc(label))
        return out

    def themes(self):
        return self.db.execute('SELECT * FROM owner_theme WHERE tool_id = ? ORDER BY id', (self.t['id'],)).fetchall()

    def sources(self):
        seen = []
        for rows in self.specs.values():
            for r in rows:
                if r['source_url'] and r['source_url'] not in seen:
                    seen.append(r['source_url'])
        return seen


def buy_button(p, ghost=False):
    if p is None or not SHOW_STORES:
        return ''
    href = p['affiliate_url'] or p['url']
    rel = 'sponsored nofollow noopener' if p['affiliate_url'] else 'nofollow noopener'
    cls = 'btn btn-ghost' if ghost else 'btn'
    return f'<a class="{cls}" href="{esc(href)}" rel="{rel}" target="_blank">Check price at {esc(p["retailer"])}</a>'


def stars(r):
    if r is None:
        return '<span class="muted">No owner ratings found</span>'
    if r['avg_rating'] is None:
        return f'<span class="rating">{r["review_count"]:,} reviews <span class="muted">(average not shown)</span></span>'
    return (f'<span class="rating"><b>{r["avg_rating"]:.1f}</b><span class="muted">/5</span> '
            f'<span class="muted">from {r["review_count"]:,} reviews</span></span>')


def render(db, spec):
    picks = [(p, Tool(db, p['tool'])) for p in spec['picks']]
    cat = spec['category']
    n_tools = db.execute('SELECT count(*) FROM tool t JOIN category c ON c.id = t.category_id WHERE c.slug = ?', (cat,)).fetchone()[0]
    n_brands = db.execute('SELECT count(DISTINCT brand_id) FROM tool t JOIN category c ON c.id = t.category_id WHERE c.slug = ?', (cat,)).fetchone()[0]
    store_hosts = {r[0].split('/')[2].replace('www.', '') for r in db.execute('SELECT website FROM retailer WHERE website IS NOT NULL')}

    def link_text(u):
        host = u.split('/')[2]
        if not SHOW_STORES and host.replace('www.', '') in store_hosts:
            return 'retailer page'
        return host

    upd = fmt_date(spec['updated'])
    all_sources = []

    def anchor(t):
        return t.t['slug']

    # --- at a glance
    glance = []
    for p, t in picks:
        s = t.sku(p['buy_sku'])
        pr = t.price(s['id'])
        torque = t.val('max_torque')
        w, wk = t.weight()
        chips = [f'{num(torque)} in-lbs' if torque else 'Torque not published',
                 f'{w} ({wk})' if w else None,
                 'Brushless' if t.t['motor_type'] == 'brushless' else 'Brushed']
        chips = ''.join(f'<span>{esc(c)}</span>' for c in chips if c)
        price = (f'<div class="price">${num(pr["price_usd"])} <small>{esc(s["sku_type"].replace("_", " "))}{(" &middot; " + esc(pr["retailer"])) if SHOW_STORES else ""}</small></div>'
                 if pr else '')
        glance.append(f"""      <div class="card pick-card">
        <span class="tag">{esc(p['label'])}</span>
        <h3><a href="#{anchor(t)}">{esc(t.name)}</a></h3>
        <p>{esc(p['headline'])}</p>
        <div class="chips">{chips}</div>
        <div class="pick-foot">{price}{stars(t.rating(s['id']))}</div>
        {('<div class="buy-box">' + buy_button(pr) + '</div>') if SHOW_STORES else ''}
      </div>""")

    # --- comparison table
    rows = []
    for p, t in picks:
        s = t.sku(p['buy_sku'])
        pr = t.price(s['id'])
        torque = t.val('max_torque')
        w, wk = t.weight()
        clutch = t.val('clutch_settings')
        length = t.val('length')
        r = t.rating(s['id'])
        rows.append('          <tr>'
                    f'<th><a href="#{anchor(t)}">{esc(t.name)}</a><br><small class="muted">{esc(p["label"])}</small></th>'
                    f'<td>{t.voltage()}</td>'
                    f'<td>{num(torque) + " in-lbs" if torque else "Not published"}</td>'
                    f'<td>{t.speeds() or "&ndash;"}</td>'
                    f'<td>{w + "<br><small class=muted>" + wk + "</small>" if w else "&ndash;"}</td>'
                    f'<td>{num(length) + " in." if length else "&ndash;"}</td>'
                    f'<td>{num(clutch) if clutch else "&ndash;"}</td>'
                    f'<td>{esc(t.warranty()) if t.warranty() else "&ndash;"}</td>'
                    f'<td>{"$" + num(pr["price_usd"]) + "<br><small class=muted>" + esc(s["sku_type"].replace("_", " ")) + "</small>" if pr else "&ndash;"}</td>'
                    f'<td>{"%.1f" % r["avg_rating"] + " <small class=muted>(" + format(r["review_count"], ",") + ")</small>" if r and r["avg_rating"] else (format(r["review_count"], ",") + " reviews" if r else "&ndash;")}</td>'
                    '</tr>')
    table = '\n'.join(rows)

    # --- one section per pick
    sections = []
    for p, t in picks:
        s = t.sku(p['buy_sku'])
        pr = t.price(s['id'])
        why = '\n'.join(f'      <p>{w}</p>' for w in p['why'])
        # buying options: every SKU of this tool with a price
        opts = []
        for k in t.skus():
            kp = t.price(k['id'])
            if kp is None:
                continue
            inc = t.items(k['id'])
            what = 'Tool only' if k['sku_type'] == 'tool_only' else ('Kit: ' + ', '.join(inc) if inc else 'Kit')
            opts.append(f'<li><b>{esc(k["model_number"])}</b> &middot; {what} &middot; <b>${num(kp["price_usd"])}</b>'
                        + (f' at <a href="{esc(kp["affiliate_url"] or kp["url"])}" rel="{"sponsored " if kp["affiliate_url"] else ""}nofollow noopener" target="_blank">{esc(kp["retailer"])}</a>' if SHOW_STORES else '') +
                        f' <small class="muted">({fmt_date(kp["observed_at"])})</small></li>')
            all_sources.append((f'{k["model_number"]} price', kp['url']))
        r = t.best_rating()
        th = t.themes()
        if r is not None:
            all_sources.append((f'{t.name} owner rating', r['url']))
        owner = [f'      <p>{stars(r)}' + (f' <span class="muted">&middot; checked {fmt_date(r["observed_on"])} (<a href="{esc(r["url"])}" rel="nofollow noopener" target="_blank">source</a>)</span>' if r else '') + '</p>']
        if th:
            pros = ''.join(f'<li>{esc(x["theme"])}</li>' for x in th if x['sentiment'] == 'praise')
            cons = ''.join(f'<li>{esc(x["theme"])}</li>' for x in th if x['sentiment'] == 'complaint')
            n_read = th[0]['reviews_read']
            owner.append(f'      <div class="grid grid-2 owner"><div><h4>What owners like</h4><ul class="pros">{pros}</ul></div>'
                         f'<div><h4>What they complain about</h4><ul class="cons">{cons or "<li>No recurring complaints in the reviews we read</li>"}</ul></div></div>')
            rare = all(x['frequency'] == 'rarely' for x in th if x['sentiment'] == 'complaint')
            owner.append(f'      <p class="muted small">Summarized in our own words from the {n_read} reviews we could read on the first page of '
                         f'<a href="{esc(json.loads(th[0]["sources"])[0])}" rel="nofollow noopener" target="_blank">a major US retailer\'s reviews</a> '
                         f'on {fmt_date(th[0]["researched_on"])}.' + (' Each complaint listed came up in only one or two of them.' if rare else '')
                         + (' ' + esc(p['owner_note']) if p.get('owner_note') else '') + '</p>')
            for u in json.loads(th[0]['sources']):
                all_sources.append((f'{t.name} owner reviews', u))
        else:
            owner.append('      <p class="muted small">We couldn\'t read individual reviews for this drill when we checked, so we only report its rating here.</p>')
        srcs = t.sources()
        for u in srcs:
            all_sources.append((f'{t.name} specs', u))
        src_list = ''.join(f'<li><a href="{esc(u)}" rel="nofollow noopener" target="_blank">{esc(link_text(u))}</a></li>' for u in srcs)
        sections.append(f"""    <section class="pick" id="{anchor(t)}">
      <span class="tag">{esc(p['label'])}</span>
      <h2>{esc(t.name)}</h2>
      <p class="muted small">{esc(t.t['name'])}</p>
      <p class="lead-in">{esc(p['headline'])}</p>
{why}
      <div class="grid grid-2 fit">
        <div class="card"><h4>Best for</h4><p>{esc(p['best_for'])}</p></div>
        <div class="card"><h4>Skip it if</h4><p>{esc(p['skip_if'])}</p></div>
      </div>
      <h3>What owners say</h3>
{chr(10).join(owner)}
      <h3>Kits and prices</h3>
      <ul class="options">{''.join(opts)}</ul>
      {('<div class="buy-box">' + buy_button(pr) + '</div>') if SHOW_STORES else ''}
      <details class="sources"><summary>Spec sources for the {esc(t.name)}</summary><ul>{src_list}</ul></details>
    </section>""")

    # --- also considered
    also = []
    for a in spec.get('also', []):
        t = Tool(db, a['tool'])
        s = t.sku(a['sku'])
        pr = t.price(s['id']) if s else None
        if pr:
            all_sources.append((f'{s["model_number"]} price', pr['url']))
        price = f' Last seen at <b>${num(pr["price_usd"])}</b> (tool only){(" at " + esc(pr["retailer"])) if SHOW_STORES else ""}, {fmt_date(pr["observed_at"])}.' if pr else ''
        also.append(f'      <li><b>{esc(t.name)}</b>: {esc(a["text"])}{price}</li>')

    guide = '\n'.join(f'      <h3>{esc(h)}</h3>\n      <p>{esc(b)}</p>' for h, b in spec['guide'])
    faq = '\n'.join(f'      <details class="faq"><summary>{esc(q)}</summary><p>{esc(a)}</p></details>' for q, a in spec['faq'])
    toc = ''.join(f'<li><a href="#{anchor(t)}">{esc(p["label"])}: {esc(t.name)}</a></li>' for p, t in picks)
    intro = '\n'.join(f'    <p>{x.format(n_tools=n_tools, n_brands=n_brands)}</p>' for x in spec['intro'])

    uniq, seen = [], set()
    for label, u in all_sources:
        if u not in seen:
            seen.add(u)
            uniq.append((label, u))
    src_html = ''.join(f'<li>{esc(l)}: <a href="{esc(u)}" rel="nofollow noopener" target="_blank">{esc(link_text(u))}</a></li>' for l, u in uniq)

    body = f"""
<section class="section">
  <div class="container article wide-article">
    <div class="breadcrumb"><a href="/">Home</a> / <a href="/best/">Best Picks</a> / {esc(spec['tag'])}</div>
    <h1>{esc(spec['h1'])}</h1>
    <p class="muted">Updated <time datetime="{spec['updated']}">{upd}</time> &middot; By the GigaTorq team &middot; Research-based, not hands-on tested</p>
    {DISCLOSURE}
{intro}
    <nav class="toc"><b>Our picks</b><ol>{toc}</ol></nav>

    <h2>Our picks at a glance</h2>
    <div class="grid grid-2 picks">
{chr(10).join(glance)}
    </div>
    <p class="muted small">Prices and ratings are what we saw at the store on the date shown and change often.</p>

    <h2>Specs side by side</h2>
    <div class="table-wrap">
      <table class="compare wide">
        <thead><tr><th>Drill</th><th>Battery (nominal)</th><th>Max torque</th><th>Speeds (RPM)</th><th>Weight</th><th>Length</th><th>Clutch settings</th><th>Tool warranty</th><th>Price</th><th>Owner rating</th></tr></thead>
        <tbody>
{table}
        </tbody>
      </table>
    </div>
    <p class="muted small">Specs as published by each brand or, where the brand doesn't publish them, a major retailer. "20V MAX" batteries are 18V nominal, the same as 18V batteries. Owner ratings are from a major US retailer, with links in the Sources section.</p>

{chr(10).join(sections)}

    <h2>Also considered</h2>
    <ul>
{chr(10).join(also)}
    </ul>

    <h2>How to choose a cordless drill</h2>
{guide}

    <h2>FAQ</h2>
{faq}

    <h2>Sources</h2>
    <details class="sources" open><summary>Where every number on this page comes from</summary><ul>{src_html}</ul></details>
  </div>
</section>
"""
    ld = {
        '@context': 'https://schema.org', '@type': 'Article', 'headline': spec['title'],
        'description': spec['description'], 'dateModified': spec['updated'],
        'author': {'@type': 'Organization', 'name': 'GigaTorq', 'url': 'https://gigatorq.com/about/'},
        'publisher': {'@type': 'Organization', 'name': 'GigaTorq', 'logo': {'@type': 'ImageObject', 'url': 'https://gigatorq.com/assets/img/favicon.png'}},
        'mainEntityOfPage': 'https://gigatorq.com' + spec['path'],
    }
    page(spec['path'], spec['title'] + ' | GigaTorq', spec['description'], body, '/best/',
         lastmod=spec['updated'], jsonld=ld, og_type='article')


def render_hub(pages):
    cards = '\n'.join(f"""      <a class="card" href="{b['path']}">
        <span class="tag">{esc(b['tag'])}</span>
        <h3>{esc(b['h1'])}</h3>
        <p>{esc(b['teaser'])}</p>
      </a>""" for b in pages)
    body = f"""
<section class="section">
  <div class="container">
    <span class="eyebrow">Best Picks</span>
    <h1>Best power tools, by job and budget</h1>
    <p class="muted" style="max-width:640px">Each guide compares published specs, current prices and owner ratings, then names a pick for each kind of buyer. More guides are on the way.</p>
    <div class="grid grid-3" style="margin-top:32px">
{cards}
    </div>
  </div>
</section>
"""
    last = max(b['updated'] for b in pages)
    page('/best/', 'Best Power Tools: Buying Guides | GigaTorq',
         'Research-based buying guides for drills, impact drivers, saws and more, built on verified specs, prices and owner ratings.',
         body, '/best/', lastmod=last)