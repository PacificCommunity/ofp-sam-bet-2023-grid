library(condor)

execute = TRUE
if(execute)
  session <- ssh_connect("NOUOFPCALC02")

# Directories
proj.dir <-".."

dir.input <- file.path(proj.dir, "13daM2F0C0_50")    # doitall.sh *.frq, *.ini, *.tag, *.age_length, condor.sub, condor_run.sh, mfcl.cfg, mfclo64
dir.output <- file.path(proj.dir, "Mix2GridModels")  # [place to put grid models]
dir.output <- file.path(proj.dir, "Mixx2GridModels")  # [place to put grid models]

frq_file <- "bet.frq"
ini_file <- "bet.ini"
tag_file <- "bet.tag"
age_length_file <- "bet.age_length"
doitall_file <- "doitall.sh"
jobs.group <- "grid_m2"
hess <-FALSE

size <- c(10,20,40)
size <- c(40)
age <- c(0.5,0.75,1.0)
steep <- c(0.65,0.8,0.95)

#######################################################################################

# Create grid model directories and run if 'executable' is TRUE
for(i in 1:length(size))
{ 
  for(j in 1:length(age))
  {
    for(k in 1:length(steep))
    {
      cat("i=", i, ", j=", j, ", k=", k, "\n", sep="")
      a.label <- formatC(100*age, width=3, flag="0")
      h.label <- formatC(100*steep, width=3, flag="0")
      runname <- paste0(jobs.group, "_s", size[i], "_a", a.label[j], "_h", h.label[k])
      model.run.dir <- file.path(dir.output, jobs.group, runname)

      # create directory for model run
      if (! dir.exists(model.run.dir)) dir.create(model.run.dir, recursive = TRUE)
      file.copy(file.path(dir.input, c(frq_file, ini_file, tag_file, age_length_file, doitall_file)), 
                model.run.dir, overwrite=TRUE)
      file.copy(file.path(dir.input, c("condor.sub", "condor_run.sh", "mfcl.cfg", "mfclo64")),
                model.run.dir, overwrite=TRUE)
      
      # doitall.sh: size weight, age weight, Hessian
      doitall <- readLines(file.path(model.run.dir, doitall_file), warn = FALSE)
      pointer <- grep(" -999 49 20", doitall, fixed = TRUE)  
      doitall[pointer] <- paste(" -999 49", size[i],"      # divide LF sample sizes by 20 (default=10)")
      pointer <- grep(" -999 50 20", doitall, fixed = TRUE)  
      doitall[pointer] <- paste(" -999 50", size[i],"      # divide WF sample sizes by 20 (default=10)")
      # divide LF & WF samples in 2 again for LL + index
      pointer <- grep(" 49 40.* 50 40", doitall)      
      doitall[pointer] <- gsub(" 49 40", paste(" 49", 2*size[i]), doitall[pointer])
      doitall[pointer] <- gsub(" 50 40", paste(" 50", 2*size[i]), doitall[pointer])
      if (hess)
      {
        doitall <- c(doitall, c("# ------------------------",
                                "# PHASE 11 - Hessian Calcs",
                                "# ------------------------",
                                "if [ ! -f junk ]; then",
                                paste("  $MFCL", frq_file, "10.par junk -switch 2 1 1 1 1 145 3"),
                                paste("  $MFCL", frq_file, "10.par junk -switch 2 1 1 1 1 145 4"),
                                paste("  $MFCL", frq_file, "10.par junk -switch 2 1 1 1 1 145 5"),
                                "fi"))  
      }
      writeLines(doitall, file.path(model.run.dir, doitall_file))

      # .age_length: age weighting
      age_l <- readLines(file.path(model.run.dir, age_length_file))
      pointer.0 <- grep("# num age length records", age_l, fixed = TRUE)
      num_age_length_records <- as.integer(age_l[pointer.0+1])
      pointer.1 <- grep("# effective sample size", age_l, fixed = TRUE)
      pointer.2 <- grep("# Year   Month   Fishery   Species", age_l, fixed = TRUE)
      pointer.3 <- pointer.2[1]
      age_l[(pointer.1+1):(pointer.3-1)] <- paste(rep(age[j], times=num_age_length_records), collapse=" ")
      writeLines(age_l, file.path(model.run.dir, age_length_file))
      
      # ini: steepness
      ini <- readLines(file.path(model.run.dir, ini_file))
      pointer.h1 <- grep("# sv(29)", ini, fixed = TRUE)
      pointer.h2 <- grep("# Generic SD of length at age", ini, fixed = TRUE)
      ini[(pointer.h1+1):(pointer.h2-1)] <- steep[k]
      writeLines(ini, file.path(model.run.dir, ini_file))
      
      # Execute on condor
      if(execute)
        condor_submit(model.run.dir)
    }
  }
}