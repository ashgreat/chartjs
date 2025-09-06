test_that("chartjs basic functionality works", {
  # Test data
  test_data <- data.frame(
    x = c("A", "B", "C"),
    y = c(1, 2, 3)
  )
  
  # Test chartjs function
  chart <- chartjs(test_data, type = "bar", x = "x", y = "y")
  
  expect_s3_class(chart, "chartjs")
  expect_s3_class(chart, "htmlwidget")
  expect_equal(chart$x$type, "bar")
  expect_equal(length(chart$x$data$labels), 3)
  expect_equal(length(chart$x$data$datasets), 1)
})

test_that("chartjs_bar works correctly", {
  test_data <- data.frame(
    categories = c("Red", "Blue", "Green"),
    values = c(10, 20, 15)
  )
  
  chart <- chartjs_bar(test_data, x = "categories", y = "values")
  
  expect_s3_class(chart, "htmlwidget")
  expect_equal(chart$x$type, "bar")
  expect_equal(chart$x$data$labels, c("Red", "Blue", "Green"))
})

test_that("chartjs_line works correctly", {
  test_data <- data.frame(
    month = c("Jan", "Feb", "Mar"),
    sales = c(10, 15, 12)
  )
  
  chart <- chartjs_line(test_data, x = "month", y = "sales")
  
  expect_s3_class(chart, "htmlwidget")
  expect_equal(chart$x$type, "line")
  expect_equal(chart$x$data$labels, c("Jan", "Feb", "Mar"))
})

test_that("chartjs_pie works correctly", {
  test_data <- data.frame(
    category = c("A", "B", "C"),
    value = c(30, 40, 30)
  )
  
  chart <- chartjs_pie(test_data, labels = "category", values = "value")
  
  expect_s3_class(chart, "htmlwidget")
  expect_equal(chart$x$type, "pie")
  expect_equal(chart$x$data$labels, c("A", "B", "C"))
})

test_that("error handling works", {
  # Test with invalid data type
  expect_error(chartjs("not_a_dataframe"), "data must be a data.frame")
  
  # Test with invalid chart type
  expect_error(
    chartjs(data.frame(x = 1, y = 2), type = "invalid"), 
    "type must be one of"
  )
})

test_that("data conversion works correctly", {
  # Test basic data conversion
  test_data <- data.frame(
    x = c("A", "B", "C"),
    y = c(1, 2, 3)
  )
  
  # Access the internal function (normally not exported)
  converted <- chartjs:::convert_data_to_chartjs(test_data, "bar", "x", "y")
  
  expect_equal(converted$labels, c("A", "B", "C"))
  expect_equal(length(converted$datasets), 1)
  expect_equal(converted$datasets[[1]]$data, c(1, 2, 3))
})

test_that("default options are properly set", {
  # Access the internal function
  options <- chartjs:::get_default_options("bar")
  
  expect_true(options$responsive)
  expect_true(options$maintainAspectRatio)
  expect_true(options$scales$y$beginAtZero)
})