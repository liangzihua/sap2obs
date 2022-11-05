class ZPICO_SI_BC000501_ERP2ERP_SYN definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods SI_BC000501_ERP2ERP_SYN_OUT
    importing
      !OUTPUT type ZPIMT_BC000501_REQ
    exporting
      !INPUT type ZPIMT_BC000501_RES
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZPICO_SI_BC000501_ERP2ERP_SYN IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZPICO_SI_BC000501_ERP2ERP_SYN'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method SI_BC000501_ERP2ERP_SYN_OUT.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'OUTPUT' kind = '0' value = ref #( OUTPUT ) )
    ( name = 'INPUT' kind = '1' value = ref #( INPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'SI_BC000501_ERP2ERP_SYN_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
