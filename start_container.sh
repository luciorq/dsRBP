# Start RStudio server tidyverse container for project dsRBP
IMAGE_NAME=luciorq/$(basename $(pwd))
## -t for [tag]
docker build -t $IMAGE_NAME .
## -e for setting root
## -v or --volume for copying folder content
docker run -d -p 8787:8787 -e ROOT=TRUE --volume $(pwd):/home/rstudio/dsRBP $IMAGE_NAME
