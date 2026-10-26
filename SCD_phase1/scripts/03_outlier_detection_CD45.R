## ============================================================
## Step 2: Outlier Sample Detection (CD45+ cells)
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
vst_df <- read.csv("CD45_VST_normalized.csv", row.names = 1, check.names = FALSE)

# WGCNA expects samples as ROWS, genes as COLUMNS (opposite of how we've
# had it so far) - so we transpose here
expr_data <- as.data.frame(t(vst_df))

cat("Data for clustering:", nrow(expr_data), "samples x", ncol(expr_data), "genes\n")

# ---- 2. Hierarchical clustering of samples ------------------------
sample_tree <- hclust(dist(expr_data), method = "average")

# ---- 3. Plot the dendrogram ----------------------------------------
png("sample_clustering_CD45.png", width = 1400, height = 600)
plot(sample_tree,
     main = "Sample clustering to detect outliers (CD45+)",
     sub = "", xlab = "", cex.lab = 1.2, cex.axis = 1, cex.main = 1.5)
dev.off()

cat("Saved sample_clustering_CD45.png - inspect this for outlier branches\n")

# ---- 3b. Quantitative outlier check (don't just eyeball the plot) -----
# For each sample, find the height at which it FIRST joins the rest of
# the tree. A true outlier joins very late (high height) compared to
# everyone else - this replaces guessing from labels in the image.

heights_at_merge <- sapply(seq_along(sample_tree$order), function(i) {
  sample_label <- sample_tree$labels[sample_tree$order[i]]
  # find the earliest merge step involving this leaf
  leaf_idx <- which(sample_tree$labels == sample_label)
  merge_row <- which(sample_tree$merge == -leaf_idx, arr.ind = TRUE)[1,1]
  sample_tree$height[merge_row]
})
names(heights_at_merge) <- sample_tree$labels[sample_tree$order]

# Sort descending - the samples joining LATEST (highest height) are the
# most outlier-like
sorted_heights <- sort(heights_at_merge, decreasing = TRUE)
cat("\nTop 10 samples by 'lateness' of joining the tree (most outlier-like first):\n")
print(head(sorted_heights, 10))
cat("\nFor reference, median join height across all samples:", median(heights_at_merge), "\n")

# Also print it to the RStudio plot pane so you can see it immediately
plot(sample_tree,
     main = "Sample clustering to detect outliers (CD45+)",
     sub = "", xlab = "")

# ---- 4. Investigate and remove flagged outlier(s) --------------------
# Based on dendrogram inspection: sample 517603 branches off alone at
# a much greater height than any other sample - classic outlier signature

outlier_id <- "517603"

# Check its metadata before removing (good practice - confirm it's not
# an important/rare sample we'd be sorry to lose, and see if metadata
# explains why it's odd)
meta <- read.csv("CD45_sample_metadata_filtered.csv", stringsAsFactors = FALSE)
cat("Metadata for flagged outlier:\n")
print(meta[meta$library_name == outlier_id, ])

# Check its total read depth vs the rest (low depth is a common cause)
total_counts <- colSums(vst_df)  # NOTE: VST isn't raw counts, this is just
# a rough proxy; real depth check would
# use raw_counts if you still have it loaded
cat("\nSample's summed VST signal vs median of all samples:\n")
cat("This sample: ", total_counts[outlier_id], "\n")
cat("Median:      ", median(total_counts), "\n")

# ---- 4b. Check the two borderline samples too (517441, 517177) --------
borderline_ids <- c("517441", "517177")
cat("\nMetadata for borderline samples:\n")
print(meta[meta$library_name %in% borderline_ids, ])

cat("\nTheir VST signal vs median:\n")
for (id in borderline_ids) {
  cat(id, ": ", total_counts[id], " (median = ", median(total_counts), ")\n", sep="")
}

# ---- 5. Remove the outlier and save a clean matrix --------------------
vst_clean <- vst_df[, colnames(vst_df) != outlier_id]
meta_clean <- meta[meta$library_name != outlier_id, ]

cat("\nRemoved", outlier_id, "-", ncol(vst_clean), "samples remain (from", ncol(vst_df), ")\n")

write.csv(vst_clean, "CD45_VST_normalized_clean.csv")
write.csv(meta_clean, "CD45_sample_metadata_clean.csv", row.names = FALSE)

cat("Saved CD45_VST_normalized_clean.csv and CD45_sample_metadata_clean.csv\n")
cat("These are the files to use for WGCNA network construction.\n")