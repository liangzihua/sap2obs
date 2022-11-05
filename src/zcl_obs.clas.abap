class ZCL_OBS definition
  public
  final
  create public .

public section.

  interfaces ZIF_SALV_EVENT_HANDLER .

  constants C_TRUE type STRING value 'true' ##NO_TEXT.
  constants C_FALSE type STRING value 'false' ##NO_TEXT.
  constants C_AUTHORTYPE_HEADER type ZAUTHORTYPE_OBS value 'HEADER' ##NO_TEXT.
  constants C_HTTP_PUT type STRING value 'PUT' ##NO_TEXT.
  constants C_HTTP_GET type STRING value 'GET' ##NO_TEXT.
  constants C_HTTP_DELETE type STRING value 'DELETE' ##NO_TEXT.
  constants C_ACTION_UPLOAD type ZZACTION_OBS value 'UPLOAD' ##NO_TEXT.         "上载
  constants C_ACTION_DOWNLOAD type ZZACTION_OBS value 'DOWNLOAD' ##NO_TEXT.         "下载
  constants C_ACTION_DELETE type ZZACTION_OBS value 'DELETE' ##NO_TEXT.         "删除
  constants C_ACTION_COPY type ZZACTION_OBS value 'COPY' ##NO_TEXT.          "复制
  constants C_ACTION_DISPLAY type ZZACTION_OBS value 'DISPLAY' ##NO_TEXT.         "显示
  constants C_ACTION_GETOBJLIST type ZZACTION_OBS value 'GETOBJLIST' ##NO_TEXT.
  constants FILETYPE_DOC type STRING value 'DOC' ##NO_TEXT.
  constants FILETYPE_DOCX type STRING value 'DOCX' ##NO_TEXT.
  constants FILETYPE_XLS type STRING value 'XLS ' ##NO_TEXT.
  constants FILETYPE_XLSX type STRING value 'XLSX' ##NO_TEXT.
  constants FILETYPE_PPT type STRING value 'PPT ' ##NO_TEXT.
  constants FILETYPE_PPTX type STRING value 'PPTX' ##NO_TEXT.
  constants FILETYPE_PDF type STRING value 'PDF' ##NO_TEXT.
  constants FILETYPE_TXT type STRING value 'TXT' ##NO_TEXT.
  constants FILETYPE_CSV type STRING value 'CSV' ##NO_TEXT.
  constants FILETYPE_BMP type STRING value 'BMP' ##NO_TEXT.
  constants FILETYPE_JPG type STRING value 'JPG' ##NO_TEXT.
  constants FILETYPE_PNG type STRING value 'PNG' ##NO_TEXT.
  constants FILETYPE_TIF type STRING value 'TIF' ##NO_TEXT.
  constants FILETYPE_GIF type STRING value 'GIF' ##NO_TEXT.
  constants APP_TYPE_HTML type STRING value 'HTML' ##NO_TEXT.
  constants APP_TYPE_OLE type STRING value 'OLE' ##NO_TEXT.

  class-methods FACTORY
    returning
      value(VALUE) type ref to ZCL_OBS .
  methods LIST_BUCKET_OBJECTS
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IV_PREFIX type ZZPREFIX_OBS optional
    exporting
      !ES_RETURN type BAPIRET2
    returning
      value(RT_OBJECT_LIST) type ZOBSTT_LIST_BUCKET_RESULT .
  methods CONSTRUCTOR .
  class-methods GUI_DOWNLOAD
    importing
      !IV_FILENAME type STRING
      !IV_DATA type XSTRING
    exceptions
      ERROR .
  methods DISPLAY_LOG_HTML
    importing
      !IV_CAPTION type ANY optional
      !IV_TYPE type ANY default 'text'
      !IV_SUBTYPE type ANY default 'html'
      !IV_DATA type STRING
      !IV_WIDTH type INT4 default 1000
      !IV_HEIGHT type INT4 default 300
      !IV_TOP type INT4 default 10
      !IV_LEFT type INT4 default 5 .
  methods CALC_SIGNTRUE
    importing
      !IS_BC000501_REQ type ZPIDT_BC000501_REQ
    exporting
      !ES_RETURN type BAPIRET2
    returning
      value(RS_SIGNTRUE) type ZOBST_SIGNTRUE .
  methods CLEAR_OBS_LOG
    importing
      !IT_BUCKET type ZBUCKET_RANGE_TAB optional
      !IV_PACKAGE type INT4 default 10000
      !IV_CLEARDATE type ZCLEARDATE_OBS optional .
  methods CLEAR_OBS_LOG_AUTO
    importing
      !IS_CONFIG type ZOBS_CONFIG .
  methods DIAPLAY_OBS_LOG
    importing
      !IT_LOGID type ZLOGID_OBS_RANGE_TAB optional
      !IT_BUCKET type ZBUCKET_RANGE_TAB optional
      !IT_OBJECTKEY type ZOBJECTKEY_RANGE_TAB optional
      !IT_ACTION type ZOBSACTION_RANGE_TAB optional
      !IT_CODE type ZCODE_OBS_RANGE_TAB optional
      !IT_UNAME type UNAME_RANGE_TAB optional
      !IT_UDATE type DATE_T_RANGE optional
      !IT_UTIME type ZUTIME_OBS_RANGE_TAB optional
      !IT_TYPE type ZMSGTY_OBS_RANGE_TAB optional .
  methods SAVE_SIGNTRUE
    importing
      !IV_UUID type STRING
      !IV_JSON type STRING .
  class-methods GET_NUMBER
    importing
      !IV_OBJECT type NROBJ
      !IV_NRRANGENR type NRNR default '01'
    exporting
      !EV_NUMBER type ANY
    exceptions
      OBJECT_NOT_FOUND
      INVAILD_LENGTH .
  methods GET_SIGNTRUE
    importing
      !IS_SIGNTRUE_REQ type ZOBSS_SIGNTRUE_REQ
    exporting
      !ES_RETURN type BAPIRET2
    returning
      value(RS_SIGNTRUE) type ZOBST_SIGNTRUE .
  methods DOWNLOAD_FILE
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IV_HTTPMETHOD type ZZHTTPMETHOD_OBS default 'GET'
      !IV_OBJECTKEY type STRING
      !IV_EXPIRES type INT4 default 3600
      !IV_NEWLINE type CHAR1 default 'X'
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  methods DELETE_ATTACHMENT
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IV_OBJECTKEY type STRING
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  methods DOWNLOAD_ATTACHMENT
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IV_OBJECTKEY type STRING
      !IV_FILETYPE type CHAR10 default 'BIN'
      !IV_DIRECT_DOWN type CHAR1 default 'X'
      !IV_NEWLINE type CHAR1 default 'X'
      !IV_DEFAULT_FILENAME type STRING default ''
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  methods DISPLAY_ATTACHMENT
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IV_OBJECTKEY type STRING
      !IV_DIALOG type CHAR1 default 'X'
    exporting
      !ES_RETURN type BAPIRET2 .
  methods HANDLE_CLOSE
    for event CLOSE of CL_GUI_DIALOGBOX_CONTAINER
    importing
      !SENDER .
  methods UPLOAD_ATTACHMENT
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IV_FILENAME type STRING optional
      !IV_DATA type XSTRING optional
      !IV_OBJECTKEY type STRING
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  methods COPY_ATTACHMENT
    importing
      !IV_SOURCEBUCKET type ZZBUCKET_OBS
      !IV_SOURCEOBJECT type STRING
      !IV_DESTBUCKET type ZZBUCKET_OBS
      !IV_DESTOBJECT type STRING
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  methods COPY_ATTACHMENT_NEW
    importing
      !IV_SOURCEBUCKET type ZZBUCKET_OBS
      !IV_SOURCEOBJECT type STRING
      !IV_DESTBUCKET type ZZBUCKET_OBS
      !IV_DESTOBJECT type STRING
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  class-methods GUI_UPLOAD
    importing
      !IV_FILENAME type STRING
    exporting
      !EV_FILELENGTH type INT4
    returning
      value(RV_DATA) type XSTRING
    exceptions
      ERROR .
  methods HTML_SHOW
    importing
      !IV_DATA type XSTRING
      !IV_TYPE type TEXT20
      !IV_SUBTYPE type TEXT20
      !IV_FILENAME type STRING
    exporting
      !ES_RETURN type BAPIRET2 .
  methods OLE_SHOW
    importing
      !IV_DATA type XSTRING
      !IV_TYPE type TEXT20
      !IV_SUBTYPE type TEXT20
      !IV_FILENAME type STRING
    exporting
      !ES_RETURN type BAPIRET2 .
  class-methods TEXT_CONVERT
    changing
      !CV_DATA type XSTRING .
  PROTECTED SECTION.
