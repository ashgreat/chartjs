#' Create a Chart.js visualization
#'
#' This function creates interactive charts using the Chart.js JavaScript library.
#' It supports all Chart.js chart types including bar, line, scatter, bubble, pie,
#' doughnut, radar, and polar area charts.
#'
#' @param data A data.frame containing the data to visualize
#' @param type Character string specifying the chart type. One of: "bar", "line",
#'   "scatter", "bubble", "pie", "doughnut", "radar", "polarArea"
#' @param x Character string specifying the column name for x-axis values (labels)
#' @param y Character string or vector specifying column name(s) for y-axis values.
#'   For bubble charts provide value and radius columns (e.g. `c("y", "r")`).
#' @param options List of Chart.js options for customizing the chart
#' @param width Width of the chart (optional, defaults to automatic sizing)
#' @param height Height of the chart (optional, defaults to automatic sizing)
#' @param elementId Element ID for the chart (optional)
#'
#' @return An htmlwidget object containing the Chart.js visualization
#' @export
#' @examples
#' \dontrun{
#' # Simple bar chart
#' data <- data.frame(
#'   labels = c("Red", "Blue", "Yellow", "Green", "Purple", "Orange"),
#'   values = c(12, 19, 3, 5, 2, 3)
#' )
#' chartjs(data, type = "bar", x = "labels", y = "values")
#'
#' # Line chart with multiple series
#' data <- data.frame(
#'   month = c("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
#'   sales = c(10, 15, 12, 18, 20, 16),
#'   costs = c(8, 12, 10, 14, 16, 13)
#' )
#' chartjs(data, type = "line", x = "month", y = c("sales", "costs"))
#'
#' # Scatter chart with two series
#' data <- data.frame(
#'   temperature = c(10, 15, 18, 22, 26),
#'   demand = c(100, 140, 170, 220, 260),
#'   production = c(120, 150, 185, 210, 240)
#' )
#' chartjs(data, type = "scatter", x = "temperature", y = c("demand", "production"))
#' }
chartjs <- function(data, type = "bar", x = NULL, y = NULL, options = NULL,
                    width = NULL, height = NULL, elementId = NULL) {
  if (!is.data.frame(data)) {
    stop("data must be a data.frame", call. = FALSE)
  }

  supported_types <- c("bar", "line", "scatter", "bubble", "pie",
                       "doughnut", "radar", "polarArea")
  if (!type %in% supported_types) {
    stop(
      sprintf(
        "type must be one of: %s",
        paste(supported_types, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  built <- build_chart_payload(data, type, x, y)

  widget_data <- list(
    type = type,
    data = built$data,
    options = merge_options(get_default_options(type), options),
    meta = built$meta
  )

  htmlwidgets::createWidget(
    name = "chartjs",
    widget_data,
    width = width,
    height = height,
    package = "chartjs",
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth = "100%",
      defaultHeight = 400,
      padding = 0,
      viewer.defaultWidth = "100%",
      viewer.defaultHeight = 400,
      browser.defaultWidth = "100%",
      browser.defaultHeight = 400,
      browser.fill = TRUE,
      viewer.fill = TRUE
    )
  )
}

#' Convert R data to Chart.js structures
#' @noRd
build_chart_payload <- function(data, type, x, y) {
  switch(
    type,
    pie = build_segment_chart(data, x, y, type),
    doughnut = build_segment_chart(data, x, y, type),
    polarArea = build_segment_chart(data, x, y, type),
    scatter = build_scatter_chart(data, x, y),
    bubble = build_bubble_chart(data, x, y),
    radar = build_multivariate_chart(data, x, y, type),
    line = build_multivariate_chart(data, x, y, type),
    bar = build_multivariate_chart(data, x, y, type),
    stop("Unsupported chart type", call. = FALSE)
  )
}

#' Build bar/line/radar style datasets
#' @noRd
build_multivariate_chart <- function(data, x, y, type) {
  labels <- resolve_labels(data, x)

  value_cols <- resolve_value_columns(data, y, exclude = x)
  validate_numeric_columns(data, value_cols)

  colors <- get_default_colors(length(value_cols))

  datasets <- lapply(seq_along(value_cols), function(i) {
    column <- value_cols[i]
    dataset <- list(
      label = column,
      data = as.numeric(data[[column]]),
      backgroundColor = colors[i],
      borderColor = colors[i],
      borderWidth = if (type %in% c("line", "radar")) 2 else 1
    )

    if (type == "line") {
      dataset$fill <- FALSE
      dataset$pointRadius <- 3
      dataset$pointHoverRadius <- 5
      dataset$tension <- 0.3
    }

    if (type == "radar") {
      dataset$fill <- TRUE
      dataset$backgroundColor <- apply_alpha(colors[i], 0.25)
    }

    if (type == "bar") {
      dataset$borderWidth <- 0
    }

    compact_list(dataset)
  })

  list(
    data = list(
      labels = labels,
      datasets = datasets
    ),
    meta = list(
      type = type,
      x = x,
      y = value_cols
    )
  )
}

#' Build pie/doughnut/polar datasets
#' @noRd
build_segment_chart <- function(data, x, y, type) {
  label_col <- x %||% names(data)[1]
  if (!label_col %in% names(data)) {
    stop(sprintf("Column '%s' not found in data", label_col), call. = FALSE)
  }

  value_col <- NULL
  if (!is.null(y)) {
    value_col <- resolve_vector(y)[1]
  } else if (ncol(data) >= 2) {
    numeric_cols <- names(data)[sapply(data, is.numeric)]
    numeric_cols <- setdiff(numeric_cols, label_col)
    if (length(numeric_cols) > 0) {
      value_col <- numeric_cols[1]
    }
  }

  if (is.null(value_col) || !value_col %in% names(data)) {
    stop("Could not determine value column for chart", call. = FALSE)
  }

  values <- as.numeric(data[[value_col]])
  labels <- as.character(data[[label_col]])

  list(
    data = list(
      labels = labels,
      datasets = list(list(
        data = values,
        backgroundColor = get_default_colors(length(values)),
        borderWidth = 0
      ))
    ),
    meta = list(
      type = type,
      x = label_col,
      y = value_col
    )
  )
}

#' Build scatter datasets
#' @noRd
build_scatter_chart <- function(data, x, y) {
  if (is.null(x) || !x %in% names(data)) {
    stop("Scatter charts require an 'x' column", call. = FALSE)
  }
  if (is.null(y)) {
    stop("Scatter charts require at least one 'y' column", call. = FALSE)
  }

  y_cols <- resolve_vector(y)
  validate_numeric_columns(data, c(x, y_cols))

  colors <- get_default_colors(length(y_cols))

  datasets <- lapply(seq_along(y_cols), function(i) {
    target <- y_cols[i]
    points <- lapply(seq_len(nrow(data)), function(row) {
      list(
        x = as.numeric(data[[x]][row]),
        y = as.numeric(data[[target]][row])
      )
    })

    list(
      label = target,
      data = points,
      backgroundColor = colors[i],
      borderColor = colors[i],
      showLine = FALSE
    )
  })

  list(
    data = list(
      labels = NULL,
      datasets = datasets
    ),
    meta = list(
      type = "scatter",
      x = x,
      y = y_cols
    )
  )
}

#' Build bubble datasets
#' @noRd
build_bubble_chart <- function(data, x, y) {
  if (is.null(x) || !x %in% names(data)) {
    stop("Bubble charts require an 'x' column", call. = FALSE)
  }
  mapping <- parse_bubble_mapping(data, y)

  validate_numeric_columns(data, c(x, mapping$value, mapping$radius))

  colors <- get_default_colors(max(1L, mapping$group_levels))

  if (!is.null(mapping$group)) {
    groups <- unique(as.character(data[[mapping$group]]))
    datasets <- Map(
      function(group_value, color) {
        subset <- data[data[[mapping$group]] == group_value, , drop = FALSE]
        list(
          label = group_value,
          data = build_bubble_points(subset, x, mapping$value, mapping$radius),
          backgroundColor = apply_alpha(color, 0.6),
          borderColor = color
        )
      },
      groups,
      colors[seq_along(groups)]
    )
  } else {
    datasets <- list(list(
      label = mapping$value,
      data = build_bubble_points(data, x, mapping$value, mapping$radius),
      backgroundColor = apply_alpha(colors[1], 0.6),
      borderColor = colors[1]
    ))
  }

  list(
    data = list(
      labels = NULL,
      datasets = datasets
    ),
    meta = list(
      type = "bubble",
      x = x,
      y = mapping$value,
      radius = mapping$radius,
      group = mapping$group
    )
  )
}

#' Parse bubble chart column mapping
#' @noRd
parse_bubble_mapping <- function(data, y) {
  if (is.null(y)) {
    stop("Bubble charts require value and radius columns via 'y'", call. = FALSE)
  }

  group <- NULL

  if (is.list(y)) {
    y_names <- names(y)
    if (!is.null(y_names) && all(y_names != "")) {
      value_col <- y[["value"]] %||% y[["y"]]
      radius_col <- y[["radius"]] %||% y[["r"]]
      group <- y[["group"]]
    } else {
      y <- unlist(y, use.names = FALSE)
      value_col <- y[1]
      radius_col <- y[2]
      group <- if (length(y) >= 3) y[3] else NULL
    }
  } else {
    y <- resolve_vector(y)
    value_col <- y[1]
    radius_col <- y[2]
    group <- if (length(y) >= 3) y[3] else NULL
  }

  if (is.null(value_col) || is.null(radius_col)) {
    stop("Bubble charts require both value and radius columns", call. = FALSE)
  }

  missing_cols <- setdiff(c(value_col, radius_col, group), names(data))
  if (length(missing_cols) > 0) {
    stop(
      sprintf(
        "Column(s) not found in data: %s",
        paste(missing_cols, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  group_levels <- if (is.null(group)) 1L else length(unique(as.character(data[[group]])))

  list(
    value = value_col,
    radius = radius_col,
    group = group,
    group_levels = group_levels
  )
}

#' Build bubble point data
#' @noRd
build_bubble_points <- function(data, x_col, y_col, r_col) {
  lapply(seq_len(nrow(data)), function(row) {
    list(
      x = as.numeric(data[[x_col]][row]),
      y = as.numeric(data[[y_col]][row]),
      r = as.numeric(data[[r_col]][row])
    )
  })
}

#' Resolve labels for cartesian charts
#' @noRd
resolve_labels <- function(data, x) {
  if (!is.null(x)) {
    if (!x %in% names(data)) {
      stop(sprintf("Column '%s' not found in data", x), call. = FALSE)
    }
    return(as.character(data[[x]]))
  }

  row_labels <- rownames(data)
  if (!is.null(row_labels)) {
    return(row_labels)
  }
  as.character(seq_len(nrow(data)))
}

#' Resolve value columns
#' @noRd
resolve_value_columns <- function(data, y, exclude = NULL) {
  if (!is.null(y)) {
    cols <- resolve_vector(y)
    missing_cols <- setdiff(cols, names(data))
    if (length(missing_cols) > 0) {
      stop(
        sprintf(
          "Column(s) not found in data: %s",
          paste(missing_cols, collapse = ", ")
        ),
        call. = FALSE
      )
    }
    return(cols)
  }

  numeric_cols <- names(data)[sapply(data, is.numeric)]
  numeric_cols <- setdiff(numeric_cols, exclude)
  if (length(numeric_cols) == 0) {
    stop("Could not find numeric columns to plot", call. = FALSE)
  }
  numeric_cols
}

#' Validate numeric columns
#' @noRd
validate_numeric_columns <- function(data, columns) {
  non_numeric <- columns[!sapply(columns, function(col) is.numeric(data[[col]]))]
  if (length(non_numeric) > 0) {
    stop(
      sprintf(
        "Column(s) must be numeric: %s",
        paste(non_numeric, collapse = ", ")
      ),
      call. = FALSE
    )
  }
}

#' Helper to resolve vectors from character or list inputs
#' @noRd
resolve_vector <- function(x) {
  if (is.null(x)) {
    return(character())
  }
  if (is.list(x)) {
    x <- unlist(x, use.names = FALSE)
  }
  if (!is.character(x)) {
    stop("Expected character vector for column selection", call. = FALSE)
  }
  x
}

#' Merge user options with default options
#' @noRd
merge_options <- function(defaults, user_options) {
  if (is.null(user_options) || length(user_options) == 0) {
    return(defaults)
  }
  utils::modifyList(defaults, user_options, keep.null = TRUE)
}

#' Get default Chart.js options for different chart types
#' @noRd
get_default_options <- function(type) {
  base_options <- list(
    responsive = TRUE,
    maintainAspectRatio = TRUE,
    plugins = list(
      legend = list(position = "top"),
      title = list(display = FALSE)
    )
  )

  if (type %in% c("bar", "line")) {
    base_options$scales <- list(
      y = list(
        beginAtZero = TRUE,
        ticks = list(precision = 0)
      )
    )
  }

  if (type == "line") {
    base_options$elements <- list(
      line = list(fill = FALSE, tension = 0.3),
      point = list(radius = 3, hoverRadius = 5)
    )
  }

  if (type == "scatter") {
    base_options$interaction <- list(mode = "nearest", intersect = TRUE)
    base_options$plugins$legend$position <- "right"
  }

  if (type %in% c("pie", "doughnut", "polarArea")) {
    base_options$plugins$legend$position <- "right"
    base_options$animation <- list(animateRotate = TRUE, animateScale = TRUE)
  }

  base_options
}

#' Get default colors for Chart.js
#' @noRd
get_default_colors <- function(n) {
  colors <- c(
    "#3366CC", "#DC3912", "#FF9900", "#109618",
    "#990099", "#0099C6", "#DD4477", "#66AA00",
    "#B82E2E", "#316395", "#994499", "#22AA99"
  )

  if (n <= length(colors)) {
    return(colors[seq_len(n)])
  }

  rep(colors, length.out = n)
}

#' Apply alpha to hex colors using grDevices
#' @noRd
apply_alpha <- function(color, alpha) {
  if (is.null(color)) {
    return(color)
  }
  grDevices::adjustcolor(color, alpha.f = alpha)
}

#' Remove NULL entries from a list recursively
#' @noRd
compact_list <- function(x) {
  x[!vapply(x, is.null, logical(1))]
}

#' Widget output function for use in Shiny
#' @param outputId output variable to read from
#' @param width Must be a valid CSS unit (like `"100%"`, `"400px"`, `"auto"`) or a
#'   number, which will be coerced to a string and have `"px"` appended.
#' @param height Same as width
#' @export
chartjsOutput <- function(outputId, width = "100%", height = "400px") {
  htmlwidgets::shinyWidgetOutput(outputId, "chartjs", width, height, package = "chartjs")
}

#' Widget render function for use in Shiny
#' @param expr An expression that generates a chartjs widget
#' @param env The environment in which to evaluate `expr`.
#' @param quoted Is `expr` a quoted expression (with `quote()`)?
#'   This is useful if you want to save an expression in a variable.
#' @export
renderChartjs <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  }
  htmlwidgets::shinyRenderWidget(expr, chartjsOutput, env, quoted = TRUE)
}
