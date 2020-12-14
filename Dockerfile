FROM rocker/geospatial:4.0.3

WORKDIR /home/rstudio/ 
RUN apt-get update && apt-get install --assume-yes apt-utils
RUN apt-get --assume-yes install libgd-dev m4 libhdf5-dev cowsay 

RUN wget https://github.com/Unidata/netcdf-c/archive/v4.6.2.tar.gz && \
	tar -xzf v4.6.2.tar.gz && \
	cd netcdf-c-4.6.2 && \
	H5DIR=/usr/local && \ 
	ZDIR=/usr/local && \
	NCDIR=/usr/local && \
	CPPFLAGS='-I${H5DIR}/include -I${ZDIR}/include' LDFLAGS='-L${H5DIR}/lib -L${ZDIR}/lib' ./configure --disable-netcdf-4 --prefix=${NCDIR} && \
	make check && \
	make install && \
	make clean && cd .. && rm v4.6.2.tar.gz && rm -r netcdf-c-4.6.2

#RUN wget http://www.netgull.com/gcc/releases/gcc-9.2.0/gcc-9.2.0.tar.gz && \
#	tar -xzf gcc-9.2.0.tar.gz && \
#	cd gcc-9.2.0 && \ 
#	ls && \
#	./contrib/download_prerequisites && \
#	./configure --enable-languages=fortran --disable-multilib && \
#	make && \
#	make install

#RUN rm gcc-9.2.0.tar.gz && rm -r gcc-9.2.0 && apt -y remove gcc g++ gfortran

#ENV EXPORT LD_LIBRARY_PATH=user/local/lib64:${LD_LIBRARY_PATH}

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

RUN mkdir -p glm3_test &&\
    chown rstudio glm3_test 
WORKDIR glm3_test

