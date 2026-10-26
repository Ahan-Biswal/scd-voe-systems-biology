## ============================================================
## Script 14: Cross-Lineage Systems-Level Pathway Convergence
## ============================================================
## Purpose: Formally test for shared systems-level crisis response
## between immune (CD45+) and erythroid (CD71+) compartments at
## both pathway (GO BP) and gene (aligned delta-kME) levels.
## Replaces the flawed unadjusted 776-gene coin-flip overlap.
## ============================================================

suppressPackageStartupMessages({
  library(ggplot2)
})

options(stringsAsFactors = FALSE)

base_dir <- "D:/SCA_analysis/SCD_phase1/data/processed"
live_dir <- file.path(base_dir, "live")

cat("============================================================\n")
cat("Cross-Lineage Convergence Analysis (CD45+ vs CD71+)\n")
cat("============================================================\n")

# 1. Gene-Level Overlap of Top Rewired Genes (|delta_kME| > 0.4)
kme_45 <- read.csv(file.path(live_dir, "CD45_aligned_delta_kME.csv"))
kme_71 <- read.csv(file.path(live_dir, "CD71_aligned_delta_kME.csv"))

common_tested <- intersect(kme_45$gene, kme_71$gene)
cat("Genes tested across both cell types:", length(common_tested), "\n")

kme_45_sub <- kme_45[match(common_tested, kme_45$gene), ]
kme_71_sub <- kme_71[match(common_tested, kme_71$gene), ]

valid <- !is.na(kme_45_sub$abs_delta_kME) & !is.na(kme_71_sub$abs_delta_kME)
kme_45_sub <- kme_45_sub[valid, ]
kme_71_sub <- kme_71_sub[valid, ]

rewired_45 <- kme_45_sub$abs_delta_kME > 0.4
rewired_71 <- kme_71_sub$abs_delta_kME > 0.4

both_rewired <- sum(rewired_45 & rewired_71)
only_45      <- sum(rewired_45 & !rewired_71)
only_71      <- sum(!rewired_45 & rewired_71)
neither      <- sum(!rewired_45 & !rewired_71)

contingency <- matrix(c(both_rewired, only_45, only_71, neither), nrow = 2)
ft_gene <- fisher.test(contingency)

cat("\n--- Gene-Level Rewiring Overlap (|delta_kME| > 0.4) ---\n")
cat("Both rewired:       ", both_rewired, "\n")
cat("Only CD45 rewired:  ", only_45, "\n")
cat("Only CD71 rewired:  ", only_71, "\n")
cat("Neither rewired:    ", neither, "\n")
cat("Fisher's Exact Odds Ratio:", round(ft_gene$estimate, 3), "\n")
cat("Fisher's Exact p-value:   ", format.pval(ft_gene$p.value, digits = 4), "\n")

# 2. Pathway-Level Convergence (GO BP Enriched Terms)
# Check if enrichment files exist
go_file_45 <- file.path(live_dir, "CD45_rewired_genes_GO_BP.csv")
go_file_71 <- file.path(live_dir, "CD71_rewired_genes_GO_BP.csv")

if (file.exists(go_file_45) && file.exists(go_file_71)) {
  ego_45 <- read.csv(go_file_45)
  ego_71 <- read.csv(go_file_71)
  
  if (nrow(ego_45) > 0 && nrow(ego_71) > 0) {
    shared_terms <- intersect(ego_45$ID, ego_71$ID)
    cat("\n--- Pathway-Level Convergence (GO BP) ---\n")
    cat("CD45 enriched terms:", nrow(ego_45), "\n")
    cat("CD71 enriched terms:", nrow(ego_71), "\n")
    cat("Shared terms:       ", length(shared_terms), "\n")
    
    if (length(shared_terms) > 0) {
      shared_df <- data.frame(
        ID = shared_terms,
        Description = ego_45$Description[match(shared_terms, ego_45$ID)],
        p_adj_CD45  = ego_45$p.adjust[match(shared_terms, ego_45$ID)],
        p_adj_CD71  = ego_71$p.adjust[match(shared_terms, ego_71$ID)],
        stringsAsFactors = FALSE
      )
      shared_df <- shared_df[order(pmin(shared_df$p_adj_CD45, shared_df$p_adj_CD71)), ]
      write.csv(shared_df, file.path(live_dir, "cross_lineage_shared_pathways.csv"), row.names = FALSE)
      cat("Saved cross_lineage_shared_pathways.csv\n")
      print(head(shared_df, 10))
    }
  } else {
    cat("One or both lineages had 0 enriched terms at FDR 0.05.\n")
  }
}

# 3. Save Summary Report for Manuscript Integration
report_lines <- c(
  "============================================================",
  "Cross-Lineage Convergence Summary Report",
  "============================================================",
  paste0("Common Genes Tested: ", length(common_tested)),
  paste0("CD45+ Rewired Genes (|delta_kME| > 0.4): ", sum(rewired_45)),
  paste0("CD71+ Rewired Genes (|delta_kME| > 0.4): ", sum(rewired_71)),
  paste0("Shared Rewired Genes: ", both_rewired),
  paste0("Fisher's Exact Odds Ratio: ", round(ft_gene$estimate, 4)),
  paste0("Fisher's Exact p-value: ", format.pval(ft_gene$p.value, digits = 4)),
  "============================================================"
)
writeLines(report_lines, file.path(live_dir, "cross_lineage_summary_report.txt"))
cat("Saved cross_lineage_summary_report.txt\n")
