## ============================================================
## Script 12: Aligned Intra-Modular Connectivity (delta-kME)
## ============================================================
## Purpose: Measure change in module connectivity (kME) by
## projecting Steady-State reference modules into both states,
## eliminating unaligned eigengene comparison errors.
## ============================================================

suppressPackageStartupMessages({
  library(WGCNA)
  library(ggplot2)
})

options(stringsAsFactors = FALSE)
enableWGCNAThreads()

base_dir <- "D:/SCA_analysis/SCD_phase1/data/processed"
live_dir <- file.path(base_dir, "live")
arch_dir <- file.path(base_dir, "archive")

# ============================================================
# Helper: Aligned kME Calculation
# ============================================================
compute_aligned_kME <- function(expr_ss, expr_voe, ss_colors, cell_type, out_csv, out_plot) {
  common_genes <- intersect(colnames(expr_ss), colnames(expr_voe))
  expr_ss   <- expr_ss[, common_genes]
  expr_voe  <- expr_voe[, common_genes]
  ss_colors <- ss_colors[common_genes]
  
  # Project SS modules onto both datasets to get aligned MEs
  cat("Computing module eigengenes for", cell_type, "...\n")
  ss_me_obj  <- moduleEigengenes(expr_ss,  colors = ss_colors)
  voe_me_obj <- moduleEigengenes(expr_voe, colors = ss_colors)
  
  ss_MEs  <- ss_me_obj$eigengenes
  voe_MEs <- voe_me_obj$eigengenes
  
  # Calculate signed kME (signedKME automatically prefixes with 'kME')
  kME_ss_mat  <- signedKME(expr_ss,  ss_MEs)
  kME_voe_mat <- signedKME(expr_voe, voe_MEs)
  
  # Extract intramodular kME for each gene's assigned module
  gene_df <- data.frame(
    gene = common_genes,
    module = ss_colors,
    kME_SS = NA_real_,
    kME_VOE = NA_real_,
    stringsAsFactors = FALSE
  )
  
  for (i in seq_len(nrow(gene_df))) {
    mod <- gene_df$module[i]
    if (mod != "grey") {
      col_target <- paste0("kME", mod)
      if (col_target %in% colnames(kME_ss_mat)) {
        gene_df$kME_SS[i]  <- kME_ss_mat[gene_df$gene[i], col_target]
        gene_df$kME_VOE[i] <- kME_voe_mat[gene_df$gene[i], col_target]
      }
    }
  }
  
  # Drop grey genes for intramodular analysis
  gene_clean <- gene_df[gene_df$module != "grey", ]
  gene_clean$delta_kME <- gene_clean$kME_VOE - gene_clean$kME_SS
  gene_clean$abs_delta_kME <- abs(gene_clean$delta_kME)
  
  # Classify rewiring behavior
  gene_clean$Category <- ifelse(gene_clean$kME_SS >= 0.7 & gene_clean$kME_VOE < 0.4, "Decaying Hub (Loss of Coordination)",
                         ifelse(gene_clean$kME_SS < 0.4 & gene_clean$kME_VOE >= 0.7, "Crisis Emergent Hub (Gain of Coordination)",
                         ifelse(gene_clean$abs_delta_kME > 0.4, "Strongly Rewired (|delta_kME| > 0.4)", "Stable")))
  
  write.csv(gene_clean, out_csv, row.names = FALSE)
  cat("Saved:", out_csv, "\n")
  
  # Publication plot: kME SS vs kME VOE
  p <- ggplot(gene_clean, aes(x = kME_SS, y = kME_VOE, color = Category)) +
    geom_point(alpha = 0.5, size = 1.2) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black", linewidth = 0.7) +
    scale_color_manual(values = c(
      "Decaying Hub (Loss of Coordination)" = "firebrick",
      "Crisis Emergent Hub (Gain of Coordination)" = "royalblue",
      "Strongly Rewired (|delta_kME| > 0.4)" = "darkorange",
      "Stable" = "grey75"
    )) +
    labs(
      title = paste0(cell_type, ": Intramodular Connectivity Shift (Steady State vs Acute VOE)"),
      subtitle = "Evaluated against aligned reference module eigengenes",
      x = "Module Connectivity in Steady State (kME_SS)",
      y = "Module Connectivity in Acute VOE (kME_VOE)"
    ) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "bottom") +
    guides(color = guide_legend(nrow = 2, byrow = TRUE))
  
  ggsave(out_plot, p, width = 9, height = 7.5, dpi = 300)
  cat("Saved:", out_plot, "\n")
  
  return(gene_clean)
}

# ============================================================
# 1. CD45+ Processing
# ============================================================
cat("\n--- CD45+ Aligned kME Analysis ---\n")
load(file.path(live_dir, "CD45_SS_reference_network.RData"))
expr_ss_45 <- expr_data
colors_45  <- moduleColors
rm(cd45_net, moduleColors, moduleLabels, MEs, expr_data)

vst_voe_45 <- read.csv(file.path(arch_dir, "CD45_VST_VOE.csv"), row.names = 1, check.names = FALSE)
expr_voe_45 <- as.data.frame(t(vst_voe_45))

cd45_kme_results <- compute_aligned_kME(
  expr_ss_45, expr_voe_45, colors_45, "CD45+ Leukocytes",
  file.path(live_dir, "CD45_aligned_delta_kME.csv"),
  file.path(live_dir, "CD45_aligned_kME_scatter.png")
)

# ============================================================
# 2. CD71+ Processing
# ============================================================
cat("\n--- CD71+ Aligned kME Analysis ---\n")
load(file.path(live_dir, "CD71_SS_reference_network.RData"))
expr_ss_71 <- expr_data
colors_71  <- moduleColors
rm(cd71_net, moduleColors, moduleLabels, MEs, expr_data)

vst_voe_71 <- read.csv(file.path(arch_dir, "CD71_VST_VOE.csv"), row.names = 1, check.names = FALSE)
expr_voe_71 <- as.data.frame(t(vst_voe_71))

cd71_kme_results <- compute_aligned_kME(
  expr_ss_71, expr_voe_71, colors_71, "CD71+ Erythroid Precursors",
  file.path(live_dir, "CD71_aligned_delta_kME.csv"),
  file.path(live_dir, "CD71_aligned_kME_scatter.png")
)

cat("\nScript 12 completed successfully.\n")
