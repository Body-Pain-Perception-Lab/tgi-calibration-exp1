read_bids <- function(projdir,sub,ses,task,dat) {
  
  # Generate comprehensive list of file names
  filenames_list <- c()
  for (i in sub){
    sub_folder <- paste0('sub-', str_pad(i, 4, pad = "0"))
    for (j in ses){
      ses_folder <- paste0('ses-', str_pad(j, 2, pad = "0"))
      for (k in length(dat)){
        task_folder <- paste0('task-', task)
        dat_folder <- dat[k]
        filepath <- file.path(projdir, sub_folder, ses_folder, dat_folder)
        filenames <- file.path(filepath,paste0(sub_folder, '_', ses_folder, '_', task_folder, '_', dat_folder, '.tsv'))
        filenames_list <- append(filenames_list, filenames)
      }
    }
  }
  
  # Check which file names exist
  existing_files <- c()
  for (f in 1:length(filenames_list)) existing_files <- c(existing_files, file.exists(filenames_list[f]))
  existing_files
  
  # Import data from existing files
  df <- data.frame()
  for (f in 1:length(filenames_list)) if (existing_files[f] == TRUE) df <- rbind(df, read_tsv(filenames_list[f]))
  
  # Define factors
  df$sub_n <- as.factor(df$sub_n)
  df$ses_n <- as.factor(df$ses_n)
  
  return(df)
}