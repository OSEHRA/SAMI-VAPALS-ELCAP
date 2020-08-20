SAMICSV ;ven/gpl - VAPALS CSV EXPORT ; 8/15/20 4:48pm
 ;;18.0;SAMI;;
 ;
 ;@license: see routine SAMIUL
 ;
 ; allow fallthrough
 ;
EN ; entry point to generate csv files from forms for a site
 ;
 ; first pick a site
 N X,Y,DIC,SITEIEN,SITEID
 S DIC=311.12
 S DIC(0)="AEMQ"
 D ^DIC
 I Y<1 Q  ; EXIT
 S SITENUM=$P(Y,"^",2)
 S SITEID=$$SITEID^SAMISITE(SITENUM)
 Q:SITEID=""
 ;
 ; todo: prompt for the form
 N SAMIFORM S SAMIFORM="siform"
 ;N SAMIFORM S SAMIFORM="ceform"
 ;
 ; prompt for the directory
 N SAMIDIR
 D GETDIR^SAMIFDM(.SAMIDIR)
 Q:SAMIDIR=""
 ;
 d ONEFORM(SITEID,SAMIFORM,SAMIDIR) ; process one form for a site
 ;
 q
 ;
ONEFORM(SITEID,SAMIFORM,SAMIDIR) ; process one form for a site
 n root s root=$$setroot^%wd("vapals-patients")
 n groot s groot=$na(@root@("graph"))
 n SAMII S SAMII=SITEID
 n cnt s cnt=0
 n forms s forms=0
 ;
 n SAMIOUT S SAMIOUT=$NA(^TMP("SAMICSV",$J))
 k @SAMIOUT
 ;
 n DICT
 d DDICT("DICT",SAMIFORM) ; get the data dictionary for this form
 q:'$d(DICT)
 ;
 N SAMIN S SAMIN=1
 N SAMIJJ s SAMIJJ=0
 f  s SAMIJJ=$o(DICT(SAMIJJ)) q:+SAMIJJ=0  d  ;
 . s $p(@SAMIOUT@(SAMIN),"|",SAMIJJ)=DICT(SAMIJJ) ; csv header
 s @SAMIOUT@(SAMIN)="siteid|samistudyid|form|"_@SAMIOUT@(SAMIN)
 ;S @SAMIOUT@(SAMIN)=@SAMIOUT@(SAMIN)_$C(13,10) ; carriage return line feed
 ; 
 f  s SAMII=$o(@groot@(SAMII)) q:SAMII=""  q:$e(SAMII,1,3)'[SITEID  d  ;
 . s cnt=cnt+1
 . w !,SAMII
 . N SAMIJ S SAMIJ=SAMIFORM
 . n done s done=0
 . f  s SAMIJ=$O(@groot@(SAMII,SAMIJ)) q:SAMIJ=""  q:done  d  ;
 . . i $e(SAMIJ,1,$l(SAMIFORM))'=SAMIFORM s done=1 q  ;
 . . s forms=forms+1
 . . n jj s jj=0
 . . s SAMIN=SAMIN+1
 . . f  s jj=$o(DICT(jj)) q:+jj=0  d  ;
 . . . s $P(@SAMIOUT@(SAMIN),"|",jj)=$g(@groot@(SAMII,SAMIJ,DICT(jj)))
 . . S @SAMIOUT@(SAMIN)=SITEID_"|"_SAMII_"|"_SAMIJ_"|"_@SAMIOUT@(SAMIN)
 . . ;s @SAMIOUT@(SAMIN)=@SAMIOUT@(SAMIN)_$C(13,10)
 . ;b
 ;ZWR @SAMIOUT@(*)
 w !,cnt_" patients, "_forms_" forms"
 n filename s filename=$$FNAME(SITEID,SAMIFORM)
 d GTF^%ZISH($na(@SAMIOUT@(1)),3,SAMIDIR,filename)
 w !,"file "_filename_" written to directory "_SAMIDIR
 q
 ;
FNAME(SITE,FORM) ; extrinsic returns the filename for the site/form
 Q SITE_"-"_FORM_"-"_$$FMTHL7^XLFDT($$HTFM^XLFDT($H))_".csv"
 ;
DDICT(RTN,FORM) ; data dictionary for FORM, returned in RTN, passed by
 ; name
 K @RTN
 ;
 N USEGR S USEGR=""
 I FORM="siform" S USEGR="form fields - intake"
 ;
 Q:USEGR=""
 N root s root=$$setroot^%wd(USEGR)
 Q:$g(root)=""
 N II S II=0
 f  s II=$o(@root@("field",II)) q:+II=0  d  ;
 . s @RTN@(II)=$g(@root@("field",II,"input",1,"name"))
 q
 ;^%wd(17.040801,"B","form fields - background",437)=""
 ;^%wd(17.040801,"B","form fields - biopsy",438)=""
 ;^%wd(17.040801,"B","form fields - ct evaluation",439)=""
 ;^%wd(17.040801,"B","form fields - follow up",440)=""
 ;^%wd(17.040801,"B","form fields - follow-up",359)=""
 ;^%wd(17.040801,"B","form fields - intake",491)=""
 ;^%wd(17.040801,"B","form fields - intervention",442)=""
 ;^%wd(17.040801,"B","form fields - pet evaluation",443)=""

 

 
