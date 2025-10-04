#' Create a proxy object for Chart.js widget manipulation
#'
#' This function creates a proxy object that can be used to update Chart.js
#' widgets that have already been rendered in a Shiny application, without
#' having to completely re-render the chart.
#'
#' @param outputId The output ID of the chart to control
#' @param session The Shiny session object (optional, defaults to current session)
#' @param type Optional chart type. Providing this (along with mappings) enables
#'   helpers such as [chartjs_update_data()] to rebuild datasets on the server.
#' @param x Optional column mapping for the x-axis or labels
#' @param y Optional column mapping for values (vector for multi-series charts)
#' @param radius Optional column name for bubble chart radii
#' @param group Optional column name used to split bubble datasets
#'
#' @return A `chartjs_proxy` object
#' @export
#' @examples
#' \dontrun{
#' # In a Shiny server function
#' proxy <- chartjs_proxy(
#'   "sales_chart",
#'   type = "bar",
#'   x = "month",
#'   y = c("sales", "forecast")
#' )
#'
#' chartjs_update_data(proxy, new_data_frame)
#' }
chartjs_proxy <- function(outputId,
                          session = shiny::getDefaultReactiveDomain(),
                          type = NULL,
                          x = NULL,
                          y = NULL,
                          radius = NULL,
                          group = NULL) {
  if (is.null(session)) {
    stop("chartjs_proxy must be called within a Shiny server function", call. = FALSE)
  }

  state <- new.env(parent = emptyenv())
  state$meta <- compact_list(list(
    type = type,
    x = x,
    y = y,
    radius = radius,
    group = group
  ))

  structure(
    list(
      id = outputId,
      session = session,
      state = state
    ),
    class = "chartjs_proxy"
  )
}

#' Update chart data via proxy
#'
#' @param proxy A `chartjs_proxy` object created with [chartjs_proxy]
#' @param data New data for the chart (same format as original data)
#' @param type Optional chart type override
#' @param x Column name for x-axis (optional, uses existing mapping if not provided)
#' @param y Column name(s) for y-axis (optional, uses existing mapping if not provided)
#' @param radius Column name for bubble radius (only used when `type == "bubble"`)
#' @param group Column name for bubble grouping (only used when `type == "bubble"`)
#'
#' @return The proxy object (for method chaining)
#' @export
chartjs_update_data <- function(proxy,
                                data,
                                type = NULL,
                                x = NULL,
                                y = NULL,
                                radius = NULL,
                                group = NULL) {
  validate_proxy(proxy)

  meta <- update_proxy_meta(proxy, list(
    type = type,
    x = x,
    y = y,
    radius = radius,
    group = group
  ))

  if (is.null(meta$type)) {
    stop("chartjs_update_data requires a chart type. Provide it when creating the proxy or via the function call.", call. = FALSE)
  }

  y_mapping <- build_proxy_y_mapping(meta)
  payload <- build_chart_payload(data, meta$type, meta$x, y_mapping)

  proxy$state$meta <- payload$meta

  proxy$session$sendCustomMessage(
    "chartjs-update-data",
    list(
      id = proxy$id,
      data = payload$data,
      meta = payload$meta
    )
  )

  invisible(proxy)
}

#' Update chart options via proxy
#'
#' @param proxy A `chartjs_proxy` object created with [chartjs_proxy]
#' @param options New options for the chart. These will be merged with the
#'   current chart options on the client.
#'
#' @return The proxy object (for method chaining)
#' @export
chartjs_update_options <- function(proxy, options) {
  validate_proxy(proxy)

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
#' @param proxy A `chartjs_proxy` object created with [chartjs_proxy]
#' @param dataset A list describing the new dataset. This list should follow the
#'   Chart.js dataset structure (e.g. contain `label`, `data`, `backgroundColor`).
#'
#' @return The proxy object (for method chaining)
#' @export
chartjs_add_dataset <- function(proxy, dataset) {
  validate_proxy(proxy)

  if (!is.list(dataset)) {
    stop("dataset must be a list matching the Chart.js dataset structure", call. = FALSE)
  }

  proxy$session$sendCustomMessage(
    "chartjs-add-dataset",
    list(
      id = proxy$id,
      dataset = dataset
    )
  )

  invisible(proxy)
}

#' Remove a dataset from the chart
#'
#' @param proxy A `chartjs_proxy` object created with [chartjs_proxy]
#' @param index Index of the dataset to remove (0-based)
#'
#' @return The proxy object (for method chaining)
#' @export
chartjs_remove_dataset <- function(proxy, index) {
  validate_proxy(proxy)

  proxy$session$sendCustomMessage(
    "chartjs-remove-dataset",
    list(
      id = proxy$id,
      index = index
    )
  )

  invisible(proxy)
}

#' Validate proxy objects
#' @noRd
validate_proxy <- function(proxy) {
  if (!inherits(proxy, "chartjs_proxy")) {
    stop("First argument must be a chartjs_proxy object", call. = FALSE)
  }
}

#' Merge proxy metadata updates
#' @noRd
update_proxy_meta <- function(proxy, updates) {
  current <- proxy$state$meta %||% list()
  updates <- compact_list(updates)
  proxy$state$meta <- utils::modifyList(current, updates, keep.null = TRUE)
  proxy$state$meta
}

#' Build y mapping for proxy updates
#' @noRd
build_proxy_y_mapping <- function(meta) {
  if (meta$type == "bubble") {
    columns <- c(meta$y, meta$radius, meta$group)
    columns <- columns[!vapply(columns, is.null, logical(1))]
    return(columns)
  }
  meta$y
}
