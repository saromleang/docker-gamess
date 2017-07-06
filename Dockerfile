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
#
# Build argument. Specifies Ubuntu Version used for the Docker build:
#
#   --build-arg IMAGE_VERSION=[16.04|12.04|14.04|17.04]
#
ARG IMAGE_VERSION=16.04

FROM ubuntu:$IMAGE_VERSION
MAINTAINER Sarom Leang "sarom@si.msg.chem.iastate.edu"

#
# Build argument. Modify by adding the following argument during docker build:
#
#   --build-arg BLAS=[none|atlas]
#
ARG BLAS=none

# Build argument. The current week's GAMESS  source download password.
#
#   --build-arg WEEKLY_PASSWORD=password
#
ARG WEEKLY_PASSWORD=none

# Build argument. Flag to reduce docker image size by un-needed files.
#
#   --build-arg REDUCE_IMAGE_SIZE=[true|false]
#
ARG REDUCE_IMAGE_SIZE=true

WORKDIR /home

RUN if [ "$BLAS" = "atlas" ]; \
then apt-get update && apt-get install -y bzip2 wget make gcc gfortran \
&& echo "\n\n\n\tBuilding ATLAS Math Library\n\n\n" \
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

RUN apt-get update && apt-get install -y wget nano csh make gcc gfortran \
&& echo "\n\n\n\tDownloading Run Script\n\n\n" \
&& wget --no-check-certificate https://www.dropbox.com/s/f717qgl7yy1f1yd/gms-docker \
&& chmod +x gms-docker \
&& echo "\n\n\n\tDowloading GAMESS\n\n\n" \
&& wget --no-check-certificate --user=source --password=$WEEKLY_PASSWORD http://www.msg.chem.iastate.edu/GAMESS/download/source/gamess-current.tar.gz -O gamess.tar.gz \
&& tar -xf gamess.tar.gz \
&& rm -rf gamess.tar.gz \
&& cd /usr/local/bin/gamess \
&& mkdir -p object \
&& export GCC_MAJOR_VERSION=`gcc --version | grep ^gcc | sed 's/gcc (.*) //g' | grep -o '[0-9]\{1,3\}\.[0-9]\{0,3\}\.[0-9]\{0,3\}' | cut -d '.' -f 1` \
&& export GCC_MINOR_VERSION=`gcc --version | grep ^gcc | sed 's/gcc (.*) //g' | grep -o '[0-9]\{1,3\}\.[0-9]\{0,3\}\.[0-9]\{0,3\}' | cut -d '.' -f 2` \
&& export NUM_CPU_CORES=`grep -c ^processor /proc/cpuinfo` \
&& sed -i 's/case 5.3:/case 5.3:\n case 5.4:/g' config \
&& sed -i 's/case 5.3:/case 5.3:\n case 5.4:/g' comp \
&& echo "\n\n\n\tSetting Up install.info\n\n\n" \
&& wget --no-check-certificate https://www.dropbox.com/s/c0sulwqf3zkmh22/install.info.docker \
&& mv install.info.docker install.info\
&& sed -i 's/TEMPLATE_GMS_PATH/\/usr\/local\/bin\/gamess/g' install.info \
&& sed -i 's/TEMPLATE_GMS_BUILD_DIR/\/usr\/local\/bin\/gamess/g' install.info \
&& sed -i 's/TEMPLATE_GMS_TARGET/linux64/g' install.info \
&& sed -i 's/TEMPLATE_GMS_FORTRAN/gfortran/g' install.info \
&& sed -i 's/TEMPLATE_GMS_GFORTRAN_VERNO/'"$GCC_MAJOR_VERSION"'.'"$GCC_MINOR_VERSION"'/g' install.info \
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
&& echo "\n\n\n\tCompiling actvte.x\n\n\n" \
&& gfortran -o /usr/local/bin/gamess/tools/actvte.x actvte.f \
&& rm -f actvte.f \
&& echo "\n\n\n\tGenerating Makefile\n\n\n" \
&& export makef=/usr/local/bin/gamess/Makefile \
&& echo "GMS_PATH = /usr/local/bin/gamess" > $makef \
&& echo "GMS_VERSION = 00" >> $makef \
&& echo "GMS_BUILD_PATH = /usr/local/bin/gamess" >> $makef \
&& echo 'include $(GMS_PATH)/Makefile.in' >> $makef \
&& echo "\n\n\n\tBuilding GAMESS\n\n\n" \
&& cd /usr/local/bin/gamess && make -j $NUM_CPU_CORES || : && make -j $NUM_CPU_CORES || : \
&& echo "\n\n\n\tValidating GAMESS\n\n\n" \
&& make checktest \
&& make clean_exams \
&& rm -rf /usr/local/bin/gamess/object \
&& cd /usr/local/bin/ \
&& apt-get remove -y wget make \
&& apt-get clean autoclean \
&& apt-get autoremove -y \
&& mkdir /home/gamess /home/gamess/scratch /home/gamess/restart \
&& rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log \
&& cp /usr/local/bin/gamess/machines/xeon-phi/rungms.interactive /usr/local/bin/gamess/rungms \
&& if [ "$REDUCE_IMAGE_SIZE" = "true" ]; \
then echo "\n\n\n\tDeleting un-need files\n\n\n"; \
rm -rf /usr/local/bin/gamess/INPUT.DOC; \
rm -rf /usr/local/bin/gamess/INTRO.DOC; \
rm -rf /usr/local/bin/gamess/IRON.DOC; \
rm -rf /usr/local/bin/gamess/PROG.DOC; \
rm -rf /usr/local/bin/gamess/REFS.DOC; \
rm -rf /usr/local/bin/gamess/TEST.DOC; \
rm -rf /usr/local/bin/gamess/ddi; \
rm -rf /usr/local/bin/gamess/graphics; \
rm -rf /usr/local/bin/gamess/libcchem; \
rm -rf /usr/local/bin/gamess/machines; \
rm -rf /usr/local/bin/gamess/misc; \
rm -rf /usr/local/bin/gamess/object; \
rm -rf /usr/local/bin/gamess/qmnuc; \
rm -rf /usr/local/bin/gamess/source; \
rm -rf /usr/local/bin/gamess/tools; \
rm -rf /usr/local/bin/gamess/vb2000; \
fi \
&& echo "\n\n\n\tContents of install.info\n\n\n" \
&& cat /usr/local/bin/gamess/install.info

WORKDIR /home/gamess
ENTRYPOINT ["/usr/local/bin/gms-docker"]
CMD ["help"]
