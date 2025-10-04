#' Create a bar chart
#'
#' @param data A data.frame containing the data to visualize
#' @param x Character string specifying the column name for x-axis (categories)
#' @param y Character string or vector specifying column name(s) for y-axis (values)
#' @param horizontal Logical, whether to create a horizontal bar chart
#' @param stacked Logical, whether to stack multiple series
#' @param options Optional Chart.js options to apply on top of bar defaults
#' @param ... Additional arguments passed to [chartjs]
#'
#' @return An htmlwidget object containing the bar chart
#' @export
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   category = c("A", "B", "C", "D"),
#'   values = c(10, 15, 8, 12)
#' )
#' chartjs_bar(data, x = "category", y = "values")
#' }
chartjs_bar <- function(data, x = NULL, y = NULL, horizontal = FALSE, stacked = FALSE,
                        options = NULL, ...) {
  bar_defaults <- list()

  if (horizontal) {
    bar_defaults$indexAxis <- "y"
  }

  if (stacked) {
    bar_defaults$scales <- list(
      x = list(stacked = TRUE),
      y = list(stacked = TRUE)
    )
  }

  combined_options <- merge_options(bar_defaults, options)

  chartjs(
    data = data,
    type = "bar",
    x = x,
    y = y,
    options = combined_options,
    ...
  )
}

#' Create a line chart
#'
#' @param data A data.frame containing the data to visualize
#' @param x Character string specifying the column name for x-axis
#' @param y Character string or vector specifying column name(s) for y-axis
#' @param smooth Logical, whether to smooth the lines (default: TRUE)
#' @param fill Logical, whether to fill the area under the line (default: FALSE)
#' @param options Optional Chart.js options to apply on top of line defaults
#' @param ... Additional arguments passed to [chartjs]
#'
#' @return An htmlwidget object containing the line chart
#' @export
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   month = c("Jan", "Feb", "Mar", "Apr"),
#'   sales = c(10, 15, 12, 18)
#' )
#' chartjs_line(data, x = "month", y = "sales")
#' }
chartjs_line <- function(data, x = NULL, y = NULL, smooth = TRUE, fill = FALSE,
                         options = NULL, ...) {
  line_defaults <- list(
    elements = list(
      line = list(tension = if (smooth) 0.4 else 0, fill = fill),
      point = list(radius = 3, hoverRadius = 5)
    )
  )

  if (fill) {
    line_defaults$plugins <- list(filler = list(propagate = TRUE))
  }

  combined_options <- merge_options(line_defaults, options)

  chartjs(
    data = data,
    type = "line",
    x = x,
    y = y,
    options = combined_options,
    ...
  )
}

#' Create a scatter plot
#'
#' @param data A data.frame containing the data to visualize
#' @param x Character string specifying the column name for x-axis
#' @param y Character string or vector specifying column name(s) for y-axis
#' @param options Optional Chart.js options to apply on top of scatter defaults
#' @param ... Additional arguments passed to [chartjs]
#'
#' @return An htmlwidget object containing the scatter plot
#' @export
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   height = c(160, 170, 180, 165, 175),
#'   weight = c(60, 70, 80, 65, 75)
#' )
#' chartjs_scatter(data, x = "height", y = "weight")
#' }
chartjs_scatter <- function(data, x = NULL, y = NULL, options = NULL, ...) {
  chartjs(
    data = data,
    type = "scatter",
    x = x,
    y = y,
    options = options,
    ...
  )
}

