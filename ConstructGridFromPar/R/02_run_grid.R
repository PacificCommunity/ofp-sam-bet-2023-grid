library(condor)

session <- ssh_connect("NOUOFPCALC02")
options(width=160)

grid.dir <- "../grid/m1"

model.dirs <- dir(grid.dir, full=TRUE)

for(i in seq_along(model.dirs))
  try(condor_submit(model.dirs[i]))
