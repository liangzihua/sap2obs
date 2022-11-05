*----------------------------------------------------------------------*
* Object          :  ZOBS_LOG
* FS ID           :  FICI0001
* Functional Owner:  文俊
* Description     :  记录OBS日志
*
*----------------------------------------------------------------------*
* TR No.      Date         Author      Description
* S4DK902804  2020.12.25  梁子华      初始版本
*
*----------------------------------------------------------------------*

REPORT zobs_log NO STANDARD PAGE HEADING MESSAGE-ID zobs.

INCLUDE zobs_log_top.
INCLUDE zobs_log_f01.
INCLUDE zobs_log_o01.
INCLUDE zobs_log_i01.


INITIALIZATION.
  PERFORM frm_initial.

AT SELECTION-SCREEN.
  PERFORM frm_function_key.

AT SELECTION-SCREEN OUTPUT.
  PERFORM frm_modify_screen.


START-OF-SELECTION.
  IF r_clear IS NOT INITIAL.
    PERFORM frm_clear_log.
  ELSE.
    PERFORM frm_display_log.
  ENDIF.

END-OF-SELECTION.
