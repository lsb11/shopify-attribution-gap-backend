-- iOS CAPI Attribution Gap — first-party submissions
-- One row per store submission. The gap is computed, never trusted from the client.

CREATE TABLE IF NOT EXISTS submissions (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  -- the two real numbers a store reports
  meta_reported INTEGER NOT NULL,   -- conversions Meta/CAPI reported in the window
  actual_orders INTEGER NOT NULL,   -- actual Shopify orders in the same window
  window_days   INTEGER NOT NULL,   -- measurement window (e.g. 30)
  -- computed server-side at insert: (actual - meta) / actual, clamped 0..1
  gap_pct       REAL    NOT NULL,
  -- optional context, never required
  platform_note TEXT,               -- free text, e.g. "Meta CAPI via gateway"
  -- moderation / trust
  status        TEXT    NOT NULL DEFAULT 'pending', -- pending | approved | rejected
  ip_hash       TEXT,               -- sha-256 of IP, dedupe + abuse only, never raw IP
  user_agent    TEXT
);

CREATE INDEX IF NOT EXISTS idx_status  ON submissions(status);
CREATE INDEX IF NOT EXISTS idx_created ON submissions(created_at);
