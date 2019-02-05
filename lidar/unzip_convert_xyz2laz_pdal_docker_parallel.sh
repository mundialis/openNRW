#!/bin/bash

############################################################################
#
# NAME:         unzip_convert_xyz2laz_pdal_docker_parallel.sh
#
# AUTHOR(S):    Anika Bettge <bettge at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Unzip and then convert the xyz in n parallel jobs to laz
#               We use a semaphore for that, from GNU Parallel,
#               https://doi.org/10.5281/zenodo.1146014
#
# Data source:  https://www.opengeodata.nrw.de/produkte/geobasis/dom/dom1l/
#
# COPYRIGHT:    (C) 2019 by Markus Neteler, mundialis
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
#   bash unzip_convert_xyz2laz_pdal_docker_parallel.sh
########################################

# get number of processors of current machine
MYNPROC=`getconf _NPROCESSORS_ONLN`
# leave one PROC free for other tasks
GCCTHREADS=`expr $MYNPROC - 1`
PJOBS=$GCCTHREADS

# for each zip: unzip and convert XYZ to LAZ
for myzip in $(ls *.zip) ; do
  folder=$(echo $myzip | sed 's+_XYZ.zip++g')
  mkdir $folder
  cd $folder
  unzip -o ../$myzip

  # launch PJOBS in parallel to convert XYZ to LAZ
  for xyz in $(ls *.xyz) ; do
    sem -j$PJOBS "echo \"Processing <$xyz>...\" ; sh ../convert_xyz2laz_pdal_docker.sh $xyz ; rm -f $xyz ; echo \"<$xyz> done\""
  done
  sem --wait

  cd ..
done
