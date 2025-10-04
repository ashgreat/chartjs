#' Diagnostic function for chartjs package
#'
#' This function helps diagnose issues with the chartjs package by checking
#' dependencies and creating a simple test chart.
#'
#' @export
#' @importFrom utils packageDescription
chartjs_debug <- function() {
  cat("=== chartjs Package Diagnostic ===\n\n")

  # Check package installation
  cat("1. Package installation check:\n")
  pkg_info <- packageDescription("chartjs")
  cat(paste("   Version:", pkg_info$Version, "\n"))
  cat(paste("   Built:", pkg_info$Built, "\n\n"))

  # Check htmlwidgets
  cat("2. htmlwidgets dependency:\n")
  if (requireNamespace("htmlwidgets", quietly = TRUE)) {
    cat("   htmlwidgets is available\n")
  } else {
    cat("   htmlwidgets is NOT available\n")
    return(invisible())
  }
  
  # Check file paths
  cat("\n3. File structure check:\n")
  yaml_path <- system.file("htmlwidgets/chartjs.yaml", package = "chartjs")
  js_path <- system.file("htmlwidgets/chartjs.js", package = "chartjs")
  chartjs_path <- system.file("htmlwidgets/lib/chartjs/chart.min.js", package = "chartjs")
  
  cat(paste("   YAML config:", ifelse(file.exists(yaml_path), "Found", "Missing"), "\n"))
  cat(paste("   JS binding:", ifelse(file.exists(js_path), "Found", "Missing"), "\n"))
  cat(paste("   Chart.js lib:", ifelse(file.exists(chartjs_path), "Found", "Missing"), "\n"))
  
  if (file.exists(chartjs_path)) {
    size <- file.size(chartjs_path)
    cat(paste("   Chart.js size:", round(size/1024), "KB\n"))
  }
  
  # Create test chart
  cat("\n4. Creating test chart:\n")
  test_data <- data.frame(
    x = c("A", "B", "C"),
    y = c(1, 2, 3)
  )
  
  tryCatch({
    test_chart <- chartjs_bar(test_data, x = "x", y = "y")
    cat("   Test chart created successfully\n")
    
    # Print chart structure
    cat("\n5. Chart structure:\n")
    cat(paste("   Type:", test_chart$x$type, "\n"))
    cat(paste("   Datasets:", length(test_chart$x$data$datasets), "\n"))
    cat(paste("   Labels:", length(test_chart$x$data$labels), "\n"))
    
    cat("\n6. Returning test chart for inspection...\n")
    return(test_chart)
    
  }, error = function(e) {
    cat(paste("   Error creating test chart:", e$message, "\n"))
    return(invisible())
  })
}
