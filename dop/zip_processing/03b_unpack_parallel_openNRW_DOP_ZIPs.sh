#!/bin/bash

############################################################################
#
# NAME:         03b_unpack_parallel_openNRW_DOP_ZIPs.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Run n DOP10 unzip jobs concurrently in the background
#               We use a semaphore for that, from GNU Parallel,
#               https://doi.org/10.5281/zenodo.1146014
#
# Data source:  https://www.opengeodata.nrw.de/produkte/geobasis/dom/dom1l/
#
# COPYRIGHT:    (C) 2019-2022 by Markus Neteler, mundialis
#
# REQUIREMENTS: GNU parallel
#                 dnf install -y parallel
#                 apt-get install parallel
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
############################################################################

# Usage:
#   bash 03b_unpack_parallel_openNRW_DOP_ZIPs.sh
########################################

#### check if we have GNU parallel tools
if [ ! -x "`which sem`" ] ; then
    echo "GNU parallel tools required, please install 'parallel' first"
    exit 1
fi

# get number of processors of current machine
MYNPROC=`getconf _NPROCESSORS_ONLN`
# leave one PROC free for other tasks
GCCTHREADS=`expr $MYNPROC - 1`
PJOBS=$GCCTHREADS

# launch PJOBS in parallel
for myzip in $(ls *.zip) ; do
  # note: no idea how to pass on a env variable inside a semaphore call with (...), so subdir usage is a bit lengthy here
  sem -j$PJOBS "( mkdir $(echo $myzip | sed 's+_XYZ.zip++g') ; cd $(echo $myzip | sed 's+_XYZ.zip++g') ; unzip -o ../$myzip )"
done
sem --wait

