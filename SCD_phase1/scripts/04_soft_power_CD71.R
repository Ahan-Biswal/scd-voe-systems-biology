## ============================================================
## Step 3: Soft-Thresholding Power Selection (CD71+ cells)
## ============================================================
## Goal: find the right beta (soft power) for network construction
## Input : CD71_VST_normalized_clean.csv
## Output: scale-free fit plot + mean connectivity plot
## ============================================================

library(WGCNA)
options(stringsAsFactors = FALSE)
enableWGCNAThreads()   # use multiple CPU cores if available

setwd("D:/SCA_analysis/SCD_phase1/data/processed")

# ---- 1. Load cleaned VST data --------------------------------------
vst_df <- read.csv("CD71_VST_normalized_clean.csv", row.names = 1, check.names = FALSE)

# WGCNA wants samples as rows, genes as columns
expr_data <- as.data.frame(t(vst_df))

cat("Data:", nrow(expr_data), "samples x", ncol(expr_data), "genes\n")

# ---- 2. Check data quality (WGCNA's built-in check) ------------------
gsg <- goodSamplesGenes(expr_data, verbose = 3)
cat("\nAll genes/samples OK?", gsg$allOK, "\n")

if (!gsg$allOK) {
  # Remove any flagged bad genes/samples automatically
  expr_data <- expr_data[gsg$goodSamples, gsg$goodGenes]
  cat("After removing flagged genes/samples:", nrow(expr_data), "samples x", ncol(expr_data), "genes\n")
}

# ---- 3. Test a range of soft-thresholding powers ----------------------
powers <- c(1:20)
sft <- pickSoftThreshold(expr_data, powerVector = powers, verbose = 5)

# ---- 4. Plot results - scale-free fit + mean connectivity -------------
png("soft_power_selection_CD71.png", width = 1000, height = 500)
par(mfrow = c(1,2))

# Plot 1: Scale-free topology fit (want this to rise toward ~0.8-0.9)
plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     xlab = "Soft Threshold (power)",
     ylab = "Scale Free Topology Model Fit, signed R^2",
     type = "n", main = "Scale independence")
text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     labels = powers, col = "red")
abline(h = 0.80, col = "blue")   # common reference line

# Plot 2: Mean connectivity (want this to be reasonably low, not exploding)
plot(sft$fitIndices[,1], sft$fitIndices[,5],
     xlab = "Soft Threshold (power)",
     ylab = "Mean Connectivity",
     type = "n", main = "Mean connectivity")
text(sft$fitIndices[,1], sft$fitIndices[,5], labels = powers, col = "red")

dev.off()

cat("\nSaved soft_power_selection_CD71.png\n")
cat("\nFull fit index table:\n")
print(sft$fitIndices)

cat("\nSuggested power by WGCNA's own heuristic:", sft$powerEstimate, "\n")

# Save the cleaned expression data for the next step (network construction)
save(expr_data, sft, file = "CD71_WGCNA_input.RData")
cat("Saved CD71_WGCNA_input.RData for the next step\n")
