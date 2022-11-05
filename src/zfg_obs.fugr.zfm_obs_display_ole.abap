FUNCTION zfm_obs_display_ole.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(IV_DATA) TYPE  XSTRING
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
          parent                   = go_docu_container
          register_on_close_event  = 'X'
          register_on_custom_event = 'X'
        IMPORTING
          error                    = lo_error
          retcode                  = ls_retcode.

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
*
*  CALL SCREEN 9000 STARTING AT 5 5
*                     ENDING AT 100 25.

  CALL SCREEN 9000  .



ENDFUNCTION.
