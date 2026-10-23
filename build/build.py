"""Build the whole GigaTorq site from the database and the content files.

Usage:  python build/build.py
Writes every HTML page plus sitemap.xml into the repo root. Needs only Python 3.8+ (no packages).
"""
import glob, json, os, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import layout, best_list, pages_static  # noqa: E402


def main():
    db = layout.load_db()
    specs = [json.load(open(f, encoding='utf-8'))
             for f in sorted(glob.glob(os.path.join(layout.ROOT, 'build', 'content', 'best-*.json')))]
    layout.FOOTER_LINKS[:] = [(s['path'], s['h1']) for s in specs]
    for s in specs:
        best_list.render(db, s)
    best_list.render_hub(specs)
    pages_static.build(db, specs)
    layout.write_sitemap()
    print(f'built {len(layout.WRITTEN)} pages ({sum(1 for w in layout.WRITTEN if w[2])} in sitemap)')


if __name__ == '__main__':
    main()