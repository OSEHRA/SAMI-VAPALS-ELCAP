SAMIUTR1 ;ven/lgc - UNIT TEST for SAMICTR1 ; 11/28/18 1:16pm
 ;;18.0;SAMI;;
 ;
 ; @section 0 primary development
 ;
 ; @routine-credits
 ; @primary-dev: Larry Carlson (lgc)
 ;  larry@fiscientific.com
 ; @primary-dev-org: Vista Expertise Network (ven)
 ;  http://vistaexpertise.net
 ; @copyright: 2012/2018, ven, all rights reserved
 ; @license: Apache 2.0
 ;  https://www.apache.org/licenses/LICENSE-2.0.html
 ;
 ; @last-updated: 10/29/18 4:11pm
 ; @application: SAMI
 ; @version: 18.0
 ; @patch-list: none yet
 ;
 ; @to-do
 ;
 ; @section 1 code
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 D EN^%ut($T(+0),2)
 Q
 ;
 ;
STARTUP n utsuccess
 n root s root=$$setroot^%wd("vapals-patients")
 k @root@("graph","XXX00001")
 n poo D PullUTarray^SAMIUTST(.poo,"all XXX00001 forms")
 m @root=poo
 Q
 ;
SHUTDOWN ; ZEXCEPT: utsuccess
 K utsuccess
 Q
 ;
 ;
UTNODUL ; @TEST - nodules
 ;nodules(rtn,vals,dict)
 n poo,root,si,vals,dict,cnt,return,arc,noder,nodea
 s root=$$setroot^%wd("vapals-patients")
 s si="XXX00001",samikey="ceform-2018-10-21"
 s vals=$na(@root@("graph",si,samikey))
 n dict s dict=$$setroot^%wd("cteval-dict")
 s dict=$na(@dict@("cteval-dict"))
 s cnt=0
 d nodules^SAMICTR1("return",.vals,.dict)
 ;now pull saved report
 D PullUTarray^SAMIUTST(.arc,"UTNODUL^SAMIUTR1 report")
 ; now compare return with arc
 n noder,nodea s noder=$na(return),nodea=$na(arc)
 s utsuccess=1
 f  s noder=$Q(@noder),nodea=$Q(@nodea) q:noder=""  d  q:'utsuccess
 . i '(@noder=@nodea) s utsuccess=0
 i '(nodea="") s utsuccess=0
 D CHKEQ^%ut(utsuccess,1,"Testing generating nodule report FAILED!")
 ;
 ; Try getting more line coverage with XXX00812
 K @root@("graph","XXX00812")
 D PullUTarray^SAMIUTST(.poo,"All XXX00812 graphstore globals")
 m @root@("graph","XXX00812")=poo
 s si="XXX00812",samikey="ceform-2018-11-28"
 s vals=$na(@root@("graph",si,samikey))
 s cnt=0
 k return
 d nodules^SAMICTR1("return",.vals,.dict)
 ;now pull saved report
 d PullUTarray^SAMIUTST(.arc,"UTNODUL^SAMIUTR1 report XXX00812")
 ; now compare return with arc
 n noder,nodea s noder=$na(return),nodea=$na(arc)
 s utsuccess=1
 f  s noder=$Q(@noder),nodea=$Q(@nodea) q:noder=""  d  q:'utsuccess
 . i '(@noder=@nodea) s utsuccess=0
 i '(nodea="") s utsuccess=0
 K @root@("graph","XXX00812")
 D CHKEQ^%ut(utsuccess,1,"Testing generating nodule XXX00812 report FAILED!")
 q
 ;
UTOUT ; @TEST - out line
 ;out(ln)
 n cnt,rtn,poo
 s cnt=1,rtn="poo",poo(1)="First line of test"
 n ln s ln="Second line test"
 s utsuccess=0
 D out^SAMICTR1(ln)
 s utsuccess=($g(poo(2))="Second line test")
 D CHKEQ^%ut(utsuccess,1,"Testing out(ln) adds line to array FAILED!")
 q
UTHOUT ; @TEST - hout line
 ;hout(ln)
 n cnt,rtn,poo
 s cnt=1,rtn="poo",poo(1)="First line of test"
 n ln s ln="Second line test"
 s utsuccess=0
 D hout^SAMICTR1(ln)
 s utsuccess=($g(poo(2))="<p><span class='sectionhead'>Second line test</span>")
 D CHKEQ^%ut(utsuccess,1,"Testing out(ln) adds line to array FAILED!")
 q
UTXVAL ; @TEST - extrinsic returns the patient value for var
 ;xval(var,vals)
 s utsuccess=0
 s arc(1)="Testing xval"
 s utsuccess=($$xval^SAMICTR1(1,"arc")="Testing xval")
 D CHKEQ^%ut(utsuccess,1,"Testing xval(var,vals) FAILED!")
 q
UTXSUB ; @TEST - extrinsic which returns the dictionary value defined by var
 ;xsub(var,vals,dict,valdx)
 n vals,var,poo,valdx,result
 s utsuccess=0
 s vals="poo"
 s var="cteval-dict"
 s poo(1)="biopsy"
 s valdx=1
 s dict=$$setroot^%wd("cteval-dict")
 s result=$$xsub^SAMICTR1(var,vals,dict,valdx)
 s utsuccess=(result="CT-guided biopsy")
 D CHKEQ^%ut(utsuccess,1,"Testing xsub(var,vals,dict,valdx) FAILED!")
 q
 ;
EOR ;End of routine SAMIUTR1