private section.

  data MT_OBJECT_LIST type ZOBSTT_LIST_BUCKET_RESULT .
  data MT_PARAMETERS type ZOBSTT_HTTP_PARA_LIST .
  data MT_HTTP_HEADER type ZOBSTT_HTTP_HEADER .
  data MS_SIGNTRUE type ZOBST_SIGNTRUE .
  data MV_BUCKETNAME type ZZBUCKET_OBS .                "桶名
  data MV_OBJECTKEY type STRING .                  "对象
  data MS_SIGNTRUE_REQ type ZOBSS_SIGNTRUE_REQ .              "OBS签名计算请求参数
  data MV_HTTP_METHOD type STRING .
  data MV_ACTION type ZZACTION_OBS .
  data MS_OBS_CONFIG type ZOBS_CONFIG .
  data MT_LOG type ZOBSTT_LOG .
  data C_LOGLIFE type ZZLOGLIFE_OBS value 180 ##NO_TEXT.
  data HTML_VIEWER type ref to CL_GUI_HTML_VIEWER .
  data DOCU_CONTAINER type ref to CL_GUI_DIALOGBOX_CONTAINER .
  constants C_CONTENTTYPE_BIN type STRING value 'application/octet-stream' ##NO_TEXT.
  constants C_DIR_SEPFLAG type CHAR1 value '\' ##NO_TEXT.
  constants C_AUTHORTYPE_URL type ZAUTHORTYPE_OBS value 'URL' ##NO_TEXT.
  constants C_ZLOGID_OBS type NROBJ value 'ZLOGID_OBS' ##NO_TEXT.

  methods PARSE_LIST_BUCKET_RESULT
    importing
      !XMLDATA type STRING
    exporting
      !NEXTMARKER type ZZOBS_NEXTMARKER
    returning
      value(IS_TRUNCATED) type STRING .
  methods PARSE_DOM_DOCUMENT
    importing
      !DOCUMENT type ref to IF_IXML_DOCUMENT
    exporting
      !NEXTMARKER type ZZOBS_NEXTMARKER
    returning
      value(IS_TRUNCATED) type STRING .
  methods SET_URL_PARAMETERS
    importing
      !NAME type STRING
      !VALUE type ANY
      !PARAMETERS type STRING
    returning
      value(R_PARAMETERS) type STRING .
  methods DELETE_OBJECT
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IV_OBJECTKEY type STRING
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  methods DOWNLOAD_OBJECT
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IV_OBJECTKEY type STRING
      !IV_FILETYPE type CHAR10 default 'BIN'
      !IV_DIRECT_DOWN type CHAR1 default 'X'
      !IV_NEWLINE type CHAR1 default 'X'
      !IV_DEFAULT_FILENAME type STRING default ''
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  methods UPLOAD_OBJECT
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IV_FILENAME type STRING optional
      !IV_DATA type XSTRING optional
      !IV_OBJECTKEY type STRING
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  methods GET_DEFAULT_FILENAME
    importing
      !IV_OBJECTKEY type STRING
    exporting
      !EV_FILENAME type STRING
      !EV_EXTENSION type STRING .
  class-methods GET_HTTPMETHOD_BY_ACTION
    importing
      !IV_ACTION type ZZACTION_OBS
    returning
      value(RV_HTTPMETHOD) type STRING .
  methods ADJUST_OBJECTKEY
    exporting
      !ES_RETURN type BAPIRET2
    changing
      !CV_OBJECTKEY type ANY .
  methods CALL_OBS_HTTPCLIENT
    importing
      !IV_OBJECTKEY type STRING
      !IV_OBSCOPYSOURCE type STRING optional
      !IV_DATA type XSTRING optional
      !IV_CDATA type STRING optional
      !IV_LENGTH type INT4 optional
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  methods GET_OBS_OBJECT_LIST
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IT_PARAMETERS type ZOBSTT_HTTP_PARA_LIST optional
    exporting
      !ES_RETURN type BAPIRET2
      !ES_RESULT type ZOBSS_RESULT .
  methods CLEAR_OBSLOG .
  methods SET_ACTION
    importing
      !IV_ACTION type ZZACTION_OBS .
  methods SET_BUCKET
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
      !IV_OBJECTKEY type STRING default '' .
  methods SCAPE_URL_OBJECTKEY
    importing
      !IV_OBJECTKEY type STRING
    returning
      value(RV_OBJECTKEY) type STRING .
  methods GET_APPLICATION_TYPE
    importing
      !IV_DOCKEY type STRING
    exporting
      !EX_TYPE type TEXT20
      !EX_SUBTYPE type TEXT20
    returning
      value(RV_APPTYPE) type STRING .
  methods FILE_SAVE_DIALOG
    importing
      value(WINDOW_TITLE) type STRING optional
      value(DEFAULT_EXTENSION) type STRING optional
      value(DEFAULT_FILE_NAME) type STRING optional
      value(FILE_FILTER) type STRING optional
      value(INITIAL_DIRECTORY) type STRING default 'c:\'
    changing
      !FILENAME type STRING optional
      !PATH type STRING optional
      !FULLPATH type STRING optional
      !USER_ACTION type I optional
    exceptions
      ERROR .
  methods SET_HTTP_HEADER_FIELD
    importing
      !IT_HTTP_HEADER type ZOBSTT_HTTP_HEADER
    changing
      !CO_HTTP_CLIENT type ref to IF_HTTP_CLIENT .
  methods SET_HTTP_HEADER
    importing
      !IV_HTTPMETHOD type STRING
      !IS_SIGNTRUE type ZOBST_SIGNTRUE
      !IV_CONTENTLENGTH type INT4 default 0
      !IV_COPYSOURCE type STRING default ''
    changing
      !CO_HTTP_CLIENT type ref to IF_HTTP_CLIENT .
  methods DIRECTORY_BROWSE
    returning
      value(RV_DIR) type STRING .
  methods SET_SALV_LAYOUT
    importing
      !IO_TABLE type ref to CL_SALV_TABLE
      !IV_HANDLE type SLIS_HANDL .
  methods LOGGING_OBSLOG
    importing
      !IS_RETURN type BAPIRET2 optional
      !IS_RESULT type ZOBSS_RESULT optional .
  methods DELETE_SIGNTRUE
    importing
      !IV_UUID type SYSUUID_C32 .
  methods GET_OBS_CONFIG
    importing
      !IV_BUCKETNAME type ZZBUCKET_OBS
    exporting
      !ES_OBS_CONFIG type ZOBS_CONFIG .
  methods HANDLE_HOTSPOT_CLICK
    for event HOTSPOT_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW_ID
      !E_COLUMN_ID
      !ES_ROW_NO .
  methods HANDLE_TOOLBAR
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_OBJECT .
  class-methods SET_NUMBER_RANGE
    importing
      !IV_LENGTH type DD01L-LENG
    exporting
      !EV_FROMNUMBER type ANY
      !EV_TONUMBER type ANY
    exceptions
      INVAILD_LENGTH .
ENDCLASS.



CLASS ZCL_OBS IMPLEMENTATION.


  METHOD adjust_objectkey.
*    CONDENSE cv_objectkey NO-GAPS. "Key不能有空格
    IF strlen( cv_objectkey ) > 1.
      IF cv_objectkey+0(1) NE '/'.
        cv_objectkey = '/' && cv_objectkey.
      ENDIF.
    ELSE.
      "Object Key不能为空
      MESSAGE e011 INTO es_return-message.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).
    ENDIF.

    "Object Key转义
    cv_objectkey = scape_url_objectkey( cv_objectkey ).
  ENDMETHOD.


  METHOD calc_signtrue.
    DATA: lo_proxy_out TYPE REF TO zpico_si_bc000501_erp2erp_syn,
          ls_output    TYPE zpimt_bc000501_req_out,
          ls_input     TYPE zpimt_bc000501_res,
          lv_uuid      TYPE sysuuid_c32,
          lv_message   TYPE bapi_msg,
          lv_seconds   TYPE p LENGTH 3 DECIMALS 1 VALUE '0.1'.

    CLEAR: ls_output,
           ls_input,
           es_return,
           rs_signtrue.

    "调用PI计算签名
    MOVE-CORRESPONDING is_bc000501_req TO  ls_output-mt_bc000501_req_out.

    IF lo_proxy_out IS INITIAL.

      TRY.
          "调用PI计算签名
          CREATE OBJECT lo_proxy_out.

          CALL METHOD lo_proxy_out->si_bc000501_erp2erp_syn_out
            EXPORTING
              output = ls_output ##ENH_OK
            IMPORTING
              input  = ls_input.

          COMMIT WORK.

          "获取签名
          lv_uuid = is_bc000501_req-uuid.
          DO 30 TIMES.
            SELECT SINGLE *
              INTO rs_signtrue
              FROM zobst_signtrue
             WHERE uuid = lv_uuid .
            IF sy-subrc EQ 0.
              EXIT.
            ELSE.
              WAIT UP TO lv_seconds SECONDS.
            ENDIF.
          ENDDO.

          IF rs_signtrue IS INITIAL.
            CLEAR: es_return.
            "调用PI获取签名失败
            MESSAGE e004 INTO lv_message.
            es_return = zcl_message=>convert_syst_to_bapiret2( ).
          ENDIF.

          FREE lo_proxy_out.

        CATCH cx_ai_system_fault INTO DATA(lo_ai_system_fault).

          lv_message = lo_ai_system_fault->if_message~get_text( ).
          CLEAR: es_return.
          es_return-type       = 'E'.
          es_return-id         = 'ZOBS'.
          es_return-number     = '000'.

          CALL METHOD zcl_cdo=>move_message_to_return
            EXPORTING
              iv_message = lv_message
            CHANGING
              cs_return  = es_return.

      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD call_obs_httpclient.
    DATA: lo_http_client TYPE REF TO if_http_client,
          lv_url         TYPE string.

    "构建URL
    CLEAR: lv_url.
    IF ms_signtrue-authortype = c_authortype_header.
      lv_url = ms_obs_config-host && iv_objectkey.
    ELSE.

      CONCATENATE ms_obs_config-host iv_objectkey   '?'
                  'AccessKeyId='  ms_signtrue-accesskeyid
                  '&Expires='     ms_signtrue-expires
                  '&Signature='   ms_signtrue-signature
                  INTO lv_url.
    ENDIF.

    CONDENSE lv_url.

    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = lv_url
      IMPORTING
        client             = lo_http_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc NE 0.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).
    ELSE.

      "设置HTTP头域
      CALL METHOD set_http_header
        EXPORTING
          iv_httpmethod    = mv_http_method
          is_signtrue      = ms_signtrue
          iv_contentlength = 0
          iv_copysource    = iv_obscopysource
        CHANGING
          co_http_client   = lo_http_client.

      "设置发送HTTP Body内容
      "二进制数据
      IF iv_data  IS NOT INITIAL.
        lo_http_client->request->set_data( EXPORTING data = iv_data length = iv_length ).
      ENDIF.

      "字符型数据
      IF iv_cdata  IS NOT INITIAL.
        lo_http_client->request->set_cdata( EXPORTING data = iv_cdata length = iv_length ).
      ENDIF.

      "请求发送
      lo_http_client->send(
           EXCEPTIONS
             http_communication_failure = 1
             http_invalid_state         = 2 ).
      IF sy-subrc EQ 0.
        "
      ENDIF.

      " 请求接收
      lo_http_client->receive(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3 ).
      IF sy-subrc EQ 0.
        "
      ENDIF.

      "获取结果
      CLEAR: es_result.
      "获取响应状态
      lo_http_client->response->get_status( IMPORTING code   = es_result-code
                                                      reason = es_result-reason ).
      "获取返回值
      es_result-rawbizdata = lo_http_client->response->get_data( )."二进制
      es_result-bizdata    = lo_http_client->response->get_cdata( )."文本、XML、JSON等

      CLEAR: es_return.
      es_return-type       = 'S'.
      es_return-id         = 'ZAM'.
      es_return-number     = '000'.
      es_return-message_v1 = es_result-code && es_result-reason.

      "关闭HTTP Connection
      lo_http_client->close( ).

      FREE lo_http_client.

    ENDIF.

    "delete signtrue
    CALL METHOD delete_signtrue
      EXPORTING
        iv_uuid = ms_signtrue-uuid.


  ENDMETHOD.


  METHOD clear_obslog.

    "日志自动清理
    IF ms_obs_config-autoclear = abap_true AND ms_obs_config-cleardate+0(6) <> sy-datum+0(6).
      "每月清理一次
      CALL FUNCTION 'ZFM_OBS_LOG_CLEAR_AUTO' STARTING NEW TASK 'OBS_LOG_CLEAR_AUTO'
        EXPORTING
          is_config = ms_obs_config.

    ENDIF.
  ENDMETHOD.


  METHOD clear_obs_log.
    DATA: lt_config  TYPE TABLE OF zobs_config,
          ls_config  TYPE zobs_config,
          lv_date    TYPE datum,
          lv_package TYPE i,
          lv_logfile TYPE zobs_config-loglife.

    "读取OBS桶配置
    SELECT *
      INTO TABLE lt_config
      FROM zobs_config
     WHERE sysid  EQ sy-sysid
       AND bucket IN it_bucket.
    LOOP AT lt_config INTO ls_config.
      "根据桶配置的生命周期，计算需要清理的日期范围
      IF iv_cleardate IS NOT INITIAL.
        lv_date = iv_cleardate.
      ELSE.
        IF ls_config-loglife IS NOT INITIAL.
          lv_logfile = ls_config-loglife.
        ELSE.
          lv_logfile = c_loglife."180.
        ENDIF.
        lv_date = sy-datum - lv_logfile .
      ENDIF.

      "设置每次清理数据包的大小
      IF iv_package IS NOT INITIAL.
        lv_package = iv_package.
      ELSE.
        lv_package = 10000.
      ENDIF.

