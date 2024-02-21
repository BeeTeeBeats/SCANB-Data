library(tidyverse)
library(janitor)

# This line helps to avoid timeouts on large downloads
Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 1000)

source("scripts/create_meta.R")
source("scripts/create_exp.R")