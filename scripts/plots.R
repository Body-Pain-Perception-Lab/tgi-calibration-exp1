
# These scripts are all for plotting the figures in the main:

# Function to get parameters of the 2 and 3 D psi for both mean and standard error
generate_summary <- function(df, parameters) {
  
  #extracting the parameters
  errors <- paste0(parameters, "_se")
  parameters = paste0("mean_",parameters)
  
  #means
  means <- df %>%
    group_by(sub) %>%
    summarize(across(all_of(parameters), ~ last(.))) %>%
    pivot_longer(cols = starts_with("mean_"), values_to = "means") %>% mutate(name = str_remove(name, "mean_"))
  
  #standard errors
  se <- df %>%
    group_by(sub) %>%
    summarize(across(all_of(errors), ~ last(.))) %>%
    pivot_longer(cols = ends_with("_se"), values_to = "se") %>% mutate(name = str_remove(name, "_se"))
  
  #combine
  data = inner_join(means,se)

  #return
  return(data)
}

#function to plot plot3 from the manuscript
plot3 = function(){
  
  #load the data
  df <- read.csv(here::here("data","fastTrl.csv")) %>% filter(ses == 1) %>% dplyr::rename(mean_t0 = t0,
                                                                                   mean_t30 = t30,
                                                                                   mean_alpha = alpha,
                                                                                   mean_S = S)
  #colors for the plot:
  
  color_dist = "#e0c2f2"
  color_outline = "#916eca"
  
  #parameters to get from the generate_summary function:
  parameters = c("t0","t30","alpha","S")
  
  #get the data:
  d = generate_summary(df, parameters)
  
  #need ggh4x for the scales of the different facets:
  
  
  # renaming and wrangling
  plot3_upper = d  %>% mutate(parameter = ifelse(name == "alpha","λ",
                                                 ifelse(name == "S","S",
                                                        ifelse(name == "t0",
                                                               "t\u2080","t\u2083\u2080")))) %>% 
    mutate(parameter = factor(parameter, levels = c("λ", "S", "t\u2080", "t\u2083\u2080"))) %>%
    #plotting
    ggplot(aes(x = means,fill = color_dist, col = color_outline))+
    geom_point(aes(y = -0.05),shape = 20, show.legend = FALSE, alpha = 0.25, size = 3,
                    position = position_jitter(height = 0.02, seed = 123))+
    geom_density(aes(y=after_stat(scaled)),show.legend = FALSE, alpha = .60,adjust = 1)+
    geom_boxplot(aes(y = 0.05),notch = TRUE, width = 0.05, alpha = .6, outlier.shape = NA, show.legend = FALSE)+
    facet_wrap(~parameter, scales = "free")+
    ylab("Scaled Density")+
    xlab("Parameter value")+
    ggtitle("Parameter distribution")+
    theme_classic()+
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          text = element_text(family = "sans",size = 12),
          plot.title = element_text(hjust = 0.5))+
    scale_fill_manual(values = color_dist)+
    scale_color_manual(values = color_outline)
  
  #adding different x scales for the distribution to highliht their ranges:
  plot3_upper = plot3_upper+
    facetted_pos_scales(
      x = list(
        parameter == "t\u2080" ~ scale_x_continuous(limits = c(0, 60), breaks = c(0,20,40,60)),
        parameter == "t\u2083\u2080" ~ scale_x_continuous(limits = c(30, 60), breaks = c(30,40,50,60)),
        parameter == "λ" ~ scale_x_continuous(limits = c(0, 5), breaks = c(0,2,4)),
        parameter == "S" ~ scale_x_continuous(limits = c(0, 12), breaks = c(0,4,8,12))
      )
    )
  
  #defining the threshold function:
  threshold_function = function(t_c,t0,t30,lambda){
    
    return(t0+(t30-t0)*(1-(30-t_c)/30)^lambda)
  }
  
  #defining the function to get the burning probability given the thresholdfunction and a warm rating:
  burning_prob = function(t_w,t_w_a,S){
    
    return(1/(1+exp(-(1/S)*(t_w-t_w_a))))
    
  }
  
  #take warm ratings from 30 to 60
  xs = seq(30,60,by = 1)
  # at cold temperature of 20
  cold_temp = 20
  

  
  #mean of the group level
  f = d %>% group_by(name) %>% summarize(value = mean(means)) %>% pivot_wider()
  dd = data.frame(xs = xs) %>% mutate(y = burning_prob(xs,threshold_function(20,f$t0,f$t30,f$alpha),f$S))
  
  
  # subject wise means (light grey lines in the plot)
  subjectwise_means = d %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(x = list(xs),
           y = list(burning_prob(xs,threshold_function(cold_temp,means_t0,means_t30,means_alpha),means_S))) %>% unnest()
  
  
  

  #getting CI for p = 0.50
  # same temps just more finegrained
  cold_temp = 20
  xs = seq(30,60,by = 0.05)
  #5000 simulations to get a good bootstrapped estimate
  n_sim = 5000
  
  # wrangling the data
  data_forplot3lower = d %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(t0_draw = list(rnorm(n_sim,means_t0, se_t0)),
           t30_draw = list(rnorm(n_sim,means_t30, se_t30)),
           S_draw = list(rnorm(n_sim,means_S, se_S)),
           lambda_draw = list(rnorm(n_sim,means_alpha, se_alpha)),
           id = list(1:n_sim),
    ) %>% 
    #now that we have added the uncertainty on the means we can group by these ides and take the means, meaning we have proporgated the uncertainty
    ungroup() %>% 
    unnest() %>% 
    group_by(id) %>% summarize(mean_t0 = mean(t0_draw),
                               mean_t30 = mean(t30_draw),
                               mean_S = mean(S_draw),
                               mean_lambda = mean(lambda_draw)) %>% 
    rowwise() %>% 
    #getting the burning probabilities at the given warm temperatures
    mutate(x = list(xs),
           y = list(burning_prob(xs,threshold_function(cold_temp,mean_t0,mean_t30,mean_lambda),mean_S)))  %>% 
    unnest()
  
  #interval i.e. p = 0.5
  ddx = data_forplot3lower %>% filter(y < 0.501 & y>0.499)
  
  #getting the HDI of the x's that produce p = 0.5
  interval = data.frame(hdi(ddx$x, ci = 0.95) %>% mutate(mean = mean(ddx$x)))

  # Now for the plotting we just need 100 sims from the bootstrapped distribution else it gets messy: else the same prodcedure:
  
  xs = seq(30,60,by = 1)
  cold_temp = 20
  n_sim = 100
  
  
  #combined plot:
  plot3_lower = d %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(t0_draw = list(rnorm(n_sim,means_t0, se_t0)),
           t30_draw = list(rnorm(n_sim,means_t30, se_t30)),
           S_draw = list(rnorm(n_sim,means_S, se_S)),
           lambda_draw = list(rnorm(n_sim,means_alpha, se_alpha)),
           id = list(1:n_sim),
    ) %>% 
    ungroup() %>% unnest() %>% group_by(id) %>% summarize(mean_t0 = mean(t0_draw),
                                                          mean_t30 = mean(t30_draw),
                                                          mean_S = mean(S_draw),
                                                          mean_lambda = mean(lambda_draw),
    ) %>% rowwise() %>% 
    mutate(x = list(xs),
           y = list(burning_prob(xs,threshold_function(cold_temp,mean_t0,mean_t30,mean_lambda),mean_S)))  %>% 
    unnest() %>%
    ggplot()+
    geom_line(data = subjectwise_means, aes(x = x, y, group = sub), col = "black", alpha = 0.1)+
    geom_line(aes(x = x, y = y, group = id), col = color_dist, alpha = 0.75)+
    geom_line(data = dd, aes(x = xs, y), col = color_outline)+
    geom_segment(data = data.frame(),aes(x = 30, y = 0.50, xend = mean(ddx$x), yend = 0.50), col = color_outline, linetype = 2)+ 
    geom_segment(data = data.frame(),aes(x = mean(ddx$x), y = 0, xend = mean(ddx$x), yend = 0.50), col = color_outline, linetype = 2)+ 
    theme_classic()+ggtitle(paste0("TGPF at Cold temperature: ", cold_temp,"°C"))+
    scale_x_continuous(breaks = scales::pretty_breaks(n = 5))+
    scale_y_continuous(expand = c(0, 0)) + 
    ylab("Burning Probability")+
    xlab("Warm Temperature °C")+
    theme(plot.title = element_text(hjust = 0.5),
          text = element_text(family = "sans",size = 12))
  
  
  # add the plots together and return it:
  plot3 = plot3_upper+plot3_lower+
  plot_annotation(tag_levels = list(c('A', 'B')))

  return(list(plot3,interval))
  
}
  
  
# convergence plots:
conv_plot = function(){
  
  #colors:
  color_dist = "black"
  color_outline = "#916eca"
  
  # read the data
  df <- read.csv(here::here("data","fastTrl.csv")) %>% filter(ses == 1)
  
  #get vector of parameters
  parameters = c("t0","t30","alpha","S")
  errors = paste0(parameters, "_se")
  
  #get dataframe with names and the group mean and standard error at each trial (this is for the standard errors themselves)
  grouplevel_se = df %>%
    pivot_longer(cols = c(errors))%>% 
    mutate(parameter = ifelse(name == "alpha_se","λ(se)",
                              ifelse(name == "S_se","S(se)",
                                     ifelse(name == "t0_se","t\u2080(se)","t\u2083\u2080(se)")))) %>% 
    mutate(parameter = factor(parameter, levels = c("λ(se)", "S(se)", "t\u2080(se)", "t\u2083\u2080(se)"))) %>% 
    group_by(parameter, trial_n) %>% 
    summarize(mean = mean(value), se = sd(value)/sqrt(n()))
  
  # plot it
  convergence_plot_se = df %>%
    pivot_longer(cols = c(errors))%>% 
    mutate(parameter = ifelse(name == "alpha_se","λ(se)",
                              ifelse(name == "S_se","S(se)",
                                     ifelse(name == "t0_se","t\u2080(se)","t\u2083\u2080(se)")))) %>% 
    mutate(parameter = factor(parameter, levels = c("λ(se)", "S(se)", "t\u2080(se)", "t\u2083\u2080(se)"))) %>% 
    ggplot()+
    geom_line(aes(x = trial_n, y = value, group = sub),col = color_dist, alpha = 0.1)+
    geom_line(data = grouplevel_se, aes(x = trial_n, y = mean), col = "#916eca")+
    geom_ribbon(data = grouplevel_se, aes(x = trial_n, y = mean, ymin = mean-2*se,ymax = mean+2*se), fill = "#916eca", alpha = 0.5)+
    facet_wrap(~parameter, scales = "free")+
    scale_y_continuous(breaks = scales::pretty_breaks(n = 5)) + 
    scale_x_continuous(breaks = scales::pretty_breaks(n = 5)) + 
    theme_classic()+
    xlab("Trial Number")+
    ylab("Standard error of parameter")+
    ggtitle("Convergence plots")+
    theme(plot.title = element_text(hjust = 0.5),
          text = element_text(family = "sans",size = 12))
  
  
  
  # Same as above just with the mean estimates
  
  color_dist = "black"
  color_outline = "#916eca"
  

  parameters = c("t0","t30","alpha","S")
  errors = paste0(parameters, "_se")
  
  grouplevel_means = df %>%
    pivot_longer(cols = c(parameters))%>% 
    mutate(parameter = ifelse(name == "alpha","λ",
                              ifelse(name == "S","S",
                                     ifelse(name == "t0","t\u2080","t\u2083\u2080")))) %>% 
    mutate(parameter = factor(parameter, levels = c("λ", "S", "t\u2080", "t\u2083\u2080"))) %>% 
    group_by(parameter, trial_n) %>% summarize(mean = mean(value), se = sd(value)/sqrt(n()))
  
  
  convergence_plot_means = df %>%
    pivot_longer(cols = c(parameters))%>% 
    mutate(parameter = ifelse(name == "alpha","λ",
                              ifelse(name == "S","S",
                                     ifelse(name == "t0","t\u2080","t\u2083\u2080")))) %>% 
    mutate(parameter = factor(parameter, levels = c("λ", "S", "t\u2080", "t\u2083\u2080"))) %>% 
    ggplot()+
    geom_line(aes(x = trial_n, y = value, group = sub),col = color_dist, alpha = 0.1)+
    geom_line(data = grouplevel_means, aes(x = trial_n, y = mean), col = "#916eca")+
    geom_ribbon(data = grouplevel_means, aes(x = trial_n, y = mean, ymin = mean-2*se,ymax = mean+2*se), fill = "#916eca", alpha = 0.5)+
    facet_wrap(~parameter, scales = "free")+
    theme_classic()+
    scale_y_continuous(breaks = scales::pretty_breaks(n = 5)) + 
    scale_x_continuous(breaks = scales::pretty_breaks(n = 5)) + 
    xlab("Trial Number")+
    ylab("Parameter value")+
    ggtitle("Convergence plots")+
    theme(plot.title = element_text(hjust = 0.5),
          text = element_text(family = "sans",size = 12))
  
  
  #return both plots:
  
  return(list(convergence_plot_means,convergence_plot_se))
  
}