*      "循环清理数据
*      DO.
*        SELECT * UP TO lv_package ROWS
*          INTO TABLE lt_log
*          FROM zobs_log
*         WHERE bucket EQ ls_config-bucket
*           AND udate  LE lv_date  .
*        IF lt_log[] IS INITIAL."无满足条件的记录，退出循环
*          EXIT.
*        ELSE.
*          DELETE zobs_log FROM TABLE lt_log.
*        ENDIF.
*      ENDDO.
      DELETE FROM zobs_log WHERE bucket EQ ls_config-bucket AND udate LE lv_date .
      IF sy-subrc = 0.
        ls_config-cleardate = sy-datum.
        MODIFY zobs_config FROM ls_config.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD clear_obs_log_auto.
    DATA: lv_date    TYPE datum,
          lv_package TYPE i,
          lv_logfile TYPE zobs_config-loglife.



    "根据桶配置的生命周期，计算需要清理的日期范围
    IF is_config-loglife IS NOT INITIAL.
      lv_logfile = is_config-loglife.
    ELSE.
      lv_logfile = c_loglife."180.
    ENDIF.
    lv_date = sy-datum - lv_logfile .

    IF lv_date > is_config-cleardate.

      "开启异步进程清理日志
      CALL FUNCTION 'ZFM_OBS_LOG_CLEAR' STARTING NEW TASK 'OBS_LOG_CLEAR' "IN BACKGROUND TASK AS SEPARATE UNIT
        EXPORTING
          is_config    = is_config
          iv_cleardate = lv_date.

    ENDIF.





  ENDMETHOD.


  method CONSTRUCTOR.
  endmethod.


  METHOD copy_attachment.
**/
*----------------------------------------------------------------------*
* 复制对象的结果不能仅根据HTTP返回头域中的status_code来判断请求是否成功，
* 头域中status_code返回200时表示服务端已经收到请求，且开始处理复制对象请求。
* 复制是否成功会在响应消息的body中，只有body体中有ETag标签才表示成功，
* 否则表示复制失败。
*----------------------------------------------------------------------*
*/

    DATA: lv_sourcebucket  TYPE zzbucket_obs,
          lv_sourceobject  TYPE string,
          lv_destbucket    TYPE zzbucket_obs,
          lv_destobject    TYPE string,
          lv_obscopysource TYPE string.

    DATA: lv_data       TYPE xstring,
          lv_filelength TYPE i,
          lv_message    TYPE bapi_msg.

    "设置桶信息
    set_bucket( iv_bucketname = iv_sourcebucket iv_objectkey = iv_sourceobject  ).
    "设置OBS操作
    set_action( c_action_copy ).


    "源对象
    CLEAR: lv_sourceobject,lv_destobject.
    lv_sourceobject = iv_sourceobject.

    CALL METHOD adjust_objectkey
      IMPORTING
        es_return    = es_return
      CHANGING
        cv_objectkey = lv_sourceobject.

    IF es_return-type NA 'EAX'.
      "目标对象
      lv_destobject   = iv_destobject.
      CALL METHOD adjust_objectkey
        IMPORTING
          es_return    = es_return
        CHANGING
          cv_objectkey = lv_destobject.

    ENDIF.

    IF es_return-type NA 'EAX'.
      lv_destbucket = iv_destbucket.
      IF iv_destbucket IS INITIAL.
        lv_destbucket = iv_sourcebucket.
      ENDIF.
      "获取OBS的签名
      CLEAR:ms_signtrue_req         ,
            es_return               ,
            es_result               .
      ms_signtrue_req-bucketname              = iv_sourcebucket.
      ms_signtrue_req-httpmethod              = mv_http_method.
      ms_signtrue_req-authortype              = c_authortype_header.
      ms_signtrue_req-contenttype             = c_contenttype_bin .
      ms_signtrue_req-contentmd5              = ''.
      ms_signtrue_req-canonicalizeheaders     = 'x-obs-copy-source:' && '/' && iv_sourcebucket && lv_sourceobject.
      ms_signtrue_req-canonicalizeresource    = '/' && lv_destbucket && lv_destobject.

      CALL METHOD get_signtrue
        EXPORTING
          is_signtrue_req = ms_signtrue_req
        IMPORTING
          es_return       = es_return.
    ENDIF.

    IF es_return-type NA 'EAX'.

      lv_obscopysource = '/' && iv_sourcebucket &&  lv_sourceobject.

      "采用HTTP Client访问OBS
      call_obs_httpclient( EXPORTING iv_objectkey     = lv_destobject
                                     iv_obscopysource = lv_obscopysource
                           IMPORTING es_return        = es_return
                                     es_result        = es_result     ).


      IF es_result-code = 200.
        "附件上载成功，ObjectKey为&1.
        MESSAGE s013 WITH iv_destobject INTO lv_message.
        es_return = zcl_message=>convert_syst_to_bapiret2( ).
      ELSE.
        "附件上载失败，错误原因：&1&2
        MESSAGE e014 WITH es_result-code es_result-reason INTO lv_message.
        es_return = zcl_message=>convert_syst_to_bapiret2( ).
      ENDIF.

    ENDIF.

    "记录日志
    logging_obslog( is_return = es_return is_result = es_result ).
    "日志自动清理
    clear_obslog( ).


  ENDMETHOD.


  METHOD copy_attachment_new.
