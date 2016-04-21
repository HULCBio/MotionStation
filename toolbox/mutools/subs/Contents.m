% Robust Control Toolbox - Mu-Analysis and Synthesis Features
%
% Mat Files
%
%	F14_nom.mat	- Example file used by ex_f14ic ex_f14s1 ex_f14tp ex_f14wt
%	ss_cont.mat	- Example file
%
% Example Files
%
%	ex1		- Example file
%	ex1d		- Example file
%	ex1t		- Example file
%	ex_f14ic	- Example file
%	ex_f14mu	- Example file
%	ex_f14s1	- Example file
%	ex_f14s2	- Example file
%	ex_f14tp	- Example file
%	ex_f14wt	- Example file called by ex_f14ic
%	ex_mkclp	- Example file
%	ex_mkpl		- Example file
%	ex_ml1		- Example file
%	ex_mmmk		- Example file called by mimo_margs
%	ex_unc		- Example file
%	ex_unic		- Example file
%	ex_uspl		- Example file
%	ex_usrp		- Example file
%	ex_usti		- Example file
%	ex_usti2	- Example file
%	ex_ustr		- Example file called by ex_ustr2 ex_ustrd
%	ex_ustr2	- Example file
%	ex_ustrd	- Example file
%	ex_wcp		- Example file
%	formloop	- generic feedback loop interconnect, used in examples
%	fow		- make first-order weight, used in examples
%	gainph_ex	- Example file
%	himat_de	- Example file
%	himat_dk	- Example file
%	himatic		- Example file called by mhimatic
%	mhimatic	- Example file
%	mimo_margs	- Example file
%	mk_acnom	- Example file called by mk_olic mk_olsim
%	mk_act		- Example file called by mk_olic mk_olsim
%	mk_olic		- Example file
%	mk_olsim	- Example file
%	mk_pert		- Example file
%	mk_wts		- Example file called by mk_olic mk_olsim
%	mkhic		- Example file
%	mkhicn		- Example file
%	mkhimat		- Example file
%	mkklp		- Example file
%	mloop_ma	- Example file
%	msdemo1		- Example file
%	msdemo2		- Example file
%	muexamp		- Example file
%	olhimic		- Example file
%	reducek		- simple controller order reduction, used in examples
%	rsexamp		- Example file
%	rsexamp_crc	- Example file
%	ssic		- Example file called by tssic
%	tankdemo	- Example file
%	trsp_ex		- Example file
%	tssic		- Example file
%
% CMEX source & dummies
%
%	amevlp.c	- CMEX executable called by genmu mu bub bubd gebub gebubd
%	amevlp		- dummy m-file to cover missing amevlp.c
%	amhxv.c		- c subroutine called by amevlp.c
%	amhxy.c		- C subroutine called by amevlp.c
%	amhxz.c		- C subroutine called by amevlp.c
%	amhyv.c		- C subroutine called by amevlp.c
%	amhyz.c		- C subroutine called by amevlp.c
%	amhzv.c		- C subroutine called by amevlp.c
%	amibndv.c	- CMEX executable called by genmu mu bub bubd gebub gebubd
%	amibndv		- dummy m-file to cover missing amibndv.c
%	amilowxy.c	- CMEX executable called by genmu mu bub bubd gebub gebubd
%	amilowxy	- dummy m-file to cover missing amilowxy.c
%	amiuppxy.c	- CMEX executable called by genmu mu bub bubd gebub gebubd
%	amiuppxy	- dummy m-file to cover missing amiuppxy.c
%	amxyzv.c	- C subroutine called by atxa.c
%	atxa.c		- C subroutine called by amxyzv.c
%	ghvvcp.c	- C subroutine called by amevlp.c
%	ghxxc.c		- C subroutine called by amevlp.c
%	ghyyc.c		- C subroutine called by amevlp.c
%	ghzzc.c		- C subroutine called by amevlp.c
%
% Dedicated subroutines to Commands
%
%	a2ynrow		- called by mu genmu
%	addrunf		- called by wsguin
%	agv2str		- called by dkitgui dtrsp sdtrsp trsp dkparmcb parmwin tabed
%	allocpim	- called by mu amiq2sol bub bubd gebub gebubd
%	amiq2sol	- called by bub bubd gebub gebubd
%	autod		- called by tankdemo
%	axxbc		- called by h2norm sdecomp ham2schr
%	bilins2z	- called by dhfsyn dhfsyn
%	bilinz2s	- called by dhfnorm dhfsynp_c sdhfnorm sdn_step
%	blknrms		- called by blknorm
%	bub		- called by genmu mu
%	bubd		- called by genmu mu
%	cgivens		- called by csord
%	chhsparm	- called by dkit
%	chomega		- called by dkit
%	chstr		- called by pass2
%	co2di		- called by fitsys msf msfbatch
%	colbut		- called by dkitgui dataent
%	comple		- called by many programs
%	compnorm	- called by sdhfnorm sdhfsyn
%	dand		- called by rub
%	dang		- called by rub
%	dataent		- called by dkitgui simgui dk_able gdataent
%	dcalc		- called by hankmr
%	deebal		- called by rub
%	deladdc		- called by simgui
%	delrunf		- called by dkitgui wsguin
%	dfitgui		- called by dkitgui dfitgui
%	dhinf_p		- called by dhfsynf
%	di2co		- called by fitsys msf msfbatch
%	dk_able		- called by dkitgui dfitgui dkparmcb dkychose omframe rready
%	dk_defin	- called by dkit himat_de
%	dkdispla	- called by dkit
%	dkparmcb	- called by dkitgui
%	dkuchose	- called by dkitgui
%	dkychose	- called by dkitgui
%	dypertsb	- called by dypert
%	extsmp		- called by fitsys msf msfbatch
%	findmuw		- called by dkit dkitgui simgui vplot addrunf delrunf wsguin
%	findrunf	- finds all running MU-GUIS
%	findsys		- called by pass2
%	fitchose	- called by msf
%	flatten		- called by genphase
%	fmfixbas	- called by fmlinp mffixbas
%	fminfo		- called by wsminfo
%	fmlp		- called by fmlinp
%	gaino		- called by sysic
%	gcnvert		- called by gebub gebubd
%	gdataent	- called by simgui
%	gdataevl	- called by dkitgui simgui dataent gdataent
%	gebub		- called by genmu
%	gebubd		- called by genmu
%	geestep		- called by rub
%	genlft		- called by starp redstar
%	geosplit	- called by hinfnorm linfnorm
%	gguivar		- Get GUI variable, called by many programs
%	gjb2		- called by simgui scrolltb
%	goptvl		- called by genmudiagnose mudiagnose rub
%	gpredict	- called by hinfsyn
%	grabvar		- called by mkdragic
%	h2v		- called by simgui gguivar mkmulink sguivar
%	ham2schr	- called by sdhfnorm sdhfsyn sdequiv
%	helpxpii	- called by bub bubd gebub gebubd
%	hinf_c		- called by hinfsyn[k] hinfe_c
%	hinf_gam	- called by hinfsyn hinfsyne
%	hinf_sp		- called by hinf_c hinf_gam hinf_st hinfe_c
%	hinf_st		- called by hinfsyn hinfsyne
%	hinfchk		- called by hinfnorm sdn_step
%	hinfe_c		- called by hinfsyne[ka]
%	hinffi_c	- called by hinffi[k]
%	hinffi_g	- called by hinffi
%	hinffi_p	- called by hinffi hinffi_c hinffi_g hinffi_t
%	hinffi_t	- called by hinffi
%	inpstuff	- called by sysic
%	ipii		- Insert Packed Index Item
%	jwhamtst	- called by hinfchk
%	kfm		- delete all figures, and clear muTools globals
%	ksum		- called by fitmag fitmaglp sclout sel autod dfitgui
%	lamb		- called by rub
%	ldpim		- called by minfo allocpim fminfo helpxpii ipii ldpim xpii
%	linp		- called by magfit
%	looptst		- called by fitmag fitmaglp
%	mamilc		- called by bub bubd gebub gebubd
%	mamiscl		- called by bub bubd gebub gebubd mamilc
%	mdipii		- called by simgui
%	mdpimdel	- called by simgui
%	mdxpii		- called by simgui mdpimdel tabed
%	mffixbas	- called by mflinp
%	mflinp		- called by magfit
%	mflp		- called by mflinp
%	mhhparms	- called by dkit
%	mkdragic	- called by scrtxtn
%	mkdragtx	- called by dkitgui simgui wsguin
%	mkmulink	- called by dkitgui
%	mknorm		- called by dkitgui simgui
%	mkours		- called by dkitgui simgui findmuw
%	mkth		- called by dfitgui
%	mtblanks	- called by sysic inpstuff namstuff pass1 pass2
%	muclear		- called by kfm
%	mucnvert	- called by bub bubd mucnvert
%	mudeclar	- called by dkitgui simgui wsguin
%	mudkaf		- called by msf msfbatch
%	muexport	- called by dkitgui simgui
%	mvtext		- called by mkdragic
%	namstuff	- called by sysic
%	nd2ssms		- called by nd2sys
%	newd		- called by rub
%	newga		- called by rub
%	newub		- called by rub
%	nicetod		- called by wsguicb wsguin
%	notherdk	- called by dkit
%	ocsf		- called by sncfbal srelbal
%	omegavl		- called by dkitgui
%	omframe		- called by dkitgui
%	onealpha	- called by wcperf
%	oniter		- called by dkitgui
%	orsf		- called by sdecomp sncfbal srelbal
%	ourslid		- called by scrolltb tabed
%	parmwin		- called by dkitgui simgui gdataent wsguin
%	pass1		- called by sysic
%	pass2		- called by sysic
%	pass3		- called by sysic
%	prefit		- called by dkitgui dfitgui
%	ptrs		- called by mu and subroutines
%	pullaprt	- called by wsguic
%	qrsc		- called by sjh6
%	redstar		- called by starp redstar
%	reindex		- called by dypert mu muunwrap unwrapp
%	reomega		- called by dkit
%	rerunhi		- called by dkit
%	rready		- called by dkitgui omframe
%	rub		- called by dypert mu
%	rubind		- called by dypert mu muunwrap unwrapp
%	rublow		- called by rub
%	rupert		- called by rublow
%	ruqvsol		- called by cmmusyn genmu
%	ruqvsolb	- called by cmmusyn
%	sclmublk	- called by sclmublk
%	scrolltb	- called by dkitgui simgui dfitgui rready
%	scrtxtn		- called by dkitgui simgui wsguin
%	sdequiv		- called by sdhfsyn sdn_step
%	sdn_step	- called by sdhfnorm
%	seesub		- called by seesys
%	sguivar		- Set GUI variable, called by many programs
%	sigmaub		- called by mu mu sigmaub sigmaub
%	sim2str		- called by sim2str sim2str
%	simplemu	- called by simplemu
%	simprmu		- called by simprmu
%	sisoloop	- called by ex_ustr2
%	sjh6		- called by clyap sncfbal srelbal sysbal
%	sm2vec		- called by bub bubd gebub gebubd
%	ssm2vec		- called by bub bubd gebub gebubd
%	stripemp	- called by oniter
%	swapiv		- Swap independent variables
%	sylv		- called by h2norm axxbc
%	syscl		- not called, may be used in debugging
%	tabed		- called by dkitgui
%	terpol		- called by dtrsp genphase sdtrsp trsp vinterp vterp
%	terpolb		- called by genphase
%	updownb		- called by simgui
%	updownb2	- called by simgui
%	var2sep		- called by mamilc
%	vec2sm		- called by amiq2sol
%	vec2ssm		- called by amiq2sol
%	wsguic		- called by wsgui wsguin
%	wsguicb		- called by wsguin
%	wsguin		- called by wsgui
%	wsminfo		- called by wsguin
%	xpii		- Extract Packed Index Item
%	ynftdami	- called by mu
%	yublksel	- called by dkitgui

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc. 
