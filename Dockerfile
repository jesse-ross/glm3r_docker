FROM rocker/geospatial:4.0.3

RUN apt-get update && apt-get install --assume-yes apt-utils
RUN apt-get --assume-yes install libgd-dev m4 libnetcdf-dev

#build GLM executable from source, based on jread's build script
#libaed, libutil, and libaid-water could be built from a fixed commit like libplot is
# mkdir /usr/local/bin && \
#  chown rstudio /usr/local/bin && \
RUN cd /usr/local/bin && \
  git clone https://github.com/AquaticEcoDynamics/libplot.git && \
  cd libplot && git reset --hard 727ed89ce21d84abadf65e16854e8dd307d0c191 && cd .. && \
  git clone https://github.com/AquaticEcoDynamics/libaed2.git && \
  git clone https://github.com/AquaticEcoDynamics/libutil.git && \
  git clone -b v3.1.0 https://github.com/AquaticEcoDynamics/GLM.git && \
  git clone https://github.com/AquaticEcoDynamics/libaed-water.git && \
  cd GLM && ./build_glm.sh

#this fork has fix for GLM_PATH variable when using
#a different binary than included with the package; restore to
#GLEON repo when https://github.com/GLEON/GLM3r/pull/20 is merged
RUN Rscript -e 'remotes::install_github("jsta/GLM3r")'

#set GLM_PATH variable so GLM3r uses the executable built here instead of the one included with the pacakage
RUN echo 'Sys.setenv(GLM_PATH = "/usr/local/bin/GLM/glm")' >> /usr/local/lib/R/etc/Rprofile.site

#add additional R packages to install here:
#RUN install2.r --error \
#  httr \
#  package...

WORKDIR /usr/local/bin

