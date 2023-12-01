#!/bin/bash

############################################################################
#
# NAME:         01_grass_import_opennrw_dgm1_epsg25832.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Script to import openNRW DGM XYZ data as regularly gridded DGMs
#               It loops over all "Gemeinden" DGM-ZIPs saved in a directory.
#
#               Note: It removes the leading "32" from East coordinate (EPSG4647 --> 25832 hack)
#                     because EPSG4647 comes with false Easting extended by 32000000 to get the preceeding 32.
#                     Hence 4647 stores with preceeding zone number, whereas 25832 does not.
#                     So 25832 coordinate xxxxxx is 32xxxxxx in 4647.
#               See also:
#                 Maßgeschneiderte EPSG-Codes für GIS-Anwendungen https://www.zentrale-stelle-sapos.de/files/EPSG-Codes.pdf
#
# COPYRIGHT:    (C) 2017-2020 by Markus Neteler, mundialis
#
# REQUIREMENTS: apt-get install fuse-zip (Ubuntu/Debian)
#               dnf install fuse-zip     (Fedora/CentOS)
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
# https://www.opengeodata.nrw.de/produkte/geobasis/hm/dgm1_xyz/

####
# first time only, create location:
# grass78 -c epsg:25832 -e ~/grassdata/openNRW_epsg25832/
#
####
#
# for all subsequent uses, start GRASS GIS for the DGM session:
# grass78 ~/grassdata/openNRW_epsg25832/PERMANENT/

# debug
# zip=dgm1_05154020_Issum_EPSG25832_XYZ.zip

# optional reference raster for grid geometry alignment
# NOTE: this can introduce a grid shift
ref_raster=""

# are we in GRASS GIS? https://grass.osgeo.org/
if  [ -z "$GISBASE" ] ; then
 echo "You must be in GRASS GIS to run this program." >&2
 exit 1
fi

#### check if we have fuse-zip
if [ ! -x "$(which fuse-zip)" ] ; then
    g.message -e "fuse-zip required, please install fuse-zip first"
    exit 1
fi

export GRASS_MESSAGE_FORMAT=plain

#check if a MASK is already present in the current mapset:
MASKTMP=mask.$$
USERMASK="usermask_$MASKTMP"
eval $(g.findfile element=cell file=MASK mapset=.)
if [ "$file" ] ; then
    g.message "A user raster mask (MASK) is present. Saving it..."
    g.rename raster=MASK,"$USERMASK" --quiet > /dev/null
fi

# loop over all openNRW dgm1 city packages a.k.a. ZIP files (outer loop)
# "Paketierung: Gemeinden"
for zip in $(ls dgm*_EPSG25832_XYZ.zip) ; do

    # process DGM1 of current city in the list
    xyz=$(basename $zip _EPSG25832_XYZ.zip)
    echo "Processing $xyz..."

    # mount ZIP file (instead of unpacking it which would double the disk space consumption)
    ZIPDIR=$(basename ${zip} .zip)
    mkdir -p ${ZIPDIR}
    fuse-zip ${zip} ${ZIPDIR}
    cd ${ZIPDIR}

    # loop over all DGM files in zip file
    # concept:
    # 1. scan all gridded points in XYZ-DGM to obtain the bounding box (since it is unknown)
    # 2. set computational region to bbox +0.5m in all directions (points must fall into cell center, not corner)
    # 3. import points as raster maps
    #
    # one city ZIP file contains many xyz tiles files... (inner loop)
    for dgm in $(ls dgm*.xyz) ; do
        # irregular spaces found in a few files :(
        # to get rid of them, we pipe the entire XYZ-DGM into the "tr", then into r.in.xyz used as bounding box scanner
        compregion=$(cat $dgm  | tr -s ' ' ' ' | r.in.xyz input=- separator=space -s -g output=dummy | cut -d' ' -f1-4)
        g.region $compregion res=1 -p

        # enlarge computational region by half a raster cell (here 0.5m) to
        # store the points as cell centers:
        g.region n=n+0.5 s=s-0.5 w=w-0.5 e=e+0.5 -p
        if [ -n "$ref_raster" ] ; then
           g.region align=$ref_raster -p
        fi

        name=$(basename $dgm .xyz)
        cat $dgm | tr -s ' ' ' ' | r.in.xyz input=- separator=space method=mean output=$name
        # shift from EPSG:4647 to EPSG:25832, adjusting false easting
        r.region map=$name e=e-32000000 w=w-32000000
        # shift raster for half pixel because in the XYZ file the left lower corner is given
        g.region rast=$name 
        g.region n=n+0.5 s=s+0.5 w=w+0.5 e=e+0.5 -p
        r.region map=$name -c
    done  # end of tile loop

    # move out of city ZIP file
    cd ..
    # import done, unmount ZIP file
    fusermount -u ${ZIPDIR} && rmdir ${ZIPDIR}

    # generate list of all tiles which are now in the GRASS GIS location/mapset
    TILELIST=$(g.list raster pattern="dgm*" sep=comma)
    # set computational region to all tiles as prep for overall DGM of city
    g.region raster=$TILELIST -p
    # merge all tiles into one virtual map, in case VRT support is included in GRASS GIS version (7.8+)
    if [ -x "$(which r.buildvrt)" ] ; then
       r.buildvrt input=$TILELIST output=$xyz
    else
       r.patch input=$TILELIST output=$xyz
    fi

    # write out merged DGM mosaik as a compressed GeoTIFF, with overviews
    # (compress GeoTIFF overviews as well)
    export COMPRESS_OVERVIEW="LZW"
    r.out.gdal -m -c input=$xyz output=${xyz}_epsg25832.tif type=Float32 createopt="COMPRESS=LZW,TILED=YES" overview=5
    r.pack input=${xyz} output=${xyz}_epsg25832.pack

    # cleanup: delete mosaik
    g.remove raster pattern=$xyz -f
    # cleanup: delete all imported tiles
    g.remove raster pattern="dgm*" -f

    # at this stage the mapset should be empty and the zip file disconnected - cleaned for the next loop cycle...

done # end of openNRW city loop ("Paketierung: Gemeinden")

#restore user mask if it was present:
eval $(g.findfile element=cell file=$USERMASK mapset=.)
if [ "$file" ] ; then
  g.message "Restoring user raster mask (MASK) ..."
  g.remove raster name=MASK -f --quiet > /dev/null
  g.rename raster="$USERMASK",MASK --quiet > /dev/null
fi

exit 0
