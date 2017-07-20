#!/bin/bash -e
# SuiteSparse deploy script
. /etc/profile.d/modules.sh

module add deploy
module add gcc/${GCC_VERSION}
module add cmake
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add lapack/3.6.0-gcc-${GCC_VERSION}

echo "making the install and lib dirs"
mkdir -p ${SOFT_DIR}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}/include
mkdir -p ${SOFT_DIR}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}/lib
echo "purging previous build config"
echo ${SOFT_DIR}
cp SuiteSparse_config_linux-${OS}.mk SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk
# Set the install and lib dirs with SED
# Since the variables have slashes (/) we need to use a different delimeter
# see http://stackoverflow.com/questions/9366816/sed-unknown-option-to-s
sed -i "s@^INSTALL_LIB =.*\$@INSTALL_LIB = ${SOFT_DIR}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}/lib@g" SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk
echo "INSTALL LIB dir is : "
grep INSTALL_LIB SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk

sed -i "s@^INSTALL_INCLUDE =.*\$@INSTALL_INCLUDE = ${SOFT_DIR}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}/include@g" SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk
echo "INSTALL INCLUDE dir is : "
grep INSTALL_INCLUDE SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk
cd ${WORKSPACE}/SuiteSparse/
echo ""
make
make library
make install
echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       SUITESPARSE_VERSION       $VERSION
setenv       SUITESPARSE_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(SUITESPARSE_DIR)/lib
prepend-path CFLAGS            $::env(SUITESPARSE_DIR)/include
MODULE_FILE
) > modules/$VERSION-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}

mkdir -p ${LIBRARIES}/${NAME}
cp modules/$VERSION-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION} ${LIBRARIES}/${NAME}/
