plot_ratings_v1 <- function(df_vas){
  
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