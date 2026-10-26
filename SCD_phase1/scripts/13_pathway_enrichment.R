## ============================================================
## Script 13: Biologically Grounded Functional Pathway Enrichment
## ============================================================
## Purpose: Functional enrichment of rewired modules and top
## shifting genes using clusterProfiler, strictly using the
## expressed gene background universe to avoid whole-genome inflation.
## ============================================================

suppressPackageStartupMessages({
  library(clusterProfiler)
  library(org.Hs.eg.db)
  library(enrichplot)
  library(ggplot2)
})

options(stringsAsFactors = FALSE)

base_dir <- "D:/SCA_analysis/SCD_phase1/data/processed"
live_dir <- file.path(base_dir, "live")

# ============================================================
# Helper: Run GO Enrichment with Explicit Background Universe
# ============================================================
run_go_enrichment <- function(target_genes, universe_genes, analysis_label, out_csv, out_png) {
  clean_target   <- unique(sub("\\..*", "", target_genes))
  clean_universe <- unique(sub("\\..*", "", universe_genes))
  
  cat("Running GO BP for", analysis_label, "\n")
  cat("Target genes:", length(clean_target), "| Universe genes:", length(clean_universe), "\n")
  
  ego <- enrichGO(
    gene          = clean_target,
    universe      = clean_universe,
    OrgDb         = org.Hs.eg.db,
    keyType       = "ENSEMBL",
    ont           = "BP",
    pAdjustMethod = "BH",
    pvalueCutoff  = 0.05,
    qvalueCutoff  = 0.05,
    readable      = TRUE
  )
  
  ego_df <- as.data.frame(ego)
  cat("Enriched terms found (BH FDR < 0.05):", nrow(ego_df), "\n")
  
  if (nrow(ego_df) > 0) {
    write.csv(ego_df, out_csv, row.names = FALSE)
    cat("Saved:", out_csv, "\n")
    
    # Save dotplot — height scales with term count to avoid whitespace
    n_terms <- min(nrow(ego_df), 15)
    plot_h <- max(3.5, 1.5 + n_terms * 0.45)
    p <- dotplot(ego, showCategory = n_terms, font.size = 10) +
      ggtitle(paste0(analysis_label, ": Enriched Biological Processes")) +
      theme_minimal(base_size = 11)
    ggsave(out_png, p, width = 9, height = plot_h, dpi = 300)
    cat("Saved dotplot:", out_png, "\n")
  } else {
    cat("No terms passed FDR 0.05 with expressed universe. Writing empty file.\n")
    write.csv(ego_df, out_csv, row.names = FALSE)
  }
  
  return(ego_df)
}

# ============================================================
# 1. CD45+ Enrichment
# ============================================================
cat("\n--- CD45+ Pathway Enrichment ---\n")
kme_45 <- read.csv(file.path(live_dir, "CD45_aligned_delta_kME.csv"))
mp_stats_45 <- read.csv(file.path(live_dir, "CD45_module_preservation_stats.csv"), row.names = 1)

# Universe: all expressed genes tested
universe_45 <- kme_45$gene

# Target 1: Genes with strong connectivity shift (|delta_kME| > 0.4)
rewired_genes_45 <- kme_45$gene[kme_45$abs_delta_kME > 0.4]

ego_cd45_rewired <- run_go_enrichment(
  rewired_genes_45, universe_45, "CD45+ Rewired Genes (|delta_kME| > 0.4)",
  file.path(live_dir, "CD45_rewired_genes_GO_BP.csv"),
  file.path(live_dir, "CD45_rewired_genes_GO_dotplot.png")
)

# Target 2: Disrupted modules (Zsummary < 2)
disrupted_mods_45 <- rownames(mp_stats_45)[mp_stats_45$Zsummary.pres < 2 & !rownames(mp_stats_45) %in% c("gold", "grey")]
cat("CD45 disrupted modules (Z < 2):", paste(disrupted_mods_45, collapse = ", "), "\n")

if (length(disrupted_mods_45) > 0) {
  mod_genes_45 <- kme_45$gene[kme_45$module %in% disrupted_mods_45]
  run_go_enrichment(
    mod_genes_45, universe_45, "CD45+ Disrupted Modules (Z < 2)",
    file.path(live_dir, "CD45_disrupted_modules_GO_BP.csv"),
    file.path(live_dir, "CD45_disrupted_modules_GO_dotplot.png")
  )
}

# ============================================================
# 2. CD71+ Enrichment
# ============================================================
cat("\n--- CD71+ Pathway Enrichment ---\n")
kme_71 <- read.csv(file.path(live_dir, "CD71_aligned_delta_kME.csv"))
mp_stats_71 <- read.csv(file.path(live_dir, "CD71_module_preservation_stats.csv"), row.names = 1)

universe_71 <- kme_71$gene
rewired_genes_71 <- kme_71$gene[kme_71$abs_delta_kME > 0.4]

ego_cd71_rewired <- run_go_enrichment(
  rewired_genes_71, universe_71, "CD71+ Rewired Genes (|delta_kME| > 0.4)",
  file.path(live_dir, "CD71_rewired_genes_GO_BP.csv"),
  file.path(live_dir, "CD71_rewired_genes_GO_dotplot.png")
)

disrupted_mods_71 <- rownames(mp_stats_71)[mp_stats_71$Zsummary.pres < 2 & !rownames(mp_stats_71) %in% c("gold", "grey")]
cat("CD71 disrupted modules (Z < 2):", paste(disrupted_mods_71, collapse = ", "), "\n")

if (length(disrupted_mods_71) > 0) {
  mod_genes_71 <- kme_71$gene[kme_71$module %in% disrupted_mods_71]
  run_go_enrichment(
    mod_genes_71, universe_71, "CD71+ Disrupted Modules (Z < 2)",
    file.path(live_dir, "CD71_disrupted_modules_GO_BP.csv"),
    file.path(live_dir, "CD71_disrupted_modules_GO_dotplot.png")
  )
}

cat("\nScript 13 completed successfully.\n")
