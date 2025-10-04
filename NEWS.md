# chartjs 0.2.0

- Rebuilt the core `chartjs()` API with strict column validation, richer
  defaults, and consistent dataset generation across all Chart.js v4 types.
- Added first-class helpers for bubble charts, stacked/horizontal bars, and
  configurable line fills and smoothing.
- Refreshed the htmlwidget binding to remove debug logging, add custom message
  handlers, and expose a lightweight error display with bundled styles.
- Expanded the Shiny proxy interface with persistent metadata support and
  helper functions for datasets and option updates.
- Updated documentation, vignette, and tests to reflect the modernised API and
  ensure CRAN-ready coverage.
