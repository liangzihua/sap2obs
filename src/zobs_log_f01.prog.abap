*&---------------------------------------------------------------------*
*& 包含               ZOBS_LOG_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form frm_initial
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_initial .
  DATA: ls_functxt TYPE smp_dyntxt.

  CLEAR:ls_functxt.
  ls_functxt-icon_id = '@BX@'.
  ls_functxt-icon_text = TEXT-fc1.
  ls_functxt-quickinfo = TEXT-fc1.
  sscrfields-functxt_01 = ls_functxt.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_function_key
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_function_key .
  DATA: lv_objid    TYPE w3objid,
        lv_filename TYPE string.

  CLEAR: lv_objid   ,
         lv_filename.

  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      PERFORM frm_view_maintenance_call  USING 'S' 'ZOBSV_CONFIG'.

    WHEN ''.
    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_view_maintenance_call
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_view_maintenance_call USING uv_action
                                     uv_view_name TYPE dd02v-tabname.
  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = uv_action
      view_name                    = uv_view_name
    EXCEPTIONS
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      OTHERS                       = 15.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_modify_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_modify_screen .
  LOOP AT SCREEN.
    IF r_clear IS NOT INITIAL.
      IF screen-group1 IS INITIAL OR screen-group1 = 'M01'.
        screen-input     = 1.
        screen-active    = 1.
        screen-invisible = 0.

      ELSE.
        screen-input     = 0.
        screen-active    = 0.
        screen-invisible = 1.
      ENDIF.
    ELSE.

      IF screen-group1 IS INITIAL OR screen-group1 = 'M02'.
        screen-input     = 1.
        screen-active    = 1.
        screen-invisible = 0.

      ELSE.
        screen-input     = 0.
        screen-active    = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_clear_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_clear_log .
  DATA: lo_obs TYPE REF TO zcl_obs.
  IF lo_obs IS INITIAL.
    CREATE OBJECT lo_obs.
  ENDIF.

  CALL METHOD lo_obs->clear_obs_log
    EXPORTING
      it_bucket  = s_bucket[]
      iv_package = p_psize.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_display_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_display_log .
  DATA: lo_obs TYPE REF TO zcl_obs.
  IF lo_obs IS INITIAL.
    CREATE OBJECT lo_obs.
  ENDIF.

  CALL METHOD lo_obs->diaplay_obs_log
    EXPORTING
      it_logid     = s_logid[]
      it_bucket    = s_bucket[]
      it_objectkey = s_objkey[]
      it_action    = s_action[]
      it_code      = s_code[]
      it_uname     = s_uname[]
      it_udate     = s_udate[]
      it_utime     = s_utime[]
      it_type      = s_type[].


*  PERFORM frm_get_logdata.
*
*
*  "布局
*  PERFORM frm_set_layout USING 'X'
*                               'X'
*                               ' '
*                               ' '
*                               'LOG'
*                      CHANGING gs_layout
*                               gs_variant     .
*
*  "构建字段目录
*  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
*    EXPORTING
*     i_buffer_active        = ''
*     i_structure_name       = 'ZOBSS_LOG_ALV'
*     i_bypassing_buffer     = ''
*    CHANGING
*     ct_fieldcat  = gt_fcat
*    EXCEPTIONS
*     inconsistent_interface = 1
*     program_error          = 2
*     OTHERS       = 3.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*  PERFORM frm_change_fcat.
*
*
*  " Call ALV
*  PERFORM frm_call_alv USING sy-repid
*                             gv_pf_status
*                             gv_user_command
*                             gv_grid_title
*                             gs_variant
*                             gs_layout
*                             gt_fcat
*                             gt_alv_extab
*                             gt_logdata    .
                     endform.
*&---------------------------------------------------------------------*
*& Form frm_get_logdata
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_get_logdata .
  DATA: lt_log TYPE TABLE OF zobs_log,
        ls_log TYPE zobs_log.



  "获取日志数据
  SELECT *
    INTO TABLE lt_log
    FROM zobs_log
   WHERE bucket    IN s_bucket
     AND objectkey IN s_objkey
     AND code      IN s_code
     AND type      IN s_type
     AND uname     IN s_uname
     AND udate     IN s_udate
     AND utime     IN s_utime.
  LOOP AT lt_log INTO ls_log.
    CLEAR: gs_logdata.
    MOVE-CORRESPONDING ls_log TO gs_logdata.

    IF gs_logdata-bizdata IS NOT INITIAL.
      IF gs_logdata-code = 200.
        gs_logdata-zaction = TEXT-a01.
      ELSE.
        gs_logdata-zaction = TEXT-a02.

      ENDIF.
    ENDIF.
    APPEND gs_logdata TO gt_logdata.

  ENDLOOP.

