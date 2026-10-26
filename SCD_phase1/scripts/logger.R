# ---- Pipeline Logger ----
# Source this at the top of every script:  source("logger.R")
# Then call log_entry() at key points.

LOG_FILE <- "D:/SCA_analysis/SCD_phase1/pipeline_log.txt"

log_entry <- function(script, action, result, genes_moved = NULL) {
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  lines <- c(
    paste0("[", ts, "] SCRIPT: ", script),
    paste0("  ACTION: ", action),
    paste0("  RESULT: ", result)
  )
  if (!is.null(genes_moved)) {
    lines <- c(lines, paste0("  GENES MOVED: ", paste(genes_moved, collapse = ", ")))
  }
  lines <- c(lines, "")  # blank line separator
  cat(paste(lines, collapse = "\n"), file = LOG_FILE, append = TRUE, sep = "\n")
}

# Example usage:
# log_entry(
#   script = "stage2_module_switch.R",
#   action = "Matched SS modules to VOE modules via Fisher's exact test",
#   result = "17,000 common genes; 3 modules unmatched (orange, royalblue, darkgreen)"
# )
