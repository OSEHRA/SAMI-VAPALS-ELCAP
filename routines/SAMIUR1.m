SAMIUR1 ;ven/gpl - sami user reports ;2018-03-08T17:53Z
 ;;18.0;SAM;;
 ;
 ; SAMIUR contains the routines to generate user reports
 ; It is currently untested & in progress.
 ;
 quit  ; no entry from top
 ;
wsReport(rtn,filter) ; generate a report based on parameters in the filter
 ;
 ; here are the user reports that are defined:
 ;  1. followup
 ;  2. activity
 ;  3. missingct
 ;  4. incomplete
 ;  5. outreach
 ;  6. enrollment
 ; the report to generate is passed in parameter samireporttype
 ;
 s debug=0
 i $g(filter("debug"))=1 s debug=1
 ;
 k return
 s HTTPRSP("mime")="text/html"
 ;
 n type,temp
 s type=$g(filter("samireporttype"))
 i type="" d  q  ; report type missing
 . d getHome^SAMIHOM3(.rtn,.filter) ; send them to home
 ;
 d getThis^%wd("temp","table.html") ; page template
 q:'$d(temp)
 ;
 n pats
 s pats=""
 n datephrase
 d select(.pats,type,.datephrase) ; select patients for the report
 q:'$d(pats)
 ;
 n ln,cnt,ii
 s (ii,ln,cnt)=0
 f  s ii=$o(temp(ii)) q:+ii=0  q:$g(temp(ii))["<thead"  d  ;
 . s cnt=cnt+1
 . s ln=$g(temp(ii))
 . n samikey,si
 . s (samikey,si)=""
 . D SAMISUB2^SAMIFRM2(.ln,samikey,si,.filter)
 . i ln["PAGE NAME" d findReplace^%ts(.ln,"PAGE NAME",$$PNAME(type,datephrase))
 . s rtn(cnt)=ln
 . ;
 s cnt=cnt+1 s rtn(cnt)="<thead><tr>"
 s cnt=cnt+1 s rtn(cnt)="<th>Enrollment Date</th>"
 s cnt=cnt+1 s rtn(cnt)="<th>Name</th>"
 s cnt=cnt+1 s rtn(cnt)="<th>SSN</th>"
 s cnt=cnt+1 s rtn(cnt)="<th>Followup</th>"
 s cnt=cnt+1 s rtn(cnt)="</tr></thead>"
 ;
 ;
 n ij
 n root s root=$$setroot^%wd("vapals-patients")
 s cnt=cnt+1 s rtn(cnt)="<tbody>"
 s ij=0
 f  s ij=$o(pats(ij)) q:+ij=0  d  ;
 . n ij2 s ij2=0
 . f  s ij2=$o(pats(ij,ij2)) q:+ij2=0  d  ;
 . . n dfn s dfn=ij2
 . . n sid s sid=$g(@root@(dfn,"samistudyid"))
 . . n name s name=$g(@root@(dfn,"saminame"))
 . . n edate s edate=$g(pats(ij,dfn,"edate"))
 . . n cefud s cefud=$g(pats(ij,dfn,"cefud"))
 . . s cnt=cnt+1 s rtn(cnt)="<tr>"
 . . s cnt=cnt+1 s rtn(cnt)="<td>"_edate_"</td>"
 . . new nuhref set nuhref="<form method=POST action=""/vapals"">"
 . . set nuhref=nuhref_"<input type=hidden name=""samiroute"" value=""casereview"">"
 . . set nuhref=nuhref_"<input type=hidden name=""studyid"" value="_sid_">"
 . . set nuhref=nuhref_"<input value="""_name_""" class=""btn btn-link"" role=""link"" type=""submit""></form>"
 . . s cnt=cnt+1
 . . s rtn(cnt)="<td>"_nuhref_"</td>"
 . . n ssn s ssn=$$GETSSN^SAMIFRM2(sid)
 . . i ssn="" d  ;
 . . . n hdr
 . . . s hdf=$$GETHDR^SAMIFRM2(sid)
 . . . s ssn=$$GETSSN^SAMIFRM2(sid)
 . . s cnt=cnt+1
 . . s rtn(cnt)="<td>"_ssn_"</td>"
 . . s cnt=cnt+1
 . . s rtn(cnt)="<td>"_cefud_"</td></tr>"
 ;
 s cnt=cnt+1 s rtn(cnt)="</tbody>"
 ;s ii=ii-1
 f  s ii=$o(temp(ii)) q:+ii=0  d  ;
 . s cnt=cnt+1
 . s ln=$g(temp(ii))
 . s rtn(cnt)=ln
 q
 ;
select(pats,type,datephrase) ; selects patient for the report
 i $g(type)="" s type="enrollment"
 s datephrase=""
 n zi s zi=0
 n root s root=$$setroot^%wd("vapals-patients")
 ;
 f  s zi=$o(@root@(zi)) q:+zi=0  d  ;
 . n sid s sid=$g(@root@(zi,"samistudyid"))
 . q:sid=""
 . n items s items=""
 . d getItems^SAMICAS2("items",sid)
 . q:'$d(items)
 . n efmdate,edate,siform,ceform,cefud,fmcefud,cedos,fmcedos
 . s siform=$o(items("siform-"))
 . s ceform=$o(items("ceform-a"),-1)
 . s (cefud,fmcefud,cedos,fmcedos)=""
 . i ceform'="" d  ;
 . . s cefud=$g(@root@("graph",sid,ceform,"cefud"))
 . . i cefud'="" s fmcefud=$$key2fm^SAMICAS2(cefud)
 . . s cedos=$g(@root@("graph",sid,ceform,"cedos"))
 . . i cedos'="" s fmcedos=$$key2fm^SAMICAS2(cedos)
 . s edate=$g(@root@("graph",sid,siform,"sidc"))
 . i edate="" s edate=$g(@root@("graph",sid,siform,"samicreatedate"))
 . s efmdate=$$key2fm^SAMICAS2(edate)
 . s edate=$$vapalsDate^SAMICAS2(efmdate)
 . ;
 . i type="followup" d  ;
 . . n nplus30 s nplus30=$$FMADD^XLFDT($$NOW^XLFDT,31)
 . . i (+fmcefud<nplus30)!(ceform="") d  ; need ct scans
 . . . s pats(efmdate,zi,"edate")=edate
 . . . s pats(efmdate,zi)=""
 . . . i ceform="" s cefud="baseline"
 . . . s pats(efmdate,zi,"cefud")=cefud
 . . s datephrase=" before "_$$vapalsDate^SAMICAS2(nplus30)
 . . q
 . i type="activity" d  ;
 . . n nminus30 s nminus30=$$FMADD^XLFDT($$NOW^XLFDT,-31)
 . . n anyform s anyform=$o(items("sort",""),-1)
 . . n fmanyform s fmanyform=$$key2fm^SAMICAS2(anyform)
 . . i (+fmanyform>nminus30)!(+efmdate>nminus30) d  ; need any new form
 . . . s pats(efmdate,zi,"edate")=edate
 . . . s pats(efmdate,zi)=""
 . . . i ceform="" s cefud="baseline"
 . . . s pats(efmdate,zi,"cefud")=cefud
 . . s datephrase=" after "_$$vapalsDate^SAMICAS2(nminus30)
 . . q
 . i type="missingct" d  ;
 . . q
 . i type="incomplete" d  ;
 . . q
 . i type="outreach" d  ;
 . . q
 . i type="enrollment" d  ;
 . . s pats(efmdate,zi,"edate")=edate
 . . s pats(efmdate,zi)=""
 . . s pats(efmdate,zi,"cefud")=cefud
 . . s datephrase=" as of "_$$vapalsDate^SAMICAS2($$NOW^XLFDT)
 q
 ;
PNAME(type,phrase) ; extrinsic returns the PAGE NAME for the report
 i type="followup" q "Followup"_$g(phrase)
 i type="activity" q "Activity"_$g(phrase)
 i type="missingct" q "Missing CT Evaluation"_$g(phrase)
 i type="incomplete" q "Incomplete Forms"_$g(phrase)
 i type="outreach" q "Outreach"_$g(phrase)
 i type="enrollment" q "Enrollment"_$g(phrase)
 q ""
 ;
