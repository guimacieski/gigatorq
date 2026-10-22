-- GigaTorq product database - schema
-- SQLite dialect (works as-is with Cloudflare D1). Ports to Postgres with minor type changes.
--
-- Design notes (from surveying Milwaukee, DeWalt, Makita, Bosch, Ryobi, Ridgid, Craftsman,
-- Black+Decker, Metabo HPT, Flex, Kobalt, Skil and retailer spec tables):
--   * Brands publish the same spec under different labels and units, so specs are stored
--     against a canonical spec dictionary (spec_definition) with label aliases (spec_alias).
--   * A "tool" (e.g. DCD1007) is different from what is sold (SKU: DCD1007B tool only,
--     DCD1007WW1 kit, DCK2101QQ2 combo). Specs live on the tool; prices live on SKUs.
--   * Many specs vary by a condition (speed 1/2/3, bevel 45 deg, mode), so each spec value
--     can carry a qualifier.
--   * Marketing voltage differs from nominal (20V MAX = 18V, 60V MAX = 54V), so platforms
--     store both.
--   * Manufacturer claims, retailer data and GigaTorq's own test results are kept apart.

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------- companies and brands

CREATE TABLE company (
  id            INTEGER PRIMARY KEY,
  slug          TEXT NOT NULL UNIQUE,
  name          TEXT NOT NULL,
  notes         TEXT
);

CREATE TABLE retailer (
  id                INTEGER PRIMARY KEY,
  slug              TEXT NOT NULL UNIQUE,
  name              TEXT NOT NULL,
  website           TEXT,
  affiliate_program TEXT
);

CREATE TABLE brand (
  id                    INTEGER PRIMARY KEY,
  slug                  TEXT NOT NULL UNIQUE,
  name                  TEXT NOT NULL,
  owner_company_id      INTEGER REFERENCES company(id),   -- who owns / makes the brand
  website_us            TEXT,
  exclusive_retailer_id INTEGER REFERENCES retailer(id),  -- e.g. Ryobi/Ridgid -> Home Depot, Kobalt -> Lowe's
  notes                 TEXT
);

-- ---------------------------------------------------------------- battery platforms

CREATE TABLE platform (
  id                  INTEGER PRIMARY KEY,
  brand_id            INTEGER NOT NULL REFERENCES brand(id),
  slug                TEXT NOT NULL UNIQUE,
  name                TEXT NOT NULL,          -- "M18", "20V MAX", "18V LXT", "ONE+", "AMPShare 18V"
  marketing_voltage_v REAL,                   -- what the box says (20 for "20V MAX")
  nominal_voltage_v   REAL,                   -- electrical nominal (18 for "20V MAX")
  battery_style       TEXT,                   -- 'slide', 'stem', 'pod'
  launched_year       INTEGER,
  status              TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','legacy','discontinued')),
  notes               TEXT
);

-- Which batteries fit which tools. A row means: batteries of battery_platform run tools of tool_platform.
CREATE TABLE platform_compat (
  battery_platform_id INTEGER NOT NULL REFERENCES platform(id),
  tool_platform_id    INTEGER NOT NULL REFERENCES platform(id),
  notes               TEXT,
  PRIMARY KEY (battery_platform_id, tool_platform_id)
);

-- Tiers / sub-lines inside a brand: FUEL, XR, ATOMIC, ONE+ HP, PWRCORE 20 XP, SubCompact...
CREATE TABLE product_line (
  id          INTEGER PRIMARY KEY,
  brand_id    INTEGER NOT NULL REFERENCES brand(id),
  platform_id INTEGER REFERENCES platform(id),
  slug        TEXT NOT NULL UNIQUE,
  name        TEXT NOT NULL,
  tier        TEXT CHECK (tier IN ('entry','mid','pro','premium','compact')),
  notes       TEXT
);

-- ---------------------------------------------------------------- categories

CREATE TABLE category (
  id        INTEGER PRIMARY KEY,
  parent_id INTEGER REFERENCES category(id),
  slug      TEXT NOT NULL UNIQUE,
  name      TEXT NOT NULL,
  sort      INTEGER NOT NULL DEFAULT 0
);

-- ---------------------------------------------------------------- units and spec dictionary

