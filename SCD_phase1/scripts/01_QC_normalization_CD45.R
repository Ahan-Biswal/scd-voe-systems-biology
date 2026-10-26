## ============================================================
## SCD Phase 1 - Step 1: QC, Filtering, Normalization (CD45+ cells)
## ============================================================
## Goal: turn raw counts into WGCNA-ready normalized data (VST)
## Input : GSE291257_geo_rawcounts_CD45_txt.gz, full_sample_map.csv
## Output: VST-normalized expression matrix + PCA plot
## ============================================================

# ---- 0. Setup -------------------------------------------------
# If these packages are not installed yet, run this ONCE:
# install.packages("BiocManager")
# BiocManager::install(c("DESeq2", "ggplot2"))

library(DESeq2)
library(ggplot2)

setwd("D:/SCA_analysis/SCD_phase1/data/raw")

# ---- 1. Load raw counts ----------------------------------------
# The count file is space-delimited, first column = gene ID (rownames)
raw_counts <- read.table(
  gzfile("GSE291257_geo_rawcounts_CD45.txt.gz"),
  header = TRUE, row.names = 1, check.names = FALSE
)

cat("Raw counts loaded:", nrow(raw_counts), "genes x", ncol(raw_counts), "samples\n")

# ---- 2. Load sample map and align to CD45 -----------------------
sample_map <- read.csv("full_sample_map_v2.csv", stringsAsFactors = FALSE)

# Keep only CD45 rows from the map
sample_map_cd45 <- sample_map[sample_map$cell_type == "CD45+ cells", ]

# The count matrix columns are named by "library_name" (e.g. "517567")
# Match order: reorder sample_map_cd45 to match column order in raw_counts
rownames(sample_map_cd45) <- sample_map_cd45$library_name
sample_map_cd45 <- sample_map_cd45[colnames(raw_counts), ]

# Sanity check: did every column find a match? (no NAs allowed)
stopifnot(all(!is.na(sample_map_cd45$GSM_ID)))
cat("All", ncol(raw_counts), "columns matched to metadata successfully\n")

# ---- 3. Filter to Steady State + VOE only ------------------------
# Phase 1 architecture uses only these two states (see proposal doc)
keep_samples <- sample_map_cd45$status %in% c("Steady State", "VOE")

counts_filtered <- raw_counts[, keep_samples]
meta_filtered   <- sample_map_cd45[keep_samples, ]

cat("After removing Follow-Up samples:", ncol(counts_filtered), "samples remain\n")
print(table(meta_filtered$status))

# ---- 4. Filter low-count genes ------------------------------------
# Keep genes with at least 10 counts in at least 20% of samples
# (standard, conservative filter - adjust later if needed)
min_samples <- ceiling(0.2 * ncol(counts_filtered))
keep_genes <- rowSums(counts_filtered >= 10) >= min_samples

counts_final <- counts_filtered[keep_genes, ]
cat("After low-count filtering:", nrow(counts_final), "genes remain (from", nrow(raw_counts), ")\n")

# ---- 5. Build DESeq2 object and normalize --------------------------
meta_filtered$status <- factor(meta_filtered$status, levels = c("Steady State", "VOE"))
meta_filtered$Sex <- factor(meta_filtered$Sex)

dds <- DESeqDataSetFromMatrix(
  countData = round(counts_final),   # DESeq2 requires integer counts
  colData   = meta_filtered,
  design    = ~ Sex + status         # Sex as covariate, status is what we care about
)

dds <- DESeq(dds)   # this runs size-factor estimation + dispersion estimation

# ---- 6. Variance Stabilizing Transformation (VST) --------------------
vst_data <- vst(dds, blind = TRUE)   # blind=TRUE: don't use status info during transform
vst_matrix <- assay(vst_data)

cat("VST matrix ready:", nrow(vst_matrix), "genes x", ncol(vst_matrix), "samples\n")

# ---- 7. PCA plot - sanity check -----------------------------------
pca_plot <- plotPCA(vst_data, intgroup = c("status"), returnData = TRUE)
percentVar <- round(100 * attr(pca_plot, "percentVar"))

p <- ggplot(pca_plot, aes(PC1, PC2, color = status)) +
  geom_point(size = 3) +
  xlab(paste0("PC1: ", percentVar[1], "% variance")) +
  ylab(paste0("PC2: ", percentVar[2], "% variance")) +
  ggtitle("PCA - CD45+ cells (Steady State vs VOE)") +
  theme_minimal()

print(p)
ggsave("../processed/PCA_CD45.png", p, width = 6, height = 5)

# ---- 8. Save outputs ------------------------------------------------
dir.create("../processed", showWarnings = FALSE)
write.csv(vst_matrix, "../processed/CD45_VST_normalized.csv")
write.csv(meta_filtered, "../processed/CD45_sample_metadata_filtered.csv", row.names = FALSE)

cat("\nDone. Saved:\n")
cat(" - CD45_VST_normalized.csv (input for WGCNA)\n")
cat(" - CD45_sample_metadata_filtered.csv\n")
cat(" - PCA_CD45.png\n")