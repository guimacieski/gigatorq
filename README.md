# GigaTorq

Static site for gigatorq.com - power tool comparisons and reviews for US buyers.

## Structure
- `index.html` - home page
- `compare/` - comparison hub and `cordless-drills/` template
- `reviews/` - review hub and `review-template/`
- `how-we-test/`, `about/`, `contact/`, `disclosure/`, `privacy/`
- `assets/css/style.css`, `assets/js/main.js`, `assets/img/`
- `_headers` - cache and security headers
- `wrangler.jsonc` - Cloudflare Workers config (serves the folder as static assets)
- `.assetsignore` - files that are not published

## New comparison or review
Copy the template folder, rename it (e.g. `compare/impact-drivers/`), replace the placeholder content, add the card to the hub page and the URL to `sitemap.xml`.

## Logo
Brand colors: black `#000000` and steel grey `#EEEFF0`. Amber `#e3a401` is the site accent.
- `assets/img/logo.svg` - steel grey logo (used on the dark site)
- `assets/img/logo-black.svg` - black logo for light backgrounds and print
- `assets/img/favicon.svg` / `favicon.png` / `apple-touch-icon.png` - bolt "o" icon
- `assets/img/og-image.png` - social share image

## Hosting
Deployed on Cloudflare Workers (static assets) from the `main` branch. Every push to `main` goes live automatically.