read_bids <- function(projdir, sub, ses, task, dat, save) {
  
  # Create all possible combinations of subject, session, and data
  combinations <- expand.grid(sub = sub, ses = ses, dat = dat)

  # Generate comprehensive list of file names
  # filenames_list <- paste0(projdir, "/sub-", sprintf("%04d", combinations$sub), "/ses-", sprintf("%02d", combinations$ses), "/beh/sub-", sprintf("%04d", combinations$sub), "_ses-", sprintf("%02d", combinations$ses), "_task-", task, "_run-", combinations$dat, ".tsv")
  filenames_list <- paste0(projdir, "/sub-", sprintf("%04d", combinations$sub), "/ses-", sprintf("%02d", combinations$ses), "/beh/sub-", sprintf("%04d", combinations$sub), "_ses-", sprintf("%02d", combinations$ses), "_task-", task, "_", combinations$dat, ".tsv")
  
  # Check which file names exist
  existing_files <- sapply(filenames_list, function(f) file.exists(f) && grepl("\\.tsv$", f))
  
  # Import data from existing files
  df <- do.call(rbind, lapply(filenames_list[existing_files], read_delim, delim = "\t", show_col_types = FALSE))
  
  # Define factors
  #df$sub <- factor(combinations$sub[existing_files])
  #df$ses <- factor(combinations$ses[existing_files])
  
  # Define factors
  df$sub <- as.factor(df$sub)
  df$ses <- as.factor(df$ses)
  
  # Save data if requested
  if (save) {
    filename <- paste0(task, ".csv")
    write.csv(df, file = here::here("data", filename), row.names = FALSE)
  }
  
  return(df)
}