#' Create a bar chart
#'
#' @param data A data.frame containing the data to visualize
#' @param x Character string specifying the column name for x-axis (categories)
#' @param y Character string or vector specifying column name(s) for y-axis (values)
#' @param horizontal Logical, whether to create a horizontal bar chart
#' @param ... Additional arguments passed to \code{\link{chartjs}}
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
chartjs_bar <- function(data, x = NULL, y = NULL, horizontal = FALSE, ...) {
  type <- if (horizontal) "horizontalBar" else "bar"
  chartjs(data = data, type = type, x = x, y = y, ...)
}

#' Create a line chart
#'
#' @param data A data.frame containing the data to visualize
#' @param x Character string specifying the column name for x-axis
#' @param y Character string or vector specifying column name(s) for y-axis
#' @param smooth Logical, whether to smooth the lines (default: TRUE)
#' @param ... Additional arguments passed to \code{\link{chartjs}}
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
chartjs_line <- function(data, x = NULL, y = NULL, smooth = TRUE, ...) {
  options <- list()
  if (!smooth) {
    options$elements <- list(line = list(tension = 0))
  }
  
  # Merge with user options
  user_options <- list(...)$options %||% list()
  options <- merge_options(options, user_options)
  
  chartjs(data = data, type = "line", x = x, y = y, options = options, ...)
}

#' Create a scatter plot
#'
#' @param data A data.frame containing the data to visualize
#' @param x Character string specifying the column name for x-axis
#' @param y Character string specifying the column name for y-axis
#' @param ... Additional arguments passed to \code{\link{chartjs}}
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
chartjs_scatter <- function(data, x = NULL, y = NULL, ...) {
  chartjs(data = data, type = "scatter", x = x, y = y, ...)
}

#' Create a pie chart
#'
#' @param data A data.frame containing the data to visualize
#' @param labels Character string specifying the column name for labels
#' @param values Character string specifying the column name for values
#' @param ... Additional arguments passed to \code{\link{chartjs}}
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
chartjs_pie <- function(data, labels = NULL, values = NULL, ...) {
  chartjs(data = data, type = "pie", x = labels, y = values, ...)
}

#' Create a doughnut chart
#'
#' @param data A data.frame containing the data to visualize
#' @param labels Character string specifying the column name for labels
#' @param values Character string specifying the column name for values
#' @param ... Additional arguments passed to \code{\link{chartjs}}
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
chartjs_doughnut <- function(data, labels = NULL, values = NULL, ...) {
  chartjs(data = data, type = "doughnut", x = labels, y = values, ...)
}

#' Create a radar chart
#'
#' @param data A data.frame containing the data to visualize
#' @param labels Character string specifying the column name for labels (axes)
#' @param values Character string or vector specifying column name(s) for values
#' @param ... Additional arguments passed to \code{\link{chartjs}}
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
chartjs_radar <- function(data, labels = NULL, values = NULL, ...) {
  chartjs(data = data, type = "radar", x = labels, y = values, ...)
}

#' Create a polar area chart
#'
#' @param data A data.frame containing the data to visualize
#' @param labels Character string specifying the column name for labels
#' @param values Character string specifying the column name for values
#' @param ... Additional arguments passed to \code{\link{chartjs}}
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
chartjs_polar <- function(data, labels = NULL, values = NULL, ...) {
  chartjs(data = data, type = "polarArea", x = labels, y = values, ...)
}

#' Null-default operator
#' @noRd
`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}