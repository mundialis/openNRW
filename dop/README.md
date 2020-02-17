Scripts to process openNRW data: Digitales Orthophoto, R-G-B-NIR, 10cm resolution, JP2000 format

Overviews:

 * product description: https://www.opengeodata.nrw.de/produkte/geobasis/
 * map of flight dates (Befliegungsdatum): https://www.tim-online.nrw.de/tim-online2/uebersicht.html?thema=dop
 * data: DOP - Digitales Orthophoto, 10cm, R-G-B-NIR | digital orthophotos, provided as JP2000, ZIPed by municipality
     * data download: https://www.opengeodata.nrw.de/produkte/geobasis/dop/dop/

Download scripts:

 * `fetch_openNRW_DOP_list.sh`: Fetch list of openNRW DOP 10cm imagery ZIP files
   * it generates: `fetch_DOP10.sh` to run the download with `wget`. Note: The overall size of all openNRW DOP10 ZIP files is 1.4 TB

Preprocessing:

 * `openNRW_unpack_DOP10.sh`: Sequentially unpacks openNRW DOP imagery ZIP files into flat directory but with optimized JP2 file names (Note: simple flat unpacking would fail since identical JP2 names exist in multiple openNRW DOP ZIP files)
 * `unpack_parallel_openNRW_DOP_ZIPs.sh`: Run *n* DOP10 unzip jobs concurrently in the background (using GNU parallel)
