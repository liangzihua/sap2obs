*&---------------------------------------------------------------------*
*& Report ZOBS_ATTCH_DOWNLOAD_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zobs_demo_textfile_download.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_bucket TYPE zzbucket_obs DEFAULT 'deppon-cubc'.
  PARAMETERS: p_objkey TYPE zzobjectkey_obs DEFAULT '/tmp/accfiles/HXD/TRANS/AUTO/20210319/HXD_0060_20210319094736445.txt'.

SELECTION-SCREEN END OF BLOCK b1.




START-OF-SELECTION.
  "上载文件
  PERFORM frm_download_file.

*&---------------------------------------------------------------------*
*& Form frm_download_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_download_file .
  DATA: lo_obs       TYPE REF TO  zcl_obs,
        lv_filename  TYPE string,
        lv_objectkey TYPE string,
        ls_return    TYPE bapiret2.


  CREATE OBJECT lo_obs.

  lv_objectkey = p_objkey.

  CALL METHOD lo_obs->download_file
    EXPORTING
      iv_bucketname = p_bucket
*     iv_httpmethod = 'GET'
      iv_objectkey  = lv_objectkey
*     iv_expires    = 3600
*     iv_newline    = 'X'
    IMPORTING
      es_return     = ls_return
      es_result     = DATA(ls_result).

  IF ls_return IS NOT INITIAL..
    MESSAGE ID ls_return-id
          TYPE ls_return-type
        NUMBER ls_return-number
          WITH ls_return-message_v1
               ls_return-message_v2
               ls_return-message_v3
               ls_return-message_v4.

  ENDIF.

  IF ls_return-type = 'S'.
    cl_demo_output=>display( data = ls_result-data ).
  ENDIF.


ENDFORM.
