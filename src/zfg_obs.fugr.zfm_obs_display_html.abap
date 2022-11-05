FUNCTION zfm_obs_display_html.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(IV_DATA) TYPE  XSTRING
*"     REFERENCE(IV_TYPE) TYPE  TEXT20
*"     REFERENCE(IV_SUBTYPE) TYPE  TEXT20
*"     REFERENCE(IV_FILENAME) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(ES_RETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------


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
        lt_html_text TYPE STANDARD TABLE OF text1024,
        lv_url       TYPE char255,
        lv_size      TYPE i.

  gv_title    = iv_filename.
*  lv_caption  = iv_filename.
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

      "初始化控件
      IF go_html_viewer IS NOT INITIAL.
        go_html_viewer->free( ).
        FREE go_html_viewer.
      ENDIF.
      IF go_docu_container IS NOT INITIAL.
        go_docu_container->free( ).
        FREE go_docu_container.
      ENDIF.

      CREATE OBJECT go_docu_container
        EXPORTING
          repid                       = sy-repid
          dynnr                       = '9000'
          extension                   = 9999
          caption                     = lv_caption
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          OTHERS                      = 6.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
        es_return = zcl_message=>convert_syst_to_bapiret2( ).
        RETURN.

      ENDIF.

      CREATE OBJECT go_html_viewer
        EXPORTING
          parent             = go_docu_container
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
      CALL METHOD go_html_viewer->load_data
        EXPORTING
          type                   = iv_type    "'application'
          subtype                = iv_subtype "'pdf'
          size                   = lv_size
*         encoding               = '8404'
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
      CALL METHOD go_html_viewer->show_url
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

  CALL SCREEN 9000  .



ENDFUNCTION.
