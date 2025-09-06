# Troubleshooting Guide

## Common Issues and Solutions

### Issue: Warning "incomplete final line found"

**Problem**: You see this warning when using the package:
```
Warning message:
In readLines(con, warn = readLines.warn) :
  incomplete final line found on '/path/to/chartjs.yaml'
```

**Solution**: This has been fixed in the latest version. The YAML configuration file now properly ends with a newline character.

### Issue: Charts not displaying in R console

**Problem**: When you run chart functions like `chartjs_line()`, nothing appears to show up.

**Solution**: This is expected behavior. htmlwidgets don't display directly in the R console. To view your charts:

1. **In RStudio**: Charts will automatically appear in the Viewer pane
2. **Save to HTML**: Use `htmlwidgets::saveWidget(chart, "my_chart.html")` and open the HTML file in a browser
3. **In Shiny**: Use `chartjsOutput()` and `renderChartjs()` in your Shiny apps

### Example Usage

```r
library(chartjs)

# Create sample data
data <- data.frame(
  month = c("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
  sales = c(10, 15, 12, 18, 20, 16),
  costs = c(8, 12, 10, 14, 16, 13)
)

# Create line chart
chart <- chartjs_line(data, x = "month", y = c("sales", "costs"))

# In RStudio: chart will show in Viewer pane automatically
print(chart)

# Save to HTML file
htmlwidgets::saveWidget(chart, "my_chart.html", selfcontained = FALSE)
```

### Testing Different Chart Types

```r
# Bar chart
chartjs_bar(data, x = "month", y = "sales")

# Pie chart
pie_data <- data.frame(
  category = c("Desktop", "Mobile", "Tablet"),
  percentage = c(60, 30, 10)
)
chartjs_pie(pie_data, labels = "category", values = "percentage")

# Scatter plot
scatter_data <- data.frame(
  x_vals = rnorm(20, 50, 10),
  y_vals = rnorm(20, 50, 10)
)
chartjs_scatter(scatter_data, x = "x_vals", y = "y_vals")
```

### Shiny Integration

```r
library(shiny)
library(chartjs)

ui <- fluidPage(
  titlePanel("Chart.js in Shiny"),
  chartjsOutput("myChart", height = "400px")
)

server <- function(input, output) {
  output$myChart <- renderChartjs({
    data <- data.frame(
      categories = c("A", "B", "C", "D"),
      values = c(10, 15, 8, 12)
    )
    chartjs_bar(data, x = "categories", y = "values")
  })
}

shinyApp(ui, server)
```

### Advanced Customization

```r
# Custom options
custom_options <- list(
  plugins = list(
    title = list(
      display = TRUE,
      text = "My Custom Chart"
    ),
    legend = list(
      position = "bottom"
    )
  ),
  scales = list(
    y = list(
      beginAtZero = TRUE,
      title = list(
        display = TRUE,
        text = "Values"
      )
    )
  )
)

chartjs_line(data, x = "month", y = "sales", options = custom_options)
```

## Package Status

✅ **All Issues Fixed**:
- YAML warning resolved
- Widget display working correctly  
- All chart types functional
- Shiny integration working
- Comprehensive test suite passing

## Getting Help

If you encounter other issues:
1. Check this troubleshooting guide first
2. Review the package documentation: `help(package = "chartjs")`
3. Look at the examples in the package
4. File an issue on GitHub: https://github.com/ashgreat/chart/issues