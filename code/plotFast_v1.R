plotFast_v1 <- function(sub,ses) {
  
  library(ggplot2)
  
  # define path and project
  path <- '/Users/au342995/Documents'
  proj <- 'MINDLAB2022_CalibrationTGI'
  projdir <- file.path(path,proj)
  
  # define subject and session
  substr <- paste0('sub-', str_pad(sub, 4, pad = "0"))
  sesstr <- paste0('ses-', str_pad(ses, 2, pad = "0"))
  
  # psi threshold data
  load(file.path(projdir,'results','psi.Rda'))
  psi_sub <- df %>% filter(sub_n == sub & ses_n == ses)
  cpt <- psi_sub %>% filter(sub_n == sub & ses_n == ses & quality == 'cold') 
  hpt <- psi_sub %>% filter(sub_n == sub & ses_n == ses & quality == 'warm')

  # fast threshold data
  load(file.path(projdir,'results','fastEst.Rda'))
  fe_sub <- df %>% filter(sub_n == sub & ses_n == ses) # define data for each subject
  fe_sub$temp_cold_na <- fe_sub$temp_cold # copy temp cold_column
  fe_sub$temp_cold_na[fe_sub$temp_cold < cpt$threshold | fe_sub$temp_warm > hpt$threshold] <- NA # remove data below CPT and above HPT
  
  # vas data points
  load(file.path(projdir,'results','vas.Rda'))
  vas_sub <- df %>% filter(sub_n == sub & ses_n == ses) # define data for each subject
  
  p1 <- ggplot(data = fe_sub, mapping = aes(x = temp_cold, y = temp_warm)) +
    theme_bw() +
    #geom_point(aes(color = as.factor(cold_warm))) + # display tested data points + 
    #scale_color_manual(labels = c("Cold", "Warm"), values=c(blues6[3], reds6[3])) + # update colors: mostly warm = red, mostly cold = blue
    
    # add threshold function
    geom_line(data = fe_sub %>% filter(threshold == 25), mapping = aes(x = temp_cold_na, y = temp_warm), size = 0.5, color = 'black')+
    geom_line(data = fe_sub %>% filter(threshold == 50), mapping = aes(x = temp_cold_na, y = temp_warm), size = 0.5, color = 'black')+
    geom_line(data = fe_sub %>% filter(threshold == 75), mapping = aes(x = temp_cold_na, y = temp_warm), size = 0.5, color = 'black')+
    # geom_line(data = df_thr_bin %>% filter(id == subN & w_percent.x == 1), mapping = aes(x = tcold, y = twarm_25), size = 0.5, color = reds6[3]) +
    # geom_line(data = df_thr_bin %>% filter(id == subN & w_percent.x == 1), mapping = aes(x = tcold, y = twarm_50), size = 0.5, color = reds6[3]) +
    # geom_line(data = df_thr_bin %>% filter(id == subN & w_percent.x == 1), mapping = aes(x = tcold, y = twarm_75), size = 0.5, color = reds6[3]) +
    # geom_line(data = df_thr_bin %>% filter(id == subN & w_percent.x == 0), mapping = aes(x = tcold, y = twarm_25), size = 0.5, color = blue6[3]) +
    # geom_line(data = df_thr_bin %>% filter(id == subN & w_percent.x == 0), mapping = aes(x = tcold, y = twarm_50), size = 0.5, color = blue6[3]) +
    # geom_line(data = df_thr_bin %>% filter(id == subN & w_percent.x == 0), mapping = aes(x = tcold, y = twarm_75), size = 0.5, color = blue6[3]) +
    
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
    ggtitle(paste('fast TGI', substr, sesstr, sep = " ")) +
    theme(legend.position = "none") # remove legend
  
  return(p1)
}