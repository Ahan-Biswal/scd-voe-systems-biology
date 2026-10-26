"""
generate_figure17_two_panel.py
Renders a 2-panel publication-grade GO Biological Process dotplot for Figure 17:
- Panel A: 66 Strongly Rewired CD71+ Genes (|Delta-kME| > 0.4) -> Protein Folding (GO:0006457)
- Panel B: 102 Turquoise-to-Red Module-Switching Genes -> Ribonucleoprotein Biogenesis & rRNA Maturation
"""

import matplotlib.pyplot as plt
import numpy as np

def create_figure17(output_png):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6.2), dpi=300, gridspec_kw={'width_ratios': [1, 1.25]})

    # Palette
    cmap = plt.cm.coolwarm_r # low padj = warm/red, high padj = cool/blue

    # -------------------------------------------------------------
    # Panel A: 66 Strongly Rewired Genes (|Delta kME| > 0.4)
    # -------------------------------------------------------------
    terms_a = [
        "Protein folding\n(GO:0006457)"
    ]
    gene_ratios_a = [8 / 68] # 0.1176
    counts_a = [8]
    padj_a = [0.0387]
    genes_a = "Key drivers: HSPA8, HSPD1, HYOU1, PDRG1, NUDC, CCDC47, ZPR1, CCT8"

    scatter_a = ax1.scatter(gene_ratios_a, [0], s=[counts_a[0] * 35], c=padj_a,
                            cmap=cmap, vmin=0.015, vmax=0.040, edgecolors='black', linewidth=1.2, zorder=3)
    
    ax1.set_yticks([0])
    ax1.set_yticklabels(terms_a, fontsize=10.5, fontweight='bold', color='#2C3E50')
    ax1.set_xlim(0.05, 0.18)
    ax1.set_ylim(-0.8, 0.8)
    ax1.set_xlabel("Gene Ratio (Count / Query Size)", fontsize=10.5, fontweight='bold', color='#2C3E50')
    ax1.set_title("A) CD71+ Strongly Rewired Genes (n = 66, |$\Delta$kME| > 0.4)\nFold Enrichment = 6.48, BH padj = 0.0387",
                  fontsize=11.5, fontweight='bold', color='#1B365D', pad=12)
    ax1.grid(axis='x', linestyle='--', alpha=0.5, zorder=1)

    # Annotation box for driver genes
    ax1.text(0.06, -0.45, genes_a, fontsize=9, fontstyle='italic',
             bbox=dict(boxstyle='round,pad=0.5', facecolor='#F8F9FA', edgecolor='#BDC3C7', alpha=0.9), zorder=4)

    # -------------------------------------------------------------
    # Panel B: 102 Turquoise-to-Red Modular Transition Genes
    # -------------------------------------------------------------
    terms_b = [
        "Ribonucleoprotein complex biogenesis (GO:0022613)",
        "Maturation of SSU-rRNA from tricistronic rRNA (GO:0000462)",
        "Regulation of Th17 type immune response (GO:2000316)",
        "Endonucleolytic cleavage of tricistronic rRNA (GO:0000479)"
    ]
    gene_ratios_b = [12 / 98, 4 / 98, 4 / 98, 3 / 98]
    counts_b = [12, 4, 4, 3]
    padj_b = [0.0168, 0.0267, 0.0275, 0.0369]

    # Invert order for standard bottom-to-top plotting
    terms_b = terms_b[::-1]
    gene_ratios_b = gene_ratios_b[::-1]
    counts_b = counts_b[::-1]
    padj_b = padj_b[::-1]

    y_pos_b = np.arange(len(terms_b))
    scatter_b = ax2.scatter(gene_ratios_b, y_pos_b, s=[c * 30 for c in counts_b], c=padj_b,
                            cmap=cmap, vmin=0.015, vmax=0.040, edgecolors='black', linewidth=1.2, zorder=3)

    ax2.set_yticks(y_pos_b)
    ax2.set_yticklabels(terms_b, fontsize=9.5, fontweight='bold', color='#2C3E50')
    ax2.set_xlim(0.01, 0.16)
    ax2.set_ylim(-0.6, len(terms_b) - 0.4)
    ax2.set_xlabel("Gene Ratio (Count / Query Size)", fontsize=10.5, fontweight='bold', color='#2C3E50')
    ax2.set_title("B) CD71+ Turquoise-to-Red Switchers (n = 102)\nSignificant GO BP Processes (FDR < 0.05)",
                  fontsize=11.5, fontweight='bold', color='#1B365D', pad=12)
    ax2.grid(axis='x', linestyle='--', alpha=0.5, zorder=1)

    # Colorbar
    cbar = fig.colorbar(scatter_b, ax=[ax1, ax2], orientation='horizontal', fraction=0.04, pad=0.18, aspect=35)
    cbar.set_label("Benjamini-Hochberg Adjusted P-value (FDR)", fontsize=10, fontweight='bold', color='#2C3E50')
    cbar.ax.tick_params(labelsize=9)

    # Size legend
    for count in [3, 6, 12]:
        ax2.scatter([], [], s=count * 30, c='gray', edgecolors='black', label=f"{count} genes")
    ax2.legend(scatterpoints=1, frameon=True, fontsize=8.5, loc='lower right', title="Gene Count",
               title_fontsize=9, labelspacing=0.8)

    plt.subplots_adjust(bottom=0.25, wspace=0.6)
    plt.savefig(output_png, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Figure 17 successfully rendered to {output_png}")

if __name__ == "__main__":
    out_file = r"d:\SCA_analysis\SCD_phase1\data\processed\live\Figure17_GO_BP_dotplot.png"
    create_figure17(out_file)
