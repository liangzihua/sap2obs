FUNCTION-POOL zfg_obs MESSAGE-ID zobs.

* INCLUDE LZFG_OBSD...                       " Local class definition


DATA: go_docu_container TYPE REF TO cl_gui_docking_container,
      go_html_viewer    TYPE REF TO cl_gui_html_viewer.

DATA: ok_code TYPE sy-ucomm,
      save_ok TYPE sy-ucomm.
DATA: gv_title TYPE cua_tit_tx.
