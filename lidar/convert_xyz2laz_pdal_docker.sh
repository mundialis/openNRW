#!/bin/sh

# openNRW XYZ to LAZ converter, based on PDAL (http://www.pdal.io)

# 2017, Markus Neteler <neteler@mundialis.de>
# 2018
# mundialis GmbH & Co. KG, Bonn
# https://www.mundialis.de

# To be used in a shell loop
#    for xyz in `ls dom1l_05315000_Köln_EPSG5555_XYZ/*.xyz` ; do sh convert_xyz2laz_pdal.sh $xyz ; done
#
########################################

INPUT=$1  # xyz
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

