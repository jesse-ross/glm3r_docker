# GLM3R in a container

Testing GLM3R in a Docker/Singularity container

## To execute an R script in the container on Yeti
```
#from inside this repo, with the .sif file at the top level directory
module load singularity/3.4.1
singularity exec -B /cxfs:/cxfs glm3r_v0.1.sif Rscript -e 'source("R/test_glm.R")'
```

## To start an interactive shell

Once you are inside the container, you can execute commands as you would normally.
```
#From the same location
singularity shell -B /cxfs:/cxfs glm3r_v0.1.sif
```
