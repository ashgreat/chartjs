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
#' @param y Character string or vector specifying column name(s) for y-axis values
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
#' }
chartjs <- function(data, type = "bar", x = NULL, y = NULL, options = list(), 
                    width = NULL, height = NULL, elementId = NULL) {
  
  # Validate inputs
  if (!is.data.frame(data)) {
    stop("data must be a data.frame")
  }
  
  if (!type %in% c("bar", "line", "scatter", "bubble", "pie", "doughnut", "radar", "polarArea")) {
    stop("type must be one of: bar, line, scatter, bubble, pie, doughnut, radar, polarArea")
  }
  
  # Convert data to Chart.js format
  chart_data <- convert_data_to_chartjs(data, type, x, y)
  
  # Create the widget data
  widget_data <- list(
    type = type,
    data = chart_data,
    options = merge_options(get_default_options(type), options)
  )
  
  # Create the htmlwidget
  htmlwidgets::createWidget(
    name = 'chartjs',
    widget_data,
    width = width,
    height = height,
    package = 'chartjs',
    elementId = elementId
  )
}

#' Convert R data to Chart.js format
#' @noRd
convert_data_to_chartjs <- function(data, type, x, y) {
  
  # Handle different chart types
  if (type %in% c("pie", "doughnut")) {
    # For pie/doughnut charts, use first column as labels, second as data
    if (is.null(x) && is.null(y)) {
      labels <- data[[1]]
      values <- data[[2]]
    } else {
      labels <- if (!is.null(x)) data[[x]] else data[[1]]
      values <- if (!is.null(y)) data[[y]] else data[[2]]
    }
    
    return(list(
      labels = labels,
      datasets = list(list(
        data = values,
        backgroundColor = get_default_colors(length(values)),
        borderWidth = 1
      ))
    ))
  }
  
  # For other chart types
  labels <- if (!is.null(x)) data[[x]] else rownames(data)
  if (is.null(labels)) labels <- seq_len(nrow(data))
  
  # Handle y variables
  if (is.null(y)) {
    # Use all numeric columns
    numeric_cols <- sapply(data, is.numeric)
    y_vars <- names(data)[numeric_cols]
  } else {
    y_vars <- y
  }
  
  # Create datasets
  datasets <- lapply(seq_along(y_vars), function(i) {
    col_name <- y_vars[i]
    values <- data[[col_name]]
    
    # Handle different chart types
    if (type == "scatter") {
      # For scatter plots, expect x and y columns
      if (length(y_vars) >= 2) {
        scatter_data <- lapply(seq_len(nrow(data)), function(j) {
          list(x = data[[y_vars[1]]][j], y = data[[y_vars[2]]][j])
        })
        return(list(
          label = paste(y_vars[1], "vs", y_vars[2]),
          data = scatter_data,
          backgroundColor = get_default_colors(1)[1],
          borderColor = get_default_colors(1)[1]
        ))
      }
    }
    
    list(
      label = col_name,
      data = values,
      backgroundColor = get_default_colors(length(y_vars))[i],
      borderColor = get_default_colors(length(y_vars))[i],
      borderWidth = if (type == "line") 2 else 1,
      fill = FALSE
    )
  })
  
  # For scatter plots, return only the first dataset
  if (type == "scatter" && length(datasets) > 0) {
    datasets <- list(datasets[[1]])
  }
  
  list(
    labels = labels,
    datasets = datasets
  )
}

#' Get default Chart.js options for different chart types
#' @noRd
get_default_options <- function(type) {
  
  base_options <- list(
    responsive = TRUE,
    maintainAspectRatio = TRUE,
    interaction = list(
      mode = 'index',
      intersect = FALSE
    ),
    plugins = list(
      legend = list(
        position = 'top'
      ),
      title = list(
        display = FALSE
      )
    )
  )
  
  # Type-specific options
  if (type %in% c("bar", "line")) {
    base_options$scales <- list(
      y = list(
        beginAtZero = TRUE
      )
    )
  }
  
  if (type == "line") {
    base_options$elements <- list(
      line = list(
        tension = 0.1
      )
    )
  }
  
  base_options
}

#' Merge user options with default options
#' @noRd
merge_options <- function(defaults, user_options) {
  if (length(user_options) == 0) {
    return(defaults)
  }
  
  # Deep merge of lists
  utils::modifyList(defaults, user_options, keep.null = TRUE)
}

#' Get default colors for Chart.js
#' @noRd
get_default_colors <- function(n) {
  colors <- c(
    "#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0", 
    "#9966FF", "#FF9F40", "#FF6384", "#C9CBCF"
  )
  
  if (n <= length(colors)) {
    return(colors[1:n])
  }
  
  # Generate more colors if needed
  rep(colors, ceiling(n / length(colors)))[1:n]
}

#' Widget output function for use in Shiny
#' @param outputId output variable to read from
#' @param width Must be a valid CSS unit (like \code{'100\%'}, 
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param height Same as width
#' @export
chartjsOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'chartjs', width, height, package = 'chartjs')
}

#' Widget render function for use in Shiny
#' @param expr An expression that generates a chartjs widget
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? 
#'   This is useful if you want to save an expression in a variable.
#' @export
renderChartjs <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, chartjsOutput, env, quoted = TRUE)
}