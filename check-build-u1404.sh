#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add gcc/${GCC_VERSION}
module add cmake
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add lapack/3.6.0-gcc-${GCC_VERSION}
module  add openblas/0.2.19-gcc-${GCC_VERSION}

cd ${WORKSPACE}/SuiteSparse
export LDFLAGS="-L${OPENBLAS_DIR}/lib -L${LAPACK_DIR}/lib"
export BLAS="-lopenblas" LAPACK="-llapack -lopenblas"
CFLAGS="-L${OPENBLAS_DIR}/lib -L${LAPACK_DIR}/lib" make install INSTALL="${SOFT_DIR}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}"
mkdir -p ${REPO_DIR}
mkdir -p modules
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
setenv       SUITESPARSE_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(SUITESPARSE_DIR)/lib
setenv CFLAGS            "$CFLAGS -I$::env(SUITESPARSE_DIR)/include"
MODULE_FILE
) > modules/$VERSION-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}

mkdir -p ${LIBRARIES}/${NAME}
cp modules/$VERSION-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} ${LIBRARIES}/${NAME}/

echo "Is the module available ?"
module avail ${NAME}
echo "Can we add the module ?"
module add  ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
