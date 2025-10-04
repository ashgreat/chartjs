#' chartjs: Interactive Charts for R Using Chart.js
#'
#' Build responsive Chart.js visualisations directly from R. Supports all
#' Chart.js chart types including bar, line, scatter, bubble, pie, doughnut,
#' radar, and polar area charts with full animation and plugin support.
#' Integrates seamlessly with Shiny applications.
#'
#' @section Main functions:
#' \itemize{
#'   \item \code{\link{chartjs}}: Main function to create Chart.js visualizations
#'   \item \code{\link{chartjs_bar}}: Create bar charts
#'   \item \code{\link{chartjs_line}}: Create line charts
#'   \item \code{\link{chartjs_scatter}}: Create scatter plots
#'   \item \code{\link{chartjs_bubble}}: Create bubble charts
#'   \item \code{\link{chartjs_pie}}: Create pie charts
#'   \item \code{\link{chartjs_doughnut}}: Create doughnut charts
#'   \item \code{\link{chartjs_radar}}: Create radar charts
#'   \item \code{\link{chartjs_polar}}: Create polar area charts
#' }
#'
#' @section Shiny integration:
#' \itemize{
#'   \item \code{\link{chartjsOutput}}: Output function for Shiny UI
#'   \item \code{\link{renderChartjs}}: Render function for Shiny server
#'   \item \code{\link{chartjs_proxy}}: Create proxy object for updates
#' }
#'
#' @name chartjs-package
#' @keywords internal
#' @import htmlwidgets
#' @importFrom utils modifyList
"_PACKAGE"
