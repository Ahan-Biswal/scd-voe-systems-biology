## ============================================================
## Step 2: Outlier Sample Detection (CD71+ cells)
## ============================================================
## Goal: find and flag samples that don't belong (bad RNA, technical
## failure, etc.) before building the WGCNA network.
## Method: hierarchical clustering - outliers show up as samples on
## their own long branch, far from all others.
## ============================================================

# install.packages("WGCNA")   # run once if not installed
library(WGCNA)

setwd("D:/SCA_analysis/SCD_phase1/data/processed")

# ---- 1. Load VST-normalized matrix from Step 1 -------------------
vst_df <- read.csv("CD71_VST_normalized.csv", row.names = 1, check.names = FALSE)

# WGCNA expects samples as ROWS, genes as COLUMNS
expr_data <- as.data.frame(t(vst_df))

cat("Data for clustering:", nrow(expr_data), "samples x", ncol(expr_data), "genes\n")

# ---- 2. Hierarchical clustering of samples ------------------------
sample_tree <- hclust(dist(expr_data), method = "average")

# ---- 3. Plot the dendrogram ----------------------------------------
png("sample_clustering_CD71.png", width = 1400, height = 600)
plot(sample_tree,
     main = "Sample clustering to detect outliers (CD71+)",
     sub = "", xlab = "", cex.lab = 1.2, cex.axis = 1, cex.main = 1.5)
dev.off()

cat("Saved sample_clustering_CD71.png - inspect this for outlier branches\n")

# ---- 3b. Quantitative outlier check (don't just eyeball the plot) -----
# For each sample, find the height at which it FIRST joins the rest of
# the tree. A true outlier joins very late (high height) compared to
# everyone else.

heights_at_merge <- sapply(seq_along(sample_tree$order), function(i) {
  sample_label <- sample_tree$labels[sample_tree$order[i]]
  leaf_idx <- which(sample_tree$labels == sample_label)
  merge_row <- which(sample_tree$merge == -leaf_idx, arr.ind = TRUE)[1,1]
  sample_tree$height[merge_row]
})
names(heights_at_merge) <- sample_tree$labels[sample_tree$order]

sorted_heights <- sort(heights_at_merge, decreasing = TRUE)
cat("\nTop 10 samples by 'lateness' of joining the tree (most outlier-like first):\n")
print(head(sorted_heights, 10))
cat("\nFor reference, median join height across all samples:", median(heights_at_merge), "\n")

# Also print it to the RStudio plot pane so you can see it immediately
plot(sample_tree,
     main = "Sample clustering to detect outliers (CD71+)",
     sub = "", xlab = "")

## ============================================================
## STOP HERE AND LOOK AT THE OUTPUT ABOVE BEFORE CONTINUING
## ============================================================
## Do NOT reuse CD45's outlier IDs (517603 etc) - CD71 is a
## different set of samples with its own outlier(s), if any.
##
## Look at the "Top 10" list and the dendrogram:
##   - Is there a sample MUCH higher than the rest (big gap)?
##   - If yes, note its ID and come back to me with the numbers
##     before removing anything - same process as CD45.
## ============================================================
