#!/bin/sh

############################################################################
#
# NAME:         r.in.opennrw_dgm.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Script to import openNRW DGM XYZ data as regularly gridded DGMs
#               It loops over all DGM-ZIPs in a directory.
#
#               Notes:It removes the leading "32" from East coordinate (EPSG4647 --> 25832 hack)
#                     because EPSG4647 comes with false Easting extended by 32000000 to get the preceeding 32.
#                     Hence 4647 stores with preceeding zone number, whereas 25832 does not.
#                     So 25832 coordinate xxxxxx is 32xxxxxx in 4647.
#               See also:
#                 Maßgeschneiderte EPSG-Codes für GIS-Anwendungen https://www.zentrale-stelle-sapos.de/files/EPSG-Codes.pdf
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

#
# openNRW data source:
# https://www.opengeodata.nrw.de/produkte/geobasis/dgm/dgm1/

####
# first time only, create location:
# grass74 -c epsg:25832 -e ~/grassdata/epsg25832_openNRW/
#
####
#
# for all subsequent uses, start GRASS GIS for the DGM session:
# grass74 ~/grassdata/epsg25832_openNRW/PERMANENT/

# debug
# zip=dgm1_05154020_Issum_EPSG4647_XYZ.zip

if  [ -z "$GISBASE" ] ; then
 echo "You must be in GRASS GIS to run this program." >&2
 exit 1
fi

#### check if we have fuse-zip
if [ ! -x "`which fuse-zip`" ] ; then
    g.message -e "fuse-zip required, please install fuse-zip first"
    exit 1
fi


# loop over all cities a.k.a. ZIP files (outer loop)
for zip in `ls dgm*_EPSG4647_XYZ.zip` ; do

  # process DGM of current city
  xyz=`basename $zip _EPSG4647_XYZ.zip`
  echo "Processing $xyz..."

  # mount ZIP file instead of unpacking and (doubling disk consumption)
  ZIPDIR=`basename ${zip} .zip`
  mkdir -p ${ZIPDIR}
  fuse-zip ${zip} ${ZIPDIR}
  cd ${ZIPDIR}

  # loop over all DGM zip files
  
  # concept:
  # 1. scan all gridded points in XYZ-DGM to obtain the bounding box (since it is unknown)
  # 2. set computational region to bbox +0.5m in all directions (points must fall into cell center, not corner)
  # 3. import points as raster maps
  
  # one ZIP file contanis many xyz tiles files... (inner loop)
  for dgm in `ls dgm*.xyz` ; do
    # irregular spaces :(
    # to get rid of them, we pipe the entire XYZ-DGM into the "tr", then into r.in.xyz used as bounding box scanner
    compregion=`cat $dgm  | tr -s ' ' ' ' | sed 's+^32++g' | r.in.xyz input=- separator=space -s -g output=dummy | cut -d' ' -f1-`
    g.region $compregion res=1 -p

    # enlarge computational region by half a raster cell (here 0.5m) to
    # store the points as cell centers:
    g.region n=n+0.5 s=s-0.5 w=w-0.5 e=e+0.5 -p

    name=`basename $dgm .xyz`
    cat $dgm | tr -s ' ' ' ' | sed 's+^32++g' | r.in.xyz input=- separator=space method=mean output=$name
    
  done  # end of tile loop

  # move out of ZIP file
  cd ..
  # import done, unmount ZIP file
  fusermount -u ${ZIPDIR} && rmdir ${ZIPDIR}
  
  # generate list of all tiles which are now in the GRASS GIS location/mapset
  TILELIST=`g.list raster pattern="dgm*" sep=comma`
  # set computational region to all tiles as prep for overall DGM of city
  g.region raster=$TILELIST -p
  
  # merge all tiles into one map
  r.patch input=$TILELIST output=$xyz
  
  # write out merged DGM mosaik as a compressed GeoTIFF
  r.out.gdal -m -c input=$xyz output=${xyz}_epsg25832.tif type=Float32 createopt="COMPRESS=LZW"
  r.pack input=${xyz} output=${xyz}_epsg25832.pack

  # cleanup: delete all imported tiles
  g.remove raster pattern="dgm*" -f
  # cleanup: delete mosaik
  g.remove raster pattern=$xyz -f

  # at this stage the mapset should be empty and the zip file disconnected. Clean for the next loop...
  
done # end of city loop
