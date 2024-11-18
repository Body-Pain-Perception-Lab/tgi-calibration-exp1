
# Utility functions for getting the data in the desired format, reporting statistics and creating tables etc.

# Function to prepare the data
prep_data = function(per_threshold = F){
  
  #reading the data:
  
  alldata <- read.csv(here::here("data","vas.csv")) 

  # Getting continuous responsiveness index:
  responders <- alldata %>%
    filter(Stimulus != "NaN") %>%
    pivot_longer(cols = c("VAS_Cold","VAS_Warm","VAS_Burn")) %>% 
    group_by(ID, Stimulus) %>%
    dplyr::summarize(meanburn = mean(value, na.rm = T), seburn = sd(value,na.rm = T)/sqrt(n()))
  
  # want it in a wide format instead of long
  dfa <- responders %>% pivot_wider(names_from = Stimulus, values_from = c("seburn","meanburn"))
  
  # define the responders as a continus variable that is defined as the burning rating on TGI minus the average burning rating on the cold and warm stimulus
  dfa$max <- ifelse(dfa$meanburn_Cold > dfa$meanburn_Warm, dfa$meanburn_Cold, dfa$meanburn_Warm)
  
  #get the uncertainty on this:
  dfa$max_se <- ifelse(dfa$meanburn_Cold > dfa$meanburn_Warm, dfa$seburn_Cold, dfa$seburn_Warm)
  
  # Mean of the difference which is the responsivity index
  dfa$mean_continous_responsiveness <- dfa$meanburn_TGI - dfa$max
  
  # and the uncertainty  
  dfa$se_continous_responsiveness <- sqrt((dfa$seburn_TGI)^2 + (dfa$max_se)^2)
  
    
  # This is for plot7 if not F.

  if(per_threshold == F){
  
  #join it 
    df = inner_join(alldata,dfa)
    
    df = df %>% mutate(Burning_prob  = as.numeric(as.character(Burning_prob ))) %>% 
      dplyr::select(ID, Trial_N, Stimulus, Quartile, Burning_prob, Stim_dur, experiment,
                    VAS_Cold, VAS_Warm, VAS_Burn,Location) %>% 
      mutate(Stimulus = as.factor(Stimulus),
             Quartile = as.numeric(str_remove(Quartile, "L")))
    
  return(df)
  }else{

    alldata$Burning_prob  = as.factor(alldata$Burning_prob )

    dff = inner_join(alldata,dfa)
    
    dff = dff %>% arrange(ID,mean_continous_responsiveness)
    
    
    
    df3 = dff %>% filter(as.character(Burning_prob)== "0.50") %>% arrange(mean_continous_responsiveness)
    
    
    ids_order_50 = dff %>% filter(as.character(Burning_prob)== "0.5") %>% 
      arrange(mean_continous_responsiveness) %>% 
      dplyr::select(mean_continous_responsiveness, ID, se_continous_responsiveness,Burning_prob ) %>% 
      distinct()%>% 
      mutate(IDs_threshold50 = 1:n()) %>% .$ID
    
    
    dd = dff %>% 
      filter(as.character(Burning_prob )== "0.5") %>% 
      arrange(mean_continous_responsiveness) %>% 
      dplyr::select(mean_continous_responsiveness, ID, se_continous_responsiveness,Burning_prob ) %>% 
      distinct()
    
    dd$ID_50 = as.numeric(factor(dd$ID, levels = ids_order_50))

  }
  
  df = inner_join(alldata,dfa)
  
  df = df %>% mutate(Burning_prob  = as.numeric(as.character(Burning_prob ))) %>% 
    dplyr::select(ID, Trial_N, Stimulus, Quartile, Burning_prob, Stim_dur, experiment,
                  VAS_Cold, VAS_Warm, VAS_Burn) %>% 
    mutate(Stimulus = as.factor(Stimulus),
           Quartile = as.numeric(str_remove(Quartile, "L")))
  return(list(df,dd))  
}


