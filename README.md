# GigaTorq

Static site for gigatorq.com - power tool comparisons and reviews for US buyers.

## Structure
- `index.html` and every page folder (`best/`, `compare/`, `reviews/`, `how-we-choose/`, `about/`, ...) - generated HTML, don't edit by hand
- `build/` - the site generator: `layout.py` (header, footer), `pages_static.py` (home, about, legal), `best_list.py` (best-list template), `content/` (editorial text for each best-list page)
- `db/` - product database (specs, kits, prices, owner ratings). See `db/README.md`
- `assets/css/style.css`, `assets/js/main.js`, `assets/img/`
- `_headers`, `_redirects` - cache/security headers and redirects
- `wrangler.jsonc` - Cloudflare Workers config (serves the folder as static assets)
- `.assetsignore` - files that are not published (`build/`, `db/`, scripts)

## Rebuilding the site
Needs Python 3.8 or newer, no packages.
1. `python db/tools/build_seed.py` - after changing anything in `db/data/`
2. `python build/build.py` - regenerates every page and `sitemap.xml` from the database and `build/content/`

## New best-list page
Copy `build/content/best-cordless-drills.json`, change the path, picks and text, then run `python build/build.py`. Numbers (specs, prices, ratings, warranty) come from the database, never from the content file.

## Logo
Brand colors: black `#000000` and steel grey `#EEEFF0`. Amber `#e3a401` is the site accent.
- `assets/img/logo.svg` - steel grey logo (used on the dark site)
- `assets/img/logo-black.svg` - black logo for light backgrounds and print
- `assets/img/favicon.svg` / `favicon.png` / `apple-touch-icon.png` - bolt "o" icon
- `assets/img/og-image.png` - social share image

## Hosting
Deployed on Cloudflare Workers (static assets) from the `main` branch. Every push to `main` goes live automatically.