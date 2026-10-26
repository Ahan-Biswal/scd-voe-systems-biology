## ============================================================
## Script 16: Figure 18 — Venn Diagram of Shared Switchers
## CD45+ ∩ CD71+ Module-Switching Genes
## ============================================================
## Reads module-switch tables and shared-switchers CSV to produce
## a proportional Venn/Euler diagram for Figure 18.
## ============================================================

suppressPackageStartupMessages({
  library(ggplot2)
})

# Try VennDiagram first; fall back to manual ggplot if not installed
venn_available <- requireNamespace("VennDiagram", quietly = TRUE)

live_dir <- "D:/SCA_analysis/SCD_phase1/data/processed/live"

# ---- Load data ----
cd45_switch <- read.csv(file.path(live_dir, "CD45_gene_module_switch.csv"),
                        stringsAsFactors = FALSE)
cd71_switch <- read.csv(file.path(live_dir, "CD71_gene_module_switch.csv"),
                        stringsAsFactors = FALSE)
shared      <- read.csv(file.path(live_dir, "CD45_CD71_shared_switchers.csv"),
                        stringsAsFactors = FALSE)

# Count switched genes
n_cd45_switched <- sum(cd45_switch$Switched == TRUE, na.rm = TRUE)
n_cd71_switched <- sum(cd71_switch$status == "switched", na.rm = TRUE)
n_shared        <- nrow(shared)

cat("CD45+ switched:", n_cd45_switched, "\n")
cat("CD71+ switched:", n_cd71_switched, "\n")
cat("Shared switchers:", n_shared, "\n")

if (venn_available) {
  library(VennDiagram)

  venn.plot <- draw.pairwise.venn(
    area1     = n_cd45_switched,
    area2     = n_cd71_switched,
    cross.area = n_shared,
    category  = c("CD45+ Switchers", "CD71+ Switchers"),
    fill      = c("#3498db", "#e74c3c"),
    alpha     = 0.5,
    cat.cex   = 1.3,
    cat.fontface = "bold",
    cex       = 1.5,
    fontface  = "bold",
    cat.pos   = c(-30, 30),
    cat.dist  = c(0.05, 0.05),
    scaled    = TRUE
  )

  png(file.path(live_dir, "Figure18_venn_shared_switchers.png"),
      width = 8, height = 6, units = "in", res = 300)
  grid::grid.draw(venn.plot)
  dev.off()

  cat("Saved: Figure18_venn_shared_switchers.png (VennDiagram)\n")

} else {
  # Manual ggplot fallback — simple labeled bar representation
  cat("VennDiagram not installed. Generating bar-based overlap figure.\n")

  df <- data.frame(
    Category = c("CD45+ only", "Shared", "CD71+ only"),
    Count    = c(n_cd45_switched - n_shared, n_shared, n_cd71_switched - n_shared)
  )
  df$Category <- factor(df$Category, levels = c("CD45+ only", "Shared", "CD71+ only"))

  p <- ggplot(df, aes(x = Category, y = Count, fill = Category)) +
    geom_col(width = 0.6) +
    geom_text(aes(label = format(Count, big.mark = ",")),
              vjust = -0.5, size = 5, fontface = "bold") +
    scale_fill_manual(values = c("#3498db", "#8e44ad", "#e74c3c")) +
    labs(title = "Cross-Cell-Type Module-Switching Overlap",
         subtitle = paste0("CD45+ switchers: ", format(n_cd45_switched, big.mark = ","),
                           "  |  CD71+ switchers: ", format(n_cd71_switched, big.mark = ","),
                           "  |  Shared: ", n_shared),
         y = "Number of Genes", x = NULL) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 15),
      legend.position = "none",
      panel.grid.major.x = element_blank()
    ) +
    coord_cartesian(ylim = c(0, max(df$Count) * 1.15))

  ggsave(file.path(live_dir, "Figure18_venn_shared_switchers.png"),
         p, width = 8, height = 6, dpi = 300)
  cat("Saved: Figure18_venn_shared_switchers.png (bar fallback)\n")
  cat("Install VennDiagram for a proper Venn: install.packages('VennDiagram')\n")
}