**/
*----------------------------------------------------------------------*
* 复制对象的结果不能仅根据HTTP返回头域中的status_code来判断请求是否成功，
* 头域中status_code返回200时表示服务端已经收到请求，且开始处理复制对象请求。
* 复制是否成功会在响应消息的body中，只有body体中有ETag标签才表示成功，
* 否则表示复制失败。
*----------------------------------------------------------------------*
*/

    DATA: lv_data       TYPE xstring,
          lv_filelength TYPE i,
          lv_message    TYPE bapi_msg.



    "下载源文件
    "下载附件
    CALL METHOD download_object
      EXPORTING
        iv_bucketname  = iv_sourcebucket
        iv_objectkey   = iv_sourceobject
        iv_filetype    = 'BIN'
        iv_direct_down = ''
      IMPORTING
        es_return      = es_return
        es_result      = es_result.
    IF es_return-type CA 'EAX'.
      RETURN.
    ENDIF.

    lv_data = es_result-rawbizdata.

    "上载目标文件
    CALL METHOD upload_object
      EXPORTING
        iv_bucketname = iv_destbucket
        iv_objectkey  = iv_destobject
        iv_data       = lv_data
      IMPORTING
        es_return     = es_return
        es_result     = es_result.

    IF es_result-code = 200.
      "附件上载成功，ObjectKey为&1.
      MESSAGE s013 WITH iv_destobject INTO lv_message.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).
    ELSE.
      "附件上载失败，错误原因：&1&2
      MESSAGE e014 WITH es_result-code es_result-reason INTO lv_message.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).
    ENDIF.

    "设置OBS操作
    set_action( c_action_copy ).

    "记录日志
    logging_obslog( is_return = es_return is_result = es_result ).
    "日志自动清理
    clear_obslog( ).

  ENDMETHOD.


  METHOD delete_attachment.

    CALL METHOD delete_object
      EXPORTING
        iv_bucketname = iv_bucketname
        iv_objectkey  = iv_objectkey
      IMPORTING
        es_return     = es_return
        es_result     = es_result.

    "记录日志
    logging_obslog( is_return = es_return is_result = es_result ).
    "日志自动清理
    clear_obslog( ).

  ENDMETHOD.


  METHOD delete_object.

    DATA: lv_objectkey TYPE string,
          lv_message   TYPE bapi_msg.

    "设置桶信息
    set_bucket( iv_bucketname = iv_bucketname iv_objectkey = iv_objectkey ).
    "设置OBS操作
    set_action( c_action_delete ).

    CLEAR: lv_objectkey.
    lv_objectkey = iv_objectkey.

    CALL METHOD adjust_objectkey
      IMPORTING
        es_return    = es_return
      CHANGING
        cv_objectkey = lv_objectkey.
    IF es_return-type NA 'EAX'.

      "获取OBS的签名
      CLEAR:ms_signtrue_req         ,
            es_return               ,
            es_result               .
      ms_signtrue_req-bucketname             = iv_bucketname.
      ms_signtrue_req-httpmethod             = mv_http_method.
      ms_signtrue_req-authortype             = c_authortype_header.
      ms_signtrue_req-contenttype            = c_contenttype_bin .
      ms_signtrue_req-contentmd5             = ''.
      ms_signtrue_req-canonicalizeheaders    = ''.
      ms_signtrue_req-canonicalizeresource   = '/' && iv_bucketname && lv_objectkey.

      CALL METHOD get_signtrue
        EXPORTING
          is_signtrue_req = ms_signtrue_req
        IMPORTING
          es_return       = es_return.
    ENDIF.

    IF es_return-type NA 'EAX'.

      "采用HTTP Client访问OBS
      call_obs_httpclient( EXPORTING iv_objectkey = lv_objectkey
                           IMPORTING es_return    = es_return
                                     es_result    = es_result     ).
      IF es_result-code = 204. "
        "附件删除成功，ObjectKey为&1.
        MESSAGE s007 WITH iv_objectkey INTO lv_message.
        es_return = zcl_message=>convert_syst_to_bapiret2( ).
      ELSE.
        "附件删除失败，错误原因：&1&2
        MESSAGE e008 WITH es_result-code  es_result-reason INTO lv_message.
        es_return = zcl_message=>convert_syst_to_bapiret2( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD delete_signtrue.
    DELETE FROM zobst_signtrue WHERE uuid = iv_uuid.
    COMMIT WORK.
  ENDMETHOD.


  METHOD diaplay_obs_log.

    DATA: lt_fcat TYPE lvc_t_fcat,
          ls_fcat TYPE lvc_s_fcat.

    DATA: ls_layout  TYPE zsalv_s_layout,
          lt_columns TYPE zsalv_tt_fcat,
          ls_columns TYPE zsalv_s_fcat.

    DATA: lv_col_pos TYPE i.

    DATA: lo_table TYPE REF TO zcl_salv.

    DEFINE change_fcat.
      READ TABLE lt_fcat INTO ls_fcat WITH KEY fieldname = &1.
      IF sy-subrc EQ 0.
        IF &2 IS NOT INITIAL.
          ls_fcat-reptext   = &2.
          ls_fcat-scrtext_l = &2.
          ls_fcat-scrtext_m = &2.
          ls_fcat-scrtext_s = &2.
        ENDIF.
        ls_fcat-key       = &3.
        ls_fcat-hotspot   = &4.
        ls_fcat-no_out    = ''.
        ls_fcat-tech      = &5.
        &6 = &6 + 1.
        ls_fcat-col_pos   = &6.
        MODIFY lt_fcat FROM ls_fcat INDEX sy-tabix.
      ENDIF.
    END-OF-DEFINITION.


    REFRESH: mt_log.
    "获取日志数据
    SELECT *
      INTO TABLE mt_log
      FROM zobs_log
     WHERE logid     IN it_logid
       AND bucket    IN it_bucket
       AND action    IN it_action
       AND objectkey IN it_objectkey[]
       AND code      IN it_code
       AND type      IN it_type
       AND uname     IN it_uname
       AND udate     IN it_udate
       AND utime     IN it_utime.

    SORT mt_log BY logid DESCENDING
                   udate DESCENDING
                   utime DESCENDING.

*    IF mt_log[] IS INITIAL.
*
*      RETURN.
*    ENDIF.

    "构建字段目录
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_buffer_active        = ''
        i_structure_name       = 'ZOBSS_LOG_ALV'
        i_bypassing_buffer     = ''
      CHANGING
        ct_fieldcat            = lt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
      RETURN.
    ENDIF.

    CLEAR:ls_fcat.
    ls_fcat-no_out = abap_true.
    MODIFY lt_fcat FROM ls_fcat TRANSPORTING no_out WHERE fieldname <> '' .

    change_fcat:'LOGID                ' '       ' 'X' ' ' ' ' lv_col_pos.
    change_fcat:'BUCKET               ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'OBJECTKEY            ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'ACTION               ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'CODE                 ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'REASON               ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'ICON                 ' TEXT-c01  ' ' 'X' ' ' lv_col_pos.
    change_fcat:'UNAME                ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'UDATE                ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'UTIME                ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'AUTHORTYPE           ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'HTTPMETHOD           ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'ACCESSKEYID          ' '       ' ' ' ' ' ' ' lv_col_pos.
*    change_fcat:'SECURITYKEY          ' '       ' ' ' '  ' '  lv_col_pos.
    change_fcat:'EXPIRES              ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'SIGNATURE            ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'AUTHORIZATION        ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'DATE                 ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'CANONICALIZEDRESOURCE' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'CONTENTTYPE          ' '       ' ' ' ' ' ' ' lv_col_pos.
    change_fcat:'SECURITYKEY          ' '       ' ' ' ' ' 'X' lv_col_pos.

    LOOP AT lt_fcat INTO ls_fcat .
      CLEAR: ls_columns.
      MOVE-CORRESPONDING ls_fcat TO ls_columns.
      APPEND ls_columns TO lt_columns.
    ENDLOOP.

    IF lo_table IS INITIAL.
      CREATE OBJECT lo_table.
    ENDIF.

    IF lo_table IS NOT INITIAL.
      CALL METHOD lo_table->display
        EXPORTING
          ir_event_handler = me
          is_layout        = ls_layout
          it_columns       = lt_columns
        CHANGING
          ct_data          = mt_log.
    ENDIF.

  ENDMETHOD.


  METHOD directory_browse.

    DATA: lv_init_dir TYPE string,
          lv_title    TYPE string,
          lv_dir_len  TYPE i.

    lv_init_dir = 'C:' && c_dir_sepflag."c盘

    lv_title = TEXT-002."选择路径

    CALL METHOD cl_gui_frontend_services=>directory_browse
      EXPORTING
        window_title         = lv_title
        initial_folder       = lv_init_dir
      CHANGING
        selected_folder      = rv_dir
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4.
    IF sy-subrc <> 0.
    ELSE.
      lv_dir_len = strlen( rv_dir ).
      IF lv_dir_len > 1.
        lv_dir_len = lv_dir_len - 1.

        IF rv_dir+lv_dir_len(1) <> c_dir_sepflag.
          rv_dir = rv_dir && c_dir_sepflag.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD display_attachment.
    DATA: lv_type     TYPE text20,
          lv_subtype  TYPE text20,
          lv_filename TYPE string.

    "下载附件
    CALL METHOD download_object
      EXPORTING
        iv_bucketname  = iv_bucketname
        iv_objectkey   = iv_objectkey
        iv_filetype    = 'BIN'
        iv_direct_down = ''
      IMPORTING
        es_return      = es_return
        es_result      = DATA(ls_result).
    IF es_return-type CA 'EAX'.
      RETURN.
    ENDIF.

    "显示附件
    DATA(lv_apptype) = get_application_type( EXPORTING
                                               iv_dockey  = iv_objectkey
                                             IMPORTING
                                               ex_type    = lv_type
                                               ex_subtype = lv_subtype ).


    IF lv_type = 'text'.
      CALL METHOD zcl_obs=>text_convert
        CHANGING
          cv_data = ls_result-rawbizdata.
    ENDIF.

    CASE lv_apptype.
      WHEN app_type_html.
        IF iv_dialog IS INITIAL.
          CALL FUNCTION 'ZFM_OBS_DISPLAY_HTML'
            EXPORTING
              iv_data     = ls_result-rawbizdata
              iv_type     = lv_type
              iv_subtype  = lv_subtype
              iv_filename = iv_objectkey
            IMPORTING
              es_return   = es_return.
        ELSE.
          CALL METHOD html_show
            EXPORTING
              iv_data     = ls_result-rawbizdata
              iv_type     = lv_type
              iv_subtype  = lv_subtype
              iv_filename = iv_objectkey
            IMPORTING
              es_return   = es_return.

        ENDIF.

      WHEN app_type_ole.
        IF iv_dialog IS INITIAL.
          CALL FUNCTION 'ZFM_OBS_DISPLAY_OLE'
            EXPORTING
              iv_data     = ls_result-rawbizdata
              iv_type     = lv_type
              iv_subtype  = lv_subtype
              iv_filename = iv_objectkey
            IMPORTING
              es_return   = es_return.

        ELSE.
          CALL METHOD ole_show
            EXPORTING
              iv_data     = ls_result-rawbizdata
              iv_type     = lv_type
              iv_subtype  = lv_subtype
              iv_filename = iv_objectkey
            IMPORTING
              es_return   = es_return.
        ENDIF.

      WHEN OTHERS.
        MESSAGE i000 WITH '不支持打开此类型的文件。'(001).
        RETURN.
    ENDCASE.
  ENDMETHOD.


  METHOD display_log_html.

    DATA: lt_html_data TYPE STANDARD TABLE OF x255,
          lv_url       TYPE char255,
          lv_size      TYPE i,
          lv_caption   TYPE char30.
    DATA: lv_encoding          TYPE abap_encoding VALUE '8400'.

    DATA: lv_xdata TYPE xstring.


    IF iv_data IS NOT INITIAL.

      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text     = iv_data
*         mimetype = ''
          encoding = lv_encoding
        IMPORTING
          buffer   = lv_xdata
        EXCEPTIONS
          failed   = 1
          OTHERS   = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer        = lv_xdata
        IMPORTING
          output_length = lv_size
        TABLES
          binary_tab    = lt_html_data.

    ELSE.
      MESSAGE s012."无效内容不能显
      RETURN.
    ENDIF.

    "初始化控件
    IF html_viewer IS NOT INITIAL.
      html_viewer->free( ).
      FREE html_viewer.
    ENDIF.

    IF docu_container IS NOT INITIAL.
      docu_container->free( ).
      FREE docu_container.
    ENDIF.

    lv_caption = iv_caption.

    CREATE OBJECT docu_container
      EXPORTING
        width                       = iv_width
        height                      = iv_height
        top                         = iv_top
        left                        = iv_left
        caption                     = lv_caption
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        event_already_registered    = 6
        error_regist_event          = 7
        OTHERS                      = 8.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    docu_container->set_vscroll_range( vscroll_range = iv_height ).
    docu_container->set_hscroll_range( hscroll_range = iv_width  ).

    SET HANDLER handle_close FOR docu_container.

    CREATE OBJECT html_viewer
      EXPORTING
        parent             = docu_container
      EXCEPTIONS
        cntl_error         = 1
        cntl_install_error = 2
        dp_install_error   = 3
        dp_error           = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    "加载数据
    CALL METHOD html_viewer->load_data
      EXPORTING
        type                   = iv_type    "'appv_type    "
        subtype                = iv_subtype "'pdfv_subtype "
        size                   = lv_size
*       encoding               = lv_encoding_html
      IMPORTING
        assigned_url           = lv_url
      CHANGING
        data_table             = lt_html_data
      EXCEPTIONS
        dp_invalid_parameter   = 1
        dp_error_general       = 2
        cntl_error             = 3
        html_syntax_notcorrect = 4
        OTHERS                 = 5.
    IF sy-subrc <> 0.
    ENDIF.

    "显示
    CALL METHOD html_viewer->show_url
      EXPORTING
        url                    = lv_url
        in_place               = ' X'
      EXCEPTIONS
        cntl_error             = 1
        cnht_error_not_allowed = 2
        cnht_error_parameter   = 3
        dp_error_general       = 4
        OTHERS                 = 5.
    IF sy-subrc <> 0.

    ENDIF.

  ENDMETHOD.


  METHOD download_attachment.

    CALL METHOD download_object
      EXPORTING
        iv_bucketname       = iv_bucketname
        iv_objectkey        = iv_objectkey
        iv_filetype         = iv_filetype
        iv_direct_down      = iv_direct_down
        iv_newline          = iv_newline
        iv_default_filename = iv_default_filename
      IMPORTING
        es_return           = es_return
        es_result           = es_result.

    "记录日志
    logging_obslog( is_return = es_return is_result = es_result ).
    "日志自动清理
    clear_obslog( ).


  ENDMETHOD.


  METHOD download_file.

    DATA:  lv_objectkey TYPE string.


    "设置桶信息
    set_bucket( iv_bucketname = iv_bucketname iv_objectkey = iv_objectkey ).
    "设置OBS操作
    set_action( c_action_download ).

    "格式化对象Key
    CLEAR: lv_objectkey.
    lv_objectkey = iv_objectkey.

    CALL METHOD adjust_objectkey
      IMPORTING
        es_return    = es_return
      CHANGING
        cv_objectkey = lv_objectkey.
    IF es_return-type CA 'EAX'.
      "记录日志
      logging_obslog( is_return = es_return is_result = es_result ).
      RETURN.
    ENDIF.

    DO 50 TIMES.

      "获取OBS的签名
      CLEAR:ms_signtrue_req         ,
            es_return               ,
            es_result               .
      ms_signtrue_req-bucketname             = iv_bucketname.
      ms_signtrue_req-httpmethod             = mv_http_method.
      ms_signtrue_req-authortype             = c_authortype_url.
      ms_signtrue_req-contenttype            = c_contenttype_bin .
      ms_signtrue_req-contentmd5             = ''.
      ms_signtrue_req-canonicalizeheaders    = ''.
      ms_signtrue_req-canonicalizeresource   = '/' && iv_bucketname && lv_objectkey.
      CALL METHOD get_signtrue
        EXPORTING
          is_signtrue_req = ms_signtrue_req
        IMPORTING
          es_return       = es_return.

      IF es_return-type CA 'EAX'.
        "记录日志
        logging_obslog( is_return = es_return is_result = es_result ).
        RETURN.
      ENDIF.

      "采用HTTP Client访问OBS
      call_obs_httpclient( EXPORTING iv_objectkey = lv_objectkey
                           IMPORTING es_return    = es_return
                                     es_result    = es_result     ).
      IF es_result-code = 200.
        es_return-type       = 'S'.
        IF iv_newline IS NOT INITIAL.
          "LF换行
          SPLIT es_result-bizdata AT cl_abap_char_utilities=>newline INTO TABLE es_result-data[].
        ELSE.
          "CR_LF换行
          SPLIT es_result-bizdata AT cl_abap_char_utilities=>cr_lf INTO TABLE es_result-data[].
        ENDIF.
        EXIT.
      ELSEIF es_result-code = 404." Connection Refused 网络不通
        es_return-type       = 'E'.
        EXIT.
      ELSE.
        CLEAR: es_return.
        es_return-type       = 'E'.

        WAIT UP TO '0.1' SECONDS.

      ENDIF.

    ENDDO.

    "记录日志
    logging_obslog( is_return = es_return is_result = es_result ).

    "日志自动清理
    clear_obslog( ).


  ENDMETHOD.


  METHOD download_object.

    DATA: lv_message    TYPE bapi_msg.

    DATA: lv_filename    TYPE string,
          lv_extension   TYPE string,
          lv_objectkey   TYPE string,
          lv_user_action TYPE i,
          lv_action      TYPE zzaction_obs.
    DATA:lt_extension TYPE TABLE OF string,
         lv_lines     TYPE i.


    "设置桶信息
    set_bucket( iv_bucketname = iv_bucketname iv_objectkey = iv_objectkey ).
    "设置OBS操作
    set_action( c_action_download ).

    CLEAR: lv_objectkey.
    lv_objectkey = iv_objectkey.

    CALL METHOD adjust_objectkey
      IMPORTING
        es_return    = es_return
      CHANGING
        cv_objectkey = lv_objectkey.
    IF es_return-type CA 'EAX'.
      RETURN.
    ENDIF.

    "获取OBS的签名
    CLEAR:ms_signtrue_req         ,
          es_return               ,
          es_result               .
    ms_signtrue_req-bucketname             = iv_bucketname.
    ms_signtrue_req-httpmethod             = mv_http_method.
    ms_signtrue_req-authortype             = c_authortype_header.
    ms_signtrue_req-contenttype            = c_contenttype_bin .
    ms_signtrue_req-contentmd5             = ''.
    ms_signtrue_req-canonicalizeheaders    = ''.
    ms_signtrue_req-canonicalizeresource   = '/' && iv_bucketname && lv_objectkey.

    CALL METHOD get_signtrue
      EXPORTING
        is_signtrue_req = ms_signtrue_req
      IMPORTING
        es_return       = es_return.

    IF es_return-type CA 'EAX'.
      RETURN.
    ENDIF.

    "采用HTTP Client访问OBS
    call_obs_httpclient( EXPORTING iv_objectkey = lv_objectkey
                         IMPORTING es_return    = es_return
                                   es_result    = es_result     ).

    IF es_result-code = 200.
      "附件二进制下载
      IF iv_direct_down IS NOT INITIAL AND iv_filetype = 'BIN'.

*         取得OBS key的文件名
        "根据Object key设置默认文件名
        CALL METHOD get_default_filename
          EXPORTING
            iv_objectkey = iv_objectkey
          IMPORTING
            ev_filename  = lv_filename
            ev_extension = lv_extension.

        IF iv_default_filename IS NOT INITIAL.
          "使用OBS Key的后半部分作为文件名
          lv_filename = iv_default_filename. "使用外部传入的文件名
        ENDIF.

        CALL METHOD file_save_dialog
          EXPORTING
            default_extension = lv_extension
            default_file_name = lv_filename
          CHANGING
            fullpath          = lv_filename
            user_action       = lv_user_action
          EXCEPTIONS
            error             = 1
            OTHERS            = 2.
        IF sy-subrc <> 0 OR lv_user_action = 9.
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
          RETURN.
        ENDIF.

*       判断后缀名是否与服务器文件名一致
        REFRESH: lt_extension .
        SPLIT lv_filename AT '.' INTO TABLE lt_extension .
        CLEAR: lv_lines.
        DESCRIBE TABLE lt_extension LINES lv_lines.
        IF lv_lines > 0.
          READ TABLE lt_extension INTO DATA(lv_extension_t) INDEX lv_lines.
          IF sy-subrc EQ 0.
            IF lv_extension_t <> lv_extension.
              CONCATENATE lv_filename '.' lv_extension INTO lv_filename.
            ENDIF.
          ELSE.
            CONCATENATE lv_filename '.' lv_extension INTO lv_filename.
          ENDIF.
        ENDIF.

        CALL METHOD gui_download
          EXPORTING
            iv_filename = lv_filename
            iv_data     = es_result-rawbizdata
          EXCEPTIONS
            error       = 1
            OTHERS      = 2.
      ELSEIF iv_filetype = 'TEXT'."直接提取文本内容

        IF iv_newline IS NOT INITIAL.
          "LF换行
          SPLIT es_result-bizdata AT cl_abap_char_utilities=>newline INTO TABLE es_result-data[].
        ELSE.
          "CR_LF换行
          SPLIT es_result-bizdata AT cl_abap_char_utilities=>cr_lf INTO TABLE es_result-data[].
        ENDIF.
      ENDIF.

      "附件下载成功，ObjectKey为&1.
      MESSAGE s009 WITH iv_objectkey INTO lv_message.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).
    ELSE.
      "附件下载失败，错误原因：&1&2
      MESSAGE e010 WITH es_result-code  es_result-reason INTO lv_message.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).
    ENDIF.


  ENDMETHOD.


  method FACTORY.
    value = new zcl_obs( ).
  endmethod.


  METHOD file_save_dialog.


    CALL METHOD cl_gui_frontend_services=>file_save_dialog
      EXPORTING
        window_title              = window_title
        default_extension         = default_extension
        default_file_name         = default_file_name
        initial_directory         = initial_directory
      CHANGING
        filename                  = filename
        path                      = path
        fullpath                  = fullpath
        user_action               = user_action "0 正常 9 取消
      EXCEPTIONS
        cntl_error                = 1
        error_no_gui              = 2
        not_supported_by_gui      = 3
        invalid_default_file_name = 4
        OTHERS                    = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid
            TYPE sy-msgty
          NUMBER sy-msgno
            WITH sy-msgv1
                 sy-msgv2
                 sy-msgv3
                 sy-msgv4
         RAISING error.

    ENDIF.


  ENDMETHOD.


  METHOD get_application_type.
    DATA:
      lt_extension TYPE TABLE OF string,
      lv_extension TYPE string,
      lv_lines     TYPE i,
      lt_html_data TYPE STANDARD TABLE OF x255,
      lv_url       TYPE char255.


    "拆分文件名
    CLEAR: lt_extension,lv_extension .
    SPLIT iv_dockey AT '.' INTO TABLE lt_extension .

    CLEAR: lv_lines.
    DESCRIBE TABLE lt_extension LINES lv_lines.

    CLEAR: lv_extension .
    IF lv_lines > 0.
      READ TABLE lt_extension INTO lv_extension INDEX lv_lines.
    ENDIF.

    CONDENSE lv_extension NO-GAPS.
    TRANSLATE lv_extension TO UPPER CASE.

    "文件名格式
    CLEAR: ex_type   ,
           ex_subtype.
    CASE lv_extension.
      WHEN filetype_bmp OR
           filetype_gif OR
           filetype_jpg OR
           filetype_png OR
           filetype_tif  .

        ex_type    = 'image'.
        ex_subtype = lv_extension.
        rv_apptype = app_type_html.

      WHEN filetype_pdf.
        ex_type    = 'application'.
        ex_subtype = 'pdf'.
        rv_apptype = app_type_html.

      WHEN filetype_txt .
