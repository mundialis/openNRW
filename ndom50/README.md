Scripts to process openNRW data: Normalisiertes Digitales Oberflächenmodell 50, 50cm resolution, GeoTIFF format

Overviews:

 * product description: https://www.bezreg-koeln.nrw.de/geobasis-nrw/produkte-und-dienste/hoehenmodelle/digitale-oberflaechenmodelle/normalisiertes
 * map of flight dates (Befliegungsdatum): https://www.tim-online.nrw.de/tim-online2/?bg=basemapDE_grau&scale=1400000&center=450000,5700000&wms=https://www.wms.nrw.de/geobasis/wms_nw_dhm-uebersicht,nw_dhm_metadaten&opacity=70&legend=true
 * data: ndom50 - Normalisiertes Digitales Oberflächenmodell, provided as 35856 tiles
     * data download: https://www.opengeodata.nrw.de/produkte/geobasis/hm/ndom50_tiff/

Download scripts:

 * `fetch_openNRW_ndom50_list.sh`: Fetch list of openNRW ndom50 URLs
   * it generates: `fetch_ndom50.sh` to run the download with `wget`. Note: The overall size of all openNRW ndom0 GeoTIFF files is 550 GB
