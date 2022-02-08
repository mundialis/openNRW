#!/bin/sh

############################################################################
#
# NAME:         01_fetch_openNRW_DOP_list.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Fetch list of openNRW DOP 10cm imagery files
#               - digital orthophoto tiles of North-Rhine Westphalia, Germany
#               The overall size of all openNRW DOP10 files is > 1.4 TB
#               Generates: 02_fetch_DOP10.sh
#
# Data source:  https://www.opengeodata.nrw.de/produkte/geobasis/dop/dop/
#
# COPYRIGHT:    (C) 2018-2022 by Markus Neteler, mundialis
#
# REQUIREMENTS: lynx, gdal, gzip, sed
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
#   sh 01_fetch_openNRW_DOP_list.sh
# Output:
#   02_fetch_DOP10.sh
########################################
# Digitale Orthophotos (10-fache Kompression) - Paketierung: Einzelkacheln
URL=https://www.opengeodata.nrw.de/produkte/geobasis/lusat/dop/dop_jp2_f10/

#### check if we have lynx tool
if [ ! -x "`which lynx`" ] ; then
    echo "lynx required, please install lynx first"
    exit 1
fi

# overall: 35860 DOPs
# Example: https://www.opengeodata.nrw.de/produkte/geobasis/lusat/dop/dop_jp2_f10/dop10rgbi_32_363_5619_1_nw.jp2
lynx -dump -nonumbers -listonly $URL | grep www.opengeodata.nrw.de/produkte/geobasis/lusat/dop/ | grep 'jp2$' | head -n 4 > opengeodata_nrw_dop10_URLs.csv

rm -f opengeodata_nrw_dop10_tiles.csv
for JP2 in `cat opengeodata_nrw_dop10_URLs.csv` ; do
  # amusingly, the output is on stderr! so we redirect it... but at the end of the line
  gdalinfo -nofl -norat "/vsicurl/$JP2" >> opengeodata_nrw_dop10_tiles.tmp 2>&1
done

# wipe out some rubbish
cat opengeodata_nrw_dop10_tiles.tmp | grep "       /vsicurl" > opengeodata_nrw_dop10_tiles.csv
rm -f opengeodata_nrw_dop10_tiles.tmp

# generate download script
cat opengeodata_nrw_dop10_URLs.csv | sed 's+^+wget -c +g' > 02_fetch_DOP10_JP2s.sh
chmod a+x 02_fetch_DOP10_JP2s.sh

# compress DOP URLs list
gzip opengeodata_nrw_dop10_URLs.csv
echo "Generated <opengeodata_nrw_dop10_URLs.csv.gz>"

# compress DOP tiles list
gzip opengeodata_nrw_dop10_tiles.csv
echo "Generated <opengeodata_nrw_dop10_tiles.csv.gz>"



echo "Single DOP10 tile import: Import into GRASS GIS with, e.g.:
r.import input=/vsicurl/https://www.opengeodata.nrw.de/produkte/geobasis/dop/dop/dop_05562014_Gladbeck_EPSG25832_JPEG2000.zip/0E_dop10rgbi_32360_5718_1_nw.jp2 output=0E_dop10rgbi_32360_5718_1_nwi resolution=value resolution_value=0.10"
echo ""
echo "For mosaics, better generate a VRT mosaic first (using <gdalbuildvrt ...>), then import the VRT file."
echo ""
echo "For a openNRW DOP10 tile index, run
gdaltindex -f GPKG openNRW_DOP10_tileindex.gpkg --optfile opengeodata_nrw_dop10_tiles.csv"
