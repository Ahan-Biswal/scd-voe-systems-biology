## ============================================================
## Soft-Power Selection: CD71+ Steady State ONLY (n=137)
## ============================================================
library(WGCNA)
options(stringsAsFactors = FALSE)
enableWGCNAThreads()

setwd("D:/SCA_analysis/SCD_phase1/data/processed")

vst_df <- read.csv("CD71_VST_SteadyState.csv", row.names = 1, check.names = FALSE)
expr_data <- as.data.frame(t(vst_df))

cat("Data:", nrow(expr_data), "samples x", ncol(expr_data), "genes\n")

gsg <- goodSamplesGenes(expr_data, verbose = 3)
cat("\nAll genes/samples OK?", gsg$allOK, "\n")
if (!gsg$allOK) {
  expr_data <- expr_data[gsg$goodSamples, gsg$goodGenes]
  cat("After filtering:", nrow(expr_data), "samples x", ncol(expr_data), "genes\n")
}

powers <- c(1:20)
sft <- pickSoftThreshold(expr_data, powerVector = powers, verbose = 5)

png("soft_power_CD71_SteadyState.png", width = 1000, height = 500)
par(mfrow = c(1,2))
plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     xlab = "Soft Threshold (power)", ylab = "Scale Free Topology Model Fit, signed R^2",
     type = "n", main = "Scale independence - CD71 Steady State")
text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2], labels = powers, col = "red")
abline(h = 0.80, col = "blue")
plot(sft$fitIndices[,1], sft$fitIndices[,5],
     xlab = "Soft Threshold (power)", ylab = "Mean Connectivity",
     type = "n", main = "Mean connectivity")
text(sft$fitIndices[,1], sft$fitIndices[,5], labels = powers, col = "red")
dev.off()

cat("\nSaved soft_power_CD71_SteadyState.png\n")
print(sft$fitIndices)
cat("\nSuggested power:", sft$powerEstimate, "\n")

save(expr_data, sft, file = "CD71_SteadyState_WGCNA_input.RData")
cat("Saved CD71_SteadyState_WGCNA_input.RData\n")
