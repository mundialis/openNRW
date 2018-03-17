#!/bin/sh

############################################################################
#
# NAME:         dgm1_extract_bonn_DEM_mosaik_procedure.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      Script to mosaik all openNRW dgm1 tiles which cover the city of Bonn
#
# COPYRIGHT:    (C) 2018 by Markus Neteler, mundialis
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
# openNRW data source:
# https://www.opengeodata.nrw.de/produkte/geobasis/dgm/dgm1/

# fetch Bonn city boundary
# see http://training.gismentors.eu/grass-gis-workshop-jena-2018/units/02.html?highlight=openstreetmap
ogr2ogr -f GPKG bonn_boundary_osm_epsg4647.gpkg -a_srs EPSG:4647 -t_srs EPSG:25832 /vsicurl_streaming/"http://overpass-api.de/api/interpreter?data=%28relation%5B%22boundary%22%3D%22administrative%22%5D%5B%22admin%5Flevel%22%3D%226%22%5D%5B%22name%22%3D%22Bonn%22%5D%3B%29%3B%28%2E%5F%3B%3E%3B%29%3Bout%3B%0A" multipolygons

grass74 -c epsg:4647 ~/grassdata/epsg4647_openNRW/
v.import bonn_boundary_osm_epsg25832.gpkg out=bonn_boundary_osm

# set computational region to vector map but align pixel geometry to DGM (any related dgm1 is fine)
g.region vector=bonn_boundary_osm align=dgm1_32330_5712_2_nw -p

# count DEMs
g.list raster pattern="dgm1_3*" > list.csv
wc -l list.csv
# 9275 list.csv

# Now easily identify DGM tiles covering the city of Bonn, using current region:
g.list raster pattern="dgm1_3*" region=.
g.list raster pattern="dgm1_3*" region=. | wc -l
# 63 tiles

# Use that list
r.patch input=`g.list raster pattern="dgm1_3*" sep=comma region=.` output=dgm1_bonn
r.colors dgm1_bonn color=elevation

# take a look
d.mon wx0
d.rast dgm1_bonn
d.vect bonn_boundary_osm type=boundary

# shaded relief
r.relief input=dgm1_bonn output=dgm1_bonn_shaded

# geomorphons
r.geomorphon elevation=dgm1_bonn forms=dgm1_bonn_geomorphon 

d.erase
d.shade shade=dgm1_bonn_shaded color=dgm1_bonn_geomorphon 
