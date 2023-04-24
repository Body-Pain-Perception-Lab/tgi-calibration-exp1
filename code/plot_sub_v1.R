# Define colors for subject-level plots
reds6  <- brewer.pal(6, "Reds")
blues6 <- brewer.pal(6, "Blues")
purples6 <- brewer.pal(6, "Purples")

# Custom labelling function for facet wrap titles
custom_labeller <- function(labels) {
  labels <- as.character(labels)
  labels <- gsub("cold", "Cold Ratings", labels)
  labels <- gsub("warm", "Warm Ratings", labels)
  labels <- gsub("burn", "Burn Ratings", labels)
  return(labels)
}

# Plot threshold data for each subject
plot_thr_sub_v1 <- function(vas_sub, fe_sub, psi_sub, title) {

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
    geom_hline(yintercept = hpt$threshold, linetype = "dashed", color = reds6[6]) +
    geom_vline(xintercept = cpt$threshold, linetype = "dashed", color = blues6[6]) +
    
    # set axes
    scale_x_continuous(breaks = seq(0, 30, by = 5)) + # change x axis
    coord_fixed(ratio = 1, xlim = c(0, 30), ylim = c(30, 50), expand = FALSE) + # change axis limits
    xlab('Cold temperature') +
    ylab('Warm temperature') +
    ggtitle(title) + # Use custom title
    theme(legend.position = "none") # remove legend
  
  return(p)
}

#Plot VAS ratings for each subject
plot_vas_sub_v1 <- function(vas_sub){

  # Reorder vas_type levels
  vas_sub <- vas_sub %>% mutate(
    vas_type = factor(vas_type, levels = c("cold", "warm", "burn")),
    stim_type = factor(stim_type, levels = c("cold", "warm", "tgi")))

  # Define plot
  p1 <- ggplot(data = vas_sub, mapping = aes(x = gain, y = vas_rating_median, fill = stim_type)) +
    theme_classic() +
    # Cold
    geom_line(data = vas_sub %>% filter(stim_type == "cold"), aes(group = sub), color = blues6[3], alpha = 1) +
    # Warm
    geom_line(data = vas_sub %>% filter(stim_type == "warm"), aes(group = sub), color = reds6[3], alpha = 1) +
    # TGI
    geom_line(data = vas_sub %>% filter(stim_type == "tgi"), aes(group = sub), color = purples6[5], alpha = 1) +
    geom_point(shape = 21, size = 2) +

    # Define additional settings
    labs(y = "VAS (0-100)", x = "Temperature Levels") + # title = ""
    #ggtitle('VAS Ratings ') +
    scale_x_continuous(breaks = c(1, 2, 3), labels = c("L25", "L50", "L75")) +
    scale_y_continuous(limits = c(0, 100)) +
    scale_fill_manual(labels = c("Cold", "TGI", "Warm"), values=c(blues6[3], purples6[5], reds6[3])) +
        theme(legend.position = "none", # remove legend
          axis.text.x = element_text(size = 6), # Change x-axis label font size
          strip.text = element_text(size = 6)) # Change font size of facet wrap headings
  
  if (nrow(vas_sub) > 0) {
  p1 <- p1 + facet_wrap(~ interaction(vas_type, threshold), labeller = labeller(.default = custom_labeller))
  # p1 <- p1 + facet_wrap(~ interaction(vas_type, threshold))
  }
    
  p1

}
