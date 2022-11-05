*&---------------------------------------------------------------------*
*& Report ZOBS_DEMO_LIST_BUCKET_OBJECTS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zobs_demo_list_bucket_objects NO STANDARD PAGE HEADING MESSAGE-ID zobs.
DATA: gr_table TYPE REF TO cl_salv_table,
      gr_salv  TYPE REF TO zcl_salv.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_bucket TYPE zzbucket_obs DEFAULT 'sap-mm-attachment'.
  PARAMETERS: p_prefix TYPE zzprefix_obs DEFAULT ''.

SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.

  PERFORM frm_get_object_list.


*&---------------------------------------------------------------------*
*& Form frm_GET_OBJECT_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_get_object_list .
  DATA: ls_return	TYPE bapiret2,
        ls_result	TYPE zobss_result.

  DATA(lr_obs) = zcl_obs=>factory( ).

  DATA(lt_object_list) = lr_obs->list_bucket_objects(
    EXPORTING
      iv_bucketname = p_bucket                 " OBS桶
      iv_prefix     = p_prefix
    IMPORTING
      es_return     = ls_return               " 返回参数
  ).

  IF lt_object_list IS NOT INITIAL.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = gr_table
          CHANGING
            t_table      = lt_object_list
        ).

        gr_salv = zcl_salv=>factory( ).
        gr_salv->display(
          EXPORTING
            ir_table = gr_table
          CHANGING
            ct_data  = lt_object_list
        ).

      CATCH cx_salv_msg. " ALV: General Error Class with Message

    ENDTRY.
  ENDIF.


ENDFORM.
