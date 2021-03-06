BrokenStick <- function(data_in, param){
  
  print("Running brockenStick now")
  
  mainDir = createPaths()
  TS_BS = filterTs(data_in, 'useBS == 1')
  figDir = file.path(mainDir, 'broken_stick', 'individual')
    
  for (i in 1:length(TS_BS)) {
  #  for (i in 1:50) {
       
    print(paste0('RECORD ', i))
    
    # run the broken stick code
    tryCatch({results = iterativeBrokenStick(TS_BS[[i]]$age, 
                                            TS_BS[[i]]$paleoData_values,
                                   plot.opt = param$plotOpt ,
                                   plotName = TS_BS[[i]]$dataSetName,
                                   figDir = figDir)
    
    if (is.na(results$cp)) {
      
      TS_BS[[i]]$brk_pts = NA
      TS_BS[[i]]$brk_ptsErr = NA
      TS_BS[[i]]$brk_dirs = NA
      
    } else {
      
      ordI = order(results$cp)
      TS_BS[[i]]$brk_pts = results$cp[ordI]
      TS_BS[[i]]$brk_ptsErr = results$cp.se[ordI]
      slopes = results$o$coefficients[3:(length(results$cp)+2)]
      TS_BS[[i]]$brk_dirs = ifelse(slopes > 0, 1, -1)
    }}, error = function(e){cat("Error:", conditionMessage(e), paste0(" and had to skip record ", TS_BS[[i]]$dataSetName))})
    
    
  }
    
  fileName = file.path(mainDir, 'RData', 'BS_results_complete.RData')
  save(TS_BS, file = fileName)
  
 
  return(TS_BS)
  
}