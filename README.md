# Lineage-Autonomous Transcriptomic Network Reorganization in Sickle Cell Vaso-Occlusive Episodes

[![R: >=4.2](https://img.shields.io/badge/R-%3E%3D4.2-blue.svg)](https://www.r-project.org/)
[![Python: >=3.9](https://img.shields.io/badge/Python-%3E%3D3.9-green.svg)](https://www.python.org/)
[![GEO: GSE291257](https://img.shields.io/badge/GEO-GSE291257-orange.svg)](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE291257)

This repository contains the complete analytical pipeline, reproducible code, processed datasets, and visualization scripts for the multi-compartment systems biology investigation of acute vaso-occlusive episodes (VOE) in Sickle Cell Disease (SCD), based on prospective transcriptomic profiling of circulating CD45+ leukocytes and CD71+ erythroid precursors from the **GSE291257** cohort (174 unique patients).

---

## 🔬 Scientific Summary & Key Findings

1. **Global Transcriptome Topology & Scale-Free Architecture:**
   - Evaluated 196 CD45+ leukocyte samples (154 Steady State, 42 VOE; 17,213 expressed genes) and 176 CD71+ erythroid precursor samples (137 Steady State, 41 VOE; 10,352 expressed genes; 2 outliers pruned at $Z > 3\sigma$).
   - Acute VOE does not induce an indiscriminate whole-transcriptome shift; steady-state and crisis samples exhibit substantial overlap along major principal components (CD45+ PC1 = 67%, PC2 = 11% biological sex).
   - Signed co-expression networks satisfy scale-free topology at soft-thresholding powers $\beta = 6$ ($R^2 = 0.88$) in CD45+ and $\beta = 16$ ($R^2 = 0.81$) in CD71+.

2. **High Modular Preservation Under Acute Crisis:**
   - Permutation testing (100 iterations) demonstrated high structural preservation across steady state and VOE for all primary modules ($Z_{\text{summary}} > 20$; CD45+ turquoise = 44.4, blue = 35.1, brown = 34.2, yellow = 23.6; CD71+ turquoise = 29.6, blue = 29.2).
   - Crisis-induced pathology is mediated by subtle intramodular hub rewiring rather than modular dissolution.

3. **Lineage Autonomy of Crisis Responses:**
   - Cross-compartment intersection of 239 rewired genes in CD45+ and 66 rewired genes in CD71+ ($|\Delta kME| > 0.40$) revealed **exactly one shared gene** (*RABGAP1L*; Fisher's exact test $p = 1.0$), demonstrating near-absolute lineage autonomy between circulating immune effectors and erythroid precursors.

4. **Lineage-Specific Adaptive Programs:**
   - **CD45+ Leukocytes:** Coordinated mitotic silencing (hub decay of *KIF11, TOP2A, CCNA2, CDK1, CDC20*) alongside emergence of inflammatory hubs (*IL1B, SOD2, CXCL8*).
   - **CD71+ Erythroid Precursors:** Targeted activation of molecular chaperone proteostasis (**Protein folding**, GO:0006457, fold enrichment = 6.48, FDR $p_{\text{adj}} = 0.0387$; *HSPA8, HSPD1, HYOU1, CCT8*) and ribosomal RNA processing (**Ribonucleoprotein complex biogenesis**, GO:0022613, fold = 4.66, FDR $p_{\text{adj}} = 0.0168$).

5. **Cell-Type Shift Deconvolution & Sensitivity Limits:**
   - xCell deconvolution revealed crisis-associated monocyte mobilization ($p_{\text{adj}} = 0.00336$) and neutrophil elevation ($p_{\text{adj}} = 0.00707$).
   - Paired intra-patient sensitivity analysis across 19 patients demonstrated that single-subject paired sampling lacks statistical power to detect crisis-specific modular shifts (0/49 genes survived FDR $< 0.05$).

---

## 📁 Repository Structure

```
.
├── README.md                                   # Comprehensive Project Guide & Reproduction Manual
├── requirements.txt                            # Python dependencies (python-docx, matplotlib, pandas)
├── environment.yml                             # Conda environment definition (R + Bioconductor + Python)
├── SCD_Pipeline_Parameters_and_Methods_Summary.docx # Formal technical specification & parameter audit
├── permutedStats-actualModules.RData          # CD45+ 100-permutation module preservation statistics
├── permutedStats-CD71.RData                   # CD71+ 100-permutation module preservation statistics
│
├── SCD_phase1/
│   ├── pipeline_log.txt                        # Execution audit trail
│   ├── scripts/                                # Sequential reproducible pipeline scripts
│   │   ├── 01_QC_normalization_CD45.R         # DESeq2 VST normalization for CD45+ leukocytes
│   │   ├── 01_QC_normalization_CD71.R         # DESeq2 VST normalization for CD71+ erythroid precursors
│   │   ├── 02_diagnose_PCA_split.R             # PCA variance decomposition & sex covariate evaluation
│   │   ├── 03_outlier_detection_CD45.R         # Hierarchical distance clustering for CD45+
│   │   ├── 03_outlier_detection_CD71.R         # Distance clustering identifying 2 outliers (516991, 381350)
│   │   ├── 03b_remove_outliers_CD71.R          # Prunes 2 outliers exceeding 3 standard deviations
│   │   ├── 04_soft_power_CD45.R                # Scale-free topology fit for combined CD45+
│   │   ├── 04_soft_power_CD71.R                # Scale-free topology fit for combined CD71+
│   │   ├── 06_split_by_status_CD45.R           # Stratifies CD45+ into Steady State vs VOE subsets
│   │   ├── 06_split_by_status_CD71.R           # Stratifies CD71+ into Steady State vs VOE subsets
│   │   ├── 07_soft_power_CD45_SteadyState.R    # Power evaluation for CD45+ Steady State
│   │   ├── 07_soft_power_CD45_VOE.R            # Power evaluation for CD45+ VOE
│   │   ├── 07_soft_power_CD71_SteadyState.R    # Power evaluation for CD71+ Steady State
│   │   ├── 07_soft_power_CD71_VOE.R            # Power evaluation for CD71+ VOE
│   │   ├── 08_build_network_CD45_SteadyState.R # CD45+ steady-state network construction
│   │   ├── 08_build_network_CD45_VOE.R         # CD45+ VOE network construction
│   │   ├── 08_build_network_CD71_SteadyState.R # CD71+ steady-state network construction
│   │   ├── 08_build_network_CD71_VOE.R         # CD71+ VOE network construction
│   │   ├── 10_build_clean_reference_networks.R # Definitive reference co-expression networks
│   │   ├── 11_module_preservation.R            # 100-permutation preservation analysis (Zsummary)
│   │   ├── 12_aligned_delta_kME.R              # Module alignment and delta-kME rewiring quantification
│   │   ├── 13_pathway_enrichment.R             # clusterProfiler GO BP & KEGG functional enrichment
│   │   ├── 14_cross_lineage_convergence.R      # Cross-compartment Fisher's exact test of rewired genes
│   │   ├── 16_figure18_venn.R                  # R script for Venn diagram of shared switchers
│   │   ├── 17_figure19_xCell_boxplot.R         # xCell cell-type proportion shifts and Wilcoxon tests
│   │   ├── 18_figure20_paired_scatter.R        # Paired intra-patient sensitivity analysis (n=19)
│   │   ├── 19_generate_figure1_workflow.py     # High-resolution workflow flowchart (Figure 1)
│   │   ├── generate_figure17_two_panel.py      # Publication two-panel GO enrichment dotplot (Figure 6)
│   │   ├── logger.R                            # Standardized pipeline logging utility
│   │   └── run_steps_11_to_14.R                # Master runner for sequential analysis execution
│   │
│   └── data/
│       ├── raw/                                # Raw counts and clinical annotation tables
│       │   ├── GSE291257_family.soft.gz        # Soft family metadata from NCBI GEO
│       │   ├── GSE291257_series_matrix.txt.gz  # Series matrix characteristics
│       │   ├── GSE291257_geo_rawcounts_CD45.txt.gz # Raw transcript counts: CD45+ leukocytes
│       │   ├── GSE291257_geo_rawcounts_CD71.txt.gz # Raw transcript counts: CD71+ erythroid precursors
│       │   ├── full_sample_map.csv             # Initial clinical mapping
│       │   └── full_sample_map_v2.csv          # Curated multi-visit clinical mapping
│       │
│       └── processed/live/                     # Verified analytical outputs and publication figures
│           ├── CD45_aligned_delta_kME.csv      # CD45+ intramodular connectivity changes
│           ├── CD45_delta_kME_table.csv        # Comprehensive CD45+ rewiring metrics
│           ├── CD45_gene_module_switch.csv     # Dynamic module transition assignments (CD45+)
│           ├── CD45_module_preservation_stats.csv # Permutation preservation statistics (CD45+)
│           ├── CD71_aligned_delta_kME.csv      # CD71+ intramodular connectivity changes
│           ├── CD71_delta_kME_table.csv        # Comprehensive CD71+ rewiring metrics
│           ├── CD71_gene_module_switch.csv     # Dynamic module transition assignments (CD71+)
│           ├── CD71_module_preservation_stats.csv # Permutation preservation statistics (CD71+)
│           ├── CD71_rewired_genes_GO_BP.csv    # Functional enrichment: CD71+ rewired genes
│           ├── CD71_turquoise_red_GO_BP_enrichment.csv # Functional enrichment: CD71+ switching genes
│           ├── CD45_xCell_SS_vs_VOE_test.csv   # Cell proportion statistical testing
│           ├── CD45_xCell_fractions.csv        # Estimated cellular fractions from xCell
│           ├── Figure1_workflow_diagram.png    # Figure 1: Systems biology workflow flowchart
│           ├── Figure17_GO_BP_dotplot.png      # Figure 6: Two-panel CD71+ GO BP dotplot
│           ├── Figure18_venn_shared_switchers.png # Figure 7: Cross-lineage comparison Venn diagram
│           ├── Figure19_xCell_boxplot.png      # Figure 8A: xCell monocyte/neutrophil mobilization
│           ├── Figure20_paired_xcell_scatter.png # Figure 8B: Paired intra-patient sensitivity
│           └── [PCA and dendrogram figures...]
│
└── papers/                                     # Publication manuscript & automated authoring pipeline
    ├── SCD_Manuscript_PLOS_Format.docx         # Publication-ready manuscript (PLOS ONE format)
    ├── build_plos_manuscript.py                # Automated script compiling the full manuscript
    └── Revised_SCD_FIRST-DRAFT.docx            # Pre-revision baseline draft
```

---

## 🚀 Reproduction Guide

### 1. Environment Installation

#### Option A: Using Conda (Recommended)
```bash
git clone https://github.com/<username>/<repo_name>.git
cd <repo_name>

conda env create -f environment.yml
conda activate scd_systems_biology
```

#### Option B: Manual Setup via R and Pip
In Python (>= 3.9):
```bash
pip install -r requirements.txt
```

In R (>= 4.2):
```r
install.packages(c("BiocManager", "ggplot2", "pheatmap", "gridExtra", "RColorBrewer"))
BiocManager::install(c("WGCNA", "DESeq2", "clusterProfiler", "org.Hs.eg.db"))
# Install xCell from GitHub if needed:
# devtools::install_github("dviraran/xCell")
```

---

### 2. Running the Analytical Pipeline

All scripts in `SCD_phase1/scripts/` are numbered sequentially and designed to run from the root repository directory:

```bash
# Step 1: Quality Control and DESeq2 Variance-Stabilizing Transformation
Rscript SCD_phase1/scripts/01_QC_normalization_CD45.R
Rscript SCD_phase1/scripts/01_QC_normalization_CD71.R
Rscript SCD_phase1/scripts/02_diagnose_PCA_split.R

# Step 2: Sample Outlier Detection and Pruning (Prunes 2 CD71+ samples at Z > 3)
Rscript SCD_phase1/scripts/03_outlier_detection_CD45.R
Rscript SCD_phase1/scripts/03_outlier_detection_CD71.R
Rscript SCD_phase1/scripts/03b_remove_outliers_CD71.R

# Step 3: Soft-Threshold Power Selection
Rscript SCD_phase1/scripts/04_soft_power_CD45.R
Rscript SCD_phase1/scripts/04_soft_power_CD71.R

# Step 4: Stratification and Network Construction
Rscript SCD_phase1/scripts/06_split_by_status_CD45.R
Rscript SCD_phase1/scripts/06_split_by_status_CD71.R
Rscript SCD_phase1/scripts/07_soft_power_CD45_SteadyState.R
Rscript SCD_phase1/scripts/07_soft_power_CD45_VOE.R
Rscript SCD_phase1/scripts/07_soft_power_CD71_SteadyState.R
Rscript SCD_phase1/scripts/07_soft_power_CD71_VOE.R
Rscript SCD_phase1/scripts/10_build_clean_reference_networks.R

# Step 5: Module Preservation, Rewiring, Enrichment, and Cross-Lineage Testing
Rscript SCD_phase1/scripts/run_steps_11_to_14.R
```

---

### 3. Rendering Figures and Compiling the Manuscript

Generate high-resolution composite figures:
```bash
# Workflow diagram (Figure 1)
python SCD_phase1/scripts/19_generate_figure1_workflow.py

# Functional enrichment two-panel dotplot (Figure 6)
python SCD_phase1/scripts/generate_figure17_two_panel.py

# Deconvolution and sensitivity plots (Figure 8)
Rscript SCD_phase1/scripts/17_figure19_xCell_boxplot.R
Rscript SCD_phase1/scripts/18_figure20_paired_scatter.R
```

Compile the complete PLOS ONE manuscript with embedded figures, formal tables, and verified citations:
```bash
python papers/build_plos_manuscript.py
```
The compiled document will be output to `papers/SCD_Manuscript_PLOS_Format.docx`.

---

## 📊 Dataset Attribution

Primary transcriptomic raw counts and clinical metadata are derived from:
- **NCBI Gene Expression Omnibus (GEO):** Accession **[GSE291257](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE291257)**
- **Cohorts:** CD45+ circulating leukocytes and CD71+ immature erythroid precursors collected prospectively from 174 unique individuals with Sickle Cell Anemia across steady-state clinical visits and acute vaso-occlusive episodes.

---

## 📜 Citation

If you use this pipeline, code, or derived co-expression modules in your research, please cite:

> Purohit et al. *Multi-Compartment Transcriptomic Profiling of Sickle Cell Vaso-Occlusive Episodes Reveals Lineage-Autonomous Network Reorganization Across Leukocyte and Erythroid Precursor Compartments.* (2026).

---

