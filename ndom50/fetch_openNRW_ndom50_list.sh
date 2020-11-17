#!/bin/sh

############################################################################
#
# NAME:        fetch_openNRW_ndom50_list.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Fetch list of openNRW nDOM 50cm TIFF files
#               - Normalisiertes Digitales Oberflächenmodell 50 - Paketierung: Einzelkacheln
#               of North-Rhine Westphalia, Germany
#               The overall size of all openNRW nDOM 50cm TIFF files is 550 GB
#               Generates: fetch_ndom50.sh
#
# Data source:  https://www.opengeodata.nrw.de/produkte/geobasis/hm/ndom50_tiff/ndom50_tiff/
#
# COPYRIGHT:    (C) 2020 by Markus Neteler, mundialis
#
# REQUIREMENTS: lynx, gdal, gTILE, sed
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
#   sh fetch_openNRW_ndom50_list.sh
# Output:
#   fetch_ndom50.sh
########################################

lynx -dump -nonumbers -listonly https://www.opengeodata.nrw.de/produkte/geobasis/hm/ndom50_tiff/ndom50_tiff/ | grep www.opengeodata.nrw.de/produkte/geobasis/hm/ndom50_tiff/ndom50_tiff/ndom50 | grep -v "meta.TILE" > opengeodata_nrw_ndom50_URLs.csv

# generate download script
cat opengeodata_nrw_ndom50_URLs.csv | sed 's+^+wget -c +g' > fetch_ndom50.sh

# compress ndom50 URLs list
gzip opengeodata_nrw_ndom50_URLs.csv
echo "Generated <opengeodata_nrw_ndom50_URLs.csv.gz>"


echo "Single tile import: Import into GRASS GIS with, e.g.:
r.import input=/vsicurl/https://www.opengeodata.nrw.de/produkte/geobasis/hm/ndom50_tiff/ndom50_tiff/ndom50_32283_5650_1_nw_2019.tif output=ndom50_32283_5650_1_nw_2019"
echo ""
echo "For mosaics, better generate a VRT mosaic first (using <gdalbuildvrt ...>), then import the VRT file."
echo ""
echo "For a tile index, run
gdaltindex -f GPKG openNRW_ndom50_tileindex.gpkg --optfile opengeodata_nrw_ndom50_tiles.csv"
