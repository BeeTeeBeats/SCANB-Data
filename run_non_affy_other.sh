#! /bin/bash

set -o errexit

#######################################################
# Build the Docker image
#######################################################

docker build -t alex0414/other_data_6 .

#######################################################
# Run docker command
#######################################################
 
dockerCommand="docker run -i -t --rm \
    -u $(id -u):$(id -g) \
    -v $(pwd):/6_process_non_affy_other \
    -v $(pwd)/../Data:/Data \
    alex0414/other_data_6"

time $dockerCommand Rscript scripts/source_all_non_affy_other.R

# $dockerCommand bash