FUNCTION zfm_obs_log_clear.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(IS_CONFIG) TYPE  ZOBS_CONFIG
*"     VALUE(IV_CLEARDATE) TYPE  ZCLEARDATE_OBS
*"----------------------------------------------------------------------
  "清理OBS日志
  DATA: lo_obs    TYPE REF TO zcl_obs,
        lt_bucket TYPE zbucket_range_tab,
        ls_bucket TYPE zbucket_range.

  CLEAR: ls_bucket .
  ls_bucket-sign   = 'I'.
  ls_bucket-option = 'EQ'.
  ls_bucket-low    = is_config-bucket.
  APPEND ls_bucket TO lt_bucket .

  IF lo_obs IS INITIAL.
    CREATE OBJECT lo_obs.
  ENDIF.

  "日志清理
  CALL METHOD lo_obs->clear_obs_log
    EXPORTING
      it_bucket    = lt_bucket[]
      iv_cleardate = iv_cleardate.

  FREE lo_obs.



ENDFUNCTION.
