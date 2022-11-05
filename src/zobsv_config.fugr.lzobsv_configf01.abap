*&---------------------------------------------------------------------*
*& 包含               LZOBSV_CONFIGF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FRM_NEW_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_new_entry .
  FIELD-SYMBOLS: <lfs_table> TYPE zobsv_config.
  IF x_header-maintview = 'ZOBSV_CONFIG'.

    ASSIGN <table1> TO <lfs_table>.
    <lfs_table>-ernam = sy-uname.
    <lfs_table>-erdat = sy-datum.
    <lfs_table>-erzet = sy-uzeit.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_FILL_HIDDEN_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_fill_hidden_field .
  FIELD-SYMBOLS: <lfs_table> TYPE zobsv_config.
  IF x_header-maintview = 'ZOBSV_CONFIG'.

    ASSIGN <table1> TO <lfs_table>.
    <lfs_table>-aenam = sy-uname.
    <lfs_table>-aedat = sy-datum.
    <lfs_table>-aezet = sy-uzeit.
  ENDIF.
ENDFORM.
