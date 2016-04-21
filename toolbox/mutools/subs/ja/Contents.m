% Mu-Analysis and Synthesis Toolbox.
%
% Matファイル
%
%	F14_nom.mat	- ex_f14ic ex_f14s1 ex_f14tp ex_f14wtで使う例題ファイル
%	ss_cont.mat	- 例題ファイル
%
% 例題ファイル
%
%	ex1		- 例題ファイル
%	ex1d		- 例題ファイル
%	ex1t		- 例題ファイル
%	ex_f14ic	- 例題ファイル
%	ex_f14mu	- 例題ファイル
%	ex_f14s1	- 例題ファイル
%	ex_f14s2	- 例題ファイル
%	ex_f14tp	- 例題ファイル
%	ex_f14wt	- ex_f14icから呼び込まれる例題ファイル
%	ex_mkclp	- 例題ファイル
%	ex_mkpl		- 例題ファイル
%	ex_ml1		- 例題ファイル
%	ex_mmmk		- mimo_margsから呼び込まれる例題ファイル
%	ex_unc		- 例題ファイル
%	ex_unic		- 例題ファイル
%	ex_uspl		- 例題ファイル
%	ex_usrp		- 例題ファイル
%	ex_usti		- 例題ファイル
%	ex_usti2	- 例題ファイル
%	ex_ustr		- ex_ustr2 ex_ustrdから呼び込まれる例題ファイル
%	ex_ustr2	- 例題ファイル
%	ex_ustrd	- 例題ファイル
%	ex_wcp		- 例題ファイル
%	formloop	- 例題で使う一般フィードバックループの相互結合
%	fow		- 例題で使う1次重みの作成
%	gainph_ex	- 例題ファイル
%	himat_de	- 例題ファイル
%	himat_dk	- 例題ファイル
%	himatic		- mhimaticから呼び込まれる例題ファイル
%	mhimatic	- 例題ファイル
%	mimo_margs	- 例題ファイル
%	mk_acnom	- mk_olic mk_olsimから呼び込まれる例題ファイル
%	mk_act		- mk_olic mk_olsimから呼び込まれる例題ファイル
%	mk_olic		- 例題ファイル
%	mk_olsim	- 例題ファイル
%	mk_pert		- 例題ファイル
%	mk_wts		- mk_olic mk_olsimから呼び込まれる例題ファイル
%	mkhic		- 例題ファイル
%	mkhicn		- 例題ファイル
%	mkhimat		- 例題ファイル
%	mkklp		- 例題ファイル
%	mloop_ma	- 例題ファイル
%	msdemo1		- 例題ファイル
%	msdemo2		- 例題ファイル
%	muexamp		- 例題ファイル
%	olhimic		- 例題ファイル
%	reducek		- 例題で使う簡単なコントローラの低次化
%	rsexamp		- 例題ファイル
%	rsexamp_crc	- 例題ファイル
%	ssic		- tssicから呼び込まれる例題ファイル
%	tankdemo	- 例題ファイル
%	trsp_ex		- 例題ファイル
%	tssic		- 例題ファイル
%
% CMEXソースファイルとダミーファイル
%
%	amevlp.c	- genmu mu bub bubd gebub gebubdから呼び込まれるCMEX実
%			  行可能ファイル
%	amevlp		- amevlp.cの代わりのダミーM-ファイル
%	amhxv.c		- amevlp.cから呼び込まれるCサブルーチン
%	amhxy.c		- amevlp.cから呼び込まれるCサブルーチン
%	amhxz.c		- amevlp.cから呼び込まれるCサブルーチン
%	amhyv.c		- amevlp.cから呼び込まれるCサブルーチン
%	amhyz.c		- amevlp.cから呼び込まれるCサブルーチン
%	amhzv.c		- amevlp.cから呼び込まれるCサブルーチン
%	amibndv.c	- genmu mu bub bubd gebub gebubdから呼び込まれるCMEX実
%			  行可能ファイル
%	amibndv		- amibndv.cの代わりのダミーM-ファイル
%	amilowxy.c	- genmu mu bub bubd gebub gebubdから呼び込まれるCMEX実
%			  行可能ファイル
%	amilowxy	- amilowxy.cの代わりのダミーM-ファイル
%	amiuppxy.c	- genmu mu bub bubd gebub gebubdから呼び込まれるCMEX実
%			  行可能ファイル
%	amiuppxy	- amiuppxy.cの代わりのダミーM-ファイル
%	amxyzv.c	- atxa.cから呼び込まれるCサブルーチン
%	atxa.c		- amxyzv.cから呼び込まれるCサブルーチン
%	ghvvcp.c	- amevlp.cから呼び込まれるCサブルーチン
%	ghxxc.c		- amevlp.cから呼び込まれるCサブルーチン
%	ghyyc.c		- amevlp.cから呼び込まれるCサブルーチン
%	ghzzc.c		- amevlp.cから呼び込まれるCサブルーチン
%
% コマンドのサブルーチン
%
%	a2ynrow		- mu genmuから実行
%	addrunf		- wsguinから実行
%	agv2str		- dkitgui dtrsp sdtrsp trsp dkparmcb parmwin tabedから実行
%	allocpim	- mu amiq2sol bub bubd gebub gebubdから実行
%	amiq2sol	- bub bubd gebub gebubdから実行
%	autod		- tankdemoから実行
%	axxbc		- h2norm sdecomp ham2schrから実行
%	bilins2z	- dhfsyn dhfsynから実行
%	bilinz2s	- dhfnorm dhfsynp_c sdhfnorm sdn_stepから実行
%	blknrms		- blknormから実行
%	bub		- genmu muから実行
%	bubd		- genmu muから実行
%	cgivens		- csordから実行
%	chhsparm	- dkitから実行
%	chomega		- dkitから実行
%	chstr		- pass2から実行
%	co2di		- fitsys msf msfbatchから実行
%	colbut		- dkitgui dataentから実行
%	comple		- 多くのプログラムから実行
%	compnorm	- sdhfnorm sdhfsynから実行
%	dand		- rubから実行
%	dang		- rubから実行
%	dataent		- dkitgui simgui dk_able gdataentから実行
%	dcalc		- hankmrから実行
%	deebal		- rubから実行
%	deladdc		- simguiから実行
%	delrunf		- dkitgui wsguinから実行
%	dfitgui		- dkitgui dfitguiから実行
%	dhinf_p		- dhfsynfから実行
%	di2co		- fitsys msf msfbatchから実行
%	dk_able		- dkitgui dfitgui dkparmcb dkychose omframe rreadyから実行
%	dk_defin	- dkit himat_deから実行
%	dkdispla	- dkitから実行
%	dkparmcb	- dkitguiから実行
%	dkuchose	- dkitguiから実行
%	dkychose	- dkitguiから実行
%	dypertsb	- dypertから実行
%	extsmp		- fitsys msf msfbatchから実行
%	findmuw		- dkit dkitgui simgui vplot addrunf delrunf wsguinから実行
%	findrunf	- 実行中のすべてのMU-GUIの検索
%	findsys		- pass2から実行
%	fitchose	- msfから実行
%	flatten		- genphaseから実行
%	fmfixbas	- fmlinp mffixbasから実行
%	fminfo		- wsminfoから実行
%	fmlp		- fmlinpから実行
%	gaino		- sysicから実行
%	gcnvert		- gebub gebubdから実行
%	gdataent	- simguiから実行
%	gdataevl	- dkitgui simgui dataent gdataentから実行
%	gebub		- genmuから実行
%	gebubd		- genmuから実行
%	geestep		- rubから実行
%	genlft		- starp redstarから実行
%	geosplit	- hinfnorm linfnormから実行
%	gguivar		- GUI変数の取得、多くのプログラムから実行
%	gjb2		- simgui scrolltbから実行
%	goptvl		- genmudiagnose mudiagnose rubから実行
%	gpredict	- hinfsynから実行
%	grabvar		- mkdragicから実行
%	h2v		- simgui gguivar mkmulink sguivarから実行
%	ham2schr	- sdhfnorm sdhfsyn sdequivから実行
%	helpxpii	- bub bubd gebub gebubdから実行
%	hinf_c		- hinfsyn[k] hinfe_cから実行
%	hinf_gam	- hinfsyn hinfsyneから実行
%	hinf_sp		- hinf_c hinf_gam hinf_st hinfe_cから実行
%	hinf_st		- hinfsyn hinfsyneから実行
%	hinfchk		- hinfnorm sdn_stepから実行
%	hinfe_c		- hinfsyne[ka]から実行
%	hinffi_c	- hinffi[k]から実行
%	hinffi_g	- hinffiから実行
%	hinffi_p	- hinffi hinffi_c hinffi_g hinffi_tから実行
%	hinffi_t	- hinffiから実行
%	inpstuff	- sysicから実行
%	ipii		- Insert Packed Indexed Item
%	jwhamtst	- hinfchkから実行
%	kfm		- すべてのfigureを消去、muToolsグローバル変数をクリア
%	ksum		- fitmag fitmaglp sclout sel autod dfitguiから実行
%	lamb		- rubから実行
%	ldpim		- minfo allocpim fminfo helpxpii ipii ldpim xpiiから実行
%	linp		- magfitから実行
%	looptst		- fitmag fitmaglpから実行
%	mamilc		- bub bubd gebub gebubdから実行
%	mamiscl		- bub bubd gebub gebubd mamilcから実行
%	mdipii		- simguiから実行
%	mdpimdel	- simguiから実行
%	mdxpii		- simgui mdpimdel tabedから実行
%	mffixbas	- mflinpから実行
%	mflinp		- magfitから実行
%	mflp		- mflinpから実行
%	mhhparms	- dkitから実行
%	mkdragic	- scrtxtnから実行
%	mkdragtx	- dkitgui simgui wsguinから実行
%	mkmulink	- dkitguiから実行
%	mknorm		- dkitgui simguiから実行
%	mkours		- dkitgui simgui findmuwから実行
%	mkth		- dfitguiから実行
%	mtblanks	- sysic inpstuff namstuff pass1 pass2から実行
%	muclear		- kfmから実行
%	mucnvert	- bub bubd mucnvertから実行
%	mudeclar	- dkitgui simgui wsguinから実行
%	mudkaf		- msf msfbatchから実行
%	muexport	- dkitgui simguiから実行
%	mvtext		- mkdragicから実行
%	namstuff	- sysicから実行
%	nd2ssms		- nd2sysから実行
%	newd		- rubから実行
%	newga		- rubから実行
%	newub		- rubから実行
%	nicetod		- wsguicb wsguinから実行
%	notherdk	- dkitから実行
%	ocsf		- sncfbal srelbalから実行
%	omegavl		- dkitguiから実行
%	omframe		- dkitguiから実行
%	onealpha	- wcperfから実行
%	oniter		- dkitguiから実行
%	orsf		- sdecomp sncfbal srelbalから実行
%	ourslid		- scrolltb tabedから実行
%	parmwin		- dkitgui simgui gdataent wsguinから実行
%	pass1		- sysicから実行
%	pass2		- sysicから実行
%	pass3		- sysicから実行
%	prefit		- dkitgui dfitguiから実行
%	ptrs		- muとサブルーチンから実行
%	pullaprt	- wsguicから実行
%	qrsc		- sjh6から実行
%	redstar		- starp redstarから実行
%	reindex		- dypert mu muunwrap unwrappから実行
%	reomega		- dkitから実行
%	rerunhi		- dkitから実行
%	rready		- dkitgui omframeから実行
%	rub		- dypert muから実行
%	rubind		- dypert mu muunwrap unwrappから実行
%	rublow		- rubから実行
%	rupert		- rublowから実行
%	ruqvsol		- cmmusyn genmuから実行
%	ruqvsolb	- cmmusynから実行
%	sclmublk	- sclmublkから実行
%	scrolltb	- dkitgui simgui dfitgui rreadyから実行
%	scrtxtn		- dkitgui simgui wsguinから実行
%	sdequiv		- sdhfsyn sdn_stepから実行
%	sdn_step	- sdhfnormから実行
%	seesub		- seesysから実行
%	sguivar		- GUI変数の設定、多くのプログラムから実行
%	sigmaub		- mu mu sigmaub sigmaubから実行
%	sim2str		- sim2str sim2strから実行
%	simplemu	- simplemuから実行
%	simprmu		- simprmuから実行
%	sisoloop	- ex_ustr2から実行
%	sjh6		- clyap sncfbal srelbal sysbalから実行
%	sm2vec		- bub bubd gebub gebubdから実行
%	ssm2vec		- bub bubd gebub gebubdから実行
%	stripemp	- oniterから実行
%	swapiv		- 独立変数のスワップ
%	sylv		- h2norm axxbcから実行
%	syscl		- 呼び出されず、デバッグ時に使います。
%	tabed		- dkitguiから実行
%	terpol		- dtrsp genphase sdtrsp trsp vinterp vterpから実行
%	terpolb		- genphaseから実行
%	updownb		- simguiから実行
%	updownb2	- simguiから実行
%	var2sep		- mamilcから実行
%	vec2sm		- amiq2solから実行
%	vec2ssm		- amiq2solから実行
%	wsguic		- wsgui wsguinから実行
%	wsguicb		- wsguinから実行
%	wsguin		- wsguiから実行
%	wsminfo		- wsguinから実行
%	xpii		- Packed Index Itemを抽出
%	ynftdami	- muから実行
%	yublksel	- dkitguiから実行



% $Revision: 1.7.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
