#' Create a proxy object for Chart.js widget manipulation
#'
#' This function creates a proxy object that can be used to update Chart.js
#' widgets that have already been rendered in a Shiny application, without
#' having to completely re-render the chart.
#'
#' @param outputId The output ID of the chart to control
#' @param session The Shiny session object (optional, defaults to current session)
#'
#' @return A chartjs_proxy object
#' @export
#' @examples
#' \dontrun{
#' # In a Shiny server function
#' proxy <- chartjs_proxy("myChart")
#' proxy %>% chartjs_update_data(new_data)
#' }
chartjs_proxy <- function(outputId, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("chartjs_proxy must be called within a Shiny server function")
  }
  
  structure(
    list(
      id = outputId,
      session = session
    ),
    class = "chartjs_proxy"
  )
}

#' Update chart data via proxy
#'
#' @param proxy A chartjs_proxy object created with \code{\link{chartjs_proxy}}
#' @param data New data for the chart (same format as original data)
#' @param x Column name for x-axis (optional, uses original if not specified)
#' @param y Column name(s) for y-axis (optional, uses original if not specified)
#'
#' @return The proxy object (for method chaining)
#' @export
chartjs_update_data <- function(proxy, data, x = NULL, y = NULL) {
  if (!inherits(proxy, "chartjs_proxy")) {
    stop("First argument must be a chartjs_proxy object")
  }
  
  # Convert data to Chart.js format
  # Note: We'd need to store the original chart type, for now assume "bar"
  chart_data <- convert_data_to_chartjs(data, "bar", x, y)
  
  proxy$session$sendCustomMessage(
    "chartjs-update-data",
    list(
      id = proxy$id,
      data = chart_data
    )
  )
  
  invisible(proxy)
}

#' Update chart options via proxy
#'
#' @param proxy A chartjs_proxy object created with \code{\link{chartjs_proxy}}
#' @param options New options for the chart
#'
#' @return The proxy object (for method chaining)
#' @export
chartjs_update_options <- function(proxy, options) {
  if (!inherits(proxy, "chartjs_proxy")) {
    stop("First argument must be a chartjs_proxy object")
  }
  
  proxy$session$sendCustomMessage(
    "chartjs-update-options",
    list(
      id = proxy$id,
      options = options
    )
  )
  
  invisible(proxy)
}

#' Add a new dataset to the chart
#'
#' @param proxy A chartjs_proxy object created with \code{\link{chartjs_proxy}}
#' @param data Vector of data values
#' @param label Label for the new dataset
#' @param color Color for the new dataset (optional)
#'
#' @return The proxy object (for method chaining)
#' @export
chartjs_add_dataset <- function(proxy, data, label, color = NULL) {
  if (!inherits(proxy, "chartjs_proxy")) {
    stop("First argument must be a chartjs_proxy object")
  }
  
  if (is.null(color)) {
    color <- get_default_colors(1)[1]
  }
  
  new_dataset <- list(
    label = label,
    data = data,
    backgroundColor = color,
    borderColor = color
  )
  
  proxy$session$sendCustomMessage(
    "chartjs-add-dataset",
    list(
      id = proxy$id,
      dataset = new_dataset
    )
  )
  
  invisible(proxy)
}

#' Remove a dataset from the chart
#'
#' @param proxy A chartjs_proxy object created with \code{\link{chartjs_proxy}}
#' @param index Index of the dataset to remove (0-based)
#'
#' @return The proxy object (for method chaining)
#' @export
chartjs_remove_dataset <- function(proxy, index) {
  if (!inherits(proxy, "chartjs_proxy")) {
    stop("First argument must be a chartjs_proxy object")
  }
  
  proxy$session$sendCustomMessage(
    "chartjs-remove-dataset",
    list(
      id = proxy$id,
      index = index
    )
  )
  
  invisible(proxy)
}