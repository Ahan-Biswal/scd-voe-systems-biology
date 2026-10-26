## ============================================================
## Stage 1 prep: Split CD45 data into Steady-State-only and VOE-only
## ============================================================
## This is required BEFORE building the two separate networks that
## Stage 1 of the architecture actually calls for.
## Input : CD45_VST_normalized_clean.csv, CD45_sample_metadata_clean.csv
## Output: two separate VST matrices, one per clinical state
## ============================================================

setwd("D:/SCA_analysis/SCD_phase1/data/processed")

vst_df <- read.csv("CD45_VST_normalized_clean.csv", row.names = 1, check.names = FALSE)
meta   <- read.csv("CD45_sample_metadata_clean.csv", stringsAsFactors = FALSE)

cat("Total samples before split:", ncol(vst_df), "\n")
print(table(meta$status))

# ---- Split by status ----
ss_samples  <- meta$library_name[meta$status == "Steady State"]
voe_samples <- meta$library_name[meta$status == "VOE"]

vst_ss  <- vst_df[, colnames(vst_df) %in% ss_samples]
vst_voe <- vst_df[, colnames(vst_df) %in% voe_samples]

cat("\nSteady State subset:", ncol(vst_ss), "samples\n")
cat("VOE subset:          ", ncol(vst_voe), "samples\n")

# Sanity check - do the counts add up?
stopifnot(ncol(vst_ss) + ncol(vst_voe) == ncol(vst_df))
cat("\nSplit checks out - counts match total.\n")

# ---- Save both subsets ----
write.csv(vst_ss,  "CD45_VST_SteadyState.csv")
write.csv(vst_voe, "CD45_VST_VOE.csv")

# Also save matching metadata subsets (useful later)
meta_ss  <- meta[meta$library_name %in% ss_samples, ]
meta_voe <- meta[meta$library_name %in% voe_samples, ]
write.csv(meta_ss,  "CD45_metadata_SteadyState.csv", row.names = FALSE)
write.csv(meta_voe, "CD45_metadata_VOE.csv", row.names = FALSE)

cat("\nSaved:\n")
cat(" - CD45_VST_SteadyState.csv /  CD45_metadata_SteadyState.csv\n")
cat(" - CD45_VST_VOE.csv / CD45_metadata_VOE.csv\n")
