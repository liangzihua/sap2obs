*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 2022.07.25 at 16:57:49
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZOBSV_CONFIG....................................*
TABLES: ZOBSV_CONFIG, *ZOBSV_CONFIG. "view work areas
CONTROLS: TCTRL_ZOBSV_CONFIG
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZOBSV_CONFIG. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZOBSV_CONFIG.
* Table for entries selected to show on screen
DATA: BEGIN OF ZOBSV_CONFIG_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZOBSV_CONFIG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZOBSV_CONFIG_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZOBSV_CONFIG_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZOBSV_CONFIG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZOBSV_CONFIG_TOTAL.

*.........table declarations:.................................*
TABLES: ZOBS_CONFIG                    .