*        ex_type    = 'plain'.
*        ex_subtype = 'txt'.
        ex_type    = 'text'.
        ex_subtype = 'plain'.
        rv_apptype = app_type_html.

      WHEN filetype_csv.
        ex_type    = 'BIN'.
        ex_subtype = 'txt'.
        rv_apptype = app_type_html.

      WHEN filetype_doc OR filetype_docx.
        ex_type    = 'R/3 Basis'.
        ex_subtype = 'Word.Document'.
        rv_apptype = app_type_ole.

      WHEN filetype_xls OR filetype_xlsx.
        ex_type    = 'R/3 Basis'.
        ex_subtype = 'Excel.Sheet'.
        rv_apptype = app_type_ole.
      WHEN filetype_ppt OR filetype_pptx.
        ex_type    = 'R/3 Basis'.
        ex_subtype = 'PowerPoint.Slide'.
        rv_apptype = app_type_ole.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD get_default_filename.
    DATA: lt_filename  TYPE TABLE OF string,
          lt_extension TYPE TABLE OF string,
          lv_extension TYPE string,
          lv_lines     TYPE i.

    SPLIT iv_objectkey AT '/' INTO TABLE lt_filename.
    lv_lines = lines( lt_filename ).

    READ TABLE lt_filename INTO ev_filename INDEX lv_lines.
    IF sy-subrc EQ 0.
      REFRESH: lt_extension .
      SPLIT ev_filename AT '.' INTO TABLE lt_extension .

      CLEAR: lv_lines.
      DESCRIBE TABLE lt_extension LINES lv_lines.

      CLEAR: lv_extension .
      IF lv_lines > 0.
        READ TABLE lt_extension INTO ev_extension INDEX lv_lines.
        IF sy-subrc EQ 0.
          "
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_httpmethod_by_action.
    CASE iv_action.
      WHEN  c_action_upload   ."上载 .
        rv_httpmethod = c_http_put.

      WHEN  c_action_download OR "下载
             c_action_getobjlist. "获取桶内对象列表
        rv_httpmethod = c_http_get.

      WHEN  c_action_display  ."显示
        rv_httpmethod = c_http_get.

      WHEN  c_action_delete   ."删除  .
        rv_httpmethod = c_http_delete.

      WHEN  c_action_copy     ."复制  .
        rv_httpmethod = c_http_put.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD get_number.
    DATA: ls_tnro   TYPE tnro,
          ls_nriv   TYPE nriv,
          ls_dd01l  TYPE dd01l,
          lv_length TYPE dd01l-leng.

    SELECT SINGLE *
      INTO @ls_nriv
      FROM nriv
     WHERE object    = @iv_object
       AND nrrangenr = @iv_nrrangenr.
    IF sy-subrc NE 0.

      SELECT SINGLE *
        INTO ls_tnro
        FROM tnro
       WHERE object = iv_object.
      IF sy-subrc <> 0.
        MESSAGE e002(nr) WITH iv_object RAISING object_not_found.
      ENDIF.

      CLEAR: ls_dd01l,lv_length.
      SELECT SINGLE *
        INTO ls_dd01l
        FROM dd01l
       WHERE domname  = ls_tnro-domlen
         AND as4local = 'A'.
      IF ls_dd01l-leng > 20.
        lv_length = 20.
      ELSE.
        lv_length = ls_dd01l-leng.
      ENDIF.

      CALL METHOD set_number_range
        EXPORTING
          iv_length     = lv_length
        IMPORTING
          ev_fromnumber = ls_nriv-fromnumber
          ev_tonumber   = ls_nriv-tonumber.
      CALL METHOD zcl_obs=>set_number_range
        EXPORTING
          iv_length      = lv_length
        IMPORTING
          ev_fromnumber  = ls_nriv-fromnumber
          ev_tonumber    = ls_nriv-tonumber
        EXCEPTIONS
          invaild_length = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE e001 RAISING invaild_length.
      ENDIF.


      ls_nriv-object     = iv_object.
      ls_nriv-nrrangenr  = iv_nrrangenr.

*      ls_nriv-fromnumber = '0000000001'.
*      ls_nriv-tonumber   = '9999999999'.
      MODIFY nriv FROM ls_nriv.
      COMMIT WORK.
    ENDIF.


    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = iv_nrrangenr
        object                  = iv_object
      IMPORTING
        number                  = ev_number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
*
    ENDIF.


  ENDMETHOD.


  METHOD get_obs_config.
    SELECT SINGLE *
      INTO es_obs_config
      FROM zobs_config
     WHERE sysid      = sy-sysid
       AND bucket     = iv_bucketname
*       AND httpmethod = iv_httpmethod
       AND active     = abap_true.
  ENDMETHOD.


  METHOD get_obs_object_list.
    DATA: lo_http_client TYPE REF TO if_http_client,
          lv_url         TYPE string,
          lv_parameters  TYPE string,
          lv_len         TYPE i.

    "构建URL
    CLEAR: lv_url.
    lv_len = strlen( ms_obs_config-host ).
    IF lv_len > 1.
      lv_len -= 1.
    ENDIF.

