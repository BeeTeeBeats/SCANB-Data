# Creates three separate files containing summaries
# of the numerical, character, and logical columns.

summariseVariables <- function(metadata) {
  add_to_char <- NULL

  # change variables to factors
  meta <- metadata %>%
    mutate_all(type.convert, as.is = TRUE) %>%
    mutate(Dataset_ID = factor(Dataset_ID)) %>%
    mutate(Sample_ID = factor(Sample_ID))


  numMatrix <-  meta %>%
    select_if(negate(is.character)) %>%
    select_if(negate(is.logical))

  charMatrix <- meta %>%
    select_if(negate(is.numeric)) %>%
    select_if(negate(is.logical))

  logicMatrix <- meta %>%
    select_if(negate(is.character)) %>%
    select_if(negate(is.numeric))

  # summarize numeric variables
  print(1)
  if ((ncol(numMatrix) > 2)) {
    numMatrix <- numMatrix %>%
        pivot_longer(3:ncol(numMatrix),
                     names_to = "Variable",
                     values_to = "Value") %>%
        group_by(Dataset_ID, Variable) %>%
        summarise(Min = min(Value, na.rm = T),
                  Mean = mean(Value, na.rm = T),
                  Max = max(Value, na.rm = T),
                  Num_Unique = length(unique(Value)),
                  Unique_Summary = paste(sort(unique(Value)), collapse = ", "))

    # remove columns with 4 or less unique values
    print(2)
    for (i in 1:nrow(numMatrix)) {
      bCol <- numMatrix[i, ]
      if (bCol$Num_Unique <= 4) {
        add_to_char <- (rbind(add_to_char, bCol))
      }
    }
    # check for number of rows
    if (!(is.null(add_to_char))) {
      numMatrix <- numMatrix %>%
        anti_join(add_to_char)
    }
  } else (numMatrix <- NULL)

  # summarize character variables
  print(3)
  if ((ncol(charMatrix) > 2)) {
    charMatrix <- charMatrix %>%
    pivot_longer(3:ncol(charMatrix),
                 names_to = "Variable",
                 values_to = "Value") %>%
    group_by(Dataset_ID, Variable) %>%
    summarise(Unique_Summary = paste(unique(Value), collapse = ", "),
              Num_Unique = length(unique(Value)))
  } else (charMatrix <- NULL)

  # summarize logical variables
  print(4)
  if ((ncol(logicMatrix) > 2)) {
    logicMatrix <- logicMatrix %>%
      pivot_longer(3:ncol(logicMatrix),
                   names_to = "Variable",
                   values_to = "Value") %>%
      group_by(Dataset_ID, Variable, Value) %>%
      summarise(temp_count = n()) %>%
      pivot_wider(names_from = Value,
                  values_from = temp_count) %>%
      rename(Num_True = `TRUE`, Num_False = `FALSE`) %>%
      relocate(Num_True, .before = Num_False)
  } else (logicMatrix <- NULL)
  # combine character variables and numeric variables with less than 4 unique values
  if (!is.null(charMatrix)) {
    charMatrix <- (rbind(charMatrix, add_to_char)) %>%
      dplyr::select(Dataset_ID, Variable, Unique_Summary, Num_Unique)
  }

  return(list(numSummary = numMatrix, charSummary = charMatrix, logSummary = logicMatrix))
}