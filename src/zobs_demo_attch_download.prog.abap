*&---------------------------------------------------------------------*
*& Report ZOBS_ATTCH_DOWNLOAD_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zobs_demo_attch_download.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_bucket TYPE zzbucket_obs DEFAULT 'mrm-attachment'.
  PARAMETERS: p_objkey TYPE zzobjectkey_obs .
  PARAMETERS: p_ftype  TYPE char10 DEFAULT 'BIN'.
  SELECTION-SCREEN COMMENT 50(50) TEXT-001 FOR FIELD p_ftype  ."默认BIN,直接下载文件内容TEXT

SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.
  "下载文件
  PERFORM frm_download_attachment.

*&---------------------------------------------------------------------*
*& Form frm_download_attachment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_download_attachment.
  DATA: lo_obs       TYPE REF TO  zcl_obs,
        lv_filename  TYPE string,
        lv_objectkey TYPE string,
        ls_return    TYPE bapiret2.


  CREATE OBJECT lo_obs.

  lv_objectkey = p_objkey.
  IF p_ftype = 'BIN'.
    CALL METHOD lo_obs->download_attachment
      EXPORTING
        iv_bucketname = p_bucket
        iv_objectkey  = lv_objectkey
      IMPORTING
        es_return     = ls_return.

  ELSE.

    CALL METHOD lo_obs->download_attachment
      EXPORTING
        iv_bucketname = p_bucket
        iv_objectkey  = lv_objectkey
        iv_filetype   = 'TEXT'
        iv_newline    = 'X'
      IMPORTING
        es_return     = ls_return
        es_result     = DATA(ls_result).


    cl_demo_output=>display( data = ls_result-data ).
  ENDIF.

  IF ls_return IS NOT INITIAL..
    MESSAGE ID ls_return-id
          TYPE 'S'
        NUMBER ls_return-number
          WITH ls_return-message_v1
               ls_return-message_v2
               ls_return-message_v3
               ls_return-message_v4 DISPLAY LIKE ls_return-type.

  ENDIF.
ENDFORM.