*    IF ms_obs_config-host+lv_len(1) EQ '/'.
*      lv_url = ms_obs_config-host && iv_bucketname.
*    ELSE.
*      lv_url = ms_obs_config-host && '/' && iv_bucketname.
*    ENDIF.
    lv_url = ms_obs_config-host.
    CONDENSE lv_url.

    CLEAR: lv_parameters.
    LOOP AT it_parameters INTO DATA(ls_parameter).
      lv_parameters = me->set_url_parameters( name = ls_parameter-name value = ls_parameter-value parameters = lv_parameters ).
    ENDLOOP.

    IF lv_parameters IS NOT INITIAL.
      lv_url  = lv_url  && '?' && lv_parameters.
    ENDIF.


    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = lv_url
      IMPORTING
        client             = lo_http_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc NE 0.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).
    ELSE.

      "设置HTTP头域

      me->set_http_header_field(
        EXPORTING
          it_http_header = me->mt_http_header " Http Header
        CHANGING
          co_http_client = lo_http_client     " HTTP Client Abstraction
      ).

      "请求发送
      lo_http_client->send(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2 ).
      IF sy-subrc EQ 0.
        "
      ENDIF.

      " 请求接收
      lo_http_client->receive(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3 ).
      IF sy-subrc EQ 0.
        "
      ENDIF.

      "获取结果
      CLEAR: es_result.
      "获取响应状态
      lo_http_client->response->get_status( IMPORTING code   = es_result-code
                                                      reason = es_result-reason ).
      "获取返回值
      es_result-rawbizdata = lo_http_client->response->get_data( )."二进制
      es_result-bizdata    = lo_http_client->response->get_cdata( )."文本、XML、JSON等

      CLEAR: es_return.
      es_return-type       = 'S'.
      es_return-id         = 'ZAM'.
      es_return-number     = '000'.
      es_return-message_v1 = es_result-code && es_result-reason.

      "关闭HTTP Connection
      lo_http_client->close( ).

      FREE lo_http_client.

    ENDIF.

    "delete signtrue
    CALL METHOD delete_signtrue
      EXPORTING
        iv_uuid = ms_signtrue-uuid.


  ENDMETHOD.


  METHOD get_signtrue.
    DATA: lo_proxy_out    TYPE REF TO zpico_si_bc000501_erp2erp_syn,
          ls_output       TYPE zpimt_bc000501_req_out,
          ls_input        TYPE zpimt_bc000501_res,
          ls_bc000501_req TYPE zpidt_bc000501_req,
          lv_message      TYPE bapi_msg,
          lv_uuid         TYPE sysuuid_c32,
          lv_seconds      TYPE p LENGTH 3 DECIMALS 1 VALUE '0.1'.
    CLEAR: ls_output,
           ls_input,
           es_return,
           rs_signtrue,
           lv_uuid.
    " 1. 根据桶的配置获取AK/SK
    CLEAR: ms_obs_config.
    CALL METHOD get_obs_config
      EXPORTING
        iv_bucketname = is_signtrue_req-bucketname
*       iv_httpmethod = is_signtrue_req-httpmethod
      IMPORTING
        es_obs_config = ms_obs_config.
    IF ms_obs_config IS INITIAL.
      "桶&1方法&2的签名配置丢失或未激活，请检查表ZOBS_CONFIG
      MESSAGE e003 WITH is_signtrue_req-bucketname is_signtrue_req-httpmethod INTO lv_message.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).
      RETURN.
    ELSE.
      "insert begin by kevin.liang on 20210401
      "AK/SK包含空格会导致计算签名出错
      CONDENSE: ms_obs_config-obsak ,
                ms_obs_config-obssk .
      "insert end by kevin.liang on 20210401
    ENDIF.

    "2. 调用PI计算签名
    CLEAR: ls_bc000501_req.
    "获取UUID
    TRY .
        CALL METHOD cl_system_uuid=>if_system_uuid_static~create_uuid_c32
          RECEIVING
            uuid = lv_uuid.
      CATCH cx_uuid_error.

    ENDTRY.
    ls_bc000501_req-uuid                     = lv_uuid                             ."请求PI的唯一码
    ls_bc000501_req-http_method              = mv_http_method          ."http请求操作方法,PUT/GET/DELETE
    ls_bc000501_req-access_key               = ms_obs_config-obsak                 ."访问密钥AK
    ls_bc000501_req-security_key             = ms_obs_config-obssk                 ."私有访问密钥SK
    ls_bc000501_req-author_type              = is_signtrue_req-authortype          ."签名授权方式(Header中携带签名、URL中携带签名)
    ls_bc000501_req-expires                  = is_signtrue_req-expires             ."有效期
    ls_bc000501_req-content_type             = is_signtrue_req-contenttype         ."Content-Type内容类型
    ls_bc000501_req-content_md5              = is_signtrue_req-contentmd5          ."Content-MD5
    ls_bc000501_req-canonicalize_headers     = is_signtrue_req-canonicalizeheaders ."HTTP请求头域中的OBS请求头字段
    ls_bc000501_req-canonicalize_resource    = is_signtrue_req-canonicalizeresource."HTTP请求所指定的OBS资源

    "调用PI计算签名
    CALL METHOD calc_signtrue
      EXPORTING
        is_bc000501_req = ls_bc000501_req
      IMPORTING
        es_return       = es_return
      RECEIVING
        rs_signtrue     = rs_signtrue.

    ms_signtrue =  rs_signtrue.

  ENDMETHOD.


  METHOD gui_download.
    DATA: lv_filelength TYPE i,
          lt_data       TYPE TABLE OF x.

    TRY.
        "数据转换
        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
          EXPORTING
            buffer        = iv_data
          IMPORTING
            output_length = lv_filelength
          TABLES
            binary_tab    = lt_data.

        "数据上载
        CALL METHOD cl_gui_frontend_services=>gui_download
          EXPORTING
            filename                = iv_filename
            filetype                = 'BIN'
          CHANGING
            data_tab                = lt_data
          EXCEPTIONS
            file_write_error        = 1
            no_batch                = 2
            gui_refuse_filetransfer = 3
            invalid_type            = 4
            no_authority            = 5
            unknown_error           = 6
            header_not_allowed      = 7
            separator_not_allowed   = 8
            filesize_not_allowed    = 9
            header_too_long         = 10
            dp_error_create         = 11
            dp_error_send           = 12
            dp_error_write          = 13
            unknown_dp_error        = 14
            access_denied           = 15
            dp_out_of_memory        = 16
            disk_full               = 17
            dp_timeout              = 18
            file_not_found          = 19
            dataprovider_exception  = 20
            control_flush_error     = 21
            not_supported_by_gui    = 22
            error_no_gui            = 23
            OTHERS                  = 24.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid
                TYPE sy-msgty
              NUMBER sy-msgno
                WITH sy-msgv1
                     sy-msgv2
                     sy-msgv3
                     sy-msgv4
             RAISING error.
        ENDIF.
      CATCH cx_root INTO DATA(lox_root).
        MESSAGE e000 WITH lox_root->if_message~get_text( ) RAISING error.
    ENDTRY.
  ENDMETHOD.


  METHOD gui_upload.
    DATA: lt_data       TYPE TABLE OF x.

    TRY.
        "文件上载
        CALL METHOD cl_gui_frontend_services=>gui_upload
          EXPORTING
            filename                = iv_filename
            filetype                = 'BIN'
          IMPORTING
            filelength              = ev_filelength
          CHANGING
            data_tab                = lt_data[]
          EXCEPTIONS
            file_open_error         = 1
            file_read_error         = 2
            no_batch                = 3
            gui_refuse_filetransfer = 4
            invalid_type            = 5
            no_authority            = 6
            unknown_error           = 7
            bad_data_format         = 8
            header_not_allowed      = 9
            separator_not_allowed   = 10
            header_too_long         = 11
            unknown_dp_error        = 12
            access_denied           = 13
            dp_out_of_memory        = 14
            disk_full               = 15
            dp_timeout              = 16
            not_supported_by_gui    = 17
            error_no_gui            = 18
            OTHERS                  = 19.


        IF sy-subrc EQ 0.

*          "将文件转换成二进制
          CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
            EXPORTING
              input_length = ev_filelength
            IMPORTING
              buffer       = rv_data
            TABLES
              binary_tab   = lt_data[]
            EXCEPTIONS
              failed       = 1
              OTHERS       = 2.
        ENDIF.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid
                TYPE sy-msgty
              NUMBER sy-msgno
                WITH sy-msgv1
                     sy-msgv2
                     sy-msgv3
                     sy-msgv4
             RAISING error.
        ENDIF.
      CATCH cx_root INTO DATA(lox_root).
        MESSAGE e000 WITH lox_root->if_message~get_text( ) RAISING error.
    ENDTRY.
  ENDMETHOD.


  METHOD handle_close.
    CALL METHOD sender->set_visible
      EXPORTING
        visible = space.
  ENDMETHOD.


  METHOD handle_hotspot_click.



  ENDMETHOD.


  METHOD handle_toolbar.

  ENDMETHOD.


  METHOD html_show.

    DATA: lt_html_data TYPE STANDARD TABLE OF x255,
          lv_url       TYPE char255,
          lv_size      TYPE i,
          lv_caption   TYPE char30,
          lv_message   TYPE bapi_msg,
          lo_root      TYPE REF TO cx_root.

    lv_caption = iv_filename.

    TRY.
        IF iv_data IS NOT INITIAL.

          CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
            EXPORTING
              buffer        = iv_data
            IMPORTING
              output_length = lv_size
            TABLES
              binary_tab    = lt_html_data.
        ENDIF.

        "初始化控件
        IF html_viewer IS NOT INITIAL.
          html_viewer->free( ).
          FREE html_viewer.
        ENDIF.

        IF docu_container IS NOT INITIAL.
          docu_container->free( ).
          FREE docu_container.
        ENDIF.

        CREATE OBJECT docu_container
          EXPORTING
            width                       = 1000
            height                      = 300
            top                         = 120
            left                        = 50
            caption                     = lv_caption
          EXCEPTIONS
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5
            event_already_registered    = 6
            error_regist_event          = 7
            OTHERS                      = 8.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
          RETURN.
        ENDIF.

        SET HANDLER handle_close FOR docu_container.

        CREATE OBJECT html_viewer
          EXPORTING
            parent             = docu_container
          EXCEPTIONS
            cntl_error         = 1
            cntl_install_error = 2
            dp_install_error   = 3
            dp_error           = 4
            OTHERS             = 5.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
          RETURN.
        ENDIF.

        "加载数据
        CALL METHOD html_viewer->load_data
          EXPORTING
            type                   = iv_type    "'application'
            subtype                = iv_subtype "'pdf'
            size                   = lv_size
          IMPORTING
            assigned_url           = lv_url
          CHANGING
            data_table             = lt_html_data
          EXCEPTIONS
            dp_invalid_parameter   = 1
            dp_error_general       = 2
            cntl_error             = 3
            html_syntax_notcorrect = 4
            OTHERS                 = 5.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
          RETURN.
        ENDIF.

        "显示
        CALL METHOD html_viewer->show_url
          EXPORTING
            url                    = lv_url
            in_place               = ' X'
          EXCEPTIONS
            cntl_error             = 1
            cnht_error_not_allowed = 2
            cnht_error_parameter   = 3
            dp_error_general       = 4
            OTHERS                 = 5.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
          RETURN.
        ENDIF.

      CATCH cx_root INTO lo_root.
        lv_message = lo_root->get_text( ).
        MESSAGE e000 WITH lv_message INTO lv_message.
        es_return = zcl_message=>convert_syst_to_bapiret2( ).
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD list_bucket_objects.

    DATA: lv_message    TYPE bapi_msg.

    DATA: lv_filename    TYPE string,
          lv_extension   TYPE string,
          lv_objectkey   TYPE string,
          lv_user_action TYPE i,
          lv_action      TYPE zzaction_obs,
          ls_return	     TYPE bapiret2,
          ls_result	     TYPE zobss_result,
          lv_nextmarker  TYPE zzobs_nextmarker,
          lv_lines       TYPE i.

    set_bucket( iv_bucketname = iv_bucketname )."设置桶信息

    set_action( me->c_action_getobjlist )."设置OBS操作

    "获取OBS的签名
    CLEAR:ms_signtrue_req         ,
          es_return               .

    ms_signtrue_req-bucketname             = iv_bucketname.
    ms_signtrue_req-httpmethod             = mv_http_method.
    ms_signtrue_req-authortype             = c_authortype_header.
    ms_signtrue_req-contenttype            = '' .
    ms_signtrue_req-contentmd5             = ''.
    ms_signtrue_req-canonicalizeheaders    = ''.
    ms_signtrue_req-canonicalizeresource   = '/'  && iv_bucketname && '/' .


    CLEAR: lv_nextmarker,
           me->mt_object_list.
    DO.

      CALL METHOD get_signtrue
        EXPORTING
          is_signtrue_req = ms_signtrue_req
        IMPORTING
          es_return       = es_return.

      IF es_return-type CA 'EAX'.
        EXIT.
      ENDIF.

      CLEAR: me->mt_http_header.
      me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = '~request_method' vaule = me->mv_http_method ) ). " 请求方法
      me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'Date' vaule = ms_signtrue-date ) ). " 日期
      me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'Authorization' vaule = ms_signtrue-authorization ) ). "


      CLEAR: me->mt_parameters.

      me->mt_parameters = VALUE #(
       ( name = 'prefix'      value = iv_prefix      )
       ( name = '&marker'     value = lv_nextmarker  )
