#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

cmake_args="
-DBLAS_LIBRARIES=$PREFIX/lib/libcblas.a;$PREFIX/lib/libatlas.a
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_C_COMPILER=/usr/bin/gcc
-DCMAKE_COLOR_MAKEFILE=OFF
-DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/g++
-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
-DCMAKE_Fortran_COMPILER=/usr/bin/gfortran
-DCMAKE_INSTALL_PREFIX=$PREFIX
-DCMAKE_MODULE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
-DCMAKE_STATIC_LINKER_FLAGS=-L$PREFIX/lib
-DPGPLOT_INCLUDE_DIRS=$PREFIX/include/pgplot
-DPGPLOT_LIBRARIES=$PREFIX/lib/libpgplot.so;$PREFIX/lib/libcpgplot.a
-DQWT_INCLUDE_DIRS=$PREFIX/include/qwt5
"
#cmake_args="$cmake_args --debug-trycompile --debug-output"
jflag=-j4

cd gcwrap
mkdir build
cd build
cmake $cmake_args ..
make $jflag VERBOSE=1

# Blow away a lot of files ... We need to keep TablePlotTkAgg.py since CASA's
# bizarre plotting code automatically imports it (from C++!) even without the
# casapy frontend. Fortunately things still seem to work even though much of
# the plotting stuff doesn't get hooked up and our matplotlib version is
# different (I think).

cd $PREFIX
rm -rf xml
rm bin/{buildmytasks,casa,casapy,xmlgenpy} lib/saxon*.jar

mkdir -p $SP_DIR
casapydir=$(echo python/2.*)
for stem in __casac__ casac.py TablePlotTkAgg.py ; do
    mv $casapydir/$stem $SP_DIR/
done
sed -e "s|$casapydir|lib/casa/tasks|g" $casapydir/casadef.py >$SP_DIR/casadef.py
rm -rf python # note! not lib/python ...
