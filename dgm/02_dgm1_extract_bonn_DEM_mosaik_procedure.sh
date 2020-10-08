#!/bin/sh

############################################################################
#
# NAME:         02_dgm1_extract_bonn_DEM_mosaik_procedure.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Script to mosaik all openNRW dgm1 tiles which cover an area (here: city of Bonn)
#
# REQUIREMENT:  All DGM1 files have been imported. See 01_grass_import_opennrw_dgm1_epsg25832.sh
#
# COPYRIGHT:    (C) 2018-2020 by Markus Neteler, mundialis
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

## Example: Bonn
#
# openNRW DGM1 data source:
# https://www.opengeodata.nrw.de/produkte/geobasis/hm/dgm1_xyz/

# fetch Bonn city boundary from OpenStreetMap
# see https://training.gismentors.eu/grass-gis-workshop-jena/units/02.html?highlight=openstreetmap
ogr2ogr -f GPKG bonn_boundary_osm_epsg25832.gpkg -a_srs EPSG:4326 -t_srs EPSG:25832 /vsicurl_streaming/"http://overpass-api.de/api/interpreter?data=%28relation%5B%22boundary%22%3D%22administrative%22%5D%5B%22admin%5Flevel%22%3D%226%22%5D%5B%22name%22%3D%22Bonn%22%5D%3B%29%3B%28%2E%5F%3B%3E%3B%29%3Bout%3B%0A" multipolygons

# start GRASS GIS
grass78 -c epsg:25832 ~/grassdata/openNRW_eps25832/

# import city boundary from OSM
v.import bonn_boundary_osm_epsg25832.gpkg out=bonn_boundary_osm

# set computational region to vector map but align pixel geometry to DGM (any related dgm1 map is fine)
g.region vector=bonn_boundary_osm align=dgm1_32330_5712_2_nw -p

# count DEMs
g.list raster pattern="dgm1_3*" > list.csv
wc -l list.csv
# 9275 list.csv in total

# Now easily identify DGM tiles covering the city of Bonn, using current region:
g.list raster pattern="dgm1_3*" region=.
g.list raster pattern="dgm1_3*" region=. | wc -l
# 63 tiles covering Bonn

# Use that list to create a virtual mosaic
r.buildvrt input=$(g.list raster pattern="dgm1_3*" sep=comma region=.) output=dgm1_bonn
r.colors dgm1_bonn color=elevation

# take a look
d.mon wx0
# visualize DGM1 of Bonn
d.rast dgm1_bonn
d.vect bonn_boundary_osm type=boundary

# compute shaded relief
r.relief input=dgm1_bonn output=dgm1_bonn_shaded
# compute geomorphons
r.geomorphon elevation=dgm1_bonn forms=dgm1_bonn_geomorphon 

# visualize geomorphons, shaded with terrain
d.erase
d.shade shade=dgm1_bonn_shaded color=dgm1_bonn_geomorphon 
