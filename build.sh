#!/bin/bash -e
# SuiteSparse build script
. /etc/profile.d/modules.sh
module add ci
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add lapack/3.6.0-gcc-${GCC_VERSION}
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
tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
# SuiteSparse does not support autotools.
# there is no configuration, only a custom Make configuration file.
# This needs to be put into the workspace
cp SuiteSparse_config_linux.mk SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk
# Set the install and lib dirs with SED
# Since the variables have slashes (/) we need to use a different delimeter
# see http://stackoverflow.com/questions/9366816/sed-unknown-option-to-s
sed -i 's@^INSTALL_LIB =.*$@INSTALL_LIB = ${SOFT_DIR}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/lib@g' SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk
echo "INSTALL LIB dir is : "
grep INSTALL_LIB SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk

sed -i 's@^INSTALL_INCLUDE =.*$@INSTALL_INCLUDE = ${SOFT_DIR}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/include@g' SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk
echo "INSTALL INCLUDE dir is : "
grep INSTALL_INCLUDE SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk

echo "making the install and lib dirs"
mkdir -p ${SOFT_DIR}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/include
mkdir -p ${SOFT_DIR}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}/lib
cd SuiteSparse
make
make library
