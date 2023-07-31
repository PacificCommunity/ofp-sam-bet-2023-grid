library(openxlsx)
source("utilities.R")

folders <- dir("d:/bet2023GridOutput/jitterMix2Grid", full=TRUE)
# folders <- c("d:/bet2023GridOutput/JitterGridMix2Output/jgm2s2a5h6", "d:/bet2023GridOutput/JitterGridMix2Output/jgm2s2a5h8")
folders <- c("d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s10_a050_h065", 
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s10_a050_h080",
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s10_a050_h095",
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s10_a075_h065", 
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s10_a075_h080",
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s10_a075_h095",
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s20_a050_h065", 
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s20_a050_h080",
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s20_a050_h095",
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s20_a075_h065", 
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s20_a075_h080",
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s20_a075_h095",
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s20_a100_h065", 
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s20_a100_h080",
             "d:/bet2023GridOutput/jitterMix2Grid/Jitter_grid_m2_s20_a100_h095")



grid.list <- lapply(folders, grid_results)
grid.tab <- do.call(rbind, grid.list)

################################################################################

write.xlsx(grid.tab, "../grid_results.xlsx")
cat("\nWrote grid_results.xlsx\n")
