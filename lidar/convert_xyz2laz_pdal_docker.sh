#!/bin/sh

############################################################################
#
# NAME:         convert_xyz2laz_pdal_docker.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      openNRW XYZ to LAZ format converter
#
# REQUIREMENTS: PDAL (http://www.pdal.io), standard system tools (basename, cat, ...)
#
# COPYRIGHT:    (C) 2017-2019 by Markus Neteler, mundialis
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
#
#
# PROCEDURE:    The openNRW DOM1L LiDAR data are delivered in XYZ ASCII format.
#               The purpose of this script is to convert the XYZ into compressed LAS format, i.e. LAZ.
#
#               Suggested data processing procedure :
#
#               1. Use 'fetch_openNRW_LIDAR_list.sh' (same repo) to generate a download list and script
#
#               2. Run the generated download script to download the DOM1L XYZ ZIP files
#
#               3. Unpack the XYZ ZIP file(s)
#
#                  3a) using "unzip":
#                      for myzip in $(ls *.zip) ; do NAME=`echo $myzip | sed 's+_XYZ.zip++g'` ; (mkdir $NAME ; cd $NAME ; unzip -o ../$myzip ) ; done
#
#                  3b) using "7z" (`apt-get install p7zip-full p7zip-rar` | `dnf install p7zip-plugins`)":
#                      for myzip in $(ls *.zip) ; do NAME=`echo $myzip | sed 's+_XYZ.zip++g'` ; (mkdir $NAME ; cd $NAME ; 7z x ../$myzip -aoa ) ; done
#
#                  3c) Parallelized unpacking, see in this repo:
#                      unpack_parallel_openNRW_LIDAR_ZIPs.sh
#
#               4. Install PDAL docker image
#
#                   docker pull pdal/pdal
#
#               5. Using this script: convert the XYZ to LAZ format using PDAL (docker)
#
#                  Due to using docker we must pipe data through /data for PDAL-in-docker:
#                  https://www.pdal.io/workshop/docker.html?highlight=docker
#
#                  Important: configure docker alias below!
#
#                  Hint: use this script in a shell loop:
#
#                   for dom1l_dir in $(ls -1 | grep dom1l_) ; do
#                       cd $dom1l_dir/
#                       for xyz in $(ls *.xyz) ; do echo "Processing <$xyz>..." ; sh ../convert_xyz2laz_pdal_docker.sh $xyz ; done
#                       cd ..
#                   done
#
######################################################################################################

###### configuration
## For convenience, we create an alias:
## On Fedora:
# alias pdal_docker="sudo /usr/bin/docker run --rm -v $(pwd):/data -t pdal/pdal pdal"
## On Ubuntu:
alias pdal_docker="docker run --rm -v $(pwd):/data -t pdal/pdal pdal"

####### nothing to change below

INPUT=$1  # xyz

if [ $# -ne 1 ] ; then
        echo "Usage:
        $0 dom1l_xxxx.xyz"
        exit 1
fi

XYZTMP=`basename $INPUT .xyz`.tmp
OUTPUT=`basename $INPUT .xyz`

# check if input is compressed which we don't like
file $INPUT | grep 'Zip archive data' > /dev/null
if [ $? -ne 1 ] ; then
   echo "ERROR: input must be uncompressed ASCII file (found $INPUT - ZIP format)"
   exit 1
fi

# fix white space which occurs in some of the openNRW XYZ files
cat $INPUT | sed '1ix,y,z' | sed 's+[[:blank:]]++g' > $XYZTMP

# convert XYZ to LAS with compression = LAZ

# docker requires escaping of " chars
#
# Filter, based on http://www.pdal.io/stages/writers.las.html
echo "{
  \"pipeline\":[
    {
      \"type\":\"readers.text\",
      \"filename\":\"/data/$XYZTMP\"
    },
    {
      \"type\":\"writers.las\",
      \"a_srs\":\"EPSG:5555\",
      \"dataformat_id\":\"0\",
      \"compression\":\"true\",
      \"filename\":\"/data/$OUTPUT.laz\"
    }
  ]
}" > convert_txt2las_$OUTPUT.pdal

## debug
# cat convert_txt2las_$OUTPUT.pdal

# conversion with PDAL pipeline using /data
pdal_docker pipeline --input /data/convert_txt2las_$OUTPUT.pdal

# remove tmp file
rm -f $XYZTMP convert_txt2las_$OUTPUT.pdal

exit 0

