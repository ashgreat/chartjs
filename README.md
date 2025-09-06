# chartjs <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/ashgreat/chartjs/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ashgreat/chartjs/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/chartjs)](https://CRAN.R-project.org/package=chartjs)
<!-- badges: end -->

Create interactive charts in R using the Chart.js JavaScript library. The `chartjs` package supports all Chart.js chart types including bar, line, scatter, bubble, pie, doughnut, radar, and polar area charts with full animation and plugin support. It integrates seamlessly with Shiny applications.

## Installation

You can install the development version of chartjs from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ashgreat/chartjs")
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

The package supports all Chart.js chart types with dedicated wrapper functions. Here are examples of all eight chart types:

### 1. Bar Charts

```r
library(chartjs)

# Vertical bar chart
data <- data.frame(
  categories = c("Red", "Blue", "Yellow", "Green", "Purple", "Orange"),
  values = c(12, 19, 3, 5, 2, 3)
)

chartjs_bar(data, x = "categories", y = "values")
```

### 2. Line Charts

```r
# Multi-series line chart (displays as pure lines without area fill)
data <- data.frame(
  month = c("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
  sales = c(10, 15, 12, 18, 20, 16),
  costs = c(8, 12, 10, 14, 16, 13)
)

chartjs_line(data, x = "month", y = c("sales", "costs"))
```

### 3. Scatter Plots

```r
# Scatter plot showing correlation
data <- data.frame(
  height = c(160, 170, 180, 165, 175, 185, 155, 190),
  weight = c(60, 70, 80, 65, 75, 85, 55, 90)
)

chartjs_scatter(data, x = "height", y = "weight")
```

### 4. Bubble Charts

```r
# Bubble chart with three dimensions
data <- data.frame(
  x = c(20, 30, 40, 50, 60),
  y = c(30, 50, 60, 70, 80),
  r = c(10, 15, 20, 25, 30)  # bubble radius
)

chartjs(data, type = "bubble", x = "x", y = c("y", "r"))
```

### 5. Pie Charts

```r
# Browser usage pie chart
data <- data.frame(
  browser = c("Chrome", "Firefox", "Safari", "Edge", "Other"),
  usage = c(55, 25, 10, 7, 3)
)

chartjs_pie(data, labels = "browser", values = "usage")
```

### 6. Doughnut Charts

```r
# Device type distribution doughnut
data <- data.frame(
  device = c("Desktop", "Mobile", "Tablet", "Other"),
  percentage = c(45, 35, 15, 5)
)

chartjs_doughnut(data, labels = "device", values = "percentage")
```

### 7. Radar Charts

```r
# Skills comparison radar chart
data <- data.frame(
  skill = c("Programming", "Design", "Communication", "Leadership", "Analytics"),
  person1 = c(9, 6, 8, 7, 8),
  person2 = c(7, 8, 9, 8, 6)
)

chartjs_radar(data, labels = "skill", values = c("person1", "person2"))
```

### 8. Polar Area Charts

```r
# Survey results polar area
data <- data.frame(
  response = c("Excellent", "Good", "Fair", "Poor"),
  count = c(25, 15, 8, 2)
)

chartjs_polar(data, labels = "response", values = "count")
```

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

- [Getting Started Guide](https://ashgreat.github.io/chartjs/articles/getting-started.html)
- [Function Reference](https://ashgreat.github.io/chartjs/reference/)
- [Chart.js Documentation](https://www.chartjs.org/docs/latest/)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is licensed under the MIT License. Chart.js is licensed under the MIT License.