*       ( name = '&key-marker' value = iv_key_marker  )
       ).

      "采用HTTP Client访问OBS
      me->get_obs_object_list(
        EXPORTING
          iv_bucketname = iv_bucketname
          it_parameters = me->mt_parameters
        IMPORTING
          es_return     = ls_return
          es_result     = ls_result ).

      IF ls_result-code = 200.
        "获取桶&1对象列表成功.
        MESSAGE s016 WITH iv_bucketname INTO lv_message.
        es_return = zcl_message=>convert_syst_to_bapiret2( ).

        "解析XML，获取文件列表
        IF me->parse_list_bucket_result(
          EXPORTING
            xmldata = ls_result-bizdata
          IMPORTING
            nextmarker = lv_nextmarker ) <> me->c_true.

          "如果解析出的XML文件中的IsTruncated=false时，标识已经返回全部结果，则终止循环
          EXIT.
        ENDIF.
      ELSE.
        "获取桶&1对象列表失败，错误原因：&1&2
        MESSAGE e017 WITH ls_result-code  ls_result-reason INTO lv_message.
        es_return = zcl_message=>convert_syst_to_bapiret2( ).
        EXIT.
      ENDIF.
    ENDDO.

    rt_object_list = me->mt_object_list.


  ENDMETHOD.


  METHOD logging_obslog.

    DATA: ls_log  TYPE zobs_log.

    "记录日志

    "分配日志流水号
    CLEAR: ls_log.
    CALL METHOD zcl_obs=>get_number
      EXPORTING
        iv_object        = c_zlogid_obs
        iv_nrrangenr     = '01'
      IMPORTING
        ev_number        = ls_log-logid
      EXCEPTIONS
        object_not_found = 1
        invaild_length   = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    ls_log-bucket    = mv_bucketname.
    ls_log-objectkey = mv_objectkey.
    ls_log-action    = mv_action. "OBS 操作

    IF ms_signtrue IS NOT INITIAL.
      MOVE-CORRESPONDING ms_signtrue TO ls_log.
    ENDIF.

    IF is_result IS NOT INITIAL.
      MOVE-CORRESPONDING is_result TO ls_log.
    ENDIF.

    IF is_return IS NOT INITIAL.
      ls_log-type  = is_return-type.
      ls_log-msgid = is_return-id.
      ls_log-msgno = is_return-number.

      MESSAGE ID is_return-id
            TYPE is_return-type
          NUMBER is_return-number
            WITH is_return-message_v1
                 is_return-message_v2
                 is_return-message_v3
                 is_return-message_v4
            INTO ls_log-message .

      CASE ls_log-type.
        WHEN 'E' OR 'A' OR 'X'.
          ls_log-icon = '@5C@'.
        WHEN 'W'.
          ls_log-icon = '@5D@'.
        WHEN OTHERS.
          ls_log-icon = '@5B@'.
      ENDCASE.

    ENDIF.

    ls_log-uname = sy-uname.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    CONVERT TIME STAMP lv_timestamp TIME ZONE 'UTC+8'"sy-zonlo
      INTO DATE ls_log-udate
           TIME ls_log-utime  .

    MODIFY zobs_log FROM ls_log.


  ENDMETHOD.


  METHOD ole_show.

    DATA : lv_app_name       TYPE char3,
           lv_doc_type       TYPE text20,
           lo_control        TYPE REF TO i_oi_container_control,
           lo_doc_proxy      TYPE REF TO i_oi_document_proxy,
           lo_error          TYPE REF TO i_oi_error,
           ls_retcode        TYPE soi_ret_string,
           lv_document_title TYPE sdbah-actid,
           lv_caption        TYPE char30,
           lv_message        TYPE bapi_msg,
           lo_root           TYPE REF TO cx_root.


    DATA: lt_html_data TYPE STANDARD TABLE OF x255,
          lv_url       TYPE char255,
          lv_size      TYPE i.

    lv_caption  = iv_filename.
    lv_app_name = iv_type.
    lv_doc_type = iv_subtype.


    TRY.
        IF iv_data IS NOT INITIAL.

          CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
            EXPORTING
              buffer        = iv_data
            IMPORTING
              output_length = lv_size
            TABLES
              binary_tab    = lt_html_data.
        ENDIF.

        IF docu_container IS NOT INITIAL.
          docu_container->free( ).
          FREE docu_container.
        ENDIF.

        CREATE OBJECT docu_container
          EXPORTING
            width                       = 1000
            height                      = 300
            top                         = 120
            left                        = 50
            caption                     = lv_caption
          EXCEPTIONS
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5
            event_already_registered    = 6
            error_regist_event          = 7
            OTHERS                      = 8.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
          RETURN.

        ENDIF.

        SET HANDLER handle_close FOR docu_container.

        c_oi_container_control_creator=>get_container_control(
                                         IMPORTING
                                           control = lo_control
                                           error   = lo_error
                                           retcode = ls_retcode ).

        IF lo_error->has_failed = abap_true.
          lo_error->raise_message( 'S' ).
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
          es_return-type = 'E'.
          RETURN.

        ENDIF.

        CALL METHOD lo_control->init_control
          EXPORTING
            r3_application_name      = lv_app_name
            inplace_enabled          = 'X'
            inplace_scroll_documents = 'X'
            parent                   = docu_container
            register_on_close_event  = 'X'
            register_on_custom_event = 'X'
          IMPORTING
            error                    = lo_error
            retcode                  = ls_retcode
          EXCEPTIONS
            javabeannotsupported     = 1
            OTHERS                   = 2.

        IF lo_error->has_failed = abap_true.
          lo_error->raise_message( 'S' ).
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
          es_return-type = 'E'.
          RETURN.
        ENDIF.

        lo_control->get_document_proxy(
                      EXPORTING document_type    = lv_doc_type
*                            document_format = 'OLE'
                      IMPORTING document_proxy   = lo_doc_proxy
                                error            = lo_error
                                retcode          = ls_retcode ).

        IF ls_retcode NE c_oi_errors=>ret_ok.
          EXIT.
        ENDIF.

        lv_document_title = iv_filename.

        "This is working
        CALL METHOD lo_doc_proxy->open_document_from_table
          EXPORTING
            document_size    = lv_size
            document_table   = lt_html_data
            document_title   = lv_document_title
            open_inplace     = 'X'
            open_readonly    = 'X'
            protect_document = 'X'
          IMPORTING
            error            = lo_error
            retcode          = ls_retcode.
        IF lo_error->has_failed = abap_true.
          lo_error->raise_message( 'S' ).
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
          es_return-type = 'E'.
          RETURN.
        ENDIF.

      CATCH cx_root INTO lo_root.
        lv_message = lo_root->get_text( ).
        MESSAGE e000 WITH lv_message INTO lv_message.
        es_return = zcl_message=>convert_syst_to_bapiret2( ).
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD parse_dom_document.

    DATA: lr_node     TYPE REF TO if_ixml_node,
          lr_iterator TYPE REF TO if_ixml_node_iterator,
          lr_node_map TYPE REF TO if_ixml_named_node_map,
          lv_name     TYPE string,
          lv_value    TYPE string.

    lr_node ?= document.


    CHECK lr_node IS NOT INITIAL.

    "创建一个节点迭代器
    lr_iterator = lr_node->create_iterator(   ).

    "获取当前节点
    lr_node = lr_iterator->get_next( ).

    "循环所有节点
    WHILE lr_node IS NOT INITIAL.

      CASE lr_node->get_type( ).
        WHEN if_ixml_node=>co_node_element.
          lv_name = to_upper( lr_node->get_name( ) ).
          IF lv_name = 'CONTENTS'.
            APPEND INITIAL LINE TO me->mt_object_list ASSIGNING FIELD-SYMBOL(<lfs_object_list>).

          ENDIF.
        WHEN if_ixml_node=>co_node_text OR
              if_ixml_node=>co_node_cdata_section.
          lv_value = lr_node->get_value( ).


          CASE lv_name.
            WHEN 'ISTRUNCATED'.
              is_truncated = lv_value.
            WHEN 'NEXTMARKER'.
              nextmarker = lv_value.
            WHEN OTHERS.

              IF <lfs_object_list> IS  ASSIGNED.
                ASSIGN COMPONENT lv_name OF STRUCTURE <lfs_object_list> TO FIELD-SYMBOL(<lfs_field>).
                IF sy-subrc EQ 0.
                  <lfs_field> = lv_value.
                ENDIF.
              ENDIF.


          ENDCASE.

        WHEN OTHERS.
      ENDCASE.
      "获取下一个节点
      lr_node = lr_iterator->get_next( ).
    ENDWHILE.





  ENDMETHOD.


  METHOD parse_list_bucket_result.

    DATA: lr_ixml          TYPE REF TO if_ixml,
          lr_streamfactory TYPE REF TO if_ixml_stream_factory,
          lr_parser        TYPE REF TO if_ixml_parser,
          lr_istram        TYPE REF TO if_ixml_istream,
          lr_document      TYPE REF TO if_ixml_document.
    "create main ixml factory
    lr_ixml = cl_ixml=>create(  ).

    "create a stream factory
    lr_streamfactory = lr_ixml->create_stream_factory( ).

    lr_istram = lr_streamfactory->create_istream_string( xmldata ).

    "create a document
    lr_document = lr_ixml->create_document( ).

    "Creates a parser
    lr_parser = lr_ixml->create_parser( document       = lr_document
                                        istream        = lr_istram
                                        stream_factory = lr_streamfactory
                                       ).

    IF lr_parser->parse( ) NE 0."Full parsing of input stream into a DOM.

      IF lr_parser->num_errors( ) <> 0."
        RETURN.
      ENDIF.

    ENDIF.


    IF lr_parser->is_dom_generating( ) = abap_true. "DOM是否生成

      "解析DOM
      is_truncated = parse_dom_document(
        EXPORTING
          document   = lr_document
        IMPORTING
          nextmarker = nextmarker ).

    ENDIF.

  ENDMETHOD.


  METHOD save_signtrue.

    DATA: ls_signtrue TYPE zobst_signtrue.

    CALL METHOD zcl_json=>deserialize
      EXPORTING
        json = iv_json
      CHANGING
        data = ls_signtrue.

    CONDENSE ls_signtrue-accesskeyid NO-GAPS.
    CONDENSE ls_signtrue-signature   NO-GAPS.
    CONDENSE ls_signtrue-expires     NO-GAPS.

    ls_signtrue-uuid  = iv_uuid.
    ls_signtrue-ernam = sy-uname.
    ls_signtrue-erdat = sy-datum.
    ls_signtrue-erzet = sy-uzeit.

    MODIFY zobst_signtrue FROM ls_signtrue.
    COMMIT WORK.

  ENDMETHOD.


  METHOD scape_url_objectkey.
    CALL METHOD cl_http_utility=>if_http_utility~escape_url
      EXPORTING
        unescaped = iv_objectkey
