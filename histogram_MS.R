histogram_MS <- function(data_in, param, climateVar){
  
  eventDetector = 'MS'
  
  figDir = file.path(createPaths(), 'histograms')
  datDir = file.path(createPaths(), 'RData')
  
  param$eventYrs = param$eventYrs[1:25]
  
  allNullEvents = matrix(NA, nrow = length(param$eventYrs), ncol = param$numIt)
  posNullEvents = matrix(NA, nrow = length(param$eventYrs), ncol = param$numIt)
  negNullEvents = matrix(NA, nrow = length(param$eventYrs), ncol = param$numIt)
  diffNullEvents = matrix(NA, nrow = length(param$eventYrs), ncol = param$numIt)
  allEvents = rep(NA, length(param$eventYrs))
  posEvents = rep(NA, length(param$eventYrs))
  negEvents = rep(NA, length(param$eventYrs))
  diffEvents = rep(NA, length(param$eventYrs))
  
  recordCounts = matrix(NA, nrow = length(param$eventYrs), ncol = 4) # years, all records, + events, - events
  recordCounts[,1] = param$eventYrs
  
  if (eventDetector == 'MS') {
    #load(file.path(datDir, 'MS_results_plusNull_complete.RData'))
    #TS_MS_orig = data_MS
    TS_MS_orig = data_in
  } else {
    # broken stick
    #load(file.path(datDir, 'BS_results_plusNull_complete.RData'))
    TS_BS_orig = data_in
  }
  
  #THese are for the composite
  everyEvent <- list()
  everyDirChange <- list()
  everyTotNullEvent <- list()
  
  for (y in 1:length(param$eventYrs)) {
    
    eventYr = param$eventYrs[y]
    print(paste('Year:', eventYr))
    
    ## MEAN SHIFT PROCESSING
    if (eventDetector == 'MS') {
      
      TS_MS = TS_MS_orig
      
      #if(!length(TS_MS) == 0 & !length(TS_MS) == 1){
      
      for (i in 1:length(TS_MS)) {
        # Filter records that don't contain event year in age range
        if (min(TS_MS[[i]]$age) > eventYr || max(TS_MS[[i]]$age) < eventYr) {
          TS_MS[[i]]$useMS = 0
          #print('Out of range')
        }
        
        #Only include annual, winterOnly, and summerOnly (exclude winter+ and summer+)
        if (length(TS_MS[[i]]$interpretation1_seasonalityGeneral) > 0) {
          if (tolower(TS_MS[[i]]$interpretation1_seasonalityGeneral) == 'summer+' | 
                tolower(TS_MS[[i]]$interpretation1_seasonalityGeneral) == 'winter+') {
            TS_MS[[i]]$useMS = -1
            print(TS_MS[[i]]$interpretation1_seasonalityGeneral)
          }
        }
      }
      TS_MS = filterTs(TS_MS, 'useMS == 1')
      
      # Assign event occurrence
      for (i in 1:length(TS_MS)) {
        
                      
        TS_MS[[i]]$eventMS = 0
        TS_MS[[i]]$dirMS = 0
        if (!is.na(TS_MS[[i]]$sig_brks) && any(TS_MS[[i]]$sig_brks >= eventYr - param$eventWindow & TS_MS[[i]]$sig_brks <= eventYr + param$eventWindow )) {
          TS_MS[[i]]$eventMS = 1
          eve_i = which(TS_MS[[i]]$sig_brks >= eventYr - param$eventWindow  & TS_MS[[i]]$sig_brks <= eventYr + param$eventWindow)
          TS_MS[[i]]$dirMS = TS_MS[[i]]$brk_dirs[eve_i]
        }
        
      }
      TS = TS_MS
      
    #}else{}
      
    } else { ## BROKEN STICK PROCESSING
      TS_BS = TS_BS_orig
      
      for (i in 1:length(TS_BS)) {
        # Filter records that don't contain event year in age range
        if (min(TS_BS[[i]]$age) > eventYr || max(TS_BS[[i]]$age) < eventYr) {
          TS_BS[[i]]$useBS = 0
          print('Out of range')
        }
        
            
        # Only include annual, winterOnly, and summerOnly (exclude winter+ and summer+)
        if (length(TS_BS[[i]]$interpretation1_seasonalityGeneral) > 0) {
          if (tolower(TS_BS[[i]]$interpretation1_seasonalityGeneral) == 'summer+' | 
                tolower(TS_BS[[i]]$interpretation1_seasonalityGeneral) == 'winter+') {
            TS_BS[[i]]$useBS = -1
            print(TS_BS[[i]]$interpretation1_seasonalityGeneral)
          }
        }
      }
      TS_BS = filterTs(TS_BS, 'useBS == 1')
      
      # Assign event occurrence
      for (i in 1:length(TS_BS)) {
        
        TS_BS[[i]]$eventBS = 0
        TS_BS[[i]]$dirBS = 0
        if (!is.na(TS_BS[[i]]$brk_pts) && any(TS_BS[[i]]$brk_pts >= eventYr - param$eventWindow & TS_BS[[i]]$brk_pts <= eventYr + param$eventWindow)) {
          eve_i = which(TS_BS[[i]]$brk_pts >= eventYr - param$eventWindow & TS_BS[[i]]$brk_pts <= eventYr + param$eventWindow)
          
          # Metric combining events occurring in event window (event takes the sign of the sum)
          dir = sum(TS_BS[[i]]$brk_dirs[eve_i]) / abs(sum(TS_BS[[i]]$brk_dirs[eve_i]))
          TS_BS[[i]]$eventBS = ifelse(is.na(dir), 0, 1)
          TS_BS[[i]]$dirBS = ifelse(is.na(dir), 0, dir)
        }
        
      }
      TS = TS_BS
    }
    
    # isolate only the records corresponding to the chosen climate interpretation
    interps = unlist(sapply(TS,"[[","interpretation1_variable"))
    if (climateVar == 'M') {
      inds = which(interps == 'M' | interps == 'P' | interps == 'P-E' | interps ==  'P/E')
    } else if (climateVar == 'T') {
      inds = which(interps == 'T' | interps == 'TM')
    } else {
      inds = 1:length(interps)
    }
    
    
    if (eventDetector == 'MS') {
      events = as.numeric(sapply(TS,"[[","eventMS"))[inds]
    } else {
      events = as.numeric(sapply(TS,"[[","eventBS"))[inds]
    }
    interps = interps[inds]
    
    # calculate the climate event direction based on the proxy climate dir and event dir: checks if the interpretation direction is the same as in the new
    dirs = unlist(sapply(TS,"[[","interpretation1_interpDirection"))[inds]
    dirs[dirs == 'positive' | dirs == 'positve' | dirs == 'postitive'] = 1
    dirs[dirs == 'negative'] = -1
    dirs[dirs == 'NA' | is.na(dirs)] = 0
    dirs = as.numeric(dirs)
    if (eventDetector == 'MS') {
      dirEvents = unlist(sapply(TS,"[[","dirMS"))[inds] # (0, 1, -1): (no, positive, negative) event
    } else {
      dirEvents = unlist(sapply(TS,"[[","dirBS"))[inds]
    }
    dirChange = dirs * dirEvents                          # (0, 1, -1): (no, positive, negative) climate event
    
    # add these for printing table of results by site
    names = unlist(sapply(TS, '[[', 'dataSetName'))[inds]
    SiteName = unlist(sapply(TS, '[[', 'geo_siteName'))[inds]
    lat = unlist(sapply(TS, '[[', 'geo_latitude'))[inds]
    lon = unlist(sapply(TS, '[[', 'geo_longitude'))[inds]
    ArchiveType = unlist(sapply(TS, '[[', 'archiveType'))[inds]
    ProxyType = unlist(sapply(TS, '[[', 'paleoData_proxyGeneral'))[inds]
    for (i in 1:length(TS)) {
      if (length(TS[[i]]$pub1_doi) == 0) {
        TS[[i]]$pub1_doi = NA
      }
    }
    for (i in 1:length(TS)) {
      if (length(TS[[i]]$originalDataUrl) == 0) {
        TS[[i]]$originalDataUrl = NA
      }
    } 
    for(i in 1:length(TS)){ # problem with this specific reference
      if(TS[[i]]$paleoData_TSid == "RyLPf9ScmVz"){
        TS[[i]]$pub1_doi = NA
      }
    }
    doi = unlist(sapply(TS, '[[', 'pub1_doi'))[inds]
    TSid = unlist(sapply(TS, '[[', 'paleoData_TSid'))[inds]
    Original = unlist(sapply(TS, '[[', 'originalDataUrl'))[inds]
    
    # save table of results by site
    event_by_site_df = data.frame(TVerseID = TSid, Dataset = names, Site = SiteName, Lat = lat, Lon = lon, Event = dirChange,Year = rep(eventYr, length(names)), Var = rep(climateVar, length(names)), Archive = ArchiveType, Proxy = ProxyType, OriginalURL = Original, DOI = doi)
    write.table(event_by_site_df, file = file.path(datDir, paste0('event_each_site_MS_',climateVar,'.csv')), append = T,row.names = F, col.names = F, sep = ',')
    
    everyEvent[[y]] <- events
    everyDirChange[[y]] <- dirChange
      
    # store real events summary for the year
    allEvents[y] = sum(events == 1) / length(events)
    posEvents[y] = sum(dirChange == 1) / length(events)
    negEvents[y] = sum(dirChange == -1) / length(events)
    diffEvents[y] = posEvents[y] - negEvents[y]
    recordCounts[y,2:4] = c(length(events), posEvents[y], negEvents[y])
    
    # Assign event occurrence
    totNullEvents = matrix(0, nrow = length(inds), ncol = param$numIt) 
    for (i in 1:length(inds)) {
      
      if (eventDetector == 'MS') {
        nullBreaks = TS[[inds[i]]]$null_sig_brks
      } else {
        nullBreaks = TS[[inds[i]]]$null_brk_pts
      }
      nullDirs = TS[[inds[i]]]$null_brk_dirs
      
      for (j in 1:param$numIt) {
        
        #sensitivity testing: added so code will not break when no event is found
                
        eventInd = which(nullBreaks[[j]] >= eventYr - param$eventWindow  & nullBreaks[[j]] <= eventYr + param$eventWindow )
        
        if (length(eventInd) > 0) {
          
          if (eventDetector == 'MS') {
            totNullEvents[i,j] = nullDirs[[j]][eventInd[1]] * dirs[i]
          } else {
            # Metric combining events occurring in event window (event takes the sign of the sum)
            dir = sum(nullDirs[[j]][eventInd]) / abs(sum(nullDirs[[j]][eventInd]))
            totNullEvents[i,j] = ifelse(is.na(dir), 0, dir) * dirs[i]
          }
          
        }
        
      } # end it loop
      
    } # end record loop
    
    allNullEvents[y,] = apply(totNullEvents, 2, function(x) sum(x != 0)) / length(inds)
    posNullEvents[y,] = apply(totNullEvents, 2, function(x) sum(x == 1)) / length(inds)
    negNullEvents[y,] = apply(totNullEvents, 2, function(x) sum(x == -1)) / length(inds)
    
    everyTotNullEvent[[y]] <- totNullEvents
    
  } # end event year loop
  
  allNullQuants = apply(allNullEvents, 1, function(x) quantile(x, probs = c(0.9, 0.95, 0.99)))
  posNullQuants = apply(posNullEvents, 1, function(x) quantile(x, probs = c(0.9, 0.95, 0.99)))
  negNullQuants = apply(negNullEvents, 1, function(x) quantile(x, probs = c(0.9, 0.95, 0.99)))
  diffNullQuants = apply(posNullEvents - negNullEvents, 1, function(x) quantile(x, probs = c(0.1,0.05,0.01,0.9, 0.95, 0.99)))
  
  output <- list(
    everyEvent = everyEvent,
    everyDirChange = everyDirChange,
    events = events,
    dirChange = dirChange,
    allEvents = allEvents,
    posEvents = posEvents,
    negEvents = negEvents,
    diffEvents = diffEvents,
    everyTotNullEvent = everyTotNullEvent,
    recordCounts = recordCounts,
    allNullEvents = allNullEvents,
    posNullEvents = posNullEvents,
    negNullEvents = negNullEvents,
    allNullQuants = allNullQuants,
    posNullQuants = posNullQuants,
    negNullQuants = negNullQuants,
    diffNullQuants = diffNullQuants)
  
  save(output, file = file.path(datDir, paste0('results_',climateVar,'_MS.RData')))
  
  return(output)
  
}
