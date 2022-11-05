class ZPICL_SI_BC000501_ERP2ERP_SYN2 definition
  public
  create public .

public section.

  interfaces ZPIII_SI_BC000501_ERP2ERP_SYN .
protected section.
private section.
ENDCLASS.



CLASS ZPICL_SI_BC000501_ERP2ERP_SYN2 IMPLEMENTATION.


  METHOD zpiii_si_bc000501_erp2erp_syn~si_bc000501_erp2erp_syn_in.
*** **** INSERT IMPLEMENTATION HERE **** ***

    DATA: lo_obs TYPE REF TO zcl_obs.

    CREATE OBJECT lo_obs.

    CALL METHOD lo_obs->save_signtrue
      EXPORTING
        iv_uuid = input-mt_bc000501_res-uuid
        iv_json = input-mt_bc000501_res-res_json.

    FREE lo_obs.

*    DATA: ls_signtrue TYPE zobst_signtrue.
*
*    CALL METHOD zcl_json=>deserialize
*      EXPORTING
*        json = input-mt_bc000501_res-res_json
*      CHANGING
*        data = ls_signtrue.
*
*    CONDENSE ls_signtrue-accesskeyid NO-GAPS.
*    CONDENSE ls_signtrue-signature   NO-GAPS.
*    CONDENSE ls_signtrue-expires     NO-GAPS.
*
*
*    ls_signtrue-uuid  = input-mt_bc000501_res-uuid.
*    ls_signtrue-ernam = sy-uname.
*    ls_signtrue-erdat = sy-datum.
*    ls_signtrue-erzet = sy-uzeit.
*
*    MODIFY zobst_signtrue FROM ls_signtrue.
*    COMMIT WORK.

  ENDMETHOD.
ENDCLASS.
