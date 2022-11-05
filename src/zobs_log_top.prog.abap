*&---------------------------------------------------------------------*
*& 包含               ZOBS_LOG_TOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,
        zobss_log_selscreen.


DATA: go_obs      TYPE REF TO zcl_obs,
      gt_logdata TYPE zobstt_log_alv,
      gs_logdata TYPE zobss_log_alv.


DATA: gt_log       TYPE TABLE OF zobs_log,
      go_container TYPE REF TO cl_gui_docking_container,
      go_grid      TYPE REF TO cl_gui_alv_grid.


DATA: gv_title        TYPE cua_tit_tx,
      gv_col_pos      TYPE lvc_colpos,
      gt_fcat         TYPE lvc_t_fcat,
      gs_layout       TYPE lvc_s_layo,
      gs_variant      TYPE disvariant,
      gt_alv_extab    TYPE slis_t_extab,
      gv_grid_title   TYPE lvc_title,
      gv_pf_status    TYPE slis_formname VALUE 'FRM_PF_STATUS_SET',
      gv_user_command TYPE slis_formname VALUE 'FRM_USER_COMMAND'.

DATA: ok_code TYPE sy-ucomm,
      save_ok TYPE sy-ucomm.

*----------------------------------------------------------------------*
*  Selection Screen
*----------------------------------------------------------------------*

SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.

  SELECT-OPTIONS: s_bucket FOR zobss_log_selscreen-bucket    ,
                  s_objkey FOR zobss_log_selscreen-objectkey MODIF ID m02,
                  s_action FOR zobss_log_selscreen-action    MODIF ID m02,
                  s_logid  FOR zobss_log_selscreen-logid     MODIF ID m02,
                  s_code   FOR zobss_log_selscreen-code      MODIF ID m02,
                  s_uname  FOR zobss_log_selscreen-uname     MODIF ID m02,
                  s_udate  FOR zobss_log_selscreen-udate     MODIF ID m02 DEFAULT sy-datum,
                  s_utime  FOR zobss_log_selscreen-utime     MODIF ID m02,
                  s_type   FOR zobss_log_selscreen-type      MODIF ID m02.
  PARAMETERS: p_psize TYPE i DEFAULT 10000  MODIF ID m01.
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-s02.

    PARAMETERS: r_view  RADIOBUTTON GROUP gp1 USER-COMMAND sel DEFAULT 'X',
                r_clear RADIOBUTTON GROUP gp1.
  SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.
