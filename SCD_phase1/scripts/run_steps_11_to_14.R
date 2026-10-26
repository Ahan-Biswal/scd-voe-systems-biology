## ============================================================
## Master Runner: Steps 11 to 14
## ============================================================
## Executes module preservation, aligned delta-kME, pathway
## enrichment, and cross-lineage convergence sequentially.
## ============================================================

scripts_dir <- "D:/SCA_analysis/SCD_phase1/scripts"

steps <- c(
  "11_module_preservation.R",
  "12_aligned_delta_kME.R",
  "13_pathway_enrichment.R",
  "14_cross_lineage_convergence.R"
)

for (script_name in steps) {
  script_path <- file.path(scripts_dir, script_name)
  cat("\n############################################################\n")
  cat(">>> STARTING:", script_name, "\n")
  cat("############################################################\n")
  
  start_time <- Sys.time()
  source(script_path)
  elapsed <- round(difftime(Sys.time(), start_time, units = "mins"), 2)
  
  cat(">>> COMPLETED:", script_name, "in", elapsed, "minutes.\n")
}

cat("\n############################################################\n")
cat(">>> ALL ANALYSIS STEPS 11-14 COMPLETED SUCCESSFULLY! <<<\n")
cat("############################################################\n")