#' Create a bubble chart
#'
#' @param data A data.frame containing the data to visualize
#' @param x Character string specifying the column name for x-coordinate
#' @param y Character string specifying the column name for y-coordinate values
#' @param radius Character string specifying the column for point radius
#' @param group Optional character string specifying the column to split datasets
#' @param options Optional Chart.js options to apply on top of bubble defaults
#' @param ... Additional arguments passed to [chartjs]
#'
#' @return An htmlwidget object containing the bubble chart
#' @export
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   x = c(20, 30, 40, 50, 60),
#'   y = c(30, 50, 60, 70, 80),
#'   r = c(10, 15, 20, 25, 30)
#' )
#' chartjs_bubble(data, x = "x", y = "y", radius = "r")
#' }
chartjs_bubble <- function(data, x = NULL, y = NULL, radius = NULL, group = NULL,
                           options = NULL, ...) {
  if (is.null(radius)) {
    stop("Bubble charts require the 'radius' argument", call. = FALSE)
  }

  mapping <- list(value = y, radius = radius)
  if (!is.null(group)) {
    mapping$group <- group
  }

  chartjs(
    data = data,
    type = "bubble",
    x = x,
    y = mapping,
    options = options,
    ...
  )
}

#' Create a pie chart
#'
#' @param data A data.frame containing the data to visualize
#' @param labels Character string specifying the column name for labels
#' @param values Character string specifying the column name for values
#' @param options Optional Chart.js options to apply on top of pie defaults
#' @param ... Additional arguments passed to [chartjs]
#'
#' @return An htmlwidget object containing the pie chart
#' @export
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   category = c("Red", "Blue", "Yellow"),
#'   count = c(300, 50, 100)
#' )
#' chartjs_pie(data, labels = "category", values = "count")
#' }
chartjs_pie <- function(data, labels = NULL, values = NULL, options = NULL, ...) {
  chartjs(
    data = data,
    type = "pie",
    x = labels,
    y = values,
    options = options,
    ...
  )
}

#' Create a doughnut chart
#'
#' @param data A data.frame containing the data to visualize
#' @param labels Character string specifying the column name for labels
#' @param values Character string specifying the column name for values
#' @param options Optional Chart.js options to apply on top of doughnut defaults
#' @param ... Additional arguments passed to [chartjs]
#'
#' @return An htmlwidget object containing the doughnut chart
#' @export
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   category = c("Red", "Blue", "Yellow"),
#'   count = c(300, 50, 100)
#' )
#' chartjs_doughnut(data, labels = "category", values = "count")
#' }
chartjs_doughnut <- function(data, labels = NULL, values = NULL, options = NULL, ...) {
  chartjs(
    data = data,
    type = "doughnut",
    x = labels,
    y = values,
    options = options,
    ...
  )
}

#' Create a radar chart
#'
#' @param data A data.frame containing the data to visualize
#' @param labels Character string specifying the column name for labels (axes)
#' @param values Character string or vector specifying column name(s) for values
#' @param options Optional Chart.js options to apply on top of radar defaults
#' @param ... Additional arguments passed to [chartjs]
#'
#' @return An htmlwidget object containing the radar chart
#' @export
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   skill = c("Programming", "Design", "Communication", "Leadership"),
#'   person1 = c(9, 6, 8, 7),
#'   person2 = c(7, 8, 7, 9)
#' )
#' chartjs_radar(data, labels = "skill", values = c("person1", "person2"))
#' }
chartjs_radar <- function(data, labels = NULL, values = NULL, options = NULL, ...) {
  chartjs(
    data = data,
    type = "radar",
    x = labels,
    y = values,
    options = options,
    ...
  )
}

#' Create a polar area chart
#'
#' @param data A data.frame containing the data to visualize
#' @param labels Character string specifying the column name for labels
#' @param values Character string specifying the column name for values
#' @param options Optional Chart.js options to apply on top of polar area defaults
#' @param ... Additional arguments passed to [chartjs]
#'
#' @return An htmlwidget object containing the polar area chart
#' @export
#' @examples
#' \dontrun{
#' data <- data.frame(
#'   category = c("Red", "Green", "Yellow", "Grey", "Blue"),
#'   value = c(11, 16, 7, 3, 14)
#' )
#' chartjs_polar(data, labels = "category", values = "value")
#' }
chartjs_polar <- function(data, labels = NULL, values = NULL, options = NULL, ...) {
  chartjs(
    data = data,
    type = "polarArea",
    x = labels,
    y = values,
    options = options,
    ...
  )
}

#' Null-default operator
#' @noRd
`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}
