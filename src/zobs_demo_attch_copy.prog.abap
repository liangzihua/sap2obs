*&---------------------------------------------------------------------*
*& Report ZOBS_ATTCH_DOWNLOAD_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zobs_demo_attch_copy.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_srcbkt TYPE zzbucket_obs DEFAULT 'sap-mm-attachment '.
  PARAMETERS: p_srcobj TYPE zzobjectkey_obs.
  PARAMETERS: p_dstbkt TYPE zzbucket_obs DEFAULT 'sap-mm-attachment '.
  PARAMETERS: p_dstobj TYPE zzobjectkey_obs.
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-s02.
    PARAMETERS: p_copy1 RADIOBUTTON GROUP gp1.
    PARAMETERS: p_copy2 RADIOBUTTON GROUP gp1 DEFAULT 'X'.
  SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  "复制对象
  PERFORM frm_copy_attachment.

*&---------------------------------------------------------------------*
*& Form frm_copy_attachment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_copy_attachment.
  DATA: lo_obs          TYPE REF TO  zcl_obs,
        lv_sourceobject TYPE string,
        lv_destobject   TYPE string,
        ls_return       TYPE bapiret2,
        ls_result       TYPE zobss_result.


  CREATE OBJECT lo_obs.

  lv_sourceobject = p_srcobj.
  lv_destobject   = p_dstobj.

  IF p_copy1 IS NOT INITIAL.
    "直接调用华为云OBS的复制方法
    CALL METHOD lo_obs->copy_attachment
      EXPORTING
        iv_sourcebucket = p_srcbkt
        iv_sourceobject = lv_sourceobject
        iv_destbucket   = p_dstbkt
        iv_destobject   = lv_destobject
      IMPORTING
        es_return       = ls_return
        es_result       = ls_result.
  ELSE.
    "先下载再上载
    CALL METHOD lo_obs->copy_attachment_new
      EXPORTING
        iv_sourcebucket = p_srcbkt
        iv_sourceobject = lv_sourceobject
        iv_destbucket   = p_dstbkt
        iv_destobject   = lv_destobject
      IMPORTING
        es_return       = ls_return
        es_result       = ls_result.
  ENDIF.

  IF ls_return IS NOT INITIAL..
    MESSAGE ID ls_return-id
          TYPE 'S'
        NUMBER ls_return-number
          WITH ls_return-message_v1
               ls_return-message_v2
               ls_return-message_v3
               ls_return-message_v4
               DISPLAY LIKE ls_return-type.

  ENDIF.



ENDFORM.