ENDFORM.

FORM frm_call_alv USING uv_repid         TYPE sy-repid
                        uv_pf_status_set TYPE slis_formname
                        uv_user_command  TYPE slis_formname
                        uv_grid_title    TYPE lvc_title
                        us_variant       TYPE disvariant
                        us_layout        TYPE lvc_s_layo
                        ut_fcat          TYPE lvc_t_fcat
                        ut_excluding     TYPE slis_t_extab
                        ut_outtab        TYPE STANDARD TABLE.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = uv_repid
      i_callback_pf_status_set = uv_pf_status_set
      i_callback_user_command  = uv_user_command
      i_grid_title             = uv_grid_title
      is_layout_lvc            = us_layout
      it_fieldcat_lvc          = ut_fcat
      it_excluding             = ut_excluding
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = us_variant
    TABLES
      t_outtab                 = ut_outtab
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.

  ENDIF.

ENDFORM.

FORM frm_pf_status_set USING rt_extab TYPE slis_t_extab.
  DATA: ls_extab TYPE slis_extab.

  REFRESH: rt_extab.
*  ls_extab-fcode = ''.
*  APPEND ls_extab TO rt_extab.


  IF gv_title IS INITIAL .
    gv_title = sy-title.
  ENDIF.
  SET TITLEBAR 'TITLE' WITH gv_title.
  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING rt_extab.
ENDFORM.


FORM frm_user_command USING r_ucomm     LIKE sy-ucomm
                            rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1'.
      IF rs_selfield-fieldname = 'ICON'.
        CLEAR: gs_logdata .
        READ TABLE gt_logdata INTO gs_logdata INDEX rs_selfield-tabindex.
        IF sy-subrc EQ 0 AND gs_logdata-bizdata IS NOT INITIAL.
          PERFORM frm_display_detail USING gs_logdata.
        ENDIF.
      ENDIF.


*      rs_selfield-refresh = 'X'.


    WHEN OTHERS.
  ENDCASE.
ENDFORM.


*----------------------------------------------------------------------*
*       FORM frm_set_layout
*----------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_set_layout USING uv_zebra TYPE lvc_zebra
                          uv_cwidth_opt TYPE lvc_cwo
                          uv_info_fname TYPE lvc_cifnm
                          uv_box_fname  TYPE lvc_fname
                          uv_handle     TYPE disvariant-handle
                CHANGING  cs_layout     TYPE lvc_s_layo
                          cs_variant    TYPE disvariant.
  CLEAR: cs_layout ,
         cs_variant.

  cs_layout-zebra      = uv_zebra       .
  cs_layout-cwidth_opt = uv_cwidth_opt  .
  cs_layout-info_fname = uv_info_fname  .
  cs_layout-box_fname  = uv_box_fname   .
  cs_layout-col_opt    = abap_true      .
  cs_variant-handle    = uv_handle      .
  cs_variant-report    = sy-repid       .

