test_that("chartjs basic functionality works", {
  test_data <- data.frame(
    x = c("A", "B", "C"),
    y = c(1, 2, 3)
  )

  chart <- chartjs(test_data, type = "bar", x = "x", y = "y")

  expect_s3_class(chart, "chartjs")
  expect_s3_class(chart, "htmlwidget")
  expect_equal(chart$x$type, "bar")
  expect_equal(length(chart$x$data$labels), 3)
  expect_equal(length(chart$x$data$datasets), 1)
})

test_that("chartjs_bar horizontal charts configure indexAxis", {
  test_data <- data.frame(
    category = c("A", "B", "C"),
    value = c(10, 15, 20)
  )

  chart <- chartjs_bar(test_data, x = "category", y = "value", horizontal = TRUE)

  expect_equal(chart$x$options$indexAxis, "y")
})

test_that("chartjs_line respects smooth and fill arguments", {
  test_data <- data.frame(
    month = c("Jan", "Feb", "Mar"),
    sales = c(10, 15, 12)
  )

  chart <- chartjs_line(test_data, x = "month", y = "sales", smooth = FALSE, fill = TRUE)

  expect_equal(chart$x$type, "line")
  expect_equal(chart$x$options$elements$line$tension, 0)
  expect_true(chart$x$options$elements$line$fill)
})

test_that("scatter data is converted into point objects", {
  test_data <- data.frame(
    height = c(160, 170),
    weight = c(60, 70)
  )

  chart <- chartjs_scatter(test_data, x = "height", y = "weight")

  expect_equal(names(chart$x$data$datasets[[1]]$data[[1]]), c("x", "y"))
  expect_equal(chart$x$data$datasets[[1]]$data[[1]]$x, 160)
})

test_that("bubble charts require radius and map correctly", {
  test_data <- data.frame(
    x = c(20, 30),
    y = c(40, 50),
    r = c(10, 15)
  )

  chart <- chartjs_bubble(test_data, x = "x", y = "y", radius = "r")

  expect_equal(chart$x$type, "bubble")
  expect_equal(names(chart$x$data$datasets[[1]]$data[[1]]), c("x", "y", "r"))
  expect_equal(chart$x$data$datasets[[1]]$data[[1]]$r, 10)
})

test_that("pie charts use provided label and value columns", {
  test_data <- data.frame(
    category = c("A", "B"),
    count = c(30, 70)
  )

  chart <- chartjs_pie(test_data, labels = "category", values = "count")

  expect_equal(chart$x$data$labels, c("A", "B"))
  expect_equal(chart$x$data$datasets[[1]]$data, c(30, 70))
})

test_that("error handling works", {
  expect_error(chartjs("not_a_dataframe"), "data must be a data.frame")
  expect_error(chartjs(data.frame(x = 1, y = 2), type = "invalid"), "type must be one of")
  expect_error(chartjs_scatter(data.frame(x = 1), x = "x"), "Scatter charts require")
})

test_that("default options include responsive behaviour", {
  options <- chartjs:::get_default_options("bar")
  expect_true(options$responsive)
  expect_true(options$maintainAspectRatio)
  expect_true(options$scales$y$beginAtZero)
})
