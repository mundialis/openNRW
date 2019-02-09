Scripts to process openNRW data: LiDAR Punktwolken DGM1L - point clouds, ~ 2 returns/sqm, XYZ ASCII format

 * lidar: LiDAR Punktwolken, ~ 2 returns/sqm | LiDAR point clouds, originally provided as XYZ ASCII lists, ZIPed by municipality
     * data download: https://www.opengeodata.nrw.de/produkte/geobasis/dgm/dgm1l/

## Fetch XYZ Lidar point cloud data

 * `fetch_openNRW_LIDAR_list.sh`: Fetch list of openNRW LIDAR XYZ ZIP files as a help for download

## Converting the LiDAR XYZ to LAZ

Data are delivered in XYZ ASCII files (CSV style), we convert them to compressed LAS = LAZ.

### a) Bulk (sequentially) unpack and convert XYZ to LAZ format

Note that this variant may require a lot of temporary disk space.

#### Unpack XYZ

 * `unpack_parallel_openNRW_LIDAR_ZIPs.sh`: Unzip the XYZ files in *n* parallel jobs

#### Convert XYZ to LAZ

 * `convert_xyz2laz_pdal.sh`: Unzip and then convert the XYZ to LAZ
 * `convert_xyz2laz_pdal_docker.sh`: Unzip and then convert the XYZ to LAZ (docker variant)

## b) Parallelized unpack and convert XYZ to LAZ format

Note that this variant does not require a lot of temporary disk space.

 * `unzip_convert_xyz2laz_pdal_parallel.sh`: Unzip and then convert the XYZ in *n* parallel jobs to LAZ
 * `unzip_convert_xyz2laz_pdal_docker_parallel.sh`: Unzip and then convert the XYZ in *n* parallel jobs to LAZ (docker variant)

## Generate LAZ tile index from all LAZ files

```bash
# be sure to quote the input wildcard "*.laz"
pdal tindex -f GPKG --lyr_name "openNRW" --t_srs "EPSG:25832" /data/openNRW/lidar/openNRW_LiDAR_tileindex_files_${STADT}.gpkg "/data/openNRW/lidar/dom1l_05162024_Neuss_EPSG25832/*.laz"
```

## Bonus track: Colorize point cloud with respective RGB Orthophoto values

Script to colorize LiDAR point cloud with RGB values from related orthophoto:

 * `lidar_colorize_pdal.sh`: requires to edit `pdal_filter_add_rgb.json`

