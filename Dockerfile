FROM rocker/geospatial:4.0.3

WORKDIR /home/rstudio/ 
RUN apt-get update && apt-get install --assume-yes apt-utils
RUN apt-get --assume-yes install libgd-dev m4 libnetcdf-dev 

RUN mkdir AquaticEcoDynamics && \
  cd AquaticEcoDynamics && \
  git clone https://github.com/AquaticEcoDynamics/libplot.git && \
  cd libplot && git reset --hard 727ed89ce21d84abadf65e16854e8dd307d0c191 && cd .. && \ 
  git clone https://github.com/AquaticEcoDynamics/libaed2.git && \
  git clone https://github.com/AquaticEcoDynamics/libutil.git && \
  git clone -b v3.1.0 https://github.com/AquaticEcoDynamics/GLM.git && \
  git clone https://github.com/AquaticEcoDynamics/libaed-water.git && \
  cd GLM && ./build_glm.sh

#this fork has fix for GLM_PATH variable when using
#a different binary than included with the package
RUN Rscript -e 'devtools::install_github("jsta/GLM3r")'

RUN echo 'Sys.setenv(LD_LIBRARY_PATH = paste("/usr/local/lib64", Sys.getenv("LD_LIBRARY_PATH"), sep=":"), \
                     GLM_PATH = "/home/rstudio/AquaticEcoDynamics/GLM/glm")' >> /usr/local/lib/R/etc/Rprofile.site

RUN mkdir -p glm3_test && \
    chown rstudio glm3_test 
WORKDIR glm3_test

