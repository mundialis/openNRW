#!/bin/sh

# MN 2017
# Script to import openNRW DGM XYZ data as regular gridded DGMs
# processes all DGM-ZIPs in a directory

####
# first time only, create location:
# grass74 -c epsg:4647 -e ~/grassdata/epsg4647_openNRW/
#
####
# 
# for all subsequent uses, start GRASS GIS for the DGM session:
# grass74 ~/grassdata/epsg4647_openNRW/PERMANENT/

# debug
# zip=dgm1_05154020_Issum_EPSG4647_XYZ.zip

if  [ -z "$GISBASE" ] ; then
 echo "You must be in GRASS GIS to run this program." >&2
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
    compregion=`cat $dgm  | tr -s ' ' ' ' | r.in.xyz input=- separator=space -s -g output=dummy | cut -d' ' -f1-`
    g.region $compregion res=1 -p

    # enlarge computational region by half a raster cell (here 0.5m) to
    # store the points as cell centers:
    g.region n=n+0.5 s=s-0.5 w=w-0.5 e=e+0.5 -p

    name=`basename $dgm .xyz`
    cat $dgm | tr -s ' ' ' ' | r.in.xyz input=- separator=space method=mean output=$name
    
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
  r.out.gdal input=$xyz output=$xyz.tif type=Float32 createopt="COMPRESS=LZW"

  # cleanup: delete all imported tiles
  g.remove raster pattern="dgm*" -f
  # cleanup: delete mosaik
  g.remove raster pattern=$xyz -f

  # at this stage the mapset should be empty and the zip file disconnected. Clean for the next loop...
  
done # end of city loop