CREATE TABLE unit (
  code        TEXT PRIMARY KEY,       -- 'in_lb', 'rpm', 'in', 'lb'...
  symbol      TEXT NOT NULL,          -- 'in-lbs', 'RPM', 'in', 'lbs'
  dimension   TEXT NOT NULL,          -- 'torque', 'rotational_speed', 'length', 'mass'...
  to_base     REAL NOT NULL DEFAULT 1 -- multiply to convert to the canonical unit of the dimension
);

CREATE TABLE spec_definition (
  id               INTEGER PRIMARY KEY,
  key              TEXT NOT NULL UNIQUE,  -- 'max_torque', 'no_load_speed', 'cut_depth'
  label            TEXT NOT NULL,         -- shown on GigaTorq pages
  data_type        TEXT NOT NULL CHECK (data_type IN ('number','range','bool','text','enum')),
  unit_code        TEXT REFERENCES unit(code),  -- canonical unit for number/range
  enum_values      TEXT,                  -- JSON array for enum specs
  qualifier_hint   TEXT,                  -- what qualifiers mean, e.g. 'speed:N', 'bevel:DEG'
  higher_is_better INTEGER CHECK (higher_is_better IN (0,1)),  -- NULL = not comparable
  description      TEXT
);

-- Which specs apply to which category, in which order, and which are headline specs.
CREATE TABLE category_spec (
  category_id INTEGER NOT NULL REFERENCES category(id),
  spec_id     INTEGER NOT NULL REFERENCES spec_definition(id),
  sort        INTEGER NOT NULL DEFAULT 0,
  is_key      INTEGER NOT NULL DEFAULT 0,  -- show on cards / comparison headers
  PRIMARY KEY (category_id, spec_id)
);

-- How brands and retailers label each spec. Used to map imported spec tables automatically.
CREATE TABLE spec_alias (
  spec_id   INTEGER NOT NULL REFERENCES spec_definition(id),
  source    TEXT NOT NULL,  -- brand or retailer slug, or '*' for generic
  label     TEXT NOT NULL,  -- exactly as published, e.g. 'Maximum Torque (in.lbs.)'
  qualifier TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (source, label)
);

-- ---------------------------------------------------------------- features (brand names for the same thing)

CREATE TABLE feature (
  id          INTEGER PRIMARY KEY,
  slug        TEXT NOT NULL UNIQUE,  -- 'kickback_control'
  name        TEXT NOT NULL,         -- 'Kickback / bind-up control'
  description TEXT
);

CREATE TABLE feature_brand_term (
  feature_id INTEGER NOT NULL REFERENCES feature(id),
  brand_id   INTEGER NOT NULL REFERENCES brand(id),
  term       TEXT NOT NULL,          -- 'ANTI-ROTATION', 'AutoStop', 'XPT'
  PRIMARY KEY (feature_id, brand_id, term)
);

-- ---------------------------------------------------------------- catalog: tools, batteries, chargers

CREATE TABLE tool (
  id                INTEGER PRIMARY KEY,
  brand_id          INTEGER NOT NULL REFERENCES brand(id),
  category_id       INTEGER NOT NULL REFERENCES category(id),
  platform_id       INTEGER REFERENCES platform(id),      -- NULL for corded/pneumatic
  product_line_id   INTEGER REFERENCES product_line(id),
  model             TEXT NOT NULL,                        -- base model: 'DCD1007', '2904', 'XPH14'
  slug              TEXT NOT NULL UNIQUE,
  name              TEXT NOT NULL,                        -- official name, as published
  power_source      TEXT NOT NULL CHECK (power_source IN ('battery','corded','battery_or_corded','pneumatic','gas')),
  motor_type        TEXT CHECK (motor_type IN ('brushless','brushed','induction','none')),
  generation        TEXT,                                 -- 'Gen 4', '2023 model'
  replaces_tool_id  INTEGER REFERENCES tool(id),          -- model history
  release_year      INTEGER,
  status            TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','discontinued','announced')),
  country_of_origin TEXT,
  official_url      TEXT,
  manual_url        TEXT,
  notes             TEXT,
  UNIQUE (brand_id, model)
);

