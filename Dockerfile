# Description: Dockerfile to build an image that will run the script to generate images from a prompt using Hugging Face's Text-to-Image Serverless API

# use the official bash image
FROM bash:4.4

# update and install required packages : curl 
RUN apk update && apk add curl

# create a directory for the app
RUN mkdir -p /app

# set the working directory
WORKDIR /app

# copy the script to the working directory
COPY ./hf_img_gen.sh /app/hf_img_gen.sh

# make the script executable
RUN chmod +x /app/hf_img_gen.sh

# set the working directory
WORKDIR /

# make directory for the images and prompts
RUN mkdir -p /data/images \
    && mkdir -p /data/prompts

# set working directory
WORKDIR /app/

# create symbolic links to the directories for the images and prompts into the app directory
RUN ln -s /data/images /app/images \
    && ln -s /data/prompts /app/prompts

# set permissions for the directories data/images and data/prompts
RUN chmod o+rw /data/images \
    && chmod o+rw /data/prompts

# set working directory /data/images
WORKDIR /data/images

# run the script
# Usage: /usr/bin/hf_img_gen.sh [-m MODEL_URL] [-f PROMPT_FILE]
#  il faut que lors du `docker run` on puisse passer les arguments, donc vu que c'est optionnel rajoute juste de quoi recuperer les arguments qui seront mis dans la variable $@
CMD ["bash", "/app/hf_img_gen.sh", "-f", "/data/prompts/prompt.txt"]


