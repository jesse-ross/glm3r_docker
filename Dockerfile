FROM rocker/geospatial:4.0.3

RUN apt-get update && apt-get install --assume-yes apt-utils
RUN apt-get --assume-yes install libgd-dev m4 libnetcdf-dev

#build GLM executable from source, based on jread's build script
#libaed, libutil, and libaid-water could be built from a fixed commit like libplot is
RUN cd /usr/local/bin && \
  git clone https://github.com/AquaticEcoDynamics/libplot.git && \
  cd libplot && git reset --hard 727ed89ce21d84abadf65e16854e8dd307d0c191 && cd .. && \
  git clone https://github.com/AquaticEcoDynamics/libaed2.git && \
  git clone https://github.com/AquaticEcoDynamics/libutil.git && \
  git clone -b v3.1.0 https://github.com/AquaticEcoDynamics/GLM.git && \
  git clone https://github.com/AquaticEcoDynamics/libaed-water.git && \
  cd GLM && ./build_glm.sh

RUN Rscript -e 'library(remotes); install_github("GLEON/GLMr");'
RUN Rscript -e 'library(remotes); install_github("GLEON/GLM3r");'
RUN Rscript -e 'library(remotes); install_github("GLEON/glmtools");'

#set GLM_PATH variable so GLM3r uses the executable built here instead of the one included with the pacakage
RUN echo 'Sys.setenv(GLM_PATH = "/usr/local/bin/GLM/glm")' >> /usr/local/lib/R/etc/Rprofile.site

#add additional R packages to install here:
RUN install2.r --error arrow \
                       igraph \
                       fst \
                       ncdf4 \
                       ncdf4.helpers \
                       retry \
                       tarchetypes \
                       targets
