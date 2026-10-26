## ============================================================
## Script 11: Permutation-Based Module Preservation Analysis
## ============================================================
## Purpose: Statistically evaluate whether Steady-State modules
## are preserved or rewired/disrupted in acute VOE.
## Reference: Steady State (CD45: N=154; CD71: N=137)
## Test:      Acute VOE   (CD45: N=42;  CD71: N=41)
## Method:    WGCNA::modulePreservation (nPermutations = 100, signed)
## Threshold: Zsummary < 2 = Disrupted/Rewired; Zsummary > 10 = Preserved
## ============================================================

suppressPackageStartupMessages({
  library(WGCNA)
  library(ggplot2)
})

options(stringsAsFactors = FALSE)
enableWGCNAThreads()

base_dir <- "D:/SCA_analysis/SCD_phase1/data/processed"
live_dir <- file.path(base_dir, "live")
arch_dir <- file.path(base_dir, "archive")

# ============================================================
# Helper: Plot and Save Preservation Summary Plot
# ============================================================
plot_preservation <- function(stats_df, cell_type, out_png) {
  # Drop gold and grey from the plot for clarity
  plot_data <- stats_df[!rownames(stats_df) %in% c("gold", "grey"), ]
  plot_data$Module <- rownames(plot_data)
  plot_data$Size   <- plot_data$moduleSize
  plot_data$Zsummary <- plot_data$Zsummary.pres
  
  # Categorize preservation
  plot_data$Preservation <- ifelse(plot_data$Zsummary > 10, "High (Z > 10)",
                            ifelse(plot_data$Zsummary >= 2, "Moderate (2 <= Z <= 10)",
                                   "Rewired / Disrupted (Z < 2)"))
  plot_data$Preservation <- factor(plot_data$Preservation, 
                                   levels = c("Rewired / Disrupted (Z < 2)", 
                                              "Moderate (2 <= Z <= 10)", 
                                              "High (Z > 10)"))
  
  p <- ggplot(plot_data, aes(x = Size, y = Zsummary, label = Module, color = Preservation)) +
    geom_point(size = 4, alpha = 0.85) +
    geom_text(vjust = -0.7, size = 3.5, fontface = "bold", show.legend = FALSE) +
    geom_hline(yintercept = 2, linetype = "dashed", color = "firebrick", linewidth = 0.8) +
    geom_hline(yintercept = 10, linetype = "dashed", color = "forestgreen", linewidth = 0.8) +
    scale_color_manual(values = c("Rewired / Disrupted (Z < 2)" = "firebrick",
                                  "Moderate (2 <= Z <= 10)" = "darkorange",
                                  "High (Z > 10)" = "forestgreen")) +
    labs(
      title = paste0(cell_type, ": WGCNA Module Preservation in Acute VOE"),
      subtitle = "Reference: Steady State | Test: Acute VOE (nPermutations = 100)",
      x = "Module Size (Gene Count)",
      y = "Preservation Z-summary Score"
    ) +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank())
  
  ggsave(out_png, p, width = 9, height = 6, dpi = 300)
}

# ============================================================
# 1. CD45+ Module Preservation
# ============================================================
cat("\n============================================================\n")
cat("1. Running Module Preservation for CD45+ Leukocytes\n")
cat("============================================================\n")

load(file.path(live_dir, "CD45_SS_reference_network.RData"))
expr_ss_cd45 <- expr_data
colors_cd45  <- moduleColors
rm(cd45_net, moduleColors, moduleLabels, MEs, expr_data)

vst_voe_cd45_file <- file.path(arch_dir, "CD45_VST_VOE.csv")
vst_voe_cd45 <- read.csv(vst_voe_cd45_file, row.names = 1, check.names = FALSE)
expr_voe_cd45 <- as.data.frame(t(vst_voe_cd45))
stopifnot(nrow(expr_voe_cd45) == 42)

common_cd45 <- intersect(colnames(expr_ss_cd45), colnames(expr_voe_cd45))
expr_ss_cd45  <- expr_ss_cd45[, common_cd45]
expr_voe_cd45 <- expr_voe_cd45[, common_cd45]
colors_cd45   <- colors_cd45[common_cd45]