*       options   =
      RECEIVING
        escaped   = rv_objectkey.
    REPLACE ALL OCCURRENCES OF '%2f' IN rv_objectkey WITH '/'.
    REPLACE ALL OCCURRENCES OF '%2F' IN rv_objectkey WITH '/'.
  ENDMETHOD.


  METHOD set_action.
    mv_action      = iv_action.
    mv_http_method = zcl_obs=>get_httpmethod_by_action( mv_action ) .
  ENDMETHOD.


  METHOD set_bucket.
    mv_bucketname = iv_bucketname .
    mv_objectkey  = iv_objectkey  .
  ENDMETHOD.


  METHOD set_http_header.
    DATA: lv_content_length  TYPE string.

    CLEAR: me->mt_http_header.

    me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = '~request_method' vaule = iv_httpmethod ) ). " 请求方法
    IF is_signtrue-authortype = c_authortype_header.
      me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'Authorization' vaule = is_signtrue-authorization ) ). " 请求方法
      me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'Date' vaule = is_signtrue-date ) ). " 日期

    ENDIF.

    IF iv_contentlength IS INITIAL.
      me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'CanonicalizedResource' vaule = is_signtrue-canonicalizeresource ) ). "
    ENDIF.

    me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'Content-Type' vaule = is_signtrue-contenttype  ) ). "
    me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'Content-MD5' vaule = ''  ) ). "

    "Content-Length
    IF iv_contentlength IS NOT INITIAL.
      lv_content_length = iv_contentlength.
      me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'Content-Length' vaule = lv_content_length  ) ). "
    ENDIF.

    "x-obs-copy-source
    IF iv_copysource IS NOT INITIAL.
      me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'x-obs-copy-source' vaule = iv_copysource  ) ). "
    ENDIF.

    me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'Connection' vaule = 'keep-alive' ) ). "

    me->set_http_header_field(
      EXPORTING
        it_http_header = me->mt_http_header " Http Header
      CHANGING
        co_http_client = co_http_client     " HTTP Client Abstraction
    ).

*    CALL METHOD co_http_client->request->set_header_field
*      EXPORTING
*        name  = '~request_method'
*        value = iv_httpmethod.
*
*
*    IF is_signtrue-authortype = c_authortype_header.
*      "授权
*      CALL METHOD co_http_client->request->set_header_field
*        EXPORTING
*          name  = 'Authorization'
*          value = is_signtrue-authorization.
*
*      "日期
*      CALL METHOD co_http_client->request->set_header_field
*        EXPORTING
*          name  = 'Date'
*          value = is_signtrue-date.
*    ENDIF.
*
*    "规范化资源 /BucketName/Objectkey
*    IF iv_contentlength IS INITIAL.
*      CALL METHOD co_http_client->request->set_header_field
*        EXPORTING
*          name  = 'CanonicalizedResource'
*          value = is_signtrue-canonicalizeresource.
*    ENDIF.
*
*    "Content-Type
*    CALL METHOD co_http_client->request->set_header_field
*      EXPORTING
*        name  = 'Content-Type'
*        value = is_signtrue-contenttype. "application/octet-stream
*
*    "Content-MD5
*    CALL METHOD co_http_client->request->set_header_field
*      EXPORTING
*        name  = 'Content-MD5'
*        value = ''.
*
*    IF iv_copysource IS NOT INITIAL.
*      CALL METHOD co_http_client->request->set_header_field
*        EXPORTING
*          name  = 'x-obs-copy-source'
*          value = iv_copysource.
*    ENDIF.
*
*    "Content-Length
*    IF iv_contentlength IS NOT INITIAL.
*      lv_content_length = iv_contentlength.
*      CALL METHOD co_http_client->request->set_header_field
*        EXPORTING
*          name  = 'Content-Length'
*          value = lv_content_length.
*    ENDIF.
*
*    CALL METHOD co_http_client->request->set_header_field
*      EXPORTING
*        name  = 'Connection'
*        value = 'keep-alive'.
  ENDMETHOD.


  METHOD set_http_header_field.
    LOOP AT it_http_header INTO DATA(ls_http_header).
      CALL METHOD co_http_client->request->set_header_field
        EXPORTING
          name  = ls_http_header-name
          value = ls_http_header-vaule.
    ENDLOOP.

  ENDMETHOD.


  METHOD set_number_range.
    DATA: lo_fromnumber TYPE REF TO data,
          lo_tonumber   TYPE REF TO data.

    IF iv_length IS INITIAL.
      MESSAGE e001 RAISING invaild_length.
    ENDIF.

    CREATE DATA lo_fromnumber TYPE n LENGTH iv_length.

    ASSIGN lo_fromnumber->* TO FIELD-SYMBOL(<lfs_fromnumber>).
    IF <lfs_fromnumber> IS ASSIGNED.
      <lfs_fromnumber> = <lfs_fromnumber> + 1.
      ev_fromnumber = <lfs_fromnumber> .
    ENDIF.

    CREATE DATA lo_tonumber TYPE n LENGTH iv_length.

    ASSIGN lo_tonumber->* TO FIELD-SYMBOL(<lfs_tonumber>).
    IF <lfs_tonumber> IS ASSIGNED.
      ev_tonumber = <lfs_tonumber> .
      REPLACE ALL OCCURRENCES OF '0' IN ev_tonumber WITH '9'.
    ENDIF.

  ENDMETHOD.


  METHOD set_salv_layout.

    "设置布局
    DATA: ls_layout_key TYPE salv_s_layout_key.
    ls_layout_key-report = sy-repid.
    ls_layout_key-handle = 'LOG'.
    DATA(lr_layout) = io_table->get_layout( ).

  ENDMETHOD.


  METHOD SET_URL_PARAMETERS.

    CHECK value IS NOT INITIAL.

    IF  parameters IS NOT INITIAL.
      r_parameters = parameters && '&' && name && '=' && value.
    ELSE.
      r_parameters =  name && '=' && value.
    ENDIF.

  ENDMETHOD.


  METHOD text_convert.
    DATA: lv_xstring TYPE xstring,
          lv_string  TYPE string.

    DATA: lt_bin_data TYPE STANDARD TABLE OF x255,
          lv_length   TYPE i.

    lv_xstring = cv_data.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_xstring
      IMPORTING
        output_length = lv_length
      TABLES
        binary_tab    = lt_bin_data.


    CALL FUNCTION 'SCMS_BINARY_TO_STRING'
      EXPORTING
        input_length  = lv_length
        mimetype      = 'text/plain'
      IMPORTING
        text_buffer   = lv_string
        output_length = lv_length
      TABLES
        binary_tab    = lt_bin_data
      EXCEPTIONS
        failed        = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text     = lv_string
        mimetype = 'text/plain'
      IMPORTING
        buffer   = lv_xstring
      EXCEPTIONS
        failed   = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    cv_data = lv_xstring.


  ENDMETHOD.


  METHOD upload_attachment.
    CALL METHOD upload_object
      EXPORTING
        iv_bucketname = iv_bucketname
        iv_filename   = iv_filename
        iv_data       = iv_data
        iv_objectkey  = iv_objectkey
      IMPORTING
        es_return     = es_return
        es_result     = es_result.

    "记录日志
    logging_obslog( is_return = es_return is_result = es_result ).

    "日志自动清理
    clear_obslog( ).

  ENDMETHOD.


  METHOD upload_object.

    DATA: lv_objectkey TYPE string.

    DATA: lv_data       TYPE xstring,
          lv_filelength TYPE i,
          lv_message    TYPE bapi_msg.


    "设置桶信息
    set_bucket( iv_bucketname = iv_bucketname iv_objectkey = iv_objectkey ).
    "设置OBS操作
    set_action( c_action_upload ).

    CLEAR: lv_objectkey.
    lv_objectkey = iv_objectkey.

    CALL METHOD adjust_objectkey
      IMPORTING
        es_return    = es_return
      CHANGING
        cv_objectkey = lv_objectkey.
    IF es_return-type NA 'EAX'.

      "获取OBS的签名
      CLEAR:ms_signtrue_req         ,
            es_return               ,
            es_result               .
      ms_signtrue_req-bucketname             = iv_bucketname.
      ms_signtrue_req-httpmethod             = mv_http_method.
      ms_signtrue_req-authortype             = c_authortype_header.
      ms_signtrue_req-contenttype            = c_contenttype_bin .
      ms_signtrue_req-contentmd5             = ''.
      ms_signtrue_req-canonicalizeheaders    = ''.
      ms_signtrue_req-canonicalizeresource   = '/' && iv_bucketname && lv_objectkey.

      CALL METHOD get_signtrue
        EXPORTING
          is_signtrue_req = ms_signtrue_req
        IMPORTING
          es_return       = es_return.

    ENDIF.

    IF es_return-type NA 'EAX'.
      "上载文件
      IF iv_filename IS NOT INITIAL.
        CALL METHOD gui_upload
          EXPORTING
            iv_filename   = iv_filename
          IMPORTING
            ev_filelength = lv_filelength
          RECEIVING
            rv_data       = lv_data
          EXCEPTIONS
            error         = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
        ENDIF.
      ELSEIF iv_data IS NOT INITIAL.
        lv_data       = iv_data.
        lv_filelength = xstrlen( lv_data ).
      ELSE.
        "上载内容不能为空
        MESSAGE e015 INTO lv_message.
        es_return = zcl_message=>convert_syst_to_bapiret2( ).

      ENDIF.

      IF es_return-type NA 'EAX'.

        "采用HTTP Client访问OBS
        call_obs_httpclient( EXPORTING iv_objectkey = lv_objectkey
                                       iv_data      = lv_data       "二进制数据
                                       iv_length    = lv_filelength
                             IMPORTING es_return    = es_return
                                       es_result    = es_result     ).

        IF es_result-code = 200.
          "附件上载成功，ObjectKey为&1.
          MESSAGE s005 WITH iv_objectkey INTO lv_message.
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
        ELSE.
          "附件上载失败，错误原因：&1&2
          MESSAGE e006 WITH es_result-code  es_result-reason INTO lv_message.
          es_return = zcl_message=>convert_syst_to_bapiret2( ).
        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD zif_salv_event_handler~on_double_click.
  ENDMETHOD.


  METHOD zif_salv_event_handler~on_link_click.

    DATA:lv_filename   TYPE string,
         lt_string_tab TYPE TABLE OF string,
         ls_string     TYPE string,
         lv_line       TYPE i,
         lv_data       TYPE string.

    IF column = 'ICON'.
      READ TABLE mt_log INTO DATA(ls_log) INDEX row.
      IF sy-subrc EQ 0.

        SPLIT ls_log-objectkey AT '/' INTO TABLE lt_string_tab.

        DESCRIBE TABLE lt_string_tab LINES lv_line.

        READ TABLE lt_string_tab INTO ls_string INDEX lv_line.
        IF sy-subrc EQ 0.
          lv_filename = ls_string.
        ENDIF.

        IF ls_log-bizdata IS NOT INITIAL.
          lv_data  = ls_log-bizdata.
        ELSE.
          lv_data  = ls_log-message.
        ENDIF.

        display_log_html( iv_caption = lv_filename
                          iv_data    = lv_data ).

      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
