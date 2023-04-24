# Define colors for group-level plots
reds6  <- brewer.pal(6, "Reds")
blues6 <- brewer.pal(6, "Blues")
purples6 <- brewer.pal(6, "Purples")

# Plot VAS ratings for all participants
plot_vas_group_v1 <- function(vas_trl, stim_type){
  
  # Number of threshold functions
  thr_n = length(unique(vas_trl$threshold))
  
  # Reorder vas_type levels
  vas_trl <- vas_trl %>% mutate(vas_type = factor(vas_type, levels = c("cold", "warm", "burn")))
  
  # Plot
  p1 <- ggplot(data = vas_trl %>% filter(stim_type == stim_type), mapping = aes(x = gain, y = vas_rating, fill = vas_type)) +
    geom_boxplot(aes(fill = interaction(gain, threshold, vas_type))) +
    geom_point(aes(fill = interaction(gain, threshold, vas_type)), shape = 21, size = 2) +
    
    # Define additional settings
    labs(title = "", y = "VAS (0-100)", x = "Temperature Levels") +
    ggtitle(paste('Stimulation:', stim_type)) +
    theme_classic() +
    scale_x_continuous(breaks = c(1, 2, 3), labels=c("L25%", "L50%", "L75%")) +
    scale_fill_manual(labels = c("Cold", "Warm", "Burn"), 
                      values = c(rep(blues6[3], thr_n*3), rep(reds6[3], thr_n*3), rep(purples6[5], thr_n*3))) + 
    theme(legend.position = "none") # remove legend
  
  if (nrow(vas_trl) > 0) {
    p1 <- p1 + facet_wrap(~ interaction(vas_type, threshold))
  }
  
  p1
  
}