FROM rocker/geospatial:3.6.1

WORKDIR /home/rstudio/ 
RUN apt-get update && apt-get install --assume-yes apt-utils
RUN apt-get --assume-yes install libgd3 m4 libhdf5-dev cowsay

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

RUN wget http://www.netgull.com/gcc/releases/gcc-9.2.0/gcc-9.2.0.tar.gz && \
	tar -xzf gcc-9.2.0.tar.gz && \
	cd gcc-9.2.0 && \ 
	ls && \
	./contrib/download_prerequisites && \
	./configure --enable-languages=fortran --disable-multilib && \
	make && \
	make install

RUN rm gcc-9.2.0.tar.gz && rm -r gcc-9.2.0 && apt -y remove gcc g++ gfortran
	
RUN Rscript -e 'devtools::install_github("GLEON/GLM3r")'

RUN echo 'Sys.setenv(LD_LIBRARY_PATH = paste("/usr/local/lib64", Sys.getenv("LD_LIBRARY_PATH"), sep=":"))' >> /usr/local/lib/R/etc/Rprofile.site

RUN mkdir -p glm3_test &&\
    chown rstudio glm3_test 
WORKDIR glm3_test

