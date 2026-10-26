## ============================================================
## Script 18: Figure 20 — Paired Δexpression vs ΔxCell Score
## 19 Paired Patients, Top Rewired Genes
## ============================================================
## Reads the pre-computed correlation results and produces
## scatter panels for Figure 20.
## ============================================================

suppressPackageStartupMessages({
  library(ggplot2)
})

live_dir <- "D:/SCA_analysis/SCD_phase1/data/processed/live"

# ---- Load correlation results ----
cor_df <- read.csv(file.path(live_dir, "CD45_rewiring_vs_xCell_correlation.csv"),
                   stringsAsFactors = FALSE)

cat("Genes in paired analysis:", nrow(cor_df), "\n")
cat("Columns:", paste(colnames(cor_df), collapse = ", "), "\n")

# ---- Panel A: Monocyte correlations ----
# Sort by adjusted P for display
cor_df <- cor_df[order(cor_df$p_Mono_adj), ]

# Highlight top genes (those closest to significance)
cor_df$highlight <- ifelse(cor_df$p_Mono_adj < 0.1, cor_df$symbol, "")

# Create a combined long-format for faceted plot
mono_df <- data.frame(
  symbol     = cor_df$symbol,
  rho        = cor_df$cor_Mono,
  p_raw      = cor_df$p_Mono,
  p_adj      = cor_df$p_Mono_adj,
  cell       = "Monocyte",
  stringsAsFactors = FALSE
)

neut_df <- data.frame(
  symbol     = cor_df$symbol,
  rho        = cor_df$cor_Neut,
  p_raw      = cor_df$p_Neut,
  p_adj      = cor_df$p_Neut_adj,
  cell       = "Neutrophil",
  stringsAsFactors = FALSE
)

long_df <- rbind(mono_df, neut_df)
long_df$cell <- factor(long_df$cell, levels = c("Monocyte", "Neutrophil"))

# Significance indicator
long_df$sig_raw <- ifelse(long_df$p_raw < 0.05, "Nominal P < 0.05", "Not significant")
long_df$sig_raw <- factor(long_df$sig_raw,
                          levels = c("Nominal P < 0.05", "Not significant"))

# Label top 5 per cell type
long_df <- long_df[order(long_df$p_adj), ]
long_df$label <- ""
for (ct in c("Monocyte", "Neutrophil")) {
  idx <- which(long_df$cell == ct)
  top5 <- head(idx, 5)
  long_df$label[top5] <- long_df$symbol[top5]
}

# ---- Rank-based scatter: Spearman rho vs -log10(raw P) ----
long_df$neg_log_p <- -log10(long_df$p_raw)

p <- ggplot(long_df, aes(x = rho, y = neg_log_p, color = sig_raw)) +
  geom_point(size = 2.5, alpha = 0.7) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed",
             color = "grey50", linewidth = 0.4) +
  scale_color_manual(values = c("Nominal P < 0.05" = "#e74c3c",
                                "Not significant" = "#95a5a6"),
                     name = NULL) +
  facet_wrap(~ cell, nrow = 1) +
  labs(x = expression("Spearman " * rho * " (\u0394expression vs \u0394xCell score)"),
       y = expression(-log[10] * "(P-value)"),
       title = "Paired Sensitivity Analysis: Rewired-Gene Expression vs Cell Composition",
       subtitle = "19 paired patients | 49 genes tested | Dashed line = nominal P = 0.05") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "grey40", size = 10),
    strip.text = element_text(face = "bold", size = 12),
    legend.position = "bottom"
  )

# Add gene labels for top genes
if (requireNamespace("ggrepel", quietly = TRUE)) {
  library(ggrepel)
  p <- p + geom_text_repel(
    data = long_df[long_df$label != "", ],
    aes(label = label),
    size = 3, max.overlaps = 15,
    segment.color = "grey60",
    color = "black"
  )
} else {
  p <- p + geom_text(
    data = long_df[long_df$label != "", ],
    aes(label = label),
    size = 3, vjust = -0.8, hjust = 0.5, color = "black"
  )
}

# Add annotation: no genes significant after BH correction
p <- p + annotate("text", x = -0.3, y = 0.3,
                  label = "0/49 significant after BH correction",
                  size = 3.5, fontface = "italic", color = "#2c3e50")

ggsave(file.path(live_dir, "Figure20_paired_xcell_scatter.png"),
       p, width = 11, height = 5.5, dpi = 300)

cat("Saved: Figure20_paired_xcell_scatter.png\n")
