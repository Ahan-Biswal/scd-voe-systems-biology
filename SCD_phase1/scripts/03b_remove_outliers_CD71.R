## ============================================================
## Step 2b: Investigate and remove CD71 outliers
## Run this AFTER 03_outlier_detection_CD71.R in the same session
## (uses vst_df, total_counts if already computed - otherwise reloads)
## ============================================================

setwd("D:/SCA_analysis/SCD_phase1/data/processed")

meta <- read.csv("CD71_sample_metadata_filtered.csv", stringsAsFactors = FALSE)
total_counts <- colSums(vst_df)

outlier_ids <- c("516991", "381350")

cat("Metadata for flagged outliers:\n")
print(meta[meta$library_name %in% outlier_ids, ])

cat("\nTheir VST signal vs median:\n")
for (id in outlier_ids) {
  cat(id, ": ", total_counts[id], " (median = ", median(total_counts), ")\n", sep="")
}

# ---- Remove and save clean matrix ----
vst_clean <- vst_df[, !(colnames(vst_df) %in% outlier_ids)]
meta_clean <- meta[!(meta$library_name %in% outlier_ids), ]

cat("\nRemoved", length(outlier_ids), "samples -", ncol(vst_clean), "remain (from", ncol(vst_df), ")\n")

write.csv(vst_clean, "CD71_VST_normalized_clean.csv")
write.csv(meta_clean, "CD71_sample_metadata_clean.csv", row.names = FALSE)

cat("Saved CD71_VST_normalized_clean.csv and CD71_sample_metadata_clean.csv\n")
cat("These are the files to use for WGCNA network construction.\n")
