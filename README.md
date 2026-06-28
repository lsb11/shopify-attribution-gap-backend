# shopify-attribution-gap-backend

A lightweight, edge-native data-collection backend built entirely on **Cloudflare Workers (Pages Functions) + D1**. It powers an open, methodology-first benchmark of the iOS attribution gap — the difference between conversions Meta reports and a store's actual Shopify orders.

No traditional server. No external database. Two Pages Functions and one D1 SQL table.

[![Deploy to Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/lsb11/shopify-attribution-gap-backend)

One click provisions a D1 database, binds it as `DB`, and deploys the Functions to your own Cloudflare account. After deploy, run the schema once (see *Deploy it yourself* below) to create the table.

## What it does

Shopify store operators submit two numbers (Meta-reported conversions, actual Shopify orders). The backend:

- validates the input server-side (rejects impossible or too-small samples),
- computes the attribution gap server-side so it can't be pre-cooked by the client,
- stores each submission as `pending` for manual review,
- serves a public aggregate that **only counts approved rows** and **stays suppressed until N ≥ 10**, publishing an outlier-resistant **median**.

It's a small, honest example of using D1 for low-latency structured storage at the edge with no server overhead.

## Architecture

```
functions/api/submit-gap.js   POST — validate + compute gap + store as pending
functions/api/gap-stats.js    GET  — public aggregate (approved only, N>=10 gate)
schema/schema.sql             D1 table + indexes
```

Pages auto-detects the `functions/` directory and maps each file to a route:
`functions/api/submit-gap.js` → `/api/submit-gap`, `functions/api/gap-stats.js` → `/api/gap-stats`.

## Deploy it yourself

```bash
# 1. create the D1 database
wrangler d1 create attribution-gap

# 2. bind it in the Cloudflare Pages dashboard (Settings -> Bindings)
#    Variable name: DB   Database: attribution-gap

# 3. create the table
wrangler d1 execute attribution-gap --remote --file=./schema/schema.sql

# 4. deploy (Pages picks up functions/ automatically)
```

The binding variable name must be `DB` — the Functions call `env.DB`.

## Design notes

- **Gap is computed server-side** from two raw counts; the client never submits a percentage.
- **Approval gate**: submissions default to `pending`; nothing reaches the public figure without review.
- **N ≥ 10 suppression**: below ten approved stores, the API returns a "collecting" state instead of a fake-precise number.
- **Median, not mean**: the published figure is robust to outliers.
- **No raw PII stored**: submitter IP is SHA-256 hashed for abuse/dedupe only, never kept raw.

## Live project

The benchmark this backend powers: https://stackarchitect.xyz/shopify-ios-attribution-gap-benchmark/

## License

MIT
