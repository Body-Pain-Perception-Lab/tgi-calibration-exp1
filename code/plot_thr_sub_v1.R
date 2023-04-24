# Plot threshold data for each subject
plot_thr_sub_v1 <- function(vas_sub, fe_sub, psi_sub, title) {
  
  # Define colors
  reds6 <- brewer.pal(6, "Reds")
  blues6 <- brewer.pal(6, "Blues")
  
  # Define CPT and HPT obtained using psi
  cpt <- psi_sub %>% filter(quality == 'cold') 
  hpt <- psi_sub %>% filter(quality == 'warm')

  # Plot parameters
  p <- ggplot(data = fe_sub, mapping = aes(x = temp_cold_na, y = temp_warm)) +
    theme_bw() +
    #geom_point(aes(color = as.factor(cold_warm))) + # display tested data points + 
    #scale_color_manual(labels = c("Cold", "Warm"), values=c(blues6[3], reds6[3])) + # update colors: mostly warm = red, mostly cold = blue
    
    # add threshold function
    geom_line(data = fe_sub %>% filter(threshold == 25), mapping = aes(x = temp_cold_na, y = temp_warm), size = 0.5, color = 'black')+
    geom_line(data = fe_sub %>% filter(threshold == 50), mapping = aes(x = temp_cold_na, y = temp_warm), size = 0.5, color = 'black')+
    geom_line(data = fe_sub %>% filter(threshold == 75), mapping = aes(x = temp_cold_na, y = temp_warm), size = 0.5, color = 'black')+
      
    # add vas points that were tested
    geom_point(data = vas_sub %>% filter(temp_cold != 30 & temp_warm !=30), mapping = aes(x = temp_cold, y = temp_warm, shape = as.factor(threshold)), size = 2) +
    
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

# Plot VAS ratings for each subject
plot_vas_sub_v1 <- function(df_vas){
  
  # Define colors
  reds6  <- brewer.pal(6, "Reds")
  blues6 <- brewer.pal(6, "Blues")
  purples6 <- brewer.pal(6, "Purples")
  
  # Define plot
  p1 <- ggplot(data = df_vas, mapping = aes(x = gain, y = vas_rating_median, fill = stim_type)) +
    # Cold
    geom_line(data = df_vas %>% filter(stim_type == "cold"), aes(group = sub), color = blues6[3], alpha = 1) +
    # Warm
    geom_line(data = df_vas %>% filter(stim_type == "warm"), aes(group = sub), color = reds6[3], alpha = 1) +
    # TGI
    geom_line(data = df_vas %>% filter(stim_type == "tgi"), aes(group = sub), color = purples6[5], alpha = 1) +
    geom_point(shape = 21, size = 3) +
    
    # Define additional settings
    labs(title = "", y = "VAS (0-100)", x = "Temperature Levels") +
    ggtitle('VAS Ratings ') +
    theme_classic() +
    scale_x_continuous(breaks = c(0.25,0.50,0.75), labels = c("L25%", "L50%", "L75%"), limits = c(0.2, 0.8)) +
    scale_fill_manual(labels = c("Cold", "TGI", "Warm"), values=c(blues6[3], purples6[5], reds6[3])) +
    facet_wrap(~ interaction(stim_type, threshold)) +
    theme(legend.position = "none") # remove legend
  p1
  
}