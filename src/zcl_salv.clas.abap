class ZCL_SALV definition
  public
  inheriting from CL_SALV_MODEL_LIST
  final
  create public .

public section.

  interfaces IF_SALV_C_SELECTION_MODE .

  methods CONSTRUCTOR .
  methods SET_GUI_STATUS
    importing
      !IV_PFREPID type SYREPID
      !IV_PFSTATUS type SYPFKEY .
  methods SET_SCREEN_DIALOG
    importing
      !IS_POPUP type ZSALV_S_POPUP optional .
  methods DISPLAY
    importing
      !IV_LIST_DISPLAY type SAP_BOOL default IF_SALV_C_BOOL_SAP=>FALSE
      !IS_LAYOUT type ZSALV_S_LAYOUT optional
      !IT_COLUMNS type ZSALV_TT_FCAT optional
      !IS_POPUP type ZSALV_S_POPUP optional
      !IV_PFREPID type SYREPID optional
      !IV_PFSTATUS type SYPFKEY optional
      !IR_EVENT_HANDLER type ref to ZIF_SALV_EVENT_HANDLER optional
      !IR_TABLE type ref to CL_SALV_TABLE optional
    changing
      !CT_DATA type DATA optional .
  methods GET_GRID
    importing
      !IR_SALV_MODEL type ref to CL_SALV_MODEL
    returning
      value(R_GRID) type ref to CL_GUI_ALV_GRID .
  methods GET_TABLE
    returning
      value(R_TABLE) type ref to CL_SALV_TABLE .
  methods SET_TABLE
    importing
      value(IR_TABLE) type ref to CL_SALV_TABLE .
  methods SET_LAYOUT
    importing
      !IS_LAYOUT type ZSALV_S_LAYOUT optional .
  methods SET_FUNCTIONS .
  methods SET_AGGREGATION
    importing
      !IT_COLUMNS type ZSALV_TT_FCAT optional
      !IV_AGGREGATION_BEFORE_ITEMS type ABAP_BOOL default '' .
  methods SET_COLUMNS
    importing
      !IT_COLUMNS type ZSALV_TT_FCAT .
  methods SET_SELECTION_MODE
    importing
      !IV_SELECTION_MODE type SALV_DE_CONSTANT default 4 .
  class-methods FACTORY
    returning
      value(RO_SALV) type ref to ZCL_SALV .
protected section.
private section.

  data MT_COLUMNS type ZSALV_TT_FCAT .
  data MS_LAYOUT type ZSALV_S_LAYOUT .
  data MR_TABLE type ref to CL_SALV_TABLE .
  data MR_DATA type ref to DATA .

  methods SET_EVENT
    importing
      !IR_EVENT_HANDLER type ref to ZIF_SALV_EVENT_HANDLER .
ENDCLASS.



CLASS ZCL_SALV IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
  ENDMETHOD.


  METHOD display.
    DATA: lv_message TYPE string.
    FIELD-SYMBOLS: <lfs_data> TYPE STANDARD TABLE.

    DATA: lt_log TYPE TABLE OF zobs_log.

