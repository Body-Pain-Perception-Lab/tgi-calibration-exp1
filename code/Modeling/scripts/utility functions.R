#function to extract estimates of the models
summary_stats_zoib = function(model, coefficients, round, part, intercept = FALSE){
  
  if(intercept == TRUE & part == "mu"){
    a = summary(model)
    coef = a[1,1]
    std =a[1,2]
    stat = a[1,3]
    p = a[1,4]
    
    return(list(beta = round(coef,round),std = round(std,round),stat = round(stat,round),p = p))
  }
  
  if(intercept == TRUE & part == "nu"){
    a = summary(model)
    coef = a[1+2+coefficients,1]
    std =a[1+2+coefficients,2]
    stat = a[1+2+coefficients,3]
    p = a[1+2+coefficients,4]
    
    return(list(beta = round(coef,round),std = round(std,round),stat = round(stat,round),p = p))
  }
  
  if(intercept == TRUE & part == "tau"){
    a = summary(model)
    coef = a[2+2+2*coefficients,1]
    std =a[2+2+2*coefficients,2]
    stat = a[2+2+2*coefficients,3]
    p = a[2+2+2*coefficients,4]
    
    return(list(beta = round(coef,round),std = round(std,round),stat = round(stat,round),p = p))
  }
  
  if(part == "mu"){
    index = 1
  }else if (part == "nu"){
    index = 1+2+coefficients
  } else if (part == "tau"){
    index = 2+2+2*coefficients
  }else{
    print("Give correct part")
  }
  
  a = summary(model)
  coef = array(NA, coefficients)
  std = array(NA, coefficients)
  stat = array(NA, coefficients)
  p = array(NA, coefficients)
  
  for (i in 1:coefficients){
    coef[i] = a[index+i,1]
    std[i] = a[index+i,2]
    stat[i] = a[index+i,3]
    p[i] = a[index+i,4]
    
  }
  
  return(list(beta = round(coef,round),std = round(std,round),stat = round(stat,round),p = p))
  
  
}

#function to calculate probabilities of rating 1 or 0 given a model:

get_prob = function(model, data, what){

  ### doing the same for the zero part and interpretning the results:
  
  coef = summary_stats_zoib(model, length(names(model$mu.coefficients))-2,2,what,intercept = FALSE)
  
  intercept = summary_stats_zoib(model, length(names(model$mu.coefficients))-2,2,what,intercept = TRUE)
  
  ## recalculating the probabilities (have to take the intercept into account because of the non-linear logit transformation)
  
  meaneffect_procent_25_to_50 = brms::inv_logit_scaled(intercept$beta)-brms::inv_logit_scaled(intercept$beta+coef$beta[4])
  
  meaneffect_procent_25_to_75 = brms::inv_logit_scaled(intercept$beta)-brms::inv_logit_scaled(intercept$beta+coef$beta[5])
  
  plus_2d_procent_25_to_50 = brms::inv_logit_scaled(intercept$beta)-brms::inv_logit_scaled(intercept$beta+coef$beta[4]-2*coef$std[4])
  minus_2d_procent_25_to_50 = brms::inv_logit_scaled(intercept$beta)-brms::inv_logit_scaled(intercept$beta+coef$beta[4]+2*coef$std[4])
  
  prob50_low = brms::inv_logit_scaled(intercept$beta)-plus_2d_procent_25_to_50
  prob50_med = brms::inv_logit_scaled(intercept$beta)-meaneffect_procent_25_to_50
  prob50_high = brms::inv_logit_scaled(intercept$beta)-minus_2d_procent_25_to_50
  
  
  
  
  meaneffect_procent_25_to_75 = brms::inv_logit_scaled(intercept$beta)-brms::inv_logit_scaled(intercept$beta+coef$beta[5])
  plus_2d_procent_25_to_75 = brms::inv_logit_scaled(intercept$beta)-brms::inv_logit_scaled(intercept$beta+coef$beta[5]-2*coef$std[5])
  minus_2d_procent_25_to_75 = brms::inv_logit_scaled(intercept$beta)-brms::inv_logit_scaled(intercept$beta+coef$beta[5]+2*coef$std[5])
  
  prob75_low = brms::inv_logit_scaled(intercept$beta)-plus_2d_procent_25_to_75
  prob75_med = brms::inv_logit_scaled(intercept$beta)-meaneffect_procent_25_to_75
  prob75_high = brms::inv_logit_scaled(intercept$beta)-minus_2d_procent_25_to_75
  
  
  prob25_low = brms::inv_logit_scaled(intercept$beta-2*intercept$std)
  prob25_med = brms::inv_logit_scaled(intercept$beta)
  prob25_high = brms::inv_logit_scaled(intercept$beta+2*intercept$std)
  
  
  #write up
  return(list("25% probability" = c(prob25_low,prob25_med, prob25_high),"50% probability" = c(prob50_low,prob50_med, prob50_high),"75% probability" = c(prob75_low,prob75_med, prob75_high)))
}
