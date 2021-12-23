FROM rocker/geospatial:4.1.2

# Disable the annoying bell on WSL2
RUN sed -i 's/^# set bell-style none$/set bell-style none/' /etc/inputrc

# Add DOI CA to local CAs so that SSL can work over VPN
COPY DOIRootCA2.crt /usr/local/share/ca-certificates
RUN update-ca-certificates

# Set a default scheduler for clustermq. This can be overridden in the
# _targets.R itself. The multicore should be nice for saving memory as it is
# threaded, but the docs say that it "sometimes causes problems (macOS,
# RStudio) and is not available on Windows. MacOS and Windows won't be problems
# since this is in docker, but RStudio is a possibility. This could potentially
# be set on a per-use-case basis; discuss use cases with team.
#
# Additionally, use the local RStudio Teams CRAN mirror for R packages (this
# requires VPN connection when building).
#
# Additionally, set GLM_PATH variable so GLM3r uses the executable built here
# instead of the one included with the package.
RUN echo '\n\
options(clustermq.scheduler = "multicore")\n\
#options(repos = c(REPO_NAME = "https://rpkg.chs.usgs.gov/prod-cran/latest"))\n\
Sys.setenv(GLM_PATH = "/usr/local/bin/GLM/glm")' \
  >> /usr/local/lib/R/etc/Rprofile.site

# Dependencies: ZeroMQ library for clustermq and libglpk40 for igraph/targets
RUN apt-get update && apt-get install -y \
  apt-utils \
  libgd-dev \
  libnetcdf-dev \
  libglpk40 \
  libzmq3-dev \
  m4  \
  vim-tiny \
  && rm -rf /var/lib/apt/lists/*

# Build GLM executable from source, based on jread's build script.
# Note that libaed, libutil, and libaid-water could be built from a fixed
# commit like libplot is.
# Also, remove these git repos after GLM is built?
RUN cd /usr/local/bin && \
  git clone https://github.com/AquaticEcoDynamics/libplot.git && \
  cd libplot && git reset --hard 727ed89ce21d84abadf65e16854e8dd307d0c191 && cd .. && \
  git clone https://github.com/AquaticEcoDynamics/libaed2.git && \
  git clone https://github.com/AquaticEcoDynamics/libutil.git && \
  git clone -b v3.1.0 https://github.com/AquaticEcoDynamics/GLM.git && \
  git clone https://github.com/AquaticEcoDynamics/libaed-water.git && \
  cd GLM && ./build_glm.sh

RUN Rscript -e 'library(remotes); \
                install_github("GLEON/GLMr"); \
                install_github("GLEON/GLM3r"); \
                install_github("GLEON/glmtools");'

# Install the necessary pipeline and parallelization packages for R
RUN install2.r --error \
  arrow \
  clustermq \
  fst \
  igraph \
  ncdf4 \
  ncdf4.helpers \
  retry \
  tarchetypes \
  targets \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
