# GLM3r in a container

Testing GLM3r in a Docker/Singularity container

## To execute an R script in the container on the cluster
This pattern can be used inside a SLURM batch script:
```
#from inside this repo, with the .sif file at the top level directory
module load singularity/3.4.1
singularity exec -B /cxfs:/cxfs glm3r_v0.1.sif Rscript -e 'source("R/test_glm.R")'
```

The `.sif` file is the Singularity image—--it can reside in any directory.  We will likely want to establish a convention for that.

## To start an interactive shell

Once you are inside the container, you can execute commands as you would normally.
```
#From the same location
singularity shell -B /cxfs:/cxfs glm3r_v0.1.sif
```

## Docker registries
Ideally a project will have a canonical hosted Docker registry to store versioned copies of images. dockerhub and code.chs.usgs.gov are the main options here.  This image is currently set up to push to `wdwatkins/glm3r` on Dockerhub.  I can give others permission to push or pull from there, or a new registry could be set up.  The `docker-compose.yml` file controls this (line 4). 

## Making changes to the image

You need to be off the VPN to build this image, since it does not include a root certificate so it can be shared externally.

This image builds from the `rocker/geospatial` image, which already contains widely-used packages like the tidyverse and geospatial packages like `sf`.  If you need other packages, uncomment lines 28-30 in the Dockerfile and add them to the `install2.r` line. This will install the specified packages from CRAN. 
```
RUN install2.r --error \
  httr \
  googleAuthR \
  <more packages...>
```
The backslashes simply allow multiple lines in the command.

### To build the image

Next, make sure Docker is running.  Then from the terminal run `docker-compose build` while inside this directory.  You will need to be off the network, since the root certificate is not included.  

When that completes, push to the registry using the appropriate registry and tag, e.g.: `docker push wdwatkins/glm3r:v0.3`.  

### Getting the image to the cluster for Singularity use

We have a built Docker image, but we still need to rebuild it as a Singularity image file that can be used on HPC platforms.  Using another Docker container, this can be done locally:
```
$ docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock -v ~/Documents/R/glm3r_docker:/output quay.io/singularity/docker2singularity wdwatkins/glm3r:v0.3 
Image Format: squashfs
Docker Image: wdwatkins/glm3r:v0.3

Inspected Size: 5090 MB

(1/10) Creating a build sandbox...
(2/10) Exporting filesystem...
(3/10) Creating labels...
(4/10) Adding run script...
(5/10) Setting ENV variables...
(6/10) Adding mount points...
(7/10) Fixing permissions...
(8/10) Stopping and removing the container...
(9/10) Building squashfs container...
INFO:    Starting build...
INFO:    Creating SIF file...
INFO:    Build complete: /tmp/wdwatkins_glm3r_v0.3-2020-12-15-a2024e2944fc.sif
(10/10) Moving the image to the output folder...
  1,903,804,416 100%   55.66MB/s    0:00:32 (xfr#1, to-chk=0/1)
Final Size: 1816MB

#see the .sif file that has been created
$ ls
Dockerfile                                        README.md                                         glm3r_docker.Rproj                                wdwatkins_glm3r_v0.3-2020-12-15-a2024e2944fc.sif*
R/                                                docker-compose.yml                                scratch/
```
You should only need to modify two parts of the `docker run` command above.  The second `-v` flag defines the location where the final .sif file is written out, in this case `~/Documents/R/glm3r_docker`.  The last part of the command is the name of the docker image, same as was used with `docker push` earlier.

An alternative method is pulling the image from Dockerhub to the cluster directly using `singularity pull`.  Anecdotally, it seems to be slower than building locally.  This method is described in the internal HPC documentation.

Now all that is left is to rsync the .sif file to the cluster:
```
#this command is also renaming the image file to remove the image id 
rsync -azvP wdwatkins_glm3r_v0.3-2020-12-15-a2024e2944fc.sif user_name@machine_name:/directory_path/wdwatkins_glm3r_v0.3.sif
```

Your Singularity image should now be ready to use!