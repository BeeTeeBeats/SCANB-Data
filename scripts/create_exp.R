library(tidyverse)

# This line helps to avoid timeouts on large downloads
Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 1000)

exp_suffix = "_exp.tsv"

data_dir = "~/Data/"
exp_dir = paste0(data_dir, "expression_data/")

if (!dir.exists(data_dir))
  dir.create(data_dir)
if (!dir.exists(exp_dir))
  dir.create(exp_dir)

urls = list(
  ABiM.100 = "https://data.mendeley.com/public-files/datasets/yzxtxn4nmd/files/a7db6476-70b8-46b0-a751-d8030598485b/file_downloaded",
  ABiM.405 = "https://data.mendeley.com/public-files/datasets/yzxtxn4nmd/files/e6e536b4-ae18-4e8c-ae46-9026efbf0e63/file_downloaded",
  Normal.66 = "https://data.mendeley.com/public-files/datasets/yzxtxn4nmd/files/c1617a54-df92-4225-8d74-95c4b79ff6c9/file_downloaded",
  OSLO2EMIT0.103 = "https://data.mendeley.com/public-files/datasets/yzxtxn4nmd/files/6617b35c-c175-46ea-8714-01a06d904578/file_downloaded",
  SCANB.9206 = "https://data.mendeley.com/public-files/datasets/yzxtxn4nmd/files/29d59830-01a6-49aa-82aa-8312ae669863/file_downloaded"
)

# Dowload and store the files, adding the appropriate title to the first column
for (name in names(urls)) {
  print(paste0("Reading expression data for ", name))
  read_tsv(urls[[name]], show_col_types = FALSE, name_repair = "unique_quiet") |>
    rename(ENS_Gene_ID = `...1`) |>
    write_tsv(paste0(exp_dir, name, exp_suffix))
}