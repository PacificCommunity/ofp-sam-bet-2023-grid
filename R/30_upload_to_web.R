# Copy selected model files to upload grid results to web

# bet-2023-grid.zip
#   [bin]
#     mfclo64
#   [grid]
#     m1_s10_a050_h65
#     ...
#   [notes]
#     estimation_uncertainty.csv
#     estimation_uncertainty.R
#   README.md

# GitHub ofp-sam-bet-2023-grid/releases/download/file/bet-2023-grid-results.zip

################################################################################

library(TAF)  # file utilities

# Source and destination paths
from <- "//penguin/assessments/bet/2023/model_runs/grid/full"
from.hessian <- "//penguin/assessments/bet/2023/model_runs/grid/full_hessian"
to <- "."
# unlink(to, recursive=TRUE)

# Create folders
models <- dir(from, pattern="m[12]", full=TRUE)
models <- basename(models[dir.exists(models)])
mkdir(file.path(to, "bin"))
mkdir(file.path(to, "grid", models))

# Copy executable
cp(file.path(from, models[1], "mfclo64"), file.path(to, "bin"))

for(i in seq_along(models))
{
  # Copy model files, including all *.par
  model.files <- c("doitall.sh", "*.par", "mfcl.cfg", "plot-final.par.rep",
                   "test_plot_output", "bet.age_length", "bet.frq", "bet.tag")
  cp(file.path(from, models[i], model.files), file.path(to, "grid", models[i]))
  # Copy Hessian files
  hessian.files <- c("neigenvalues", "xinit.rpt", # omit dohessian_standalone.sh
                     "bet.var", "bet_hess_inv_diag", "bet_pos_hess_cor")
  cp(file.path(from.hessian, models[i], hessian.files),
     file.path(to, "grid", models[i]))
}

# Then produce zip file in Linux, preserving executable bit for mfclo64 and *.sh
# $ chmod 755 bin/mfclo64 grid/*/*.sh
# $ zip -rX zipfile.zip bin grid notes README.md
