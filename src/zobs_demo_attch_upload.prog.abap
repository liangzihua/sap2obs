*&---------------------------------------------------------------------*
*& Report ZOBS_ATTCH_UPLOAD_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zobs_demo_attch_upload.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_bucket TYPE zzbucket_obs DEFAULT 'mrm-attachment'.
  PARAMETERS: p_file TYPE rlgrap-filename MEMORY ID zfilename.

SELECTION-SCREEN END OF BLOCK b1.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM frm_select_file CHANGING p_file.

START-OF-SELECTION.
  "上载文件
  PERFORM frm_upload_file.

*&---------------------------------------------------------------------*
*& Form frm_upload_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_upload_file .
  DATA: lo_obs       TYPE REF TO  zcl_obs,
        lv_filename  TYPE string,
        lv_objectkey TYPE string.

  lv_filename = p_file.

  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = lv_filename
    IMPORTING
      stripped_name = lv_objectkey
*     FILE_PATH     =
    EXCEPTIONS
      x_error       = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  lv_objectkey = '/sapdemo/'&& sy-sysid && '/' && sy-datum && '/' && lv_objectkey.


  CREATE OBJECT lo_obs.

  CALL METHOD lo_obs->upload_attachment
    EXPORTING
      iv_bucketname = p_bucket
      iv_filename   = lv_filename
      iv_objectkey  = lv_objectkey
*     iv_expires    = 3600
    IMPORTING
      es_return     = DATA(ls_return).

    IF ls_return IS NOT INITIAL..
      MESSAGE ID ls_return-id
            TYPE ls_return-type
          NUMBER ls_return-number
            WITH ls_return-message_v1
                 ls_return-message_v2
                 ls_return-message_v3
                 ls_return-message_v4.

    ENDIF.
*  cl_demo_output=>display( data = ls_return ).
*  .


ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_select_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_select_file CHANGING cv_file TYPE rlgrap-filename .
  DATA: lt_filetable TYPE filetable,
        ls_filetable TYPE file_table,
        lv_subrc     TYPE i,
        lv_title     TYPE string..


  lv_title = TEXT-t01.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lv_title
*      file_filter             = 'Excel(*.xlsx)|*.xlsx|Excel(*.xls)|*.xls'
    CHANGING
      file_table              = lt_filetable
      rc                      = lv_subrc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc EQ 0.
    LOOP AT lt_filetable INTO ls_filetable.
      cv_file = ls_filetable-filename.
    ENDLOOP.
  ENDIF.

ENDFORM.
