#
# GAMESS on UBUNTU 16.04
#
# Build settings:
# Latest GNU compiler : 5.4
# No math library : Using GAMESS blas.o,  if $BLAS  == "none"
# ATLAS math library : Using ATLAS 3.10.3, if $BLAS  == "atlas"
# No MPI library : Using sockets
#
# Container structure:
# /usr
# └── /local
#     └── /bin
#         ├── /gamess (contains source and executable)
#         ├── free-sema.pl (script to clean up any leftover semaphores)
#         └── gms-docker (script executed by docker run)
#
# /home
# └── gamess (should be mapped to host folder containing input files)
#
# if $BLAS == "atlas"
#
# /opt
# └── /atlas (math library)
#
FROM ubuntu:16.04
MAINTAINER Sarom Leang "sarom@si.msg.chem.iastate.edu"
#
# Build argument. Modify by adding the following argument during docker build:
#
#   --build-arg BLAS=[none|atlas]
#
ARG BLAS=none

WORKDIR /home

RUN if [ "$BLAS" = "atlas" ]; \
then apt-get update && apt-get install -y bzip2 wget make gcc gfortran \
&& wget --no-check-certificate https://downloads.sourceforge.net/project/math-atlas/Stable/3.10.3/atlas3.10.3.tar.bz2 \
&& for f in *.tar.*; do tar -xf $f && rm -f $f; done \
&& cd /home/ATLAS \
&& mkdir build && cd build \
&& ../configure -b 64 --shared -D c -DWALL \
&& make build \
&& make shared \
&& make install DESTDIR=/opt/atlas \
&& cd /home \
&& rm -rf atlas3.10.3.tar.bz2 \
&& rm -rf ATLAS \
&& apt-get remove -y bzip2 \
&& apt-get clean autoclean \
&& apt-get autoremove -y; \
fi

ENV LD_LIBRARY_PATH=/opt/atlas/lib:$LD_LIBRARY_PATH

WORKDIR /usr/local/bin

COPY gamess.tar.gz /usr/local/bin

WORKDIR /usr/local/bin
RUN apt-get update && apt-get install -y wget nano csh make gcc gfortran \
&& wget --no-check-certificate https://www.dropbox.com/s/f717qgl7yy1f1yd/gms-docker \
&& chmod +x gms-docker \
&& wget --no-check-certificate https://www.dropbox.com/s/pjnib04bgnndqse/free-sema.pl \
&& chmod +x free-sema.pl \
&& tar -xf gamess.tar.gz \
&& cd /usr/local/bin/gamess \
&& mkdir -p object \
&& sed -i 's/case 5.3:/case 5.3:\n case 5.4:/g' config \
&& sed -i 's/case 5.3:/case 5.3:\n case 5.4:/g' comp \
&& wget --no-check-certificate https://www.dropbox.com/s/c0sulwqf3zkmh22/install.info.docker \
&& mv install.info.docker install.info\
&& sed -i 's/TEMPLATE_GMS_PATH/\/usr\/local\/bin\/gamess/g' install.info \
&& sed -i 's/TEMPLATE_GMS_BUILD_DIR/\/usr\/local\/bin\/gamess/g' install.info \
&& sed -i 's/TEMPLATE_GMS_TARGET/linux64/g' install.info \
&& sed -i 's/TEMPLATE_GMS_FORTRAN/gfortran/g' install.info \
&& sed -i 's/TEMPLATE_GMS_GFORTRAN_VERNO/5.4/g' install.info \
&& \
if [ "$BLAS" = "atlas" ]; \
then sed -i 's/TEMPLATE_GMS_MATHLIB_PATH/\/opt\/atlas\/lib/g' install.info \
&& sed -i 's/TEMPLATE_GMS_MATHLIB/atlas/g' install.info; \
else sed -i 's/TEMPLATE_GMS_MATHLIB/none/g' install.info; \
fi \
&& sed -i 's/TEMPLATE_GMS_DDI_COMM/sockets/g' install.info \
&& sed -i 's/TEMPLATE_GMS_LIBCCHEM/false/g' install.info \
&& sed -i 's/TEMPLATE_GMS_PHI/false/g' install.info \
&& sed -i 's/TEMPLATE_GMS_SHMTYPE/sysv/g' install.info \
&& sed -i 's/TEMPLATE_GMS_OPENMP/false/g' install.info \
&& sed -e "s/^\*UNX/    /" tools/actvte.code > actvte.f \
&& gfortran -o /usr/local/bin/gamess/tools/actvte.x actvte.f \
&& rm -f actvte.f \
&& export makef=/usr/local/bin/gamess/Makefile \
&& echo "GMS_PATH = /usr/local/bin/gamess" > $makef \
&& echo "GMS_VERSION = 00" >> $makef \
&& echo "GMS_BUILD_PATH = /usr/local/bin/gamess" >> $makef \
&& echo 'include $(GMS_PATH)/Makefile.in' >> $makef \
&& make \
&& make checktest \
&& rm -rf /usr/local/bin/gamess/object \
&& cd /usr/local/bin/ \
&& rm -rf gamess.tar.gz \
&& apt-get remove -y wget make \
&& apt-get clean autoclean \
&& apt-get autoremove -y \
&& mkdir /home/gamess /home/gamess/scratch /home/gamess/restart \
&& rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

WORKDIR /home/gamess
ENTRYPOINT ["/usr/local/bin/gms-docker"]
CMD ["help"]
