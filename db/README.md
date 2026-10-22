# GigaTorq product database

SQLite schema (runs as-is on Cloudflare D1) for power tool specs, kits, prices and GigaTorq test results.

## Files
- `schema.sql` - all tables, indexes and the `v_tool_spec` view
- `seed/01_reference.sql` - units, 45 categories, 75 spec definitions, which specs apply to each category, 112 brand/retailer label aliases, features
- `seed/02_brands.sql` - 18 brands and their owners, 7 retailers, 21 battery platforms, product lines, warranty policies
- `seed/03_sample_products.sql` - 18 real tools from 12 brands (162 spec values, 22 SKUs), each value with its source URL

Load order: `schema.sql`, then the seed files in number order.

## How it fits together
- **tool** is the thing we test (DCD1007). **sku** is what stores sell (DCD1007B tool only, DCD1007WW1 kit). `sku_item` lists what is in the box.
- **platform** holds both marketing and nominal voltage (20V MAX = 18V). `platform_compat` says which batteries fit which tools (FLEXVOLT runs 20V MAX tools).
- **spec_definition** is our own spec dictionary with one canonical name and unit per spec. `spec_alias` maps each brand's label ("Maximum Torque (in.lbs.)", "Torque (lb-in)") to it.
- **tool_spec** stores one value per spec, in the spec's unit. `qualifier` handles values that depend on a setting: `speed:1`, `angle:45`, `side:left`, `material:steel`. `raw_text` keeps exactly what the source said.
- **feature** groups brand trademarks for the same thing (ANTI-ROTATION, AutoStop -> kickback control).
- Manufacturer claims (`tool_claim`), store data (`source_type = retailer`) and our own measurements (`test_run`, `test_result`, `score`) are kept separate.

## What the brand survey showed
- Spec tables vary a lot: Makita publishes ~20 fields, DeWalt shows ~5 by default, Milwaukee and Ryobi load specs with JavaScript.
- The same spec has many names and units, and multi-speed tools publish ranges per gear.
- Retailer pages (Home Depot, Lowe's, Acme, dealers) often fill gaps but sometimes mislabel fields (Ridgid impact rate listed as "BPM").
- "Weight" can mean bare tool, tool with battery, or the whole kit. We store bare and with-battery weight separately and never use kit weight.