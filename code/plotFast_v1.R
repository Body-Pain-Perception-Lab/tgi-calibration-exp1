plotFast_v2 <- function(vas_sub, fe_sub, psi_sub, title) {
  
  cpt <- psi_sub %>% filter(quality == 'cold') 
  hpt <- psi_sub %>% filter(quality == 'warm')

  p <- ggplot(data = fe_sub, mapping = aes(x = temp_cold, y = temp_warm)) +
    theme_bw() +
    #geom_point(aes(color = as.factor(cold_warm))) + # display tested data points + 
    #scale_color_manual(labels = c("Cold", "Warm"), values=c(blues6[3], reds6[3])) + # update colors: mostly warm = red, mostly cold = blue
    
    # add threshold function
    geom_line(data = fe_sub %>% filter(threshold == 25), mapping = aes(x = temp_cold_na, y = temp_warm), size = 0.5, color = 'black')+
    geom_line(data = fe_sub %>% filter(threshold == 50), mapping = aes(x = temp_cold_na, y = temp_warm), size = 0.5, color = 'black')+
    geom_line(data = fe_sub %>% filter(threshold == 75), mapping = aes(x = temp_cold_na, y = temp_warm), size = 0.5, color = 'black')+
      
    # add vas points that were tested
    geom_point(data = vas_sub %>% filter(target_warm_t1 != 30 & target_cold_t1 !=30), mapping = aes(x = target_cold_t1, y = target_warm_t1, shape = as.factor(threshold)), size = 2) +
    
    # add cpt and hpt as dashed lines
    geom_hline(yintercept = hpt$threshold, linetype="dashed", color = reds6[6]) +
    geom_vline(xintercept = cpt$threshold, linetype="dashed", color = blues6[6]) +
    
    # set axes
    scale_x_continuous(breaks=seq(0,30,by=5)) + # change x axis
    coord_fixed(ratio = 1, xlim = c(0,30), ylim = c(30,50), expand = FALSE) + # change axis limits
    xlab('Cold temperature') +
    ylab('Warm temperature') +
    ggtitle(title) + # Use custom title
    theme(legend.position = "none") # remove legend
  
  return(p)
}