## ============================================================
## Stage 1 Network: CD71+ Steady State ONLY (n=137)
## power=3, deepSplit=4 (informed by full-dataset tuning)
## ============================================================
library(WGCNA)
options(stringsAsFactors = FALSE)
enableWGCNAThreads()

setwd("D:/SCA_analysis/SCD_phase1/data/processed")

load("CD71_SteadyState_WGCNA_input.RData")   # loads expr_data, sft

soft_power <- 15

cat("Using soft power:", soft_power, " | deepSplit: 4\n")
cat("Data:", nrow(expr_data), "samples x", ncol(expr_data), "genes\n")

net <- blockwiseModules(
  expr_data,
  power = soft_power,
  TOMType = "signed",
  minModuleSize = 30,
  deepSplit = 4,
  reassignThreshold = 0,
  mergeCutHeight = 0.25,
  numericLabels = TRUE,
  pamRespectsDendro = FALSE,
  saveTOMs = TRUE,
  saveTOMFileBase = "CD71_SteadyState_TOM",
  verbose = 3,
  maxBlockSize = 20000
)

cat("\nModule detection complete.\n")

moduleColors <- labels2colors(net$colors)
cat("\nModule sizes (CD71 Steady State):\n")
print(table(moduleColors))

png("gene_dendrogram_CD71_SteadyState.png", width = 1200, height = 600)
plotDendroAndColors(
  net$dendrograms[[1]],
  moduleColors[net$blockGenes[[1]]],
  "Module colors",
  dendroLabels = FALSE, hang = 0.03, addGuide = TRUE, guideHang = 0.05,
  main = "CD71+ Steady State - Gene dendrogram and modules"
)
dev.off()
cat("Saved gene_dendrogram_CD71_SteadyState.png\n")

MEs <- net$MEs
moduleLabels <- net$colors
save(net, moduleColors, moduleLabels, MEs, expr_data,
     file = "CD71_SteadyState_network.RData")

cat("\nSaved CD71_SteadyState_network.RData\n")
cat("Number of modules (excluding grey):",
    length(unique(moduleColors)) - ("grey" %in% moduleColors), "\n")
cat("Largest module size:", max(table(moduleColors)[names(table(moduleColors)) != "grey"]), "\n")
cat("Largest module as % of total genes:",
    round(100 * max(table(moduleColors)[names(table(moduleColors)) != "grey"]) / ncol(expr_data), 1), "%\n")
grey_n <- ifelse("grey" %in% names(table(moduleColors)), table(moduleColors)["grey"], 0)
cat("Grey (unassigned) genes:", grey_n, "-",
    round(100 * grey_n / ncol(expr_data), 1), "% of total\n")