# Plot for the Cold pain thresholds (supplementary material)
CPT_plot = function(){
  
  #colors:
  color_dist = "#add8e6"
  color_outline = "#0c79a6"
  
  #read the data and get the parameter estimates:
  
  df <- read.csv(here::here("data","psi.csv")) %>% 
    filter(ses == 1 & quality == "cold")%>% 
    dplyr::rename(mean_threshold = threshold,
                  mean_slope = slope)
      
  
  
  parameters = c("threshold","slope")
  errors = paste0(parameters, "_se")
  
  d = generate_summary(df,parameters)
  
  
  #ploting the distribution of parameter values:

  plotCPT_upper = d  %>% mutate(parameter = ifelse(name == "threshold","Threshold (α)",
                                                   ifelse(name == "slope","Slope (β)",NA))) %>% 
    mutate(parameter = factor(parameter, levels = c("Threshold (α)", "Slope (β)"))) %>% 
    ggplot(aes(x = means,fill = color_dist, col = color_outline))+
    geom_point(aes(y = -0.05),shape = 20, show.legend = FALSE, alpha = 0.25, size = 3,
               position = position_jitter(height = 0.02, seed = 123))+
    geom_density(aes(y=after_stat(scaled)),show.legend = FALSE, alpha = .60)+
    geom_boxplot(aes(y = 0.05),notch = TRUE, width = 0.05, alpha = .6, outlier.shape = NA, show.legend = FALSE)+
    facet_wrap(~parameter, scales = "free", ncol = 1)+
    ylab("Scaled Density")+
    xlab("Parameter value")+
    ggtitle("Parameter distribution")+
    theme_classic()+
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank())+
    scale_fill_manual(values = color_dist)+
    scale_color_manual(values = color_outline)+
    theme(plot.title = element_text(hjust = 0.5),
          text = element_text(family = "sans",size = 12))
  

  #threshold function for PSI on cold:
  
  threshold_function_psi = function(x,threshold,slope){
    
    return(1/(1+exp(-(slope)*(threshold-x))))
    
  }
  
  #temperatures to plot:
  xs = seq(0,30,by = 1)
  
  
  #grouplevel estimates 
  f = d %>% group_by(name) %>% summarize(value = mean(means)) %>% pivot_wider()
  dd = data.frame(xs = xs) %>% 
    mutate(y = threshold_function_psi(xs,f$threshold,f$slope))
  
  

  
  #subjectwise means (grey lines)
  subjectwise_means = d %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(x = list(xs),
           y = list(threshold_function_psi(xs,means_threshold ,means_slope))) %>% unnest()
  
  
  #again as with plot 3 we get a more finegrained interval and many simulations to estimate temperature at p = 0.5 and the uncertainty associated with it
  xs = seq(0,30,by = 0.05)
  n_sim = 5000
  
  #wrangling and bootstrapping
  data_forplot3lower = d %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(threshold_draw = list(rnorm(n_sim,means_threshold, se_threshold)),
           slope_draw = list(rnorm(n_sim,means_slope, se_slope)),
           id = list(1:n_sim),
    ) %>% 
    ungroup() %>% 
    unnest() %>% 
    group_by(id) %>% 
    summarize(mean_threshold = mean(threshold_draw),
              mean_slope = mean(slope_draw)
    ) %>% 
    rowwise() %>% 
    mutate(x = list(xs),
           y = list(threshold_function_psi(xs,mean_threshold,mean_slope)))  %>% 
    unnest()
  
  # getting the confidence interval at p = 0.5
  ddx = data_forplot3lower %>% filter(y < 0.501 & y>0.499)
  
  interval = data.frame(hdi(ddx$x, ci = 0.95) %>% mutate(mean = mean(ddx$x)))
  
  
  # less simulations are needed for plotting:
  
  n_sim = 100
  
  #combine with group level with uncertainty
  plotCPT_lower = d %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(threshold_draw = list(rnorm(n_sim,means_threshold, se_threshold)),
           slope_draw = list(rnorm(n_sim,means_slope, se_slope)),
           id = list(1:n_sim),
    ) %>% 
    ungroup() %>% 
    unnest() %>% 
    group_by(id) %>% 
    summarize(mean_threshold = mean(threshold_draw),
              mean_slope = mean(slope_draw)
    ) %>% 
    rowwise() %>% 
    mutate(x = list(xs),
           y = list(threshold_function_psi(xs,mean_threshold,mean_slope)))  %>% 
    unnest() %>%
    ggplot()+
    geom_line(data = subjectwise_means, aes(x = x, y, group = sub), col = "black", alpha = 0.25)+
    geom_line(aes(x = x, y = y, group = id), col = color_dist, alpha = 0.75)+
    scale_x_continuous(breaks = scales::pretty_breaks(n = 5))+
    geom_line(data = dd, aes(x = xs, y), col = "#0c79a6")+
    geom_segment(data = data.frame(),aes(x = 0, y = 0.50, xend = 5.55, yend = 0.50), col = color_outline, linetype = 2)+ 
    geom_segment(data = data.frame(),aes(x = 5.55, y = 0, xend = 5.55, yend = 0.50), col = color_outline, linetype = 2)+ 
    theme_classic()+
    scale_y_continuous(expand = c(0, 0), limits = c(0, 1), breaks = c(0,0.25,0.5,0.75,1))+
    ggtitle("Cold Pain Thresholds")+
    theme(plot.title = element_text(hjust = 0.5),
          text = element_text(family = "sans",size = 12))+
    ylab("Burning Probability")+
    xlab("Cold Temperature °C")

  
  
  
  supplementary_plot = plotCPT_upper+ plotCPT_lower
  supplementary_plot
  return(list(supplementary_plot, interval))
  
}

