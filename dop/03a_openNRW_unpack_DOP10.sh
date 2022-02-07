#!/bin/sh

############################################################################
#
# NAME:         03_openNRW_unpack_DOP10.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Unpacks openNRW DOP imagery ZIP files into flat directory but with optimized JP2 file names.
#               Note: simple flat unpacking would fail since identical JP2 names exist in multiple openNRW DOP ZIP files.
#
#               Example:
#                orig:   dop_05974044_Warstein_EPSG25832_JPEG2000.zip  /  2A_dop10rgbi_32458_5698_1_nw.jp2
#                result: dop_05974044_2A_dop10rgbi_32458_5698_1.jp2
# 
# COPYRIGHT:    (C) 2018-2022 by Markus Neteler, mundialis
#
# REQUIREMENTS: 7z
#               to install: apt-get install p7zip-full p7zip-rar -y
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
#   run this in the /mnt/geoserver_geodata/openNRW_DOP10/ directory (after having
#   fetched the DOP ZIP files) in which the ZIPs are stored:
#
#   sh openNRW_unpack_DOP10.sh
########################################

#### check if we have 7z
if [ ! -x "`which 7z`" ] ; then
    echo "7z required, please install first (<apt-get install p7zip-full p7zip-rar> | <dnf install p7zip-plugins>)"
    exit 1
fi

# we are in /mnt/geoserver_geodata/openNRW_DOP10/ and unpack final JP2 tiles into dop10_tiles/
mkdir -p dop10_tiles && cd dop10_tiles

# loop of ZIPs in now parent dir
for myzip in `ls ../*.zip` ; do

  # use a tmp/ dir for the ZIP content
  mkdir -p tmp && cd tmp

  # unzip parallelized ../$myzip into tmp
  7z x  ../$myzip

  # loop of JP2 files to be renamed
  for mytile in `ls *.jp2` ; do
  
     #  orig:   dop_05974044_Warstein_EPSG25832_JPEG2000.zip  /  2A_dop10rgbi_32458_5698_1_nw.jp2
     #  result: dop_05974044_2A_dop10rgbi_32458_5698_1.jp2

     # JP2 name laundry   
     name_partzip=`echo $myzip   | cut -d'_' -f1,2`
     name_parttile=`echo $mytile | sed 's+_nw++g'`

     echo "Renaming to ${name_partzip}_${name_parttile}..."	
     mv $mytile ../${name_partzip}_${name_parttile}
  done

  cd ..
  rmdir tmp

  # cleanup processed DOP10 ZIP
  mkdir -p zips_done
  mv $myzip zips_done/
done

echo "Unpacking done. Processed ZIP files are in directory <./zips_done/>"

exit 0

