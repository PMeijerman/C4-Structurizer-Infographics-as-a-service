# Structurizr

This file will detail the steps to get this structurizr model up and running

## Requirements

- [Docker](https://docs.docker.com/desktop/install/windows-install/)

## How to run
- Pull image: `docker pull structurizr/lite`
- Run Docker Container: `docker run -it --rm -p 8080:8080 -v PathToThisFile:/usr/local/structurizr structurizr/lite`
- Open browser: http://localhost:8080  