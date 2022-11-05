FUNCTION zfm_obs_log_clear_auto.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(IS_CONFIG) TYPE  ZOBS_CONFIG
*"----------------------------------------------------------------------
  "清理OBS日志
  DATA: lo_obs    TYPE REF TO zcl_obs,
        ls_config TYPE zobs_config.
  IF lo_obs IS INITIAL.
    CREATE OBJECT lo_obs.
  ENDIF.
  "日志清理
  CALL METHOD lo_obs->clear_obs_log_auto
    EXPORTING
      is_config = is_config.

  FREE lo_obs.


ENDFUNCTION.
