# chartjs <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/ashgreat/chart/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ashgreat/chart/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/chartjs)](https://CRAN.R-project.org/package=chartjs)
<!-- badges: end -->

Create interactive charts in R using the Chart.js JavaScript library. The `chartjs` package supports all Chart.js chart types including bar, line, scatter, bubble, pie, doughnut, radar, and polar area charts with full animation and plugin support. It integrates seamlessly with Shiny applications.

## Installation

You can install the development version of chartjs from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ashgreat/chart")
```

## Quick Start

### Basic Bar Chart

```r
library(chartjs)

# Create sample data
data <- data.frame(
  categories = c("Red", "Blue", "Yellow", "Green", "Purple", "Orange"),
  values = c(12, 19, 3, 5, 2, 3)
)

# Create bar chart
chartjs_bar(data, x = "categories", y = "values")
```

### Line Chart with Multiple Series

```r
# Create sample data
data <- data.frame(
  month = c("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
  sales = c(10, 15, 12, 18, 20, 16),
  costs = c(8, 12, 10, 14, 16, 13)
)

# Create line chart
chartjs_line(data, x = "month", y = c("sales", "costs"))
```

### Pie Chart

```r
# Create sample data  
data <- data.frame(
  browser = c("Chrome", "Firefox", "Safari", "Edge", "Other"),
  usage = c(55, 25, 10, 7, 3)
)

# Create pie chart
chartjs_pie(data, labels = "browser", values = "usage")
```

## Chart Types

The package supports all major Chart.js chart types:

- **Bar Charts**: `chartjs_bar()`
- **Line Charts**: `chartjs_line()`
- **Scatter Plots**: `chartjs_scatter()`
- **Bubble Charts**: `chartjs()` with type "bubble"
- **Pie Charts**: `chartjs_pie()`
- **Doughnut Charts**: `chartjs_doughnut()`
- **Radar Charts**: `chartjs_radar()`
- **Polar Area Charts**: `chartjs_polar()`

## Shiny Integration

The package provides seamless integration with Shiny applications:

```r
library(shiny)
library(chartjs)

ui <- fluidPage(
  titlePanel("Chart.js in Shiny"),
  chartjsOutput("myChart")
)

server <- function(input, output) {
  output$myChart <- renderChartjs({
    data <- data.frame(
      x = c("A", "B", "C", "D"),
      y = c(10, 15, 8, 12)
    )
    chartjs_bar(data, x = "x", y = "y")
  })
}

shinyApp(ui, server)
```

### Dynamic Updates

Update charts dynamically using proxy functions:

```r
# In your Shiny server function
proxy <- chartjs_proxy("myChart")
proxy %>% chartjs_update_data(new_data)
```

## Customization

Customize charts using Chart.js options:

```r
options <- list(
  plugins = list(
    title = list(
      display = TRUE,
      text = "My Custom Chart"
    )
  ),
  scales = list(
    y = list(
      beginAtZero = TRUE
    )
  )
)

chartjs_bar(data, x = "categories", y = "values", options = options)
```

## Features

- ✅ All Chart.js chart types supported
- ✅ Full Chart.js options and configuration support  
- ✅ Seamless Shiny integration with reactive updates
- ✅ Event handling (clicks, hovers)
- ✅ Animation support
- ✅ Plugin system integration
- ✅ Responsive design
- ✅ Custom themes and styling

## Documentation

- [Getting Started Guide](https://ashgreat.github.io/chart/articles/getting-started.html)
- [Function Reference](https://ashgreat.github.io/chart/reference/)
- [Chart.js Documentation](https://www.chartjs.org/docs/latest/)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is licensed under the MIT License. Chart.js is licensed under the MIT License.