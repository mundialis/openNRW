#!/bin/sh

############################################################################
#
# NAME:         fetch_openNRW_LIDAR_list.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Fetch list of openNRW LIDAR XYZ ZIP files
#               - LiDAR XYZ file of North-Rhine Westphalia, Germany
#               The overall size of all openNRW LIDAR10 ZIP files is 1.4 TB
#
# Data source:  https://www.opengeodata.nrw.de/produkte/geobasis/dom/dom1l/
#
# COPYRIGHT:    (C) 2018 by Markus Neteler, mundialis
#
# REQUIREMENTS: lynx, gzip
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
#   sh fetch_openNRW_LIDAR_list.sh
########################################

lynx -dump -nonumbers -listonly https://www.opengeodata.nrw.de/produkte/geobasis/dom/dom1l/ | grep www.opengeodata.nrw.de/produkte/geobasis | grep EPSG25832_XYZ.zip > opengeodata_nrw_lidar_URLs.csv

cat opengeodata_nrw_lidar_URLs.csv | sed 's+^+wget -c +g' > download_openNRW_LIDAR_XYZ_ZIP_files.sh

echo "openNRW LiDAR URLs stored in <opengeodata_nrw_lidar_URLs.csv>"
echo ""
echo "Next run (warning: 1.4 TB of disk space needed! - or reduce the list to your needs by editing the file):
  sh download_openNRW_LIDAR_XYZ_ZIP_files.sh

Then, to convert XYZ.zip to LAZ:
  sh convert_xyz2laz_pdal.sh
"