# same as for the cold pain threshold just with heat:
HPT_plot = function(){
  
  #colors
  color_dist = "#f26c4f"
  color_outline = "#a51214"
  
  #data wrangling and getting the estimates
  df <- read.csv(here::here("data","psi.csv")) %>% 
    filter(ses == 1 & quality == "warm")%>% 
    dplyr::rename(mean_threshold = threshold,
                  mean_slope = slope)
  
  
  
  parameters = c("threshold","slope")
  errors = paste0(parameters, "_se")
  
  d = generate_summary(df,parameters)
  
  #plotting the distribution of the parameters
  
  plotHPT_upper = d  %>% mutate(parameter = ifelse(name == "threshold","Threshold (α)",
                                                   ifelse(name == "slope","Slope (β)",NA))) %>% 
    mutate(parameter = factor(parameter, levels = c("Threshold (α)", "Slope (β)"))) %>% 
    ggplot(aes(x = means,fill = color_dist, col = color_outline))+
    geom_point(aes(y = -0.05),shape = 20, show.legend = FALSE, alpha = 0.25, size = 3,
               position = position_jitter(height = 0.02, seed = 123))+
    geom_density(aes(y=after_stat(scaled)),show.legend = FALSE, alpha = .60)+
    geom_boxplot(aes(y = 0.05),notch = TRUE, width = 0.05, alpha = .6, outlier.shape = NA, show.legend = FALSE)+
    facet_wrap(~parameter, scales = "free", ncol = 1)+
    ylab("Scaled Density")+
    xlab("Parameter value")+
    ggtitle("Parameter distribution")+
    theme_classic()+
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank())+
    scale_fill_manual(values = color_dist)+
    scale_color_manual(values = color_outline)+
    theme(plot.title = element_text(hjust = 0.5),
          text = element_text(family = "sans",size = 12))
  
  #using ggh4x for the scaling of the different facets
  
  plotHPT_upper = plotHPT_upper+
    facetted_pos_scales(
      x = list(
        parameter == "Threshold (α)" ~ scale_x_continuous(limits = c(30, 60), breaks = c(30,40,50,60)),
        parameter == "Slope (β)" ~ scale_x_continuous(limits = c(0, 2), breaks = c(0,1,2))
      )
    )
  
  
  
  #function used for PSI on heat:
  
  threshold_function_psi = function(x,threshold,slope){
    
    return(1/(1+exp(-(slope)*(x-threshold))))
    
  }
  
  #temperatures
  
  xs = seq(30,60,by = 1)
  
  
  #grouplevel
  f = d %>% group_by(name) %>% summarize(value = mean(means)) %>% pivot_wider()
  dd = data.frame(xs = xs) %>% 
    mutate(y = threshold_function_psi(xs,f$threshold,f$slope))
  
  

  #subjectwise means (grey lines)
  subjectwise_means = d %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(x = list(xs),
           y = list(threshold_function_psi(xs,means_threshold ,means_slope))) %>% unnest()
  
  
  #gettin bootstrapped temperature at p = 0.5
  
  xs = seq(30,60,by = 0.05)
  n_sim = 5000
  
  data_forplot3lower = d %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(threshold_draw = list(rnorm(n_sim,means_threshold, se_threshold)),
           slope_draw = list(rnorm(n_sim,means_slope, se_slope)),
           id = list(1:n_sim),
    ) %>% 
    ungroup() %>% 
    unnest() %>% 
    group_by(id) %>% 
    summarize(mean_threshold = mean(threshold_draw),
              mean_slope = mean(slope_draw)
    ) %>% 
    rowwise() %>% 
    mutate(x = list(xs),
           y = list(threshold_function_psi(xs,mean_threshold,mean_slope)))  %>% 
    unnest()
  
  
  ddx = data_forplot3lower %>% filter(y < 0.501 & y>0.499)
  
  interval = data.frame(hdi(ddx$x, ci = 0.95) %>% mutate(mean = mean(ddx$x)))
  
  
  #less sim for plot:
  
  n_sim = 100
  
  #combine with group level with uncertainty
  plotHPT_lower = d %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(threshold_draw = list(rnorm(n_sim,means_threshold, se_threshold)),
           slope_draw = list(rnorm(n_sim,means_slope, se_slope)),
           id = list(1:n_sim),
    ) %>% 
    ungroup() %>% 
    unnest() %>% 
    group_by(id) %>% 
    summarize(mean_threshold = mean(threshold_draw),
              mean_slope = mean(slope_draw)
    ) %>% 
    rowwise() %>% 
    mutate(x = list(xs),
           y = list(threshold_function_psi(xs,mean_threshold,mean_slope)))  %>% 
    unnest() %>%
    ggplot()+
    geom_line(data = subjectwise_means, aes(x = x, y, group = sub), col = "black", alpha = 0.25)+
    geom_line(aes(x = x, y = y, group = id), col = color_dist, alpha = 0.75)+
    geom_line(data = dd, aes(x = xs, y), col = color_outline)+
    geom_segment(data = data.frame(),aes(x = 30, y = 0.50, xend = 44.4, yend = 0.50), col = color_outline, linetype = 2)+ 
    geom_segment(data = data.frame(),aes(x = 44.4, y = 0, xend = 44.4, yend = 0.50), col = color_outline, linetype = 2)+ 
    theme_classic()+
    scale_y_continuous(expand = c(0, 0), limits = c(0, 1), breaks = c(0,0.25,0.5,0.75,1))+
    scale_x_continuous(breaks = scales::pretty_breaks(n = 5))+
    ggtitle("Heat Pain Thresholds")+
    theme(plot.title = element_text(hjust = 0.5),
          text = element_text(family = "sans",size = 12))+
    ylab("Burning Probability")+
    xlab("Warm Temperature °C")
  
  supplementary_plot = plotHPT_upper+ plotHPT_lower
  
  return(list(supplementary_plot, interval))
  
}