ENDFORM.
*----------------------------------------------------------------------*
*       FORM frm_build_fcat
*----------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_build_fcat USING uv_fieldname
                          uv_reptext   TYPE reptext
                          uv_ref_table TYPE lvc_rtname
                          uv_ref_field TYPE lvc_rfname
                          uv_key       TYPE lvc_key
                          uv_nozero    TYPE lvc_nozero
                          uv_dosum     TYPE lvc_dosum
                          uv_convexit  TYPE convexit
                          uv_edit      TYPE lvc_edit
                          uv_checkbox  TYPE lvc_checkb
                          uv_noout     TYPE lvc_noout
                          uv_hotspot   TYPE lvc_hotspt
                CHANGING  cv_col_pos
                          ct_fcat      TYPE lvc_t_fcat.

  DATA:lv_fieldname   TYPE lvc_fname.
  FIELD-SYMBOLS:<lfs_fcat> TYPE lvc_s_fcat.
  lv_fieldname = uv_fieldname.
  CONDENSE lv_fieldname NO-GAPS.

  APPEND INITIAL LINE TO ct_fcat ASSIGNING <lfs_fcat>.
  cv_col_pos = cv_col_pos + 1.
  <lfs_fcat>-col_pos     = cv_col_pos.
  <lfs_fcat>-fieldname   = lv_fieldname.
  <lfs_fcat>-reptext     = uv_reptext.
  <lfs_fcat>-ref_table   = uv_ref_table.
  <lfs_fcat>-ref_field   = uv_ref_field.
  <lfs_fcat>-key         = uv_key.
  <lfs_fcat>-coltext     = uv_reptext.
  <lfs_fcat>-scrtext_l   = uv_reptext.
  <lfs_fcat>-scrtext_m   = uv_reptext.
  <lfs_fcat>-scrtext_s   = uv_reptext.
  <lfs_fcat>-no_zero     = uv_nozero.
  <lfs_fcat>-do_sum      = uv_dosum.
  <lfs_fcat>-convexit    = uv_convexit.
  <lfs_fcat>-edit        = uv_edit.
  <lfs_fcat>-checkbox    = uv_checkbox.
  <lfs_fcat>-no_out      = uv_noout.
  <lfs_fcat>-hotspot     = uv_hotspot.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_change_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_change_fcat .
  FIELD-SYMBOLS: <lfs_fcat> TYPE lvc_s_fcat.

  LOOP AT gt_fcat ASSIGNING <lfs_fcat>..
    CASE <lfs_fcat>-fieldname.
      WHEN 'LOGID'.
        <lfs_fcat>-key     = abap_true.
        <lfs_fcat>-col_pos = 1.
      WHEN 'BUCKET'.
        <lfs_fcat>-col_pos = 2.
      WHEN 'OBJECTKEY '.
        <lfs_fcat>-col_pos = 3.
      WHEN 'CODE '.
        <lfs_fcat>-col_pos = 4.
      WHEN 'REASON '.
        <lfs_fcat>-col_pos = 5.
      WHEN 'ICON '.
        <lfs_fcat>-col_pos   = 6.
        <lfs_fcat>-hotspot   = abap_true.
        <lfs_fcat>-reptext   = TEXT-c01.
        <lfs_fcat>-scrtext_l = TEXT-c01.
        <lfs_fcat>-scrtext_m = TEXT-c01.
        <lfs_fcat>-scrtext_s = TEXT-c01.
      WHEN 'UNAME '.
        <lfs_fcat>-col_pos = 7.
      WHEN 'UDATE '.
        <lfs_fcat>-col_pos = 8.
      WHEN 'UTIME '.
        <lfs_fcat>-col_pos = 9.
      WHEN 'ACCESSKEYID'.
        <lfs_fcat>-col_pos = 10.
      WHEN 'EXPIRES '.
        <lfs_fcat>-col_pos = 11.
      WHEN 'SIGNATURE '.
        <lfs_fcat>-col_pos = 12.
*      WHEN 'MESSAGE '.
*        <lfs_fcat>-col_pos = 13.
*      WHEN 'ZACTION '.
*        <lfs_fcat>-col_pos = 14.
*        <lfs_fcat>-hotspot = abap_true.
      WHEN OTHERS.
        <lfs_fcat>-no_out = abap_true.
    ENDCASE.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_display_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LOGDATA
*&---------------------------------------------------------------------*
FORM frm_display_detail USING us_logdata TYPE zobss_log_alv.
  DATA: lo_obs        TYPE REF TO zcl_obs,
        lv_filename   TYPE string,
        lt_string_tab TYPE TABLE OF string,
        ls_string     TYPE string,
        lv_line       TYPE i.
  IF lo_obs IS INITIAL.
    CREATE OBJECT lo_obs.
  ENDIF.

  SPLIT us_logdata-objectkey AT '/' INTO TABLE lt_string_tab.

  DESCRIBE TABLE lt_string_tab LINES lv_line.

  READ TABLE lt_string_tab INTO ls_string INDEX lv_line.
  IF sy-subrc EQ 0.
    lv_filename = ls_string.
  ENDIF.

  lo_obs->display_log_html( iv_caption = lv_filename " us_logdata-objectkey
                            iv_data    = us_logdata-bizdata ).

*  DATA:lt_bizdata TYPE TABLE OF string.
*
*  IF us_logdata-code = 200.
*    SPLIT us_logdata-bizdata AT cl_abap_char_utilities=>cr_lf INTO TABLE lt_bizdata.
*    cl_demo_output=>display( lt_bizdata ).
*  ELSE.
*    cl_demo_output=>display_xml( us_logdata-bizdata ).
*    cl_demo_output=>display_html( us_logdata-bizdata ).
*
*  ENDIF.
ENDFORM.
