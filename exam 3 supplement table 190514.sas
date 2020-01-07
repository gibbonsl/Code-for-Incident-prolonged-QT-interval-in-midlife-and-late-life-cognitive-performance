*libname fun "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS";
libname fun "G:\Laura\FH2016\HAAS";

*proc import out=temp2 datafile="C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS\forsas181204.dta" replace;
proc import out=temp2 datafile="G:\Laura\FH2016\HAAS\forsasexam3.dta" replace;run;

data temp2;set temp2;
if _Imputation_=0 then delete;run;* unimputed data;
proc contents;run;

proc means data=temp2 /*noprint*/;
	var es2 eun2 wdun23 wds23 wcun23 wcs23;by _Imputation_;
      output out=outs mean= es2 eun2 wdun23 wds23 wcun23 wcs23 	stderr=  ses2 seun2 wdun23 wds23 wcun23 wcs23;
proc mianalyze data=outs edf=4581;
	modeleffects  es2 eun2 wdun23 wds23 wcun23 wcs23;	stderr ses2 seun2 wdun23 wds23 wcun23 wcs23;run;


proc import out=temp3 datafile="G:\Laura\FH2016\HAAS\forsasexam3dd.dta" replace;run;

data temp3;set temp3;
if _Imputation_=0 then delete;run;* unimputed data;

proc means data=temp3 ;
	var wds23 wdun23 wcs23 wcun23 ;by _Imputation_;
      output out=outs mean=wds23 wdun23 wcs23 wcun23
	stderr=swds23 swdun23 swcs23 swcun23;run;
proc mianalyze data=outs edf=4581;
	modeleffects  wds23 wdun23 wcs23 wcun23;
	stderr  wds23 swdun23 swcs23 swcun23;run;

proc sort data=temp2;by hhp _Imputation_;
proc sort data=temp3;by hhp _Imputation_;
data tempx;merge temp3 temp2;by hhp _Imputation_;
s=es2*wds23*wcs23;
uns=eun2*wdun23*wcun23;
run;

proc sort data=tempx;by _Imputation_;
proc means data=tempx ;
	var s uns ;by _Imputation_;
      output out=outs mean= s uns	stderr=  ss sun ;run;
proc mianalyze data=outs edf=2954;* why not 2501??;
	modeleffects    s uns ;	stderr ss sun ;run;
