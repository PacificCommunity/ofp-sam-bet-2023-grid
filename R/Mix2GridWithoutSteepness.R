library(condor)

execute = TRUE
if(execute)
  session = ssh_connect("claudioc@SUVOFPSUBMIT")

# Directories
proj.dir   = ".."
dir.condor = file.path(proj.dir, "stepLor_M")    # doitall.sh
dir.input  = file.path(proj.dir, "stepLor_M")  # skj.frq, skj.ini, skj.tag
dir.mfcl   = file.path(proj.dir, "mfcl2111")            # condor.sub, condor_run.sh, mfcl.cfg, mfclo64
dir.output = file.path(proj.dir, "model_runs")      # [place to put grid models]

jobs.group = "stepLor_M_hess7a2111"

#S1 <- 0.65; S2 <- 0.8; S3 <- 0.95
S <- 0.8 #c(S1, S2, S3)
T <- "T2"# c("T1", "T2", "T3") # different T for different doitall 
# G1 estimated growth; G2 fix growth parameters from team JAJ 
# dont forget to change the G1 or G2 definition in runname otherwise you will mess up the names

#M <- seq(8, 15, 1)    # different values for M multiplier
RR <- c(98) #seq(91, 99, 1)  # reporting rates from 0.91 to 0.99

# Create grid model directories and run if 'executable' is TRUE
for(k in 1:length(RR)){ #length(RR)){
  #for(i in 1:2){ #length(T)){
  #  for(j in 1:2){ #length(S)){
      # i=1
      # j=1
      # k=1
      cat(", k=", k, "\n", sep="")
      runname = paste0(jobs.group,"_",RR[k])#paste0(T, "G1", S, "_", RR[k])  # G2 means fixed growth
      model.run.dir = file.path(dir.output, jobs.group,runname)
      # create directory for model run
      if (! dir.exists(model.run.dir)) dir.create(model.run.dir, recursive = TRUE)
      file.copy(file.path(dir.input, c("skj.frq", "skj.ini", "skj.tag")), model.run.dir, overwrite=TRUE)
      file.copy(file.path(dir.condor, "doitall.sh"), model.run.dir, overwrite=TRUE)
      file.copy(file.path(dir.mfcl, c("condor.sub", "condor_run.sh", "mfcl.cfg", "mfclo64")),
                model.run.dir, overwrite=TRUE)
      
      # ini: steepness, growth, (movement)
      # newmov   = readLines(paste0(model.run.dir, "movement.txt"))
      ini  = readLines(file.path(model.run.dir, "skj.ini"))
      pointer.h1  = grep("# sv(29)", ini, fixed = TRUE)
      pointer.h2 = grep("# Generic SD of length at age", ini, fixed = TRUE)
      ini[(pointer.h1+1):(pointer.h2-1)] <- S
      writeLines(ini, file.path(model.run.dir, "skj.ini"))

      # doitall.sh: reporting rate, Hessian, M multiplier
      doitall = readLines(file.path(model.run.dir, "doitall.sh"), warn = FALSE)
      # pointer = grep(" 2 128 11       # Initial Z is M*1.1", doitall, fixed=TRUE)  # M multiplier
      # tmp.doitall[pointer] = paste0(" 2 128 ", M[k],"       # Initial Z is M*1.1 ", tmp.doitall,fixed=TRUE)
      pointer.rr = grep(" 1 33 90 ", doitall, fixed = TRUE)  # maximum tag reporting rate
      doitall[pointer.rr] = paste(" 1 33", RR[k],"  # Maximum tag reporting rate for all fisheries")
      
      doitall = c(doitall, c("# ------------",
                             "# PHASE 8 - Hessian Calcs",
                             "# ------------",
                             "if [ ! -f junk ]; then",
                             "$MFCL skj.frq 07a.par junk -switch 2 1 1 1 1 145 3",
                             "$MFCL skj.frq 07a.par junk -switch 2 1 1 1 1 145 4",
                             "$MFCL skj.frq 07a.par junk -switch 2 1 1 1 1 145 5",
                             "fi"))  
      writeLines(doitall, file.path(model.run.dir, "doitall.sh"))

      # Execute on condor
      if(execute)
        condor_submit(model.run.dir)
    }
#  }
#}
