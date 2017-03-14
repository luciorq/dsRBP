# analysis project template

## Directory Structure
  - raw/
  - data/
  - results/
  - images/
  - plots/
  - lib/
  - src/

## Get started
- [Install the Docker client](http://docs.docker.com)

## Build Image and Start Container
- Open Terminal in project folder and ./start_container.sh
- open a browser to http://localhost:8787

## Run new image
docker run [tag_name]

## Check which container is Running
docker ps

## To stop container
docker stop [container_number]

## Open Terminal
docker exec -it [container_number] /bin/bash