# plot 7 (responsivity index)
plot7 = function(){
  
  #getting data:
  df = prep_data(per_threshold = T)
  
  # colors for plot: ()
  colors = c("#916eca")
  
  
  #wrangle data to fit the plot
  
  dd50 = df[[2]] %>% mutate(Burning_prob  = ifelse(Burning_prob  == 0.5, "0.50",Burning_prob )) %>%
    filter(Burning_prob  == "0.50") %>% 
    dplyr::rename(Burning_Probability = Burning_prob ) %>% 
    mutate(IDs = ID_50, prob = "0.50") %>% 
    arrange(mean_continous_responsiveness)
  
  #plot:
  plot7 = rbind(dd50) %>% dplyr::rename(Burning_probability = prob) %>%  ggplot()+ 
    geom_pointrange(aes(y = IDs, x = mean_continous_responsiveness, xmin = mean_continous_responsiveness-se_continous_responsiveness, xmax = mean_continous_responsiveness+se_continous_responsiveness, col = Burning_probability))+
    ylab("Participants ordered by Responsivity index")+
    xlab("Responsivity index")+
    theme_classic()+geom_vline(xintercept = 0, linetype = 2)+scale_color_manual(values = colors[1])+
    theme(
      legend.position = c(1, .50),
      legend.justification = c("right", "top"),
      legend.box.just = "right",
      legend.margin = margin(6, 6, 6, 6),
      text = element_text(family = "sans",size = 12)
    )+
    labs(color = "Burning Probability")
  
  plot7
  
  
  return(plot7)
  
}


