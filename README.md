# chartjs <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/ashgreat/chartjs/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ashgreat/chartjs/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/chartjs)](https://CRAN.R-project.org/package=chartjs)
<!-- badges: end -->

`chartjs` brings the flexibility of [Chart.js&nbsp;v4](https://www.chartjs.org/) to R. The
package provides type-specific helpers, sensible defaults, and Shiny proxy tools
so you can build professional interactive visualisations without writing any
JavaScript.

## Installation

You can install the development version of `chartjs` from GitHub with:

``` r
# install.packages("pak")
pak::pak("ashgreat/chartjs")
```

## Quick start

``` r
library(chartjs)

# Tidy data for a basic bar chart
data <- data.frame(
  product = c("Alpha", "Bravo", "Charlie", "Delta"),
  sales = c(120, 180, 160, 90)
)

chartjs_bar(data, x = "product", y = "sales")
```

Line charts enable multiple series with optional smoothing and area fills:

``` r
trend <- data.frame(
  month = month.abb[1:6],
  actual = c(10, 16, 14, 22, 24, 26),
  target = c(12, 15, 18, 20, 23, 25)
)

chartjs_line(trend, x = "month", y = c("actual", "target"), smooth = TRUE, fill = FALSE)
```

## Supported chart types

All core Chart.js chart types are available through thin, well-documented
wrappers:

``` r
chartjs_bar(data, x = "product", y = "sales", horizontal = TRUE)
chartjs_line(trend, x = "month", y = c("actual", "target"), fill = TRUE)
chartjs_scatter(mtcars, x = "wt", y = c("mpg", "qsec"))
bubble_data <- data.frame(
  x = c(10, 15, 18, 25),
  y = c(50, 80, 65, 95),
  size = c(8, 12, 10, 16),
  segment = c("North", "South", "East", "West")
)
chartjs_bubble(bubble_data, x = "x", y = "y", radius = "size", group = "segment")
chartjs_pie(data.frame(stage = c("Discovery", "Delivery"), value = c(35, 65)),
            labels = "stage", values = "value")
# Additional helpers are available for doughnut, radar, and polar area charts
```

Every wrapper accepts an `options` argument so you can merge in bespoke
Chart.js configuration while retaining package defaults.

## Customisation

Use `options` to inject any Chart.js configuration block. For example, to create
stacked horizontal bars with formatted tick labels:

``` r
sales <- data.frame(
  region = c("North", "South", "East", "West"),
  hardware = c(120, 90, 150, 110),
  software = c(80, 60, 95, 70)
)

chartjs_bar(
  sales,
  x = "region",
  y = c("hardware", "software"),
  horizontal = TRUE,
  stacked = TRUE,
  options = list(
    plugins = list(title = list(display = TRUE, text = "Quarterly revenue")),
    scales = list(
      x = list(stacked = TRUE, ticks = list(callback = htmlwidgets::JS(
        "function(value) { return '$' + value + 'k'; }"
      )))
    )
  )
)
```

## Shiny integration

Render charts in Shiny using the familiar `chartjsOutput()` and
`renderChartjs()` helpers. The proxy interface lets you stream updates without
re-rendering the widget:

``` r
server <- function(input, output, session) {
  output$sales_chart <- renderChartjs({
    chartjs_bar(
      sales,
      x = "region",
      y = c("hardware", "software"),
      stacked = TRUE
    )
  })

  proxy <- chartjs_proxy("sales_chart", type = "bar", x = "region", y = c("hardware", "software"))

  observeEvent(input$refresh, {
    chartjs_update_data(proxy, mutate_sales_data())
  })
}
```

## Learning more

- Browse the `vignettes/` directory for a walk-through of the mapping helpers
  and advanced Chart.js configuration.
- Explore `inst/examples/` for reproducible scripts you can adapt.
- See the pkgdown site (or build it locally) for rendered examples.

Feedback and contributions are very welcome. Please open an issue or pull
request on [GitHub](https://github.com/ashgreat/chartjs).
