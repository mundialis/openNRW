#!/bin/sh

############################################################################
#
# NAME:         01_fetch_openNRW_historic_DOP_list.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>, Lina Krisztian
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Fetch list of openNRW historic DOP 10cm imagery files
#               - digital orthophoto tiles of North-Rhine Westphalia, Germany
#               The overall size of all openNRW DOP10 files is > 1.4 TB
#               Generates: 02_fetch_DOP10_JP2s.sh
#
# Data source:  https://www.opengeodata.nrw.de/produkte/geobasis/lusat/hist/hist_dop/hist_dop_jp2_f10/
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
#   sh 01_fetch_openNRW_historic_DOP_list.sh YEAR
# Output:
#   02_fetch_DOP10_JP2s.sh
########################################
YEAR=$1
# Digitale Orthophotos (10-fache Kompression) - Paketierung: Einzelkacheln
URL=https://www.opengeodata.nrw.de/produkte/geobasis/lusat/hist/hist_dop/hist_dop_jp2_f10/hist_dop_${YEAR}/epsg_25832/

#### check if year set
if [ $# -ne 1 ] ; then
    echo "You must parse the historic year, which should be processed."
    exit 1
fi

#### check if we have lynx tool
if [ ! -x "`which lynx`" ] ; then
    echo "lynx required, please install lynx first"
    exit 1
fi

# overall: 35860 DOPs
lynx -dump -nonumbers -listonly $URL | grep www.opengeodata.nrw.de/produkte/geobasis/lusat/ | grep 'jp2$' | sed 's+^+/vsicurl/+g' > opengeodata_historic_${YEAR}_nrw_dop10_URLs.csv

# generate download script
cat opengeodata_historic_${YEAR}_nrw_dop10_URLs.csv | sed 's+^+wget -c +g' > 02_fetch_DOP10_JP2s.sh
chmod a+x 02_fetch_DOP10_JP2s.sh

# compress DOP URLs list
gzip opengeodata_historic_${YEAR}_nrw_dop10_URLs.csv
echo "Generated <opengeodata_historic_${YEAR}_nrw_dop10_URLs.csv.gz>"

echo "
Some notes:
"
echo "GRASS GIS: single DOP10 file import (10 cm resolution):
r.import input=/vsicurl/https://www.opengeodata.nrw.de/produkte/geobasis/lusat/hist/hist_dop/hist_dop_jp2_f10/hist_dop_2021/epsg_25832/dop10rgbi_32_280_5652_1_nw_2021.jp2 output=dop10rgbi_32_280_5652_1_nw_2021 resolution=value resolution_value=0.10"
echo ""
echo "For mosaics, better generate a VRT mosaic first (using <gdalbuildvrt ...>), then import the VRT file."
echo ""
echo 'For an openNRW DOP10 tile index, run
YEAR=XXXX
gzip -d opengeodata_historic_${YEAR}_nrw_dop10_URLs.csv.gz
gdaltindex -f GPKG openNRW_historic_${YEAR}_DOP10_tileindex.gpkg --optfile opengeodata_historic_${YEAR}_nrw_dop10_URLs.csv'
