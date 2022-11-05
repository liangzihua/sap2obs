*&---------------------------------------------------------------------*
*& Report ZOBS_DEMO_ATTCH_DELETE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zobs_demo_attch_delete.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_bucket TYPE zzbucket_obs DEFAULT 'mrm-attachment'.
  PARAMETERS: p_objkey TYPE zzobjectkey_obs .

SELECTION-SCREEN END OF BLOCK b1.




START-OF-SELECTION.
  "上载文件
  PERFORM frm_delete_attachment .

*&---------------------------------------------------------------------*
*& Form frm_delete_attachment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_delete_attachment .
  DATA: lo_obs       TYPE REF TO  zcl_obs,
        lv_filename  TYPE string,
        lv_objectkey TYPE string,
        ls_return    TYPE bapiret2,
        lv_message   TYPE string.


  CREATE OBJECT lo_obs.

  lv_objectkey = p_objkey.

  CALL METHOD lo_obs->delete_attachment
    EXPORTING
      iv_bucketname = p_bucket
      iv_objectkey  = lv_objectkey
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


ENDFORM.
