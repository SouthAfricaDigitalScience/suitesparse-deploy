#!/bin/bash -e
# SuiteSparse build script
. /etc/profile.d/modules.sh
module add ci
module add gcc/${GCC_VERSION}
module add cmake
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add lapack/3.6.0-gcc-${GCC_VERSION}
module  add openblas/0.2.19-gcc-${GCC_VERSION}
SOURCE_FILE=${NAME}-${VERSION}.tar.gz

mkdir -p $WORKSPACE
mkdir -p $SRC_DIR
mkdir -p $SOFT_DIR

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  wget http://faculty.cse.tamu.edu/davis/${NAME}/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi

# get metis

tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
cd ${WORKSPACE}/SuiteSparse
make config
export LDFLAGS="-L${OPENBLAS_DIR}/lib -L${LAPACK_DIR}/lib64"
export BLAS="-lopenblas" LAPACK="-llapack -lopenblas"
make library
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$LAPACK_DIR/lib64"
CFLAGS="-L${OPENBLAS_DIR}/lib -L${LAPACK_DIR}/lib64" make
