library(tidyverse)
library(janitor)
library(readxl)
source("~/6_process_non_affy_other/functions/summariseVariables.R")

# This line helps to avoid timeouts on large downloads
Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 1000)

# Check https://data.mendeley.com/datasets/yzxtxn4nmd/3 for potential updates to the supplemental data.
# This code used the most recent version at the time of writing: version 2023-01-13
source_file_url = "https://data.mendeley.com/public-files/datasets/yzxtxn4nmd/files/33d08b30-4685-4814-ab87-606a20c3092b/file_downloaded"
source_file_name = "Supplementary Data Table 1 - 2023-01-13.xlsx"

platform_id = "TEMPORARY_PLATFORM_ID"

# Fill out columns you want to exclude
excluded_columns = list(
    ABiM.100 = c(

    ),
    ABiM.405 = c(

    ),
    Normal.66 = c(

    ),
    OSLO2EMIT0.103 = c(

    ),
    SCANB.9206 = c(

    )
)

raw_suffix = ".tsv"
prelim_suffix = ".tsv"
sum_char_suffix = "_char.tsv"
sum_num_suffix = "_num.tsv"
sum_log_suffix = "_log.tsv"

data_dir = "~/Data/"
metasum_dir = paste0(data_dir, "metadata_summaries/")
prelim_dir = paste0(data_dir, "prelim_metadata/")
raw_dir = paste0(data_dir, "raw_metadata/")
tmp_dir = paste0(data_dir, "tmp/")


# create directories
if (!dir.exists(data_dir))
  dir.create(data_dir)
if (!dir.exists(metasum_dir))
  dir.create(metasum_dir)
if (!dir.exists(prelim_dir))
  dir.create(prelim_dir)
if (!dir.exists(raw_dir))
  dir.create(raw_dir)
if (!dir.exists(tmp_dir))
  dir.create(tmp_dir)

# Download excel file (contains multiple sheets)
download.file(source_file_url, destfile = paste0(tmp_dir, source_file_name), mode = "wb")

# Separate the sheets into files
# Note: I suppressed the warnings because readxl can't seem to tell that
#       the Ki67 column in the SCANB.9206 sheet is supposed to be characters
#       and not logical values. This is also why when I read in the data, I
#       read all columns as text and then convert them after the fact.
suppressWarnings(sheet_names <- excel_sheets(paste0(tmp_dir, source_file_name)))
for (sheet_name in sheet_names) {

    print(paste0("Reading data from ", sheet_name))

    # Read in the data
    # Note: As mentioned above, this is where I convert the types after reading
    #       them all in as text. This avoids readxl throwing pointless warnings
    #       and turning the SCANB.9206 sheet's Ki67 column into nothing but NA values.
    temp_data = read_excel(paste0(tmp_dir, source_file_name), sheet = sheet_name, col_types = "text")
    temp_data <- temp_data %>%
        mutate(across(everything(), ~type.convert(.x, as.is = TRUE)))

    # Save the raw metadata
    write_tsv(temp_data, paste0(raw_dir, sheet_name, raw_suffix))

    # Clean up the metadata
    cleaned_data = temp_data |>
        janitor::clean_names() |>
        rename(Sample_ID = gex_assay) |>
        mutate(Dataset_ID = sheet_name, .before = Sample_ID) |>
        mutate(Platform_ID = platform_id, .after = Sample_ID) |>
        dplyr::select(-excluded_columns[[sheet_name]])

    # Save the cleaned metadata
    write_tsv(cleaned_data, paste0(prelim_dir, sheet_name, prelim_suffix))

    # Summarize the metadata
    summaries = summariseVariables(cleaned_data)

    # Save the summaries
    if (nrow(summaries$numSummary >= 1)) {
        write_tsv(summaries$numSummary, paste0(metasum_dir, sheet_name, sum_num_suffix))
    }
    if (nrow(summaries$charSummary >= 1)) {
        write_tsv(summaries$charSummary, paste0(metasum_dir, sheet_name, sum_char_suffix))
    }
    if (!is.null(summaries$logSummary) && nrow(summaries$logSummary >= 1)) {
        write_tsv(summaries$logSummary, paste0(metasum_dir, sheet_name, sum_log_suffix))
    }
}

# Unlink tmp directory
unlink(tmp_dir, recursive = TRUE, force = TRUE)