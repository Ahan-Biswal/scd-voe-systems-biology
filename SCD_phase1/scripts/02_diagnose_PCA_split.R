## ============================================================
## Diagnostic: What is driving the PC1 split?
## Run this AFTER 01_QC_normalization_CD45.R has been run
## (uses dds / vst_data / meta_filtered already in memory)
## ============================================================
## NOTE: meta_filtered already contains Sex, libprep_batch, subject_id,
## status - no need to re-merge anything, script 1 already loaded it all
## from full_sample_map_v2.csv

colData(vst_data)$Sex <- factor(meta_filtered$Sex)
colData(vst_data)$libprep_batch <- factor(meta_filtered$libprep_batch)

# ---- PCA colored by Sex ----
p_sex <- plotPCA(vst_data, intgroup = "Sex") + ggtitle("PCA colored by Sex")
print(p_sex)
ggsave("../processed/PCA_CD45_by_Sex.png", p_sex, width = 6, height = 5)

# ---- PCA colored by libprep batch ----
p_batch <- plotPCA(vst_data, intgroup = "libprep_batch") + ggtitle("PCA colored by libprep batch")
print(p_batch)
ggsave("../processed/PCA_CD45_by_batch.png", p_batch, width = 7, height = 5)

cat("Saved PCA_CD45_by_Sex.png and PCA_CD45_by_batch.png\n")

# ---- Check if PC1 is driven by subject identity (repeated patient samples) ----
pca_data <- plotPCA(vst_data, intgroup = "status", returnData = TRUE)

cat("nrow(pca_data):", nrow(pca_data), "\n")
cat("nrow(meta_filtered):", nrow(meta_filtered), "\n")

# Align meta_filtered to pca_data's row order explicitly by rowname
meta_aligned <- meta_filtered[rownames(pca_data), ]
pca_data$subject_id <- meta_aligned$subject_id

# Count how many samples per subject
subj_counts <- table(meta_filtered$subject_id)
cat("\nSamples per subject - summary:\n")
print(summary(as.numeric(subj_counts)))
cat("Subjects with >1 sample:", sum(subj_counts > 1), "out of", length(subj_counts), "\n")

# Plot PC1 colored by subject (too many subjects for a clean legend, so just visualize spread)
p_subj <- ggplot(pca_data, aes(PC1, PC2, color = as.factor(subject_id))) +
  geom_point(size = 2) +
  theme_minimal() +
  theme(legend.position = "none") +
  ggtitle("PCA colored by subject_id (no legend - too many subjects)")

print(p_subj)
ggsave("../processed/PCA_CD45_by_subject.png", p_subj, width = 6, height = 5)
cat("Saved PCA_CD45_by_subject.png\n")