CREATE TABLE battery (
  id                  INTEGER PRIMARY KEY,
  brand_id            INTEGER NOT NULL REFERENCES brand(id),
  platform_id         INTEGER NOT NULL REFERENCES platform(id),
  product_line_id     INTEGER REFERENCES product_line(id),
  model               TEXT NOT NULL,             -- 'DCB205'
  name                TEXT NOT NULL,
  capacity_ah         REAL,                      -- 5.0; for dual-voltage packs, Ah at the lower voltage
  capacity_ah_alt     REAL,                      -- second rating for dual packs (FLEXVOLT, MultiVolt)
  energy_wh           REAL,
  cell_format         TEXT,                      -- '18650', '21700', 'pouch'
  cell_count          INTEGER,
  weight_lb           REAL,
  fuel_gauge          INTEGER CHECK (fuel_gauge IN (0,1)),
  status              TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','discontinued','announced')),
  official_url        TEXT,
  notes               TEXT,
  UNIQUE (brand_id, model)
);

CREATE TABLE charger (
  id           INTEGER PRIMARY KEY,
  brand_id     INTEGER NOT NULL REFERENCES brand(id),
  platform_id  INTEGER REFERENCES platform(id),
  model        TEXT NOT NULL,
  name         TEXT NOT NULL,
  output_a     REAL,
  ports        INTEGER DEFAULT 1,
  notes        TEXT,
  UNIQUE (brand_id, model)
);

-- One row per published spec value. Values are stored in the spec's canonical unit;
-- raw_text keeps exactly what the source said (e.g. '2-7/16-in', '0-550 / 0-2,100 RPM').
CREATE TABLE tool_spec (
  tool_id     INTEGER NOT NULL REFERENCES tool(id) ON DELETE CASCADE,
  spec_id     INTEGER NOT NULL REFERENCES spec_definition(id),
  qualifier   TEXT NOT NULL DEFAULT '',  -- '', 'speed:1', 'speed:2', 'bevel:45', 'material:steel'
  value_num   REAL,                      -- single number (or max of a 0-N range)
  value_min   REAL,                      -- ranges: nail length 2 to 3.5 in
  value_max   REAL,
  value_bool  INTEGER CHECK (value_bool IN (0,1)),
  value_text  TEXT,                      -- enums and free text ('SDS-PLUS', '2 x 16')
  raw_text    TEXT,
  source_type TEXT NOT NULL DEFAULT 'manufacturer' CHECK (source_type IN ('manufacturer','retailer','other')),
  source_url  TEXT,
  retrieved_on TEXT,                     -- ISO date
  PRIMARY KEY (tool_id, spec_id, qualifier)
);

CREATE TABLE tool_feature (
  tool_id    INTEGER NOT NULL REFERENCES tool(id) ON DELETE CASCADE,
  feature_id INTEGER NOT NULL REFERENCES feature(id),
  brand_term TEXT,                       -- what the brand calls it on this tool
  PRIMARY KEY (tool_id, feature_id)
);

-- Marketing claims stay separate from specs ("up to 275 holes per charge", "most powerful").
CREATE TABLE tool_claim (
  id          INTEGER PRIMARY KEY,
  tool_id     INTEGER NOT NULL REFERENCES tool(id) ON DELETE CASCADE,
  claim       TEXT NOT NULL,
  conditions  TEXT,
  source_url  TEXT,
  retrieved_on TEXT
);

-- ---------------------------------------------------------------- what is sold: SKUs and kits

CREATE TABLE sku (
  id           INTEGER PRIMARY KEY,
  brand_id     INTEGER NOT NULL REFERENCES brand(id),
  model_number TEXT NOT NULL,             -- 'DCD1007B', '2904-20', 'XPH14Z', 'R872311K'
  title        TEXT NOT NULL,
  sku_type     TEXT NOT NULL CHECK (sku_type IN ('tool_only','kit','combo_kit','battery','battery_pack','charger','starter_kit','accessory')),
  upc          TEXT,
  msrp_usd     REAL,
  status       TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','discontinued','announced')),
  official_url TEXT,
  UNIQUE (brand_id, model_number)
);

