#!/bin/bash -e
# SuiteSparse deploy script
. /etc/profile.d/modules.sh

module add deploy
module add gcc/${GCC_VERSION}
module add cmake
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add lapack/3.6.0-gcc-${GCC_VERSION}
module add  openblas/0.2.19-gcc-${GCC_VERSION}
echo "making the install and lib dirs"
mkdir -p ${SOFT_DIR}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}
echo "purging previous build config"
echo ${SOFT_DIR}
cd ${WORKSPACE}/SuiteSparse/
echo ""
make distclean
export LDFLAGS="-L${OPENBLAS_DIR}/lib -L${LAPACK_DIR}/lib"
export BLAS="-lopenblas" LAPACK="-llapack -lopenblas"
make library
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$LAPACK_DIR/lib"
CFLAGS="-L${OPENBLAS_DIR}/lib -L${LAPACK_DIR}/lib" make

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
