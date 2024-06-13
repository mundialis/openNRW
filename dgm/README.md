Scripts to process openNRW data: Digitales Geländemodell (DGM / DEM), 1m resolution, ASCII grid

Overview: https://www.opengeodata.nrw.de/produkte/geobasis/

* DGM1: Digitales Geländemodell, 1m | gridded digital elevation model, provided as XYZ matrices, ZIPed by municipality
     * data download: https://www.opengeodata.nrw.de/produkte/geobasis/hm/dgm1_xyz/

Preprocessing:

* `01_grass_import_opennrw_dgm1_epsg25832.sh`: Script to import openNRW DGM XYZ data as regularly gridded DGMs.
   * It loops over all DGM-ZIPs in a directory.
   * It removes the leading "32" from East coordinate (EPSG 4647 --> EPSG 25832 hack) because EPSG 4647 comes with false Easting extended by 32000000 to get the preceeding 32. Hence 4647 stores with preceeding zone number, whereas 25832 does not (so, a 25832 coordinate xxxxxx corresponds to 32xxxxxx in 4647).

Postprocessing (example for Bonn):

* `02_dgm1_extract_bonn_DEM_mosaik_procedure.sh`: Script to mosaic all openNRW dgm1 tiles which cover the city of Bonn (adapt to your needs)