-- Box contents. Exactly one of tool_id / battery_id / charger_id / item_text per row.
CREATE TABLE sku_item (
  id         INTEGER PRIMARY KEY,
  sku_id     INTEGER NOT NULL REFERENCES sku(id) ON DELETE CASCADE,
  qty        INTEGER NOT NULL DEFAULT 1,
  tool_id    INTEGER REFERENCES tool(id),
  battery_id INTEGER REFERENCES battery(id),
  charger_id INTEGER REFERENCES charger(id),
  item_text  TEXT,                       -- 'Side handle', 'Belt clip', '24T framing blade'
  CHECK ((tool_id IS NOT NULL) + (battery_id IS NOT NULL) + (charger_id IS NOT NULL) + (item_text IS NOT NULL) = 1)
);

-- ---------------------------------------------------------------- warranty

CREATE TABLE warranty_policy (
  id                    INTEGER PRIMARY KEY,
  brand_id              INTEGER NOT NULL REFERENCES brand(id),
  platform_id           INTEGER REFERENCES platform(id),       -- NULL = whole brand
  product_line_id       INTEGER REFERENCES product_line(id),
  applies_to            TEXT NOT NULL CHECK (applies_to IN ('tool','battery','charger','all')),
  years                 REAL,                                  -- NULL with is_lifetime = 1
  is_lifetime           INTEGER NOT NULL DEFAULT 0,
  requires_registration INTEGER NOT NULL DEFAULT 0,
  name                  TEXT,                                  -- 'Lifetime Service Agreement'
  extras                TEXT,                                  -- '1 year free service, 90-day satisfaction'
  source_url            TEXT
);

CREATE TABLE tool_warranty (
  tool_id            INTEGER PRIMARY KEY REFERENCES tool(id) ON DELETE CASCADE,
  warranty_policy_id INTEGER NOT NULL REFERENCES warranty_policy(id)
);

-- ---------------------------------------------------------------- retailers, affiliate links, prices

CREATE TABLE listing (
  id               INTEGER PRIMARY KEY,
  sku_id           INTEGER NOT NULL REFERENCES sku(id) ON DELETE CASCADE,
  retailer_id      INTEGER NOT NULL REFERENCES retailer(id),
  retailer_item_id TEXT,                 -- Home Depot Internet #, Lowe's Item #, ASIN
  url              TEXT NOT NULL,
  affiliate_url    TEXT,
  active           INTEGER NOT NULL DEFAULT 1,
  UNIQUE (retailer_id, sku_id)
);

CREATE TABLE price_observation (
  id          INTEGER PRIMARY KEY,
  listing_id  INTEGER NOT NULL REFERENCES listing(id) ON DELETE CASCADE,
  observed_at TEXT NOT NULL,             -- ISO datetime
  price_usd   REAL NOT NULL,
  in_stock    INTEGER CHECK (in_stock IN (0,1)),
  promo_text  TEXT
);

-- ---------------------------------------------------------------- GigaTorq testing and reviews

