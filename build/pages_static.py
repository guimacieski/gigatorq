"""Static pages (home, hubs, about, legal). Run through build.py."""
from layout import page, DISCLOSURE, esc  # noqa: F401


def build(db, best_pages):
    # ---------------- Home ----------------
    n_tools = db.execute('SELECT count(*) FROM tool').fetchone()[0]
    n_brands = db.execute('SELECT count(DISTINCT brand_id) FROM tool').fetchone()[0]
    n_specs = db.execute('SELECT count(*) FROM tool_spec').fetchone()[0]
    picks_cards = '\n'.join(
        f'''          <a class="card" href="{b['path']}">
            <span class="tag">{esc(b['tag'])}</span>
            <h3>{esc(b['h1'])}</h3>
            <p>{esc(b['teaser'])}</p>
          </a>''' for b in best_pages)
    home = f"""
    <section class="hero">
      <div class="container">
        <span class="eyebrow">Power tools, compared by the numbers</span>
        <h1>More torque.<br>Less guesswork.</h1>
        <p class="lead">We compare drills, drivers, saws and grinders on verified specs, real prices and what owners report, so you can buy the right tool the first time.</p>
        <div class="hero-actions">
          <a href="/best/" class="btn">See our best picks</a>
          <a href="/how-we-choose/" class="btn btn-ghost">How we choose</a>
        </div>
        <div class="hero-stats">
          <div>{n_tools}<small>Tools in our database</small></div>
          <div>{n_brands}<small>Brands covered</small></div>
          <div>{n_specs:,}<small>Verified spec values</small></div>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <span class="eyebrow">Latest buying guides</span>
        <h2>Our best picks</h2>
        <div class="grid grid-3" style="margin-top:28px">
{picks_cards}
        </div>
      </div>
    </section>

    <section class="section section-alt">
      <div class="container">
        <span class="eyebrow">Shop by category</span>
        <h2>Find your tool</h2>
        <div class="grid grid-4" style="margin-top:28px">
          <a class="card cat-card" href="/best/cordless-drills/"><div class="icon">&#128297;</div><h3>Drills</h3></a>
          <a class="card cat-card" href="/reviews/#impact-drivers"><div class="icon">&#9881;&#65039;</div><h3>Impact Drivers</h3></a>
          <a class="card cat-card" href="/reviews/#hammer-drills"><div class="icon">&#128296;</div><h3>Hammer Drills</h3></a>
          <a class="card cat-card" href="/reviews/#circular-saws"><div class="icon">&#129690;</div><h3>Circular Saws</h3></a>
          <a class="card cat-card" href="/reviews/#miter-saws"><div class="icon">&#129690;</div><h3>Miter Saws</h3></a>
          <a class="card cat-card" href="/reviews/#reciprocating-saws"><div class="icon">&#129690;</div><h3>Reciprocating Saws</h3></a>
          <a class="card cat-card" href="/reviews/#angle-grinders"><div class="icon">&#9889;</div><h3>Angle Grinders</h3></a>
          <a class="card cat-card" href="/reviews/#impact-wrenches"><div class="icon">&#128297;</div><h3>Impact Wrenches</h3></a>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <span class="eyebrow">Our method</span>
        <h2>How we choose</h2>
        <div class="grid grid-3 steps" style="margin-top:28px">
          <div class="step"><h3>Verify the specs</h3><p class="muted">We collect specs from brand and retailer pages, convert them to the same units and flag numbers that are missing or don't match.</p></div>
          <div class="step"><h3>Read what owners say</h3><p class="muted">We record owner ratings at major retailers and, where reviews are publicly readable, sum up the praise and complaints that keep coming back.</p></div>
          <div class="step"><h3>Weigh value and pick</h3><p class="muted">We weigh specs, kit contents, warranty and price together, then pick the best option for each type of buyer.</p></div>
        </div>
        <p style="margin-top:24px"><a href="/how-we-choose/">Read our full method &rarr;</a></p>
      </div>
    </section>

    <section class="section section-alt">
      <div class="container center">
        <span class="eyebrow">Newsletter</span>
        <h2>New comparisons, straight to your inbox</h2>
        <p class="muted">One email when a new comparison drops. No spam.</p>
        <form class="newsletter">
          <input type="email" placeholder="you@example.com" required aria-label="Email address">
          <button class="btn" type="submit">Subscribe</button>
        </form>
      </div>
    </section>
    """
    page("/", "GigaTorq | Power Tool Comparisons and Reviews",
         "Research-based power tool comparisons. We compare drills, impact drivers, saws and grinders on verified specs, prices and owner feedback so you can buy the right tool.", home, lastmod='2026-10-22')

    # Compare and Reviews are built by tools_pages.py
    # ---------------- How we choose ----------------
    how = """
    <section class="section">
      <div class="container article">
        <span class="eyebrow">Our method</span>
        <h1>How we choose</h1>
        <p>GigaTorq recommendations are research-based. We don't currently run hands-on tests. Instead, we combine verified specs, real prices and a large body of owner feedback, and we show our work on every page. If we ever test a tool ourselves, the page will say so clearly.</p>
        <h2>1. Verified specs</h2>
        <p>We collect specs from each brand's US site and from major retailers, then convert them to the same units so tools can be compared fairly. For example, "20V MAX" tools run at 18V nominal, the same as most "18V" tools, and we show both. When brands and retailers disagree, or a brand doesn't publish a number, we say so instead of guessing.</p>
        <h2>2. What owners say</h2>
        <p>We record each tool's star rating and review count at major US retailers, with the date we checked. Where reviews are publicly readable, we read them and look for patterns: problems and praise that come up again and again, not one-off stories. We summarize them in our own words, say how many reviews we read, and link to the sources. When we couldn't read enough reviews to see a pattern, the page says so. We never copy reviews or present other people's experiences as our own.</p>
        <h2>3. Price, kit and warranty</h2>
        <p>We compare what you actually get for the money: which batteries and charger come in the box, how the price compares with similar tools, and how long the warranty lasts.</p>
        <h2 id="ai">4. How we use AI</h2>
        <p>GigaTorq uses AI tools to research at a scale one person couldn't manage alone: collecting spec sheets from every brand, converting them to the same units, reading owner reviews and drafting summaries.</p>
        <p>AI doesn't decide what's true. Every number on a page comes from a brand or retailer source that we link to, and our database won't accept a spec without one. When sources disagree, the page says so instead of picking a number. An engineer with hands-on power tool experience reviews the picks before they go live.</p>
        <p>Some images on the site are AI-generated illustrations of the tools, made using photos of the real model as a reference. Each one is captioned as an AI illustration, so it's never mistaken for a photo of the actual product.</p>
        <h2>What we weigh</h2>
        <p>Every pick comes down to four things:</p>
        <ul>
          <li><strong>Power</strong> - torque, speed and capacity compared with tools in the same class.</li>
          <li><strong>Features</strong> - brushless motor, brakes, kickback control, lights and other useful extras.</li>
          <li><strong>Owner satisfaction</strong> - how owners rate the tool and what they report over time.</li>
          <li><strong>Value</strong> - what you get for the price, including kit contents and warranty.</li>
        </ul>
        <h2>Independence</h2>
        <p>Brands don't see our pages before they're published and can't pay for placement or a better score. <a href="/disclosure/">Read our disclosure</a>.</p>
        <h2>Keeping pages current</h2>
        <p>Prices and models change. We update pages when a new model replaces an old one or a price moves enough to change a pick, and every page shows when it was last updated.</p>
      </div>
    </section>
    """
    page("/how-we-choose/", "How We Choose Power Tools | GigaTorq",
         "Our research method: verified specs, owner feedback from major retailers, prices and warranty, weighed for power, features, owner satisfaction and value.", how, '/how-we-choose/', lastmod='2026-11-02')

    # ---------------- About ----------------
    from best_list import AUTHOR
    if AUTHOR.get('name'):
        author_html = (f'''        <section id="author" class="author-box">
          <span class="eyebrow">Who writes GigaTorq</span>
          <h2>{esc(AUTHOR['name'])}</h2>
          <p class="muted small">{esc(AUTHOR['title'])}</p>
          <p>{esc(AUTHOR['bio'])}</p>
        </section>''')
    else:
        author_html = '        <p>GigaTorq is written by a mechanical assembler and engineer with years of hands-on work with power tools.</p>'

    about = """
    <section class="section">
      <div class="container article">
        <span class="eyebrow">About</span>
        <h1>About GigaTorq</h1>
        <p>GigaTorq is an independent power tool comparison site for US buyers. We compare tools on verified specs, real prices and what owners report, and tell you which one to buy for the way you work.</p>
{author_html}
        <h2>Our promise</h2>
        <ul>
          <li>We're clear about how every pick is made: research, not hands-on testing.</li>
          <li>We summarize owner feedback in our own words and link to the sources.</li>
          <li>We use AI to research at scale, and we say so. Every number still links to its source. <a href="/how-we-choose/#ai">How we use AI</a></li>
          <li>Brands can't pay for placement or scores.</li>
          <li>We update pages when better tools come out or prices change.</li>
        </ul>
        <h2>Money and independence</h2>
        <p>GigaTorq doesn't make money from its links yet. If that changes, it will never change our picks, and we'll say so on every page. <a href="/disclosure/">Read our disclosure</a>.</p>
      </div>
    </section>
    """
    about = about.replace('{author_html}', author_html)
    page("/about/", "About GigaTorq", "Who we are and how GigaTorq researches and compares power tools.", about, '/about/', lastmod='2026-10-24')

    # ---------------- Contact ----------------
    contact = """
    <section class="section">
      <div class="container article">
        <span class="eyebrow">Contact</span>
        <h1>Get in touch</h1>
        <p>Questions, tool suggestions or corrections? Email us at <a href="mailto:hello@gigatorq.com">hello@gigatorq.com</a>.</p>
        <p>Brands and PR: <a href="mailto:reviews@gigatorq.com">reviews@gigatorq.com</a>. Sending us a tool doesn't guarantee coverage or a positive review.</p>
      </div>
    </section>
    """
    page("/contact/", "Contact | GigaTorq", "Contact the GigaTorq team.", contact)

    # ---------------- Disclosure ----------------
    disclosure = """
    <section class="section">
      <div class="container article">
        <span class="eyebrow">Legal</span>
        <h1>Disclosure</h1>
        <p class="muted">Last updated October 22, 2026</p>
        <p>GigaTorq doesn't earn money from the links on this site. Store links go straight to the retailer's product page so you can check the current price.</p>
        <p>If that changes, we'll update this page and label it clearly on every page before it happens.</p>
        <h2>Our independence</h2>
        <p>Brands do not review our content before publication and cannot pay for placement or a better pick.</p>
        <p>This disclosure is provided in line with the US Federal Trade Commission's guidance on endorsements and testimonials.</p>
      </div>
    </section>
    """
    page("/disclosure/", "Disclosure | GigaTorq", "How GigaTorq makes money and stays independent.", disclosure, lastmod='2026-10-22')

    # ---------------- Privacy ----------------
    privacy = """
    <section class="section">
      <div class="container article">
        <span class="eyebrow">Legal</span>
        <h1>Privacy policy</h1>
        <p class="muted">Last updated October 22, 2026</p>
        <p class="placeholder">STARTER TEXT: review and complete this policy before launch, especially once you add analytics, ads or a newsletter provider.</p>
        <h2>What we collect</h2>
        <p>If you subscribe to our newsletter, we collect your email address. Our hosting provider and any analytics tools may collect standard technical data such as IP address, browser type and pages visited.</p>
        <h2>Links to stores</h2>
        <p>When you click a link to a store, that store's own privacy policy applies to what happens on its site.</p>
        <h2>Your choices</h2>
        <p>You can unsubscribe from emails at any time, and you can block or delete cookies in your browser settings.</p>
        <h2>Contact</h2>
        <p>Privacy questions: <a href="mailto:hello@gigatorq.com">hello@gigatorq.com</a>.</p>
      </div>
    </section>
    """
    page("/privacy/", "Privacy Policy | GigaTorq", "GigaTorq privacy policy.", privacy, lastmod='2026-10-22')

    # ---------------- 404 ----------------
    nf = """
    <section class="section">
      <div class="container center">
        <span class="eyebrow">404</span>
        <h1>Stripped screw.</h1>
        <p class="muted">That page doesn't exist. Let's get you back on track.</p>
        <a class="btn" href="/">Back to home</a>
      </div>
    </section>
    """
    page("/404.html", "Page Not Found | GigaTorq", "Page not found.", nf)