*    CREATE DATA mr_data TYPE HANDLE it_data.


    IF ir_table IS INITIAL.
      GET REFERENCE OF ct_data INTO mr_data.
      ASSIGN mr_data->* TO <lfs_data>.

      TRY.
          CALL METHOD cl_salv_table=>factory
            IMPORTING
              r_salv_table = mr_table
            CHANGING
              t_table      = <lfs_data>.

        CATCH cx_salv_msg.
      ENDTRY.
    ELSE.

      mr_table = ir_table.

    ENDIF.

    "设置布局
    CALL METHOD set_layout
      EXPORTING
        is_layout = is_layout.

    "设置选择模式
    CALL METHOD set_selection_mode.

    "设置字段目录
    CALL METHOD set_columns
      EXPORTING
        it_columns = it_columns .


    "以弹窗方式显示ALV
    IF is_popup IS NOT INITIAL.
      CALL METHOD set_screen_dialog
        EXPORTING
          is_popup = is_popup.
    ENDIF.

    "设置GUI Status
    CALL METHOD set_gui_status
      EXPORTING
        iv_pfrepid  = iv_pfrepid
        iv_pfstatus = iv_pfstatus.

    "事件注册
    CALL METHOD set_event
      EXPORTING
        ir_event_handler = ir_event_handler.

    "显示ALV
    mr_table->display( ).

  ENDMETHOD.


  METHOD factory.
    ro_salv = NEW zcl_salv( ).
  ENDMETHOD.


  METHOD get_grid.
    DATA: lo_grid_adapter TYPE REF TO cl_salv_grid_adapter.
    lo_grid_adapter ?= ir_salv_model->r_controller->r_adapter.
    IF lo_grid_adapter IS BOUND.
      r_grid = lo_grid_adapter->get_grid( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_table.
    r_table = mr_table.
  ENDMETHOD.


  METHOD set_aggregation.

    DATA: ls_ddic_reference TYPE salv_s_ddic_reference,
          lr_columns        TYPE REF TO cl_salv_columns_table,
          lr_column         TYPE REF TO cl_salv_column_table,
          lt_column_ref     TYPE salv_t_column_ref.

    DATA: lv_scrtext_l TYPE scrtext_l,
          lv_scrtext_m TYPE scrtext_m,
          lv_scrtext_s TYPE scrtext_s.

    DATA: lv_column_count TYPE i,
          lv_col_pos      TYPE i.

    DATA: lt_columns TYPE zsalv_tt_fcat.

    DATA(lr_aggregations) = mr_table->get_aggregations( ).

    IF it_columns[] IS NOT INITIAL.
      lt_columns = it_columns[].
    ELSE.
      lt_columns = mt_columns[].
    ENDIF.

    LOOP AT lt_columns INTO DATA(ls_columns).
      IF ls_columns-do_sum IS NOT INITIAL.
        TRY.
            lr_aggregations->add_aggregation(
              EXPORTING
                columnname  = ls_columns-fieldname        " ALV Control: Field Name of Internal Table Field
                aggregation = if_salv_c_aggregation=>total " Aggregation
*            RECEIVING
*               value       =                              " ALV: Aggregations
            ).
          CATCH cx_salv_data_error. " ALV: General Error Class (Checked in Syntax Check)
          CATCH cx_salv_not_found.  " ALV: General Error Class (Checked in Syntax Check)
          CATCH cx_salv_existing.   " ALV: General Error Class (Checked in Syntax Check)

        ENDTRY.
      ENDIF.
    ENDLOOP.

    IF iv_aggregation_before_items IS NOT INITIAL.
      lr_aggregations->set_aggregation_before_items( ).
    ENDIF.


  ENDMETHOD.


  METHOD set_columns.

    DATA: ls_ddic_reference TYPE salv_s_ddic_reference,
          lr_columns        TYPE REF TO cl_salv_columns_table,
          lr_column         TYPE REF TO cl_salv_column_table,
          lt_column_ref     TYPE salv_t_column_ref.

    DATA: lv_scrtext_l TYPE scrtext_l,
          lv_scrtext_m TYPE scrtext_m,
          lv_scrtext_s TYPE scrtext_s.

    DATA: lv_column_count TYPE i,
          lv_col_pos      TYPE i.

    me->mt_columns = it_columns[].

    lr_columns = mr_table->get_columns( ).

    "冻结主键
    lr_columns->set_key_fixation( if_salv_c_bool_sap=>true ).

    IF it_columns[] IS INITIAL.
      TRY.
          lr_column ?= lr_columns->get_column( 'MANDT' ). "向下兼容
        CATCH cx_salv_not_found.

      ENDTRY.
      "技术字段
      IF lr_column IS NOT INITIAL.
        lr_column->set_technical( if_salv_c_bool_sap=>true ).
      ENDIF.
    ELSE.
      lt_column_ref   = lr_columns->get( ).
      lv_column_count = lines( lt_column_ref ).

      LOOP AT lt_column_ref INTO DATA(ls_column_ref).
        READ TABLE it_columns INTO DATA(ls_columns) WITH KEY fieldname = ls_column_ref-columnname .
        IF sy-subrc EQ 0.
          TRY.
              lr_column ?= lr_columns->get_column( ls_columns-fieldname ). "向下兼容
            CATCH cx_salv_not_found.
              ...
          ENDTRY.

          "设置列位置
*          lv_col_pos = lv_column_count + ls_columns-col_pos.
          "SALV SET_COLUMN_POSITION中会默认删除字段，如果字段的位置，为空或超过字段总数，
          "Append在最后，否则是insert到指定位置
          lv_col_pos = ls_columns-col_pos.
          lr_columns->set_column_position( columnname = ls_columns-fieldname
                                           position   = lv_col_pos ).

          "设置主键
          IF ls_columns-key IS NOT INITIAL.
            lr_column->set_key( abap_true ).
            lr_column->set_key_presence_required(
              value = if_salv_c_bool_sap=>true
            ).
          ENDIF.

          "设置热点
          IF ls_columns-hotspot IS NOT INITIAL.
            lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
          ENDIF.

          "设置参考字段
          IF ls_columns-ref_table IS NOT INITIAL AND ls_columns-ref_field IS NOT INITIAL.
            CLEAR: ls_ddic_reference.
            ls_ddic_reference-table = ls_columns-ref_table.
            ls_ddic_reference-field = ls_columns-ref_field.
            lr_column->set_ddic_reference( ls_ddic_reference ).
          ENDIF.

          "设置文本

          IF ls_columns-reptext IS NOT INITIAL.
            lv_scrtext_l   = ls_columns-reptext.
            lv_scrtext_m   = ls_columns-reptext.
            lv_scrtext_s   = ls_columns-reptext.
          ELSE.
            lv_scrtext_l   = ls_columns-scrtext_l.
            lv_scrtext_m   = ls_columns-scrtext_m.
            lv_scrtext_s   = ls_columns-scrtext_s.
          ENDIF.
          lr_column->set_long_text( lv_scrtext_l ).
          lr_column->set_medium_text( lv_scrtext_m ).
          lr_column->set_short_text( lv_scrtext_s ).

          "隐藏列
          IF ls_columns-no_out IS NOT INITIAL.
            lr_column->set_visible( cl_salv_column_table=>false ).
          ENDIF.

          "设置前导零
          IF ls_columns-lzero IS NOT INITIAL.
            lr_column->set_leading_zero( if_salv_c_bool_sap=>false ).
          ELSE.
            lr_column->set_leading_zero( if_salv_c_bool_sap=>true ).
          ENDIF.
          "输出隐藏零
          IF ls_columns-no_zero IS NOT INITIAL.
            lr_column->set_zero( if_salv_c_bool_sap=>false ).
          ELSE.
            lr_column->set_zero( if_salv_c_bool_sap=>true ).
          ENDIF.

          "设置转换函数
          IF ls_columns-edit_mask IS NOT INITIAL.
            lr_column->set_edit_mask( ls_columns-edit_mask ).
          ENDIF.

          "设置符号
          IF ls_columns-no_sign IS NOT INITIAL.
            lr_column->set_sign( if_salv_c_bool_sap=>false ).
          ENDIF.

          IF ls_columns-decimals_o IS NOT INITIAL.
            lr_column->set_decimals( ls_columns-decimals_o ).
          ENDIF.

          "设置输出长度
          IF ls_columns-outputlen IS NOT INITIAL.
            lr_column->set_output_length( ls_columns-outputlen ).
          ENDIF.

          "列抬头的工具提示
          IF ls_columns-tooltip IS NOT INITIAL.
            lr_column->set_tooltip( ls_columns-tooltip ).
          ENDIF.

          "列优化
          IF ls_columns-col_opt IS NOT INITIAL.
            lr_column->set_optimized( if_salv_c_bool_sap=>true ).
          ENDIF.



          "技术字段
          IF ls_columns-tech IS NOT INITIAL.
            ls_column_ref-r_column->set_technical( if_salv_c_bool_sap=>true ).
          ENDIF.

        ELSE.
          "技术字段
          ls_column_ref-r_column->set_technical( if_salv_c_bool_sap=>true ).
        ENDIF.
      ENDLOOP.

    ENDIF.


  ENDMETHOD.


  METHOD set_event.
    IF ir_event_handler IS NOT INITIAL.
      DATA(lr_event) = mr_table->get_event( ).

      SET HANDLER ir_event_handler->on_link_click FOR lr_event.
      SET HANDLER ir_event_handler->on_double_click FOR lr_event.
    ENDIF.
  ENDMETHOD.


  METHOD set_functions.
    DATA: lr_functions TYPE REF TO cl_salv_functions_list.
    lr_functions = mr_table->get_functions( ).
    lr_functions->set_all( abap_true )."Activate All Generic ALV Functions，将激活所有的ALV内置通用按钮

  ENDMETHOD.


  METHOD set_gui_status.
    IF  iv_pfrepid IS NOT INITIAL AND iv_pfstatus IS NOT INITIAL.
      mr_table->set_screen_status(
         pfstatus     = iv_pfstatus"系统提示的标准Status为SAPLSALV_METADATA_STATUS程序中的SALV_TABLE_STANDARD
         report       = iv_pfrepid
         "注：此参数只对SALV标准的预设保留按钮起作用，也就是说，当 IV_PFSTATUS GUI Status是从
         "系统中提供的标准Gui Staus拷贝时才起作用，即通用此参数来屏蔽或显示某些预置按钮
         "对自己完全新创建的GUI Status是的按钮（实质上是根据 FunCode来判断的）不起作用
         set_functions = mr_table->c_functions_all )."显示所有通用的预设按钮
    ELSE.
      "显示所有通用的预设按钮
      set_functions( ).
    ENDIF.
  ENDMETHOD.


  METHOD set_layout.
    IF is_layout IS NOT INITIAL.
      ms_layout = is_layout.
    ELSE.
      ms_layout-cwidth_opt   = abap_true.
      ms_layout-zebra        = abap_true.
      ms_layout-edit         = abap_true.
      ms_layout-report       = sy-repid.
      ms_layout-handle       = 'SALV'.
      ms_layout-title        = sy-title.
    ENDIF.
    "设置布局
    DATA: ls_layout_key TYPE salv_s_layout_key.
    ls_layout_key-report = ms_layout-report .
    ls_layout_key-handle = ms_layout-handle.
    DATA(lr_layout) = mr_table->get_layout( ).

    lr_layout->set_key( ls_layout_key ).
    lr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

    "设置斑马线
    DATA(lr_display) = mr_table->get_display_settings( ).
    IF ms_layout-zebra IS NOT INITIAL.
      lr_display->set_striped_pattern( cl_salv_display_settings=>true ).

    ENDIF.

    "设置Grid Title
    IF ms_layout-title IS NOT INITIAL.
      lr_display->set_list_header( ms_layout-title ).
    ENDIF.

    "优化列宽
    DATA(lr_columns) = mr_table->get_columns( ).
    IF ms_layout-cwidth_opt IS NOT INITIAL."优化列宽
      lr_columns->set_optimize( abap_true ).
    ENDIF.

  ENDMETHOD.


  METHOD set_screen_dialog.
    "以弹窗方式显示ALV
    IF is_popup IS NOT INITIAL.
      mr_table->set_screen_popup(
         start_column = is_popup-start_column
         end_column   = is_popup-end_column
         start_line   = is_popup-start_line
         end_line     = is_popup-end_line     ).
    ENDIF.
  ENDMETHOD.


  METHOD set_selection_mode.
    DATA(lr_selection)  = mr_table->get_selections( ).
    lr_selection->set_selection_mode( iv_selection_mode )."if_salv_c_selection_mode=>row_column
  ENDMETHOD.


  METHOD set_table.
    mr_table = ir_table.
  ENDMETHOD.
ENDCLASS.
