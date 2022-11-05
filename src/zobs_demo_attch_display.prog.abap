*&---------------------------------------------------------------------*
*& Report ZOBS_ATTCH_DOWNLOAD_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zobs_demo_attch_display.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_bucket TYPE zzbucket_obs DEFAULT 'mrm-attachment'.
  PARAMETERS: p_objkey TYPE zzobjectkey_obs .

SELECTION-SCREEN END OF BLOCK b1.



START-OF-SELECTION.
*  CALL SCREEN 9000.
  "显示对象
  PERFORM frm_display_attachment.

*&---------------------------------------------------------------------*
*& Form frm_display_attachment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_display_attachment.
  DATA: lo_obs        TYPE REF TO  zcl_obs,
        lv_objectkey  TYPE string,
        lv_destobject TYPE string,
        ls_return     TYPE bapiret2.


  CREATE OBJECT lo_obs.

  lv_objectkey = p_objkey.

  CALL METHOD lo_obs->display_attachment
    EXPORTING
      iv_bucketname = p_bucket
      iv_objectkey  = lv_objectkey
      iv_dialog     = abap_false   "选择屏幕调用，参数设为空
    IMPORTING
      es_return     = ls_return.

  IF ls_return IS NOT INITIAL..
    MESSAGE ID ls_return-id
          TYPE ls_return-type
        NUMBER ls_return-number
          WITH ls_return-message_v1
               ls_return-message_v2
               ls_return-message_v3
               ls_return-message_v4.

  ENDIF.



ENDFORM.
