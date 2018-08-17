#!/bin/sh

############################################################################
#
# NAME:         convert_xyz2laz_pdal_docker.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      openNRW XYZ to LAZ converter, based on PDAL (http://www.pdal.io)
#
#               Use 'fetch_openNRW_LIDAR_list.sh' to generate a download list and script
#
# COPYRIGHT:    (C) 2017, 2018 by Markus Neteler, mundialis
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

## Usage:
# To be used in a shell loop
#    for xyz in `ls dom1l_05315000_Köln_EPSG5555_XYZ/*.xyz` ; do sh convert_xyz2laz_pdal.sh $xyz ; done
#
########################################

INPUT=$1  # xyz

if [ $# -ne 1 ] ; then
        echo "Usage:
        $0 dom1l_xxxx.xyz"
        exit 1
fi

XYZTMP=`basename $INPUT .xyz`.tmp
OUTPUT=`basename $INPUT .xyz`

#https://www.pdal.io/workshop/docker.html?highlight=docker
# docker pull pdal/pdal

# we pipe data through /data!
alias pdal_docker="sudo /usr/bin/docker run --rm -v $(pwd):/data -t pdal/pdal pdal"

# fix white space which occurs in some of the openNRW XYZ files
cat $INPUT | sed '1ix,y,z' | sed 's+[[:blank:]]++g' > $XYZTMP

# convert XYZ to LAS with compression = LAZ

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

cat convert_txt2las_$OUTPUT.pdal

# conversion with PDAL pipeline
pdal_docker pipeline --input /data/convert_txt2las_$OUTPUT.pdal

# remove tmp file
rm -f $XYZTMP convert_txt2las_$OUTPUT.pdal

exit 0

