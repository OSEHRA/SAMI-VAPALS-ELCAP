SAMIUTOT ;ven/lgc - UNIT TEST for SAMIDOUT ; 10/24/18 12:54pm
 ;;18.0;SAMI;;
 ;
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 D EN^%ut($T(+0),2)
 Q
 ;
 ;
STARTUP n utsuccess
 Q
 ;
SHUTDOWN ; ZEXCEPT: utsuccess
 K utsuccess
 Q
 ;
 ;
UTALL ; @TEST - code for ppi ALL^SAMID, export all sami dds
 ;ALL(SAMILOG) ; code for ppi ALL^SAMID, export all sami dds
 q
UTONE ; @TEST - code for ppi ONE^SAMID, export sami dd
 ;ONE(SAMIDD,SAMIPKG,SAMILOG) ; code for ppi ONE^SAMID, export sami dd
 q
 ;
EOR ;End of routine SAMIUTOT