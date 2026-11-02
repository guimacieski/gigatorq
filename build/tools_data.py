"""Export every tool in the database to assets/data/tools.json for the Compare and Reviews pages."""
import json, os
from layout import ROOT
from best_list import Tool, SHOTS, num, inch, fmt_date

QUAL = {
    'material:wood': 'wood', 'material:steel': 'steel', 'material:masonry': 'masonry', 'material:concrete': 'concrete',
    'material:wood_holesaw': 'hole saw in wood', 'material:wood_selffeed': 'self-feed bit in wood',
    'side:left': 'left', 'side:right': 'right', 'mode:hammer': 'hammer mode', 'mode:power': 'power mode',
    'position:nested': 'nested', 'position:vertical': 'vertical', 'position:against_fence': 'against fence', 'turbo': 'turbo',
}
INCH_KEYS = {'chuck_size', 'drilling_capacity', 'cut_depth', 'blade_diameter', 'arbor_size', 'collet_size', 'stroke_length',
             'wheel_diameter', 'crown_capacity', 'base_capacity', 'crosscut_capacity'}


def qual_label(q):
    out = []
    for part in q.split(','):
        part = part.strip()
        if part.startswith('angle:'):
            out.append(f'at {part[6:]}°')
        elif part.startswith('battery:'):
            out.append(f'with {part[8:]} battery')
        else:
            out.append(QUAL.get(part, part.replace('_', ' ')))
    return ', '.join(out)


def fmt_value(key, row, unit):
    v = row['value_num']
    if row['value_min'] is not None:
        return f"{num(row['value_min'])}–{num(row['value_max'])}{(' ' + unit) if unit else ''}"
    if row['value_bool'] is not None:
        return 'Yes' if row['value_bool'] else 'No'
    if row['value_text'] is not None:
        t = str(row['value_text']).replace('_', ' ')
        return t[:1].upper() + t[1:]
    if v is None:
        return None
    if key in INCH_KEYS and abs(v * 16 - round(v * 16)) < 1e-6:
        return inch(v)
    return f"{num(v)}{(' ' + unit) if unit else ''}"


def export(db):
    specdefs = {r['key']: r for r in db.execute(
        'SELECT sd.key, sd.label, sd.data_type, sd.higher_is_better, u.symbol FROM spec_definition sd LEFT JOIN unit u ON u.code = sd.unit_code')}
    cats = {}
    for c in db.execute('SELECT c.id, c.slug, c.name FROM category c WHERE EXISTS (SELECT 1 FROM tool t WHERE t.category_id = c.id) ORDER BY c.sort, c.name'):
        order = [(r['key'], r['is_key']) for r in db.execute(
            'SELECT sd.key, cs.is_key FROM category_spec cs JOIN spec_definition sd ON sd.id = cs.spec_id WHERE cs.category_id = ? '
            'ORDER BY cs.is_key DESC, cs.sort, sd.id', (c['id'],))]
        cats[c['slug']] = {'name': c['name'], 'specs': [
            {'k': k, 'label': specdefs[k]['label'], 'key': bool(isk),
             'hib': None if specdefs[k]['higher_is_better'] is None else bool(specdefs[k]['higher_is_better'])} for k, isk in order if k != 'voltage']}  # voltage shows with the platform

    # best-list picks, so a tool can link to the page that recommends it
    picks = {}
    for f in sorted(os.listdir(os.path.join(ROOT, 'build', 'content'))):
        if f.startswith('best-') and f.endswith('.json'):
            spec = json.load(open(os.path.join(ROOT, 'build', 'content', f), encoding='utf-8'))
            for p in spec['picks']:
                picks[p['tool']] = {'label': p['label'], 'page': spec['h1'], 'url': spec['path'] + '#' + p['tool'],
                                    'best_for': p['best_for'], 'skip_if': p['skip_if'], 'headline': p['headline']}

    tools = []
    for row in db.execute('SELECT t.slug FROM tool t JOIN brand b ON b.id = t.brand_id ORDER BY b.name, t.model'):
        t = Tool(db, row['slug'])
        cat = db.execute('SELECT slug FROM category WHERE id = ?', (t.t['category_id'],)).fetchone()['slug']
        specs, nums = {}, {}
        for key, rows in t.specs.items():
            if key not in specdefs:
                continue
            unit = specdefs[key]['symbol'] or ''
            parts, speedvals = [], []
            for r in rows:
                val = fmt_value(key, r, unit)
                if val is None:
                    continue
                q = r['qualifier']
                if q and q.startswith('speed:') and ',' not in q:
                    speedvals.append((q, r['value_num']))
                    continue
                parts.append(f'{val} ({qual_label(q)})' if q else val)
            if speedvals:
                speedvals.sort()
                parts.insert(0, ' / '.join(num(v) for _, v in speedvals) + (f' {unit}' if unit else ''))
            if parts:
                specs[key] = '; '.join(parts)
            # one comparable number: plain value, or the top speed across gears
            plain = [r['value_num'] for r in rows if r['value_num'] is not None and not r['qualifier']]
            gears = [v for _, v in speedvals]
            if plain or gears:
                nums[key] = max(plain + gears)
        pr = None  # tool-only price first, then a kit
        for s in sorted(t.skus(), key=lambda s: s['sku_type'] != 'tool_only'):
            p = t.price(s['id'])
            if p:
                pr = {'usd': p['price_usd'], 'what': 'tool only' if s['sku_type'] == 'tool_only' else 'kit', 'on': fmt_date(p['observed_at'][:10])}
                break
        r = t.best_rating()
        th = t.themes()
        img = next((sh['name'] for sh in SHOTS if sh.get('kind') != 'Battery' and
                    (sh['name'] == t.t['slug'] or sh.get('query', '').startswith(t.name + ' '))), None)
        tools.append({
            's': t.t['slug'], 'b': t.t['brand'], 'm': t.t['model'], 'n': t.t['name'], 'c': cat,
            'p': t.t['platform'], 'v': t.t['nominal'], 'motor': t.t['motor_type'], 'power': t.t['power_source'],
            'w': t.warranty(), 'img': img, 'specs': specs, 'nums': nums,
            'price': pr, 'rating': ({'avg': r['avg_rating'], 'count': r['review_count'], 'on': fmt_date(r['observed_on'])} if r else None),
            'likes': [x['theme'] for x in th if x['sentiment'] == 'praise'],
            'gripes': [x['theme'] for x in th if x['sentiment'] == 'complaint'],
            'read': th[0]['reviews_read'] if th else None,
            'pick': picks.get(t.t['slug']),
        })
    out = os.path.join(ROOT, 'assets', 'data')
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, 'tools.json'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump({'categories': cats, 'tools': tools}, f, ensure_ascii=False, separators=(',', ':'))
    return len(tools)