hist_BS_plot <- function(data_in,param, climateVar){
  
  eventDetector = 'BS'
  
  figDir = file.path(createPaths(), 'histograms')
  datDir = file.path(createPaths(), 'RData')
  
  eventTypeStr = ifelse(climateVar == 'M', 'moisture', 
                        ifelse(climateVar == 'T', 'temperature', ''))
  eventDetectorStr = ifelse(eventDetector == 'MS', 'Mean shift', 'Broken stick')
  
  posCol = ifelse(climateVar == 'M', '#003c30', '#67001f')
  negCol = ifelse(climateVar == 'M', '#543005', '#053061')
  posFill = ifelse(climateVar == 'M', '#35978f', '#d6604d')
  negFill = ifelse(climateVar == 'M', '#bf812d', '#4393c3')
  quantCol = c('#fed976', '#fd8d3c', '#fc4e2a')
  
  eventYrs = param$eventYrs[1:25]
  allEvents = data_in$allEvents
  allNullQuants = data_in$allNullQuants
  negEvents = data_in$negEvents
  posEvents = data_in$posEvents
  diffEvents = data_in$diffEvents
  recordCounts = data_in$recordCounts
  posNullQuants = data_in$posNullQuants
  negNullQuants = data_in$negNullQuants
  diffNullQuants = data_in$diffNullQuants
  allNullEvents = data_in$allNullEvents
  posNullEvents = data_in$posNullEvents
  negNullEvents = data_in$negNullEvents
  
  
  if (plotOpt) {
    
    if (climateVar == 'All') {
      
      s  <- ggplot() + geom_col(aes(x = eventYrs, y = allEvents),
                                fill = 'grey60', color = 'grey10') +
        geom_line(aes(x = eventYrs, y = allNullQuants[1,]), color = quantCol[1]) +
        geom_line(aes(x = eventYrs, y = allNullQuants[2,]), color = quantCol[2]) +
        geom_line(aes(x = eventYrs, y = allNullQuants[3,]), color = quantCol[3]) +
        #geom_point(aes(x = eventYrs, y = allNullQuants[1,]), color = quantCol[1]) +
        #geom_point(aes(x = eventYrs, y = allNullQuants[2,]), color = quantCol[2]) +
        #geom_point(aes(x = eventYrs, y = allNullQuants[3,]), color = quantCol[3]) +
        scale_x_reverse(name = 'ky BP', 
                           breaks = eventYrs[seq(1,25,by=2)], 
                           labels = eventYrs[seq(1,25,by=2)]/1000) +
        ylab('Fraction of events') +
        theme_bw() + theme(plot.title = element_text(hjust = 0.5),
                           legend.position = "bottom", 
                           legend.text = element_text(size = 12)) +
        ggtitle(paste0(eventDetectorStr, ':\nAll events'))
      
      d  <- ggplot()+ 
        geom_line(aes(x = eventYrs, y = recordCounts[,2]),
                  color = 'grey10') +
        scale_x_reverse(name = 'ky BP', 
                        breaks = eventYrs[seq(1,25,by=2)], 
                        labels = eventYrs[seq(1,25,by=2)]/1000) +
        ylab('# records') +
        theme_bw() + 
        theme(legend.position = "none")
      
      p1 <- ggplotGrob(s)
      p2 <- ggplotGrob(d)
      
      p <- rbind(p1, p2, size = "first")
      p$widths <- unit.pmax(p1$widths, p2$widths)
      pdf(file.path(figDir, paste0(eventDetector, '_', 
                                   climateVar, '.pdf')))
      grid.newpage()
      grid.draw(p)
      dev.off()
      
      plots = list(p)
      
        
    } else {
      
      b  <- ggplot()+ 
        geom_line(aes(x = eventYrs, y = recordCounts[,2]),
                  color = 'grey10') +
        scale_x_reverse(name = 'ky BP', 
                        breaks = eventYrs[seq(1,25,by=2)], 
                        labels = eventYrs[seq(1,25,by=2)]/1000) +
        ylab('# records') +
        theme_bw() + 
        theme(legend.position = "none")
      
      p1 = ggplot() + geom_col(aes(x = eventYrs, y = allEvents), 
                               fill = 'grey60', color = 'grey10') +
        geom_line(aes(x = eventYrs, y = allNullQuants[1,]), color = quantCol[1]) +
        geom_line(aes(x = eventYrs, y = allNullQuants[2,]), color = quantCol[2]) +
        geom_line(aes(x = eventYrs, y = allNullQuants[3,]), color = quantCol[3]) +
        #geom_point(aes(x = eventYrs, y = allNullQuants[1,]), color = quantCol[1]) +
        #geom_point(aes(x = eventYrs, y = allNullQuants[2,]), color = quantCol[2]) +
        #geom_point(aes(x = eventYrs, y = allNullQuants[3,]), color = quantCol[3]) +
        scale_x_reverse(name = 'ky BP', 
                           breaks = eventYrs[seq(1,25,by=2)], 
                           labels = eventYrs[seq(1,25,by=2)]/1000) +
        ylab('Fraction of events') +
        theme_bw() + theme(plot.title = element_text(hjust = 0.5)) +
        ggtitle(paste0(eventDetectorStr, ':\nAll ', eventTypeStr,' events'))
      
      p2 = ggplot() + geom_col(aes(x = eventYrs, y = posEvents), fill = posCol) +
        geom_line(aes(x = eventYrs, y = posNullQuants[1,]), color = quantCol[1]) +
        geom_line(aes(x = eventYrs, y = posNullQuants[2,]), color = quantCol[2]) +
        geom_line(aes(x = eventYrs, y = posNullQuants[3,]), color = quantCol[3]) +
        #geom_point(aes(x = eventYrs, y = posNullQuants[1,]), color = quantCol[1]) +
        #geom_point(aes(x = eventYrs, y = posNullQuants[2,]), color = quantCol[2]) +
        #geom_point(aes(x = eventYrs, y = posNullQuants[3,]), color = quantCol[3]) +
        scale_x_reverse(name = 'ky BP', 
                           breaks = eventYrs[seq(1,25,by=2)], 
                           labels = eventYrs[seq(1,25,by=2)]/1000) +
        ylab('Fraction of events') +
        theme_bw() + theme(plot.title = element_text(hjust = 0.5)) +
        ggtitle(paste0('Positive ', eventTypeStr,' events'))
      
      p3 = ggplot() + geom_col(aes(x = eventYrs, y = negEvents), fill = negCol) +
        geom_line(aes(x = eventYrs, y = negNullQuants[1,], color = '0.9')) +
        geom_line(aes(x = eventYrs, y = negNullQuants[2,], color = '0.95')) +
        geom_line(aes(x = eventYrs, y = negNullQuants[3,], color = '0.99')) +
        #geom_point(aes(x = eventYrs, y = negNullQuants[1,]), color = quantCol[1]) +
        #geom_point(aes(x = eventYrs, y = negNullQuants[2,]), color = quantCol[2]) +
        #geom_point(aes(x = eventYrs, y = negNullQuants[3,]), color = quantCol[3]) +
        scale_color_manual(name = 'Quantile', 
                           values = c('0.9' = quantCol[1], 
                                      '0.95' = quantCol[2], '0.99' = quantCol[3])) +
        scale_x_reverse(name = 'ky BP', breaks = eventYrs[seq(1,25,by=2)], 
                           labels = eventYrs[seq(1,25,by=2)]/1000) +
        ylab('Fraction of events') +
        theme_bw() + theme(plot.title = element_text(hjust = 0.5),
                           legend.position = "bottom", 
                           legend.text = element_text(size = 12)) +
        ggtitle(paste0('Negative ', eventTypeStr,' events'))
      
      g0 <- ggplotGrob(b)
      g1 <- ggplotGrob(p1)
      g2 <- ggplotGrob(p2)
      g3 <- ggplotGrob(p3)
      
      g <- rbind(g1, g2, g3, g0, size = "first")
      g$widths <- unit.pmax(g1$widths, g2$widths, g3$widths, g0$widths)
      pdf(file.path(figDir, paste0(eventDetector, '_', 
                                   climateVar, '_v2.pdf')))
      grid.newpage()
      grid.draw(g)
      dev.off()
      
      ## NET HISTOGRAM
      
      b  <- ggplot()+ 
        geom_line(aes(x = eventYrs, y = recordCounts[,2]),
                  color = 'grey10') +
        scale_x_reverse(name = 'ky BP', 
                        breaks = eventYrs[seq(1,25,by=2)], 
                        labels = eventYrs[seq(1,25,by=2)]/1000) +
        ylab('# records') +
        theme_bw() + 
        theme(legend.position = "none")
      
      posDiff = diffEvents
      negDiff = diffEvents
      posDiff[diffEvents < 0] = 0
      negDiff[diffEvents > 0] = 0
      
      p1 = ggplot() +
        geom_col(aes(x = eventYrs, y = posDiff), fill = posCol) +
        geom_col(aes(x = eventYrs, y = negDiff), fill = negCol) +
        geom_line(aes(x = eventYrs, y = diffNullQuants[1,]), color = quantCol[1]) +
        geom_line(aes(x = eventYrs, y = diffNullQuants[2,]), color = quantCol[2]) +
        geom_line(aes(x = eventYrs, y = diffNullQuants[3,]), color = quantCol[3]) +
        #geom_point(aes(x = eventYrs, y = diffNullQuants[1,]), color = quantCol[1]) +
        #geom_point(aes(x = eventYrs, y = diffNullQuants[2,]), color = quantCol[2]) +
        #geom_point(aes(x = eventYrs, y = diffNullQuants[3,]), color = quantCol[3]) +
        geom_line(aes(x = eventYrs, y = diffNullQuants[4,]), color = quantCol[1]) +
        geom_line(aes(x = eventYrs, y = diffNullQuants[5,]), color = quantCol[2]) +
        geom_line(aes(x = eventYrs, y = diffNullQuants[6,]), color = quantCol[3]) +
        #geom_point(aes(x = eventYrs, y = diffNullQuants[4,]), color = quantCol[1]) +
        #geom_point(aes(x = eventYrs, y = diffNullQuants[5,]), color = quantCol[2]) +
        #geom_point(aes(x = eventYrs, y = diffNullQuants[6,]), color = quantCol[3]) +
        scale_x_reverse(name = 'ky BP', 
                           breaks = eventYrs[seq(1,25,by=2)], 
                           labels = eventYrs[seq(1,25,by=2)]/1000) +
        ylab('Fraction of events') +
        theme_bw() + theme(plot.title = element_text(hjust = 0.5)) +
        ggtitle(paste0(eventDetectorStr, ':\nNet ', eventTypeStr,' events'))
      
      p2 = ggplot() + geom_col(aes(x = eventYrs, y = posEvents), fill = posCol) +
        geom_line(aes(x = eventYrs, y = posNullQuants[1,]), color = quantCol[1]) +
        geom_line(aes(x = eventYrs, y = posNullQuants[2,]), color = quantCol[2]) +
        geom_line(aes(x = eventYrs, y = posNullQuants[3,]), color = quantCol[3]) +
        #geom_point(aes(x = eventYrs, y = posNullQuants[1,]), color = quantCol[1]) +
        #geom_point(aes(x = eventYrs, y = posNullQuants[2,]), color = quantCol[2]) +
        #geom_point(aes(x = eventYrs, y = posNullQuants[3,]), color = quantCol[3]) +
        scale_x_reverse(name = 'ky BP', 
                           breaks = eventYrs[seq(1,25,by=2)], 
                           labels = eventYrs[seq(1,25,by=2)]/1000) +
        ylab('Fraction of events') +
        theme_bw() + theme(plot.title = element_text(hjust = 0.5)) +
        ggtitle(paste0('Positive ', eventTypeStr,' events'))
      
      p3 = ggplot() + geom_col(aes(x = eventYrs, y = negEvents), fill = negCol) +
        geom_line(aes(x = eventYrs, y = negNullQuants[1,], color = '0.9')) +
        geom_line(aes(x = eventYrs, y = negNullQuants[2,], color = '0.95')) +
        geom_line(aes(x = eventYrs, y = negNullQuants[3,], color = '0.99')) +
        #geom_point(aes(x = eventYrs, y = negNullQuants[1,]), color = quantCol[1]) +
        #geom_point(aes(x = eventYrs, y = negNullQuants[2,]), color = quantCol[2]) +
        #geom_point(aes(x = eventYrs, y = negNullQuants[3,]), color = quantCol[3]) +
        scale_color_manual(name = 'Quantile',
                           values = c('0.9' = quantCol[1], 
                                      '0.95' = quantCol[2], '0.99' = quantCol[3])) +
        scale_x_reverse(name = 'ky BP', 
                           breaks = eventYrs[seq(1,25,by=2)], 
                           labels = eventYrs[seq(1,25,by=2)]/1000) +
        ylab('Fraction of events') +
        theme_bw() + theme(plot.title = element_text(hjust = 0.5),
                           legend.position = "bottom", 
                           legend.text = element_text(size = 12)) +
        ggtitle(paste0('Negative ', eventTypeStr,' events'))
      
      d0 <- ggplotGrob(b)
      d1 <- ggplotGrob(p1)
      d2 <- ggplotGrob(p2)
      d3 <- ggplotGrob(p3)
      
      d <- rbind(d1, d2, d3, d0, size = "first")
      d$widths <- unit.pmax(d1$widths, d2$widths, d3$widths, d0$widths)
      pdf(file.path(figDir, paste0(eventDetector, '_', climateVar, '.pdf')))
      grid.newpage()
      grid.draw(d)
      dev.off()
      
      plots = list(g,d)
      
    }
    
  }
  
  if (climateVar == 'T') {
    
    if (eventDetector == 'MS') {
      posDiff_T_MS = posDiff
      negDiff_T_MS = negDiff
      posEvents_T_MS = posEvents
      negEvents_T_MS = negEvents
      quants_T_MS = diffNullQuants
      
      save(posDiff_T_MS, negDiff_T_MS, quants_T_MS, 
           file = file.path(datDir, 'histogram_T_MS.RData'))
      save(posEvents_T_MS, negEvents_T_MS, 
           file = file.path(datDir, 'histogram_ALL_T_MS.RData'))
      
      histogram  <- list(posDiff_T_MS, negDiff_T_MS, quants_T_MS, 
                         posEvents_T_MS, negEvents_T_MS)
      
    } else {
      posDiff_T_BS = posDiff
      negDiff_T_BS = negDiff
      posEvents_T_BS = posEvents
      negEvents_T_BS = negEvents
      quants_T_BS = diffNullQuants
      
      save(posDiff_T_BS, negDiff_T_BS, quants_T_BS, 
           file = file.path(datDir, 'histogram_T_BS.RData'))
      save(posEvents_T_BS, negEvents_T_BS, 
           file = file.path(datDir, 'histogram_ALL_T_BS.RData'))
      
      histogram  <- list(posDiff_T_BS, negDiff_T_BS, quants_T_BS,
                         posEvents_T_BS, negEvents_T_BS)
      
    }
    
  } 
  
  if (climateVar == 'M') {
    
    if (eventDetector == 'MS') {
      posDiff_M_MS = posDiff
      negDiff_M_MS = negDiff
      posEvents_M_MS = posEvents
      negEvents_M_MS = negEvents
      quants_M_MS = diffNullQuants
      
      save(posDiff_M_MS, negDiff_M_MS, quants_M_MS, 
           file = file.path(datDir, 'histogram_M_MS.RData'))
      save(posEvents_M_MS, negEvents_M_MS, 
           file = file.path(datDir, 'histogram_ALL_M_MS.RData'))
      
      histogram  <- list(posDiff_M_MS, negDiff_M_MS, quants_M_MS,
                         posEvents_M_MS, negEvents_M_MS)
      
    } else {
      posDiff_M_BS = posDiff
      negDiff_M_BS = negDiff
      posEvents_M_BS = posEvents
      negEvents_M_BS = negEvents
      quants_M_BS = diffNullQuants
      
      save(posDiff_M_BS, negDiff_M_BS, quants_M_BS, 
           file = file.path(datDir, 'histogram_M_BS.RData'))
      save(posEvents_M_BS, negEvents_M_BS, 
           file = file.path(datDir, 'histogram_ALL_M_BS.RData'))
      
      histogram  <- list(posDiff_M_BS, negDiff_M_BS, quants_M_BS, 
                         posEvents_M_BS, negEvents_M_BS)
      
    }
    
  }
  
if (climateVar == 'All') {

    histogram <- NA

  }



  save(recordCounts, file = file.path(datDir, 
                                      paste0('recordCountStats_', 
                                      eventDetector, '_', 
                                       climateVar, '.RData')))
  
  output  <- list(plots, histogram)
  
  return(output)
}