multiData_cd45  <- list(SS = list(data = expr_ss_cd45), VOE = list(data = expr_voe_cd45))
multiColor_cd45 <- list(SS = colors_cd45)

perm_file_cd45 <- "d:/SCA_analysis/permutedStats-actualModules.RData"
use_saved_cd45 <- file.exists(perm_file_cd45)

cat("Starting permutation test (CD45+)... (100 permutations)\n")
mp_cd45 <- modulePreservation(
  multiData_cd45,
  multiColor_cd45,
  referenceNetworks = 1,
  nPermutations = 100,
  networkType = "signed",
  randomSeed = 42,
  loadPermutedStatistics = use_saved_cd45,
  permutedStatisticsFile = perm_file_cd45,
  verbose = 2
)

stats_cd45 <- mp_cd45$preservation$Z[[1]][[2]]
obs_cd45   <- mp_cd45$preservation$observed[[1]][[2]]
stats_cd45$medianRank <- obs_cd45$medianRank.pres

cat("\n--- CD45+ Module Preservation Summary ---\n")
print(stats_cd45[, c("moduleSize", "Zsummary.pres", "medianRank")])

write.csv(stats_cd45, file.path(live_dir, "CD45_module_preservation_stats.csv"))
plot_preservation(stats_cd45, "CD45+ Leukocytes", file.path(live_dir, "CD45_module_preservation_plot.png"))
cat("Saved CD45_module_preservation_stats.csv and plot.\n")

rm(mp_cd45, expr_ss_cd45, expr_voe_cd45, multiData_cd45, multiColor_cd45)
gc()

# ============================================================
# 2. CD71+ Module Preservation
# ============================================================
cat("\n============================================================\n")
cat("2. Running Module Preservation for CD71+ Erythroid Precursors\n")
cat("============================================================\n")

load(file.path(live_dir, "CD71_SS_reference_network.RData"))
expr_ss_cd71 <- expr_data
colors_cd71  <- moduleColors
rm(cd71_net, moduleColors, moduleLabels, MEs, expr_data)

vst_voe_cd71_file <- file.path(arch_dir, "CD71_VST_VOE.csv")
vst_voe_cd71 <- read.csv(vst_voe_cd71_file, row.names = 1, check.names = FALSE)
expr_voe_cd71 <- as.data.frame(t(vst_voe_cd71))
stopifnot(nrow(expr_voe_cd71) == 41)

common_cd71 <- intersect(colnames(expr_ss_cd71), colnames(expr_voe_cd71))
expr_ss_cd71  <- expr_ss_cd71[, common_cd71]
expr_voe_cd71 <- expr_voe_cd71[, common_cd71]
colors_cd71   <- colors_cd71[common_cd71]

multiData_cd71  <- list(SS = list(data = expr_ss_cd71), VOE = list(data = expr_voe_cd71))
multiColor_cd71 <- list(SS = colors_cd71)

cat("Starting permutation test (CD71+)... (100 permutations)\n")
mp_cd71 <- modulePreservation(
  multiData_cd71,
  multiColor_cd71,
  referenceNetworks = 1,
  nPermutations = 100,
  networkType = "signed",
  randomSeed = 42,
  permutedStatisticsFile = "d:/SCA_analysis/permutedStats-CD71.RData",
  verbose = 3
)

stats_cd71 <- mp_cd71$preservation$Z[[1]][[2]]
obs_cd71   <- mp_cd71$preservation$observed[[1]][[2]]
stats_cd71$medianRank <- obs_cd71$medianRank.pres

cat("\n--- CD71+ Module Preservation Summary ---\n")
print(stats_cd71[, c("moduleSize", "Zsummary.pres", "medianRank")])

write.csv(stats_cd71, file.path(live_dir, "CD71_module_preservation_stats.csv"))
plot_preservation(stats_cd71, "CD71+ Erythroid Precursors", file.path(live_dir, "CD71_module_preservation_plot.png"))
cat("Saved CD71_module_preservation_stats.csv and plot.\n")

cat("\nDone! Module preservation analysis complete for both cell populations.\n")
