## ============================================================
## Script 10: Build Clean Steady-State Reference Networks
## ============================================================
## Purpose: Build definitive reference co-expression networks
## strictly on Steady-State samples (unmixed, signed topology).
## - CD45+ SS: N = 154, power = 6, deepSplit = 2
## - CD71+ SS: N = 137, power = 16, deepSplit = 2
## ============================================================

suppressPackageStartupMessages({
  library(WGCNA)
})

options(stringsAsFactors = FALSE)
enableWGCNAThreads()

base_dir <- "D:/SCA_analysis/SCD_phase1/data/processed"
out_dir  <- file.path(base_dir, "live")
dir.create(out_dir, showWarnings = FALSE)

# ============================================================
# 1. CD45+ Steady-State Reference Network
# ============================================================
cat("\n============================================================\n")
cat("1. Building CD45+ Steady-State Reference Network (N = 154)\n")
cat("============================================================\n")

vst_cd45_file <- file.path(base_dir, "archive/CD45_VST_SteadyState.csv")
vst_cd45 <- read.csv(vst_cd45_file, row.names = 1, check.names = FALSE)
expr_cd45 <- as.data.frame(t(vst_cd45))

cat("CD45 SS data dimensions:", nrow(expr_cd45), "samples x", ncol(expr_cd45), "genes\n")

# Verify sample count is strictly 154
stopifnot(nrow(expr_cd45) == 154)

cd45_net <- blockwiseModules(
  expr_cd45,
  power = 6,
  networkType = "signed",
  TOMType = "signed",
  minModuleSize = 30,
  deepSplit = 2,
  mergeCutHeight = 0.25,
  reassignThreshold = 0,
  numericLabels = TRUE,
  pamRespectsDendro = FALSE,
  saveTOMs = TRUE,
  saveTOMFileBase = file.path(out_dir, "CD45_SS_TOM_signed_p6"),
  maxBlockSize = 20000,
  verbose = 3
)

cd45_colors <- labels2colors(cd45_net$colors)
names(cd45_colors) <- colnames(expr_cd45)

cat("\nCD45 SS Module distribution:\n")
print(table(cd45_colors))

# Save reference network
expr_data <- expr_cd45
moduleColors <- cd45_colors
moduleLabels <- cd45_net$colors
MEs <- cd45_net$MEs
colnames(MEs) <- paste0("ME", labels2colors(as.numeric(sub("^ME", "", colnames(MEs)))))

save(cd45_net, moduleColors, moduleLabels, MEs, expr_data,
     file = file.path(out_dir, "CD45_SS_reference_network.RData"))
cat("Saved CD45_SS_reference_network.RData\n")

# Save dendrogram plot
png(file.path(out_dir, "CD45_SS_reference_dendrogram.png"), width = 1200, height = 600, res = 120)
plotDendroAndColors(
  cd45_net$dendrograms[[1]],
  cd45_colors[cd45_net$blockGenes[[1]]],
  "Module colors",
  dendroLabels = FALSE, hang = 0.03, addGuide = TRUE, guideHang = 0.05,
  main = "CD45+ Steady State Reference Network (Signed, Power = 6, deepSplit = 2)"
)
dev.off()

# Clean up memory before CD71
rm(cd45_net, expr_cd45, vst_cd45, cd45_colors, moduleColors, moduleLabels, MEs, expr_data)
gc()

# ============================================================
# 2. CD71+ Steady-State Reference Network
# ============================================================
cat("\n============================================================\n")
cat("2. Building CD71+ Steady-State Reference Network (N = 137)\n")
cat("============================================================\n")

vst_cd71_file <- file.path(base_dir, "archive/CD71_VST_SteadyState.csv")
vst_cd71 <- read.csv(vst_cd71_file, row.names = 1, check.names = FALSE)
expr_cd71 <- as.data.frame(t(vst_cd71))

cat("CD71 SS data dimensions:", nrow(expr_cd71), "samples x", ncol(expr_cd71), "genes\n")

# Verify sample count is strictly 137
stopifnot(nrow(expr_cd71) == 137)

cd71_net <- blockwiseModules(
  expr_cd71,
  power = 16,
  networkType = "signed",
  TOMType = "signed",
  minModuleSize = 30,
  deepSplit = 2,
  mergeCutHeight = 0.25,
  reassignThreshold = 0,
  numericLabels = TRUE,
  pamRespectsDendro = FALSE,
  saveTOMs = TRUE,
  saveTOMFileBase = file.path(out_dir, "CD71_SS_TOM_signed_p16"),
  maxBlockSize = 20000,
  verbose = 3
)

cd71_colors <- labels2colors(cd71_net$colors)
names(cd71_colors) <- colnames(expr_cd71)

cat("\nCD71 SS Module distribution:\n")
print(table(cd71_colors))

# Save reference network
expr_data <- expr_cd71
moduleColors <- cd71_colors
moduleLabels <- cd71_net$colors
MEs <- cd71_net$MEs
colnames(MEs) <- paste0("ME", labels2colors(as.numeric(sub("^ME", "", colnames(MEs)))))

save(cd71_net, moduleColors, moduleLabels, MEs, expr_data,
     file = file.path(out_dir, "CD71_SS_reference_network.RData"))
cat("Saved CD71_SS_reference_network.RData\n")

# Save dendrogram plot
png(file.path(out_dir, "CD71_SS_reference_dendrogram.png"), width = 1200, height = 600, res = 120)
plotDendroAndColors(
  cd71_net$dendrograms[[1]],
  cd71_colors[cd71_net$blockGenes[[1]]],
  "Module colors",
  dendroLabels = FALSE, hang = 0.03, addGuide = TRUE, guideHang = 0.05,
  main = "CD71+ Steady State Reference Network (Signed, Power = 16, deepSplit = 2)"
)
dev.off()

cat("\nDone! Reference networks for CD45+ and CD71+ successfully built.\n")
