#!/bin/sh

############################################################################
#
# NAME:        fetch_openNRW_DOP_list.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Fetch list of openNRW DOP 10cm imagery ZIP files
#               - digital orthophoto tiles of North-Rhine Westphalia, Germany
#               The overall size of all openNRW DOP10 ZIP files is 1.4 TB
#
# Data source:  https://www.opengeodata.nrw.de/produkte/geobasis/dop/dop/
#
# COPYRIGHT:    (C) 2018 by Markus Neteler, mundialis
#
# REQUIREMENTS: lynx, gdal, gzip
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
#   sh fetch_openNRW_DOP_list.sh
########################################

lynx -dump -nonumbers -listonly https://www.opengeodata.nrw.de/produkte/geobasis/dop/dop/ | grep www.opengeodata.nrw.de/produkte/geobasis | grep EPSG25832_JPEG2000.zip > opengeodata_nrw_dop10_URLs.csv

rm -f opengeodata_nrw_dop10_tiles.csv
for ZIP in `cat opengeodata_nrw_dop10_URLs.csv` ; do
  # amusingly, the output is on stderr! so we redirect it... but at the end of the line
  gdalinfo -nofl -norat "/vsizip/vsicurl/$ZIP" >> opengeodata_nrw_dop10_tiles.tmp 2>&1
done

# wipe out some rubbish
cat opengeodata_nrw_dop10_tiles.tmp | grep "       /vsizip/vsicurl" > opengeodata_nrw_dop10_tiles.csv
rm -f opengeodata_nrw_dop10_tiles.tmp

gzip opengeodata_nrw_dop10_URLs.csv
echo "Generated <opengeodata_nrw_dop10_URLs.csv.gz>"

gzip opengeodata_nrw_dop10_tiles.csv
echo "Generated <opengeodata_nrw_dop10_tiles.csv.gz>"



echo "Single tile import: Import into GRASS GIS with, e.g.:
r.import input=/vsizip/vsicurl/https://www.opengeodata.nrw.de/produkte/geobasis/dop/dop/dop_05562014_Gladbeck_EPSG25832_JPEG2000.zip/0E_dop10rgbi_32360_5718_1_nw.jp2 output=0E_dop10rgbi_32360_5718_1_nw"
echo ""
echo "For mosaics, better generate a VRT mosaic first (using <gdalbuildvrt ...>), then import the VRT file."
echo ""
echo "For a tile index, run
gdaltindex -f GPKG openNRW_DOP10_tileindex.gpkg --optfile opengeodata_nrw_dop10_tiles.csv"
