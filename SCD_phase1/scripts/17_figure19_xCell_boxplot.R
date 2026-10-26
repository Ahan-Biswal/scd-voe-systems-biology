## ============================================================
## Script 17: Figure 19 — xCell Monocyte & Neutrophil Boxplots
## Steady State vs VOE in CD45+ Samples
## ============================================================
## Reads the xCell fractions matrix and sample metadata to produce
## side-by-side boxplots for Figure 19.
## ============================================================

suppressPackageStartupMessages({
  library(ggplot2)
})

live_dir <- "D:/SCA_analysis/SCD_phase1/data/processed/live"
raw_dir  <- "D:/SCA_analysis/SCD_phase1/data/raw"

# ---- Load xCell fractions (cell_type × samples, wide format) ----
xcell <- read.csv(file.path(live_dir, "CD45_xCell_fractions.csv"),
                  stringsAsFactors = FALSE, check.names = FALSE)

# First column is cell_type
rownames(xcell) <- xcell$cell_type
xcell$cell_type <- NULL

# ---- Load sample metadata ----
sample_map <- read.csv(file.path(raw_dir, "full_sample_map_v2.csv"),
                       stringsAsFactors = FALSE)

# Filter to CD45+ SS/VOE
meta <- sample_map[sample_map$cell_type == "CD45+ cells" &
                     sample_map$status %in% c("Steady State", "VOE"), ]

# Match xCell column names (X-prefixed library_name) to metadata
meta$xcell_col <- paste0("X", meta$library_name)

# Keep only columns present in xCell matrix
meta <- meta[meta$xcell_col %in% colnames(xcell), ]

cat("Matched samples:", nrow(meta), "\n")

# ---- Extract Monocyte and Neutrophil rows ----
extract_cell <- function(cell_label) {
  if (!cell_label %in% rownames(xcell)) {
    # Try partial match
    matches <- grep(cell_label, rownames(xcell), value = TRUE, ignore.case = TRUE)
    if (length(matches) > 0) cell_label <- matches[1]
    else stop(paste("Cell type not found:", cell_label))
  }
  vals <- as.numeric(xcell[cell_label, meta$xcell_col])
  data.frame(
    sample = meta$library_name,
    status = meta$status,
    cell_type = cell_label,
    abundance = vals,
    stringsAsFactors = FALSE
  )
}

mono <- extract_cell("Monocyte")
neut <- extract_cell("Neutrophil")

plot_df <- rbind(mono, neut)
plot_df$status <- factor(plot_df$status, levels = c("Steady State", "VOE"))

# Load test results for annotation
test_df <- read.csv(file.path(live_dir, "CD45_xCell_SS_vs_VOE_test.csv"),
                    stringsAsFactors = FALSE)

# Build annotation labels
get_padj <- function(ct) {
  row <- test_df[test_df$cell_type == ct, ]
  if (nrow(row) == 0) return("")
  padj <- row$p_adjust[1]
  if (padj < 0.001) return("***")
  if (padj < 0.01)  return("**")
  if (padj < 0.05)  return("*")
  return("ns")
}

mono_sig <- get_padj("Monocyte")
neut_sig <- get_padj("Neutrophil")

# ---- Plot ----
p <- ggplot(plot_df, aes(x = status, y = abundance, fill = status)) +
  geom_boxplot(outlier.shape = 21, outlier.size = 1.5, alpha = 0.7, width = 0.6) +
  geom_jitter(width = 0.15, alpha = 0.3, size = 0.8) +
  facet_wrap(~ cell_type, scales = "free_y", nrow = 1) +
  scale_fill_manual(values = c("Steady State" = "#3498db", "VOE" = "#e74c3c")) +
  labs(x = NULL,
       y = "xCell Abundance Score",
       title = "xCell-Estimated Immune Cell Abundance",
       subtitle = "CD45+ samples: Steady State vs VOE") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "grey40"),
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 12),
    panel.grid.major.x = element_blank()
  )

# Add significance annotations
# Calculate y-positions for annotations
anno_df <- data.frame(
  cell_type = c("Monocyte", "Neutrophil"),
  label = c(
    paste0("adj P = 0.00336 ", mono_sig),
    paste0("adj P = 0.00707 ", neut_sig)
  ),
  stringsAsFactors = FALSE
)

# Get max values per cell type for positioning
for (ct in c("Monocyte", "Neutrophil")) {
  sub <- plot_df[plot_df$cell_type == ct, ]
  ymax <- max(sub$abundance, na.rm = TRUE)
  anno_df$ypos[anno_df$cell_type == ct] <- ymax * 1.08
}

p <- p + geom_text(data = anno_df,
                   aes(x = 1.5, y = ypos, label = label),
                   inherit.aes = FALSE,
                   size = 3.5, fontface = "italic", color = "grey30")

ggsave(file.path(live_dir, "Figure19_xCell_boxplot.png"),
       p, width = 9, height = 5, dpi = 300)

cat("Saved: Figure19_xCell_boxplot.png\n")
