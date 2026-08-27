### Unreleased
- Added a note on the About page that this is the patched fork, plus this Fork changelog tab (#15)

### 2026-08-26
- Fixed: barcode scan was silently doing nothing on the Purchase page (#14)

### 2026-08-18
- Code-review hardening pass before go-live (#13)

### 2026-08-14
- Auto-copy a product's Brand userfield onto new stock entries when it's added, instead of typing it in by hand (#2, #3)
- Track Variant alongside Brand the same way (#4)
- Pre-fill the Brand/Variant fields on the Purchase page from the scanned barcode (#5)
- Auto-fill Brand when a brand-new product is created straight from a barcode scan (#10)
- Show a per-product Variant breakdown on the stock overview page (#9)
- About page now shows the fork's actual build commit, not just the pinned upstream version (#6, #7, #8)

### 2026-08-13
- Added containerized Docker build with CI images published to GHCR on every push (#1)
