#!/bin/sh

############################################################################
#
# NAME:         lidar_colorize_pdal.sh
#
# AUTHOR(S):    Markus Neteler <neteler at mundialis.de>
#               mundialis GmbH & Co. KG, Bonn
#               https://www.mundialis.de
#
# PURPOSE:      colorizes LiDAR point cloud with RGB values from related orthophoto,
#               based on PDAL (http://www.pdal.io)
#
# COPYRIGHT:    (C) 2017 by Markus Neteler, mundialis
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

## Usage:
# pdal pipeline --input pdal_filter_add_rgb.json 

pdal pipeline --input $i
