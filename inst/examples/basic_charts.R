#!/usr/bin/env Rscript

# Basic Chart.js Examples for R
# This file contains examples of different chart types using the chartjs package

library(chartjs)

# Example 1: Bar Chart
cat("Creating bar chart...\n")
bar_data <- data.frame(
  labels = c("Red", "Blue", "Yellow", "Green", "Purple", "Orange"),
  values = c(12, 19, 3, 5, 2, 3)
)

bar_chart <- chartjs_bar(bar_data, x = "labels", y = "values")
print(bar_chart)

# Example 2: Line Chart
cat("Creating line chart...\n")
line_data <- data.frame(
  month = c("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
  sales = c(10, 15, 12, 18, 20, 16),
  costs = c(8, 12, 10, 14, 16, 13)
)

line_chart <- chartjs_line(line_data, x = "month", y = c("sales", "costs"))
print(line_chart)

# Example 3: Pie Chart
cat("Creating pie chart...\n")
pie_data <- data.frame(
  category = c("Desktop", "Mobile", "Tablet"),
  percentage = c(55, 35, 10)
)

pie_chart <- chartjs_pie(pie_data, labels = "category", values = "percentage")
print(pie_chart)

# Example 4: Scatter Plot
cat("Creating scatter plot...\n")
set.seed(42)
scatter_data <- data.frame(
  x_vals = rnorm(20, 50, 10),
  y_vals = rnorm(20, 50, 10)
)

scatter_chart <- chartjs_scatter(scatter_data, x = "x_vals", y = "y_vals")
print(scatter_chart)

# Example 5: Doughnut Chart
cat("Creating doughnut chart...\n")
doughnut_data <- data.frame(
  segment = c("Segment A", "Segment B", "Segment C", "Segment D"),
  value = c(300, 50, 100, 75)
)

doughnut_chart <- chartjs_doughnut(doughnut_data, labels = "segment", values = "value")
print(doughnut_chart)

# Example 6: Radar Chart
cat("Creating radar chart...\n")
radar_data <- data.frame(
  skill = c("Programming", "Design", "Communication", "Leadership", "Analytics"),
  john = c(90, 60, 80, 70, 85),
  jane = c(70, 85, 90, 80, 75)
)

radar_chart <- chartjs_radar(radar_data, labels = "skill", values = c("john", "jane"))
print(radar_chart)

cat("All examples completed!\n")