CREATE TABLE test_protocol (
  id               INTEGER PRIMARY KEY,
  category_id      INTEGER NOT NULL REFERENCES category(id),
  slug             TEXT NOT NULL UNIQUE,  -- 'drill-spade-1in-spf-holes-per-charge'
  name             TEXT NOT NULL,
  metric_unit      TEXT NOT NULL,         -- 'holes', 'seconds', 'screws', 'cuts'
  higher_is_better INTEGER NOT NULL CHECK (higher_is_better IN (0,1)),
  method           TEXT NOT NULL,         -- how the test is run (markdown)
  version          INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE test_run (
  id           INTEGER PRIMARY KEY,
  protocol_id  INTEGER NOT NULL REFERENCES test_protocol(id),
  tool_id      INTEGER NOT NULL REFERENCES tool(id),
  battery_id   INTEGER REFERENCES battery(id),     -- battery used (NULL for corded)
  sku_id       INTEGER REFERENCES sku(id),         -- the unit tested
  unit_source  TEXT CHECK (unit_source IN ('purchased','loaned','gifted')),
  run_date     TEXT NOT NULL,
  conditions   TEXT,                               -- JSON: temp, material lot, bit used...
  notes        TEXT
);

CREATE TABLE test_result (
  run_id  INTEGER NOT NULL REFERENCES test_run(id) ON DELETE CASCADE,
  trial   INTEGER NOT NULL DEFAULT 1,
  value   REAL NOT NULL,
  PRIMARY KEY (run_id, trial)
);

CREATE TABLE score (
  tool_id    INTEGER NOT NULL REFERENCES tool(id) ON DELETE CASCADE,
  criterion  TEXT NOT NULL CHECK (criterion IN ('power','features','owner_satisfaction','value','overall','runtime','ergonomics')),
  score      REAL NOT NULL CHECK (score BETWEEN 0 AND 10),
  method_version INTEGER NOT NULL DEFAULT 1,
  scored_on  TEXT NOT NULL,
  PRIMARY KEY (tool_id, criterion, method_version)
);

CREATE TABLE review (
  id           INTEGER PRIMARY KEY,
  tool_id      INTEGER NOT NULL REFERENCES tool(id),
  slug         TEXT NOT NULL UNIQUE,
  title        TEXT NOT NULL,
  verdict      TEXT,
  status       TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published','archived')),
  published_on TEXT,
  updated_on   TEXT
);

CREATE TABLE comparison (
  id           INTEGER PRIMARY KEY,
  category_id  INTEGER NOT NULL REFERENCES category(id),
  slug         TEXT NOT NULL UNIQUE,
  title        TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published','archived')),
  published_on TEXT,
  updated_on   TEXT
);

CREATE TABLE comparison_entry (
  comparison_id INTEGER NOT NULL REFERENCES comparison(id) ON DELETE CASCADE,
  tool_id       INTEGER NOT NULL REFERENCES tool(id),
  award         TEXT,                    -- 'Best overall', 'Best value'
  rank          INTEGER,
  PRIMARY KEY (comparison_id, tool_id)
);

-- ---------------------------------------------------------------- owner feedback (summarized, never copied)

-- Aggregate rating snapshot per retailer listing (numbers only, as displayed by the retailer).
CREATE TABLE rating_snapshot (
  id           INTEGER PRIMARY KEY,
  sku_id       INTEGER NOT NULL REFERENCES sku(id) ON DELETE CASCADE,
  retailer_id  INTEGER NOT NULL REFERENCES retailer(id),
  observed_on  TEXT NOT NULL,
  avg_rating   REAL,              -- e.g. 4.7 (out of 5)
  review_count INTEGER,
  url          TEXT NOT NULL
);

-- Recurring themes found across owner reviews, written in our own words.
CREATE TABLE owner_theme (
  id           INTEGER PRIMARY KEY,
  tool_id      INTEGER NOT NULL REFERENCES tool(id) ON DELETE CASCADE,
  sentiment    TEXT NOT NULL CHECK (sentiment IN ('praise','complaint','mixed')),
  theme        TEXT NOT NULL,     -- 'Chuck slips under heavy load'
  frequency    TEXT CHECK (frequency IN ('often','sometimes','rarely')),
  reviews_read INTEGER,           -- how many reviews this theme was judged from
  sources      TEXT,              -- JSON array of source URLs
  researched_on TEXT NOT NULL
);

-- ---------------------------------------------------------------- indexes

CREATE INDEX idx_tool_category ON tool(category_id);
CREATE INDEX idx_tool_platform ON tool(platform_id);
CREATE INDEX idx_tool_spec_spec ON tool_spec(spec_id, value_num);
CREATE INDEX idx_sku_item_tool ON sku_item(tool_id);
CREATE INDEX idx_price_listing ON price_observation(listing_id, observed_at);

-- ---------------------------------------------------------------- handy view: one row per tool spec, ready to display

CREATE VIEW v_tool_spec AS
SELECT b.name AS brand, t.model, t.name AS tool, c.name AS category,
       sd.key AS spec_key, sd.label AS spec, ts.qualifier,
       ts.value_num, ts.value_min, ts.value_max, ts.value_bool, ts.value_text,
       u.symbol AS unit, ts.raw_text, ts.source_url
FROM tool_spec ts
JOIN tool t            ON t.id = ts.tool_id
JOIN brand b           ON b.id = t.brand_id
JOIN category c        ON c.id = t.category_id
JOIN spec_definition sd ON sd.id = ts.spec_id
LEFT JOIN unit u       ON u.code = sd.unit_code;