# Plot 5

plot5 = function(){
  
  # get data:
  df = prep_data(per_threshold = F)
  
  df1 = df
  
  # colors:
  
  blue <- c("#add8e6")
  red <- c("#f26c4f")
  purple <- c("#a47ab7")
  
  #making the data factors:
  df1$Quartile = as.factor(df1$Quartile)
  df1$Burning_prob = as.factor(df1$Burning_prob)
  
  # renaming the levels
  levels(df1$Quartile) = c("First","Second","Third")
  levels(df1$Stimulus) = c("Cold","TGI","Warm")
  levels(df1$Burning_prob) = c("0.25","0.50","0.75")
  
  # function for the facets 
  tag_facet2 <- function(p, tag_pool = letters, x = -Inf, y = Inf, hjust = -0.5, vjust = 1.5, family = "", ...) {
    
    gb <- ggplot_build(p)
    lay <- gb$layout$layout
    tags <- cbind(lay, label = toupper(paste0(tag_pool[lay$PANEL])), x = x, y = y)
    
    p + geom_text(data = tags, aes_string(x = "x", y = "y", label = "label"), ..., hjust = hjust, 
                  vjust = vjust, family = family, inherit.aes = FALSE)
  }
  
  # plotting plot 5
  
  plot5 = df1 %>% dplyr::rename("VAS: Cold" = VAS_Cold, "VAS: Warm" = VAS_Warm,"VAS: Burn" = VAS_Burn) %>%
    pivot_longer(cols = c(`VAS: Cold`,`VAS: Warm`,`VAS: Burn`), values_to = "Ratings",names_to = "RatingScale") %>% 
    group_by(ID,Stimulus,Burning_prob,Quartile, RatingScale) %>% 
    summarize(mean = 100*mean(Ratings)) %>% 
    dplyr::rename("Stimulus:" = Stimulus, "Quartile:" = Quartile) %>% 
    ggplot() +
    geom_boxplot(aes(x = Burning_prob, y = mean, fill=`Stimulus:`, shape=`Quartile:`, alpha=`Quartile:`),
                 outlier.color = NA, position = position_dodge(width = 0.8), width = 0.6) +
    geom_point(aes(x = Burning_prob, y = mean, fill = `Stimulus:`, group = `Quartile:`),shape = 21,col ="black",
               position = position_jitterdodge(jitter.width = 0.1),
               size = 1.5, alpha = .5)+
    
    
    
    stat_summary(aes(x = Burning_prob, y = mean, group = `Stimulus:`),
                 fun = median, geom = "line", position = position_dodge(width = 0.8), alpha = 1, color = "black", size = 1)+
    facet_grid(RatingScale ~ `Stimulus:`, labeller = label_value)+
    xlab("Burning probability")+ylab(paste("Mean VAS"))+
    theme_classic()+
    scale_y_continuous(expand = c(0, 0), limits = c(-4, 104), breaks = c(0,25,50,75,100))+
    theme(plot.title = element_text(hjust = 0.5),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(), 
          axis.line = element_line(colour = "black"),
          legend.position = "bottom",
          strip.text.x = element_blank(),
          axis.text.x = element_text(size=12),
          axis.text.y = element_text(size=10),
          text = element_text(family = "sans",size = 12)
    )+
    guides(fill = guide_legend(title = "Stimulus:", order = 1),
           color = guide_legend(title = "Stimulus:", order = 1),
           alpha = guide_legend(title = "Quartile:", order = 2,values = c(.2, .5, .8),override.aes = list(fill = "black")),
           shape = guide_legend(title = "Quartile:", order = 2))+
    scale_color_manual(values = c(blue[1], purple[1], red[1])) +
    scale_fill_manual(values = c(blue[1], purple[1], red[1]))
  
  
  plot5 = tag_facet2(plot5)
  plot5
  
  return(plot5)
}


# plot 6 
plot6 = function(){
  
  # get data:
  df = prep_data(per_threshold = F)
  
  df1 = df
  
  # colors:
  blue <- c("#add8e6")
  red <- c("#f26c4f")
  purple <- c("#a47ab7")
  
  
  #The cold warm ratio:
  
  df1$ColdOrWarm_ratio <- df1$VAS_Cold / (df1$VAS_Cold + df1$VAS_Warm) 
  
  #Address the rare cases where neither cold nor warm sensations were experienced, replacing NAs
  df1$ColdOrWarm_ratio[is.na(df1$ColdOrWarm_ratio)] <- NA
  
  #factors and names
  df1$Quartile = as.factor(df1$Quartile)
  df1$Burning_prob = as.factor(df1$Burning_prob)
  
  levels(df1$Quartile) = c("First","Second","Third")
  levels(df1$Stimulus) = c("Cold","TGI","Warm")
  levels(df1$Burning_prob) = c("0.25","0.50","0.75")
  
  # plot
  plot6 = df1  %>% group_by(ID,Stimulus,Burning_prob,Quartile) %>% 
    dplyr::rename("Stimulus:" = Stimulus, "Quartile:" = Quartile, "Burning probability:" = Burning_prob)  %>% summarize(mean = mean(ColdOrWarm_ratio)) %>% 
    ggplot() +
    geom_boxplot(aes(x = `Quartile:`, y = mean, fill = `Stimulus:`, shape = `Burning probability:`, alpha = `Burning probability:`),
                 outlier.color = NA, position = position_dodge(width = 0.8), width = 0.6)+
    geom_point(aes(x = `Quartile:`, y = mean, fill = `Stimulus:`, group=`Burning probability:`),
               shape = 21, col ="black",
               position = position_jitterdodge(jitter.width = 0.1),
               size = 1.5, alpha = 0.5)+
    stat_summary(aes(x = `Quartile:`, y = mean, group = `Stimulus:`),
                 fun = median, geom = "line", position = position_dodge(width = 0.8), alpha = 1, color = "black", size = 1)+
    #geom_line(data = linedata, aes(x = Burning_prob, y = median, color = `Stimulus:`, shape = `Quartile:`, alpha = `Quartile:`))+
    facet_grid(. ~ `Stimulus:`, scales = "free_y", labeller = label_value) +
    xlab("Quartile") +
    scale_y_continuous(expand = c(0, 0), limits = c(-0.01, 1.01), breaks = c(0,0.25,0.50,0.75,1))+
    ylab(paste("Thermosensory index")) +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(), 
          axis.line = element_line(colour = "black"),
          legend.position = "bottom",
          strip.text.x = element_blank(),
          axis.text.x = element_text(size=12),
          axis.text.y = element_text(size=10),
          legend.key = element_blank(),
          text = element_text(family = "sans",size = 12)
    ) +
    scale_color_manual(values = c(blue[1], purple[1], red[1])) +
    scale_fill_manual(values = c(blue[1], purple[1], red[1])) +
    scale_alpha_manual(values = c(.2, .5, .8), guide = guide_legend(override.aes = list(fill = "black")))
  
  plot6
  
  return(plot6)
}



# plot 4 

# arguments are:
#lowest point of the facets
#highest point of the facets
#highest point of the facets

#subjects to plot:
plot4 = function(tminwarm,tmaxwarm, subers){

  
  # subjects from experiment 1 (import to cut the curve properly:)
  exp1_subs = unique(prep_data(F)$ID[which(prep_data(F)$experiment == 1)])
  
  pacman::p_load(ggplot2, tidyverse, DHARMa, glmmTMB, reshape,gamlss,scales, flextable,gghalves, patchwork,bayestestR)

  source(here::here("scripts","Utility_functions.R"))
  source(here::here("scripts","plots.R"))
  
  #subjects
  
  #all subs 
  
  
  # First we get warm and cold pain threshold functions:
  
  #get HPT
  df <- read.csv(here::here("data","psi.csv")) %>% 
    filter(ses == 1 & quality == "warm")%>% 
    dplyr::rename(mean_threshold = threshold,
                  mean_slope = slope)
  
  parameters = c("threshold","slope")
  errors = paste0(parameters, "_se")
  
  hpt = generate_summary(df,parameters)
  
  
  #get CPT
  
  df <- read.csv(here::here("data","psi.csv")) %>% 
    filter(ses == 1 & quality == "cold")%>% 
    dplyr::rename(mean_threshold = threshold,
                  mean_slope = slope)
  
  
  parameters = c("threshold","slope")
  errors = paste0(parameters, "_se")
  
  cpt = generate_summary(df,parameters)
  
  
  # now we can make the outline of the plots with these first we need functions for making the graphs of the psychometrics!
  
  threshold_function_psi_cold = function(x,threshold,slope){
    
    return(1/(1+exp(-(slope)*(threshold-x))))
    
  }
  
  threshold_function_psi_warm = function(x,threshold,slope){
    
    return(1/(1+exp(-(slope)*(x-threshold))))
    
  }
  
  
  # x values for the cold
  xs = seq(0,30,by = 0.1)
  

  #subjectwise means
  cpt_tempwise = cpt %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(x = list(xs),
           y = list(threshold_function_psi_cold(xs,means_threshold ,means_slope))) %>% unnest() %>% mutate(quality = "cold")
  
  
  #x-values for warm
  xs = seq(30,tmaxwarm,by = 0.1)
  
  
  #subjectwise means
  hpt_tempwise = hpt %>% 
    pivot_wider(values_from = c("means","se")) %>%  
    rowwise() %>% 
    mutate(x = list(xs),
           y = list(threshold_function_psi_cold(xs,means_threshold ,means_slope))) %>% unnest() %>% mutate(quality = "warm")
  
  

  #loading the binary responses ( points of the plot)  

  binary_resp <- read.csv(here::here("data","fastTrl.csv")) %>% filter(ses == 1) %>% mutate(resp = ifelse(temp_cw == 1, "warm","cold"))
  
  

  
  # Now lets cut the curves for each subject!
  
  #loading the 3 curves for each subject:
  curves = read.csv(here::here("data","fastEst.csv")) %>% 
    filter(ses == 1)%>% filter(temp_warm < tmaxwarm)
  
  #then cutting them based on experiment and therefore threshold of cold pain and heat pain
  
  painthresholds = rbind(cpt %>% pivot_wider(values_from = c("means","se")) %>% mutate(threshold_quality = "cold"),
                         hpt %>% pivot_wider(values_from = c("means","se")) %>% mutate(threshold_quality = "warm")) %>% 
    dplyr::select(means_threshold, means_slope,sub,threshold_quality) %>% pivot_wider(values_from = c("means_threshold","means_slope"), names_from = "threshold_quality")
  
  curves_and_thresh = inner_join(curves,painthresholds)
  
  
  #firstly for exp2 where the curve is cut such that the pain thresholds of cold and heat match the threshold probabilities:
  curves_exp2 = curves_and_thresh %>% filter(!sub %in% exp1_subs) %>% 
    group_by(sub,threshold) %>% 
    mutate(prob_burn_cold = threshold_function_psi_cold(temp_cold,means_threshold_cold,means_slope_cold),
           prob_burn_warm = threshold_function_psi_warm(temp_warm,means_threshold_warm,means_slope_warm)) %>% 
    mutate(inside_cold = ifelse(prob_burn_cold*100 > threshold, T, F),
           inside_warm = ifelse(prob_burn_warm*100 > threshold, T, F))%>% 
    filter(sub %in% subers & inside_cold == F & inside_warm == F)
  
  #secondly for exp1 where the curve is cut at 0.5 for CPT and HPT.
  curves_exp1 = curves_and_thresh %>% filter(sub %in% exp1_subs) %>% 
    group_by(sub,threshold) %>% 
    mutate(prob_burn_cold = threshold_function_psi_cold(temp_cold,means_threshold_cold,means_slope_cold),
           prob_burn_warm = threshold_function_psi_warm(temp_warm,means_threshold_warm,means_slope_warm)) %>% 
    mutate(inside_cold = ifelse(prob_burn_cold*100 > 50, T, F),
           inside_warm = ifelse(prob_burn_warm*100 > 50, T, F))%>% 
    filter(sub %in% subers & inside_cold == F & inside_warm == F)
  
    #binding the curves into one dataframe:
  curves = rbind(curves_exp1,curves_exp2)
  
  
  
  # now for coloring the curves! 
  
  calculate_proportion <- function(x_input, y_input, binned_x, binned_y, responses) {
    
    # Calculate distances between input point and binned points
    distances <- sqrt((binned_x - x_input)^2 + (binned_y - y_input)^2)
    
    # Calculate weights based on distances
    weights <- 1 / (distances^2 + 1)  # Adding 1 to avoid division by zero
    
    # Normalize weights
    weights <- weights / sum(weights)
    
    # Calculate weighted proportions of "cold" and "warm" responses
    cold_proportion <- sum(weights * (responses == "cold"))
    warm_proportion <- sum(weights * (responses == "warm"))
    
    return(warm_proportion)
  }

  #test  function
  
  #binary_resp_sub3 = binary_resp %>% filter(sub == 3)
  #calculate_proportion(25,40,binary_resp_sub3$cold_t,binary_resp_sub3$warm_t,binary_resp_sub3$resp)
  
  
  #initalize dataframe
  color_curves = data.frame()
  
  #loop through subjects
  for(subb in subers){
    binary_resp_subb = binary_resp %>%  filter(sub == subb)
    
    q = curves %>% filter(sub == subb) %>% rowwise() %>% 
      mutate(color = calculate_proportion(temp_cold,temp_warm,binary_resp_subb$cold_t,binary_resp_subb$warm_t,binary_resp_subb$resp)) %>% ungroup()
    
    color_curves = rbind(color_curves,q)
  }
  
  
  #here one might change the thresholding for when its cold and or warm or others for now just over 0.5 its warm and else cold
  color_curves = color_curves %>% mutate(colors = as.factor(ifelse(color > 0.5, 1, 0)))
  
  
  
  
  #lastly we need the black curve!
  
  library(R.matlab)
  
  mat_data <- readMat(here::here("data","allWarmTCW.mat"))[[1]]
  
  mat_data = data.frame(t(mat_data))
  
  names(mat_data) =  c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
                       19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
                       35, 36, 37, 38, 39, 40, 41, 42, 43)  
  
  
  mat_data = mat_data %>% mutate(x = seq(0,30,0.1)) %>% pivot_longer(cols = -x, names_to = "sub",values_to = "black_y") %>% 
    filter(black_y < tmaxwarm) %>% 
    mutate(sub = as.factor(sub))
  
  
  
  # Now for the plotting!:
  
  plot4 = data.frame(sub = as.factor(subers))  %>% ggplot()+
    
    #black curve:
    geom_line(data = mat_data %>% filter(sub %in% subers)%>% mutate(sub = as.factor(sub)), aes(x = x, y = black_y), col ="black", linetype = 2)+
    
    #curve!
    geom_point(data =  color_curves%>% mutate(sub = as.factor(sub)), aes(x = temp_cold, y = temp_warm, group = threshold, color = colors),size = 0.5)+
    
    #binary resps (points)
    geom_point(data = binary_resp %>% filter(sub %in% subers)%>% mutate(sub = as.factor(sub)), aes(x = cold_t, y = warm_t, col = resp))+
    

    #extra
    scale_color_manual(values = c("#add8e6","#f26c4f","#add8e6","#f26c4f"))+
    theme_classic()+
    ylab("Warm Temperature (°C)")+
    xlab("Cold Temperature (°C)")+
    theme(legend.position = "none",
          text = element_text(family = "sans",size = 12))+
    coord_cartesian(ylim = c(tminwarm,tmaxwarm))+
    #      strip.background = element_blank(),        # this is the border of the facets
    #      strip.text.x = element_blank())+            # this is the labels in the facets
    facet_wrap(~sub)
  
  
  return(list(plot4))

}



# plot 7
Full_plot_7 = function(){
  
    #reading the data:
    
    alldata <- read.csv(here::here("data","vas.csv")) 
    
    alldata %>% pivot_longer(cols = c("VAS_Cold","VAS_Warm","VAS_Burn")) %>% filter(name == "VAS_Burn") %>% 
      group_by(Stimulus,ID,Burning_prob) %>% 
      dplyr::summarize(meanburn = mean(value, na.rm = T), seburn = sd(value,na.rm = T)/sqrt(n()),n =n()) %>% 
      ggplot(aes(x = Burning_prob, y = meanburn, col = Stimulus))+
      geom_pointrange(aes(ymin = meanburn - 2 * seburn, ymax = meanburn + 2 * seburn))+
      facet_wrap(~ID)+theme_classic()
    
    
    # Getting continuous responsiveness index:
    responders_50 <- alldata %>%
      filter(Stimulus != "NaN") %>%
      pivot_longer(cols = c("VAS_Cold","VAS_Warm","VAS_Burn")) %>% filter(Burning_prob == "0.5") %>% 
      group_by(ID, Stimulus) %>%
      dplyr::summarize(meanburn = mean(value, na.rm = T), seburn = sd(value,na.rm = T)/sqrt(n()))
    
    # want it in a wide format instead of long
    dfa <- responders_50 %>% pivot_wider(names_from = Stimulus, values_from = c("seburn","meanburn"))
    
    # define the responders as a continus variable that is defined as the burning rating on TGI minus the average burning rating on the cold and warm stimulus
    dfa$max <- ifelse(dfa$meanburn_Cold > dfa$meanburn_Warm, dfa$meanburn_Cold, dfa$meanburn_Warm)
    
    #get the uncertainty on this:
    dfa$max_se <- ifelse(dfa$meanburn_Cold > dfa$meanburn_Warm, dfa$seburn_Cold, dfa$seburn_Warm)
    
    # Mean of the difference which is the responsivity index
    dfa$mean_continous_responsiveness <- dfa$meanburn_TGI - dfa$max
    
    # and the uncertainty  
    dfa$se_continous_responsiveness <- sqrt((dfa$seburn_TGI)^2 + (dfa$max_se)^2)
    
    
    ids_order_50 = dfa %>% mutate(Burning_prob = "0.5") %>% 
      arrange(mean_continous_responsiveness) %>% 
      dplyr::select(mean_continous_responsiveness, ID, se_continous_responsiveness,Burning_prob)%>% ungroup()
    
    
    ################ 25
    
    alldata <- read.csv(here::here("data","vas.csv")) 
    
    # Getting continuous responsiveness index:
    responders_25 <- alldata %>%
      filter(Stimulus != "NaN") %>%
      pivot_longer(cols = c("VAS_Cold","VAS_Warm","VAS_Burn")) %>% filter(Burning_prob == "0.25") %>% 
      group_by(ID, Stimulus) %>%
      dplyr::summarize(meanburn = mean(value, na.rm = T), seburn = sd(value,na.rm = T)/sqrt(n()))
    
    # want it in a wide format instead of long
    dfa <- responders_25 %>% pivot_wider(names_from = Stimulus, values_from = c("seburn","meanburn"))
    
    # define the responders as a continus variable that is defined as the burning rating on TGI minus the average burning rating on the cold and warm stimulus
    dfa$max <- ifelse(dfa$meanburn_Cold > dfa$meanburn_Warm, dfa$meanburn_Cold, dfa$meanburn_Warm)
    
    #get the uncertainty on this:
    dfa$max_se <- ifelse(dfa$meanburn_Cold > dfa$meanburn_Warm, dfa$seburn_Cold, dfa$seburn_Warm)
    
    # Mean of the difference which is the responsivity index
    dfa$mean_continous_responsiveness <- dfa$meanburn_TGI - dfa$max
    
    # and the uncertainty  
    dfa$se_continous_responsiveness <- sqrt((dfa$seburn_TGI)^2 + (dfa$max_se)^2)
    
    
    ids_order_25 = dfa %>% mutate(Burning_prob = "0.25") %>% 
      arrange(mean_continous_responsiveness) %>% 
      dplyr::select(mean_continous_responsiveness, ID, se_continous_responsiveness,Burning_prob)%>% ungroup()
    
    
    
    ########################## 75
    
    alldata <- read.csv(here::here("data","vas.csv")) 
    
    # Getting continuous responsiveness index:
    responders_75 <- alldata %>%
      filter(Stimulus != "NaN") %>%
      pivot_longer(cols = c("VAS_Cold","VAS_Warm","VAS_Burn")) %>% filter(Burning_prob == "0.75") %>% 
      group_by(ID, Stimulus) %>%
      dplyr::summarize(meanburn = mean(value, na.rm = T), seburn = sd(value,na.rm = T)/sqrt(n()))
    
    # want it in a wide format instead of long
    dfa <- responders_75 %>% pivot_wider(names_from = Stimulus, values_from = c("seburn","meanburn"))
    
    # define the responders as a continus variable that is defined as the burning rating on TGI minus the average burning rating on the cold and warm stimulus
    dfa$max <- ifelse(dfa$meanburn_Cold > dfa$meanburn_Warm, dfa$meanburn_Cold, dfa$meanburn_Warm)
    
    #get the uncertainty on this:
    dfa$max_se <- ifelse(dfa$meanburn_Cold > dfa$meanburn_Warm, dfa$seburn_Cold, dfa$seburn_Warm)
    
    # Mean of the difference which is the responsivity index
    dfa$mean_continous_responsiveness <- dfa$meanburn_TGI - dfa$max
    
    # and the uncertainty  
    dfa$se_continous_responsiveness <- sqrt((dfa$seburn_TGI)^2 + (dfa$max_se)^2)
    
    
    ids_order_75 = dfa %>% mutate(Burning_prob = "0.75") %>% 
      arrange(mean_continous_responsiveness) %>% 
      dplyr::select(mean_continous_responsiveness, ID, se_continous_responsiveness,Burning_prob) %>% ungroup()
    
    
    allids = unique(ids_order_25$ID)
    
    
    ids_not_in50 = allids[!allids %in% ids_order_50$ID]
    
    databind = data.frame(mean_continous_responsiveness = rep(NA, length(ids_not_in50)), ID = ids_not_in50,
               se_continous_responsiveness = rep(NA, length(ids_not_in50)), Burning_prob = rep("0.5",length(ids_not_in50)))
    
    ids_order_50 = rbind(ids_order_50,databind)
    
    
    
    ids_not_in75 = allids[!allids %in% ids_order_75$ID]
    
    databind2 = data.frame(mean_continous_responsiveness = rep(NA, length(ids_not_in75)), ID = ids_not_in75,
                          se_continous_responsiveness = rep(NA, length(ids_not_in75)), Burning_prob = rep("0.5",length(ids_not_in75)))
    
    ids_order_75 = rbind(ids_order_75,databind2)
    
    
    ids_order_25 = ids_order_25 %>% mutate(IDS_order = ID)
    ids_order_50 = ids_order_50 %>% mutate(IDS_order = ID)
    ids_order_75 = ids_order_75 %>% mutate(IDS_order = ID)
    
    
    qq = rbind(ids_order_25,ids_order_50,ids_order_75)
    
    
    colors = c("#e0c2f2","#a478b8","#916eca")
    # the plot
    qq %>% group_by(Burning_prob) %>% arrange(mean_continous_responsiveness) %>% mutate(IDS = 1:n()) %>% ungroup() %>% dplyr::rename(Burning_probability = Burning_prob) %>% mutate(IDs = 1:nrow(.)) %>% 
      ggplot()+ 
      geom_pointrange(aes(y = IDS, x = mean_continous_responsiveness, xmin = mean_continous_responsiveness-se_continous_responsiveness, xmax = mean_continous_responsiveness+se_continous_responsiveness, col = Burning_probability))+
      ylab("Participants ordered for each threhold probability")+
      xlab("Responsivity index")+
      scale_y_continuous(limits = c(0,40))+
      theme_classic()+geom_vline(xintercept = 0, linetype = 2)+scale_color_manual(values = colors)+ theme(
        legend.position = c(1, .50),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6)
      )+
      labs(color = "Burning Probability")
    
    
  
}






