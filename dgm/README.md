Scripts to process openNRW data: Digitales Geländemodell, 1m resolution, ASCII grid

Overview: https://www.opengeodata.nrw.de/produkte/geobasis/

 * dgm: Digitales Geländemodell, 1m | digital elevation model, provided as XYZ matrices, ZIPed by municipality
     * data download: https://www.opengeodata.nrw.de/produkte/geobasis/dgm/dgm1/

Preprocessing:

 * `r.in.opennrw_dgm.sh`:  Script to import openNRW DGM XYZ data as regularly gridded DGMs. It loops over all DGM-ZIPs in a directory.
 * `r.in.opennrw_dgm_epgs25832.sh`: Script to import openNRW DGM XYZ data as regularly gridded DGMs. It loops over all DGM-ZIPs in a directory. It removes the leading "32" from East coordinate (EPSG 4647 --> EPSG 25832 hack) because EPSG 4647 comes with false Easting extended by 32000000 to get the preceeding 32.  Hence 4647 stores with preceeding zone number, whereas 25832 does not. So 25832 coordinate xxxxxx is 32xxxxxx in 4647.

Postprocessing:

 * `dgm1_extract_bonn_DEM_mosaik_procedure.sh`: Script to mosaik all openNRW dgm1 tiles which cover the city of Bonn (adapt to your needs)