#function take takes the models used in the study and makes a table of all regression coefficients.
get_main_tables <- function(model, round = 2) {
  
  #retrieve the fixed effects of the model
  
  if("Component" %in% names(data.frame(parameters::model_parameters(model)))){
    
    fixedeffecs <- parameters::model_parameters(model) %>%
      mutate(CI = NULL, CI_low = NULL, CI_high = NULL, df_error = NULL) %>%
      dplyr::rename(parameter = Component) %>%
      dplyr::select(parameter, everything()) %>% 
      mutate(parameter = ifelse(str_detect(parameter, "conditional"), "μ", ifelse(str_detect(parameter, "sigma"), "σ", ifelse(str_detect(parameter, "tau"), "τ", "ν"))))
    #renaming
    names(fixedeffecs) <- c("parameter","contrast", "\u03B2", "SE", "t", "p")
    #formular for the model (i.e. the math)
    formular <- as.character(formula(model))
  }else{
    
    fixedeffecs <- parameters::model_parameters(model) %>%
      mutate(CI = NULL, CI_low = NULL, CI_high = NULL, df_error = NULL, Component = "conditional") %>%
      dplyr::rename(parameter = Component) %>%
      dplyr::select(parameter, everything()) %>% 
      mutate(parameter = ifelse(str_detect(parameter, "conditional"), "μ", ifelse(str_detect(parameter, "sigma"), "σ", ifelse(str_detect(parameter, "tau"), "τ", "ν"))))
    #renaming
    names(fixedeffecs) <- c("parameter","contrast", "\u03B2", "SE", "t", "p")
    #formular for the model (i.e. the math)
    formular <- as.character(formula(model))
  }
  #get family
  family = family(model)[2]
  link = model$mu.link
  
  if(family == "Beta Inflated"){
    family = "ZOIB"
  }
  
  #formating and rounding the numeric values:
  fixedeffecs[, 3:6] <- apply(fixedeffecs[, 3:6], 2, function(x) formatC(x, format = "g", digits = round))
  #the table
  ft <- flextable(fixedeffecs) %>%
    add_header_row(values = paste0(formular[2], formular[1], formular[3], ", ", family, "(link = ",link,")"), colwidths = c(ncol(fixedeffecs))) %>%
    #add_header_lines(values = title) %>%
    width(j = c(1, 3:ncol(fixedeffecs)), width = 1) %>%
    width(j = 2, width = 1.8) %>%
    fontsize(size = 10, part = "all") %>%
    theme_vanilla() %>%
    align(i = 1:2, j = NULL, align = "center", part = "header")
  return(ft)
}

# convinient function to make p-values to desired format
make_pvalue <- function(p_value) {
  if (p_value > 0.05) {
    p_value <- round(p_value, 2)
    p <- paste("p = ", p_value)
  }
  if (p_value < 0.05) {
    p <- "p < .05 "
  }
  if (p_value < 0.01) {
    p <- "p < .01"
  }
  if (p_value < 0.001) {
    p <- "p < .001"
  }
  if (p_value < 0.0001) {
    p <- "p < .0001"
  }
  return(p)
}


# for reporting statistics:
# takes statistics made in the analysis markdown and displays the results:
make_new_reporting = function(stats, number, Z, inc_df = F){
  
  if(Z){
    z_stat = stats$stat[number]
    p_value = stats$p[number]
    ci = list(low = as.numeric(stats$beta[number])-2*as.numeric(stats$std[number]), high = as.numeric(stats$beta[number])+2*as.numeric(stats$std[number]))
    beta_stat = stats$beta[number]
    if(inc_df){
      text = paste0("$\\", "beta", "$"," = ",beta_stat,", 95% CI = [", ci$low, " ; ", ci$high,"]",", Z = ", z_stat, ", ", make_pvalue(p_value))
    }
    
    return(text)
    
  }else if(!Z){
    beta_stat = sprintf("%.2f", stats$beta[number])
    t_stat = sprintf("%.2f", stats$stat[number])
    p_value = stats$p[number]
    ci = list(low = sprintf("%.2f", stats$CI_low[number]), high = sprintf("%.2f", stats$CI_high[number]))
    df = sprintf("%.2f", stats$df[number])
    if(inc_df){
      text = paste0("$\\", "beta", "$"," = ",beta_stat, ", 95% CI = [", ci$low, "; ", ci$high,"]",", t(",df,") = ",t_stat,", ",make_pvalue(p_value))
    }else{
      text = paste0("$\\", "beta", "$"," = ",beta_stat, ", 95% CI = [", ci$low, "; ", ci$high,"]",", ",make_pvalue(p_value))
    }
    return(text)
  }
  return("error")
}


summary_stats_zoib_new <- function(model, coefficients, round, part, intercept = FALSE) {
  
  dfdataframe = parameters::model_parameters(model)
  if(part == "mu"){
    part = "conditional"
  }
  
  if("Component" %in% colnames(data.frame(dfdataframe))){
    dd = data.frame(dfdataframe) %>% filter(Component == part)
  }else{
    dd = data.frame(dfdataframe)
  }
  if(intercept){
    dd = dd[1:(coefficients+1),]
  }else{
    dd = dd[2:(coefficients+1),]
  }
  
  beta = round(dd$Coefficient,round)
  se = round(dd$SE, round)
  CI_low = round(dd$CI_low, round)
  CI_high = round(dd$CI_high, round)
  stat = round(dd$t, round)
  p = round(dd$p, round)
  df = round(dd$df_error, round)
  
  return(list(beta = beta, se = se, stat = stat,CI_low = CI_low,CI_high = CI_high,df = df, p = p))
}

#getting proportions for the methods section.

get_prop = function(value,df, quality){
  
  df1 = df %>% group_by(ID) %>% mutate(number = get(paste0("VAS_",quality)) == value) %>% summarize(prop = sum(number) / n())
  df1 = df1 %>% summarize(mean_prop = mean(prop), se_prop = sd(prop, na.rm = T)/sqrt(n()))
  
  return(df1)
}


