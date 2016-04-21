% Mu-Analysis and Synthesis Toolbox
% Version 3.0.8 (R14) 05-May-2004
%
% ?V‹@”\
% Readme  - Mu-analysis and Synthesis Toolbox‚ÉŠÖ‚·‚é?d—v‚ÈƒŠƒŠ?[ƒX?î•ñ
%           (Readme‚ðƒ_ƒuƒ‹ƒNƒŠƒbƒN‚·‚é‚©?A"whatsnew directoryname"‚Æƒ^
%           ƒCƒv‚µ‚Ä‚­‚¾‚³‚¢?B‚½‚Æ‚¦‚Î?A"whatsnew mutools/commands"‚Æƒ^
%           ƒCƒv‚·‚é‚Æ?A‚±‚Ìƒtƒ@ƒCƒ‹‚ð•\Ž¦‚µ‚Ü‚·?B)
%
% •W?€‰‰ŽZ/Šî–{ŠÖ?”
%
% abv       - constant/varying/system?s—ñ‚ð?ã‚©‚ç?‡‚ÉŒ‹?‡
% cjt       - varying/system?s—ñ‚Ì‹¤–ð“]’u
% daug      - constant/varying/system?s—ñ‚ð‘ÎŠp‚ÉŠg‘å
% madd      - constant/varying/system?s—ñ‚Ì‰ÁŽZ
% minv      - constant/varying/system?s—ñ‚Ì‹t?s—ñ
% mmult     - constant/varying/system?s—ñ‚Ì?æŽZ
% mscl      - SYSTEM‚Ü‚½‚ÍVARYING?s—ñ‚ðƒXƒJƒ‰”{
% msub      - constant/varying/system?s—ñ‚ÌŒ¸ŽZ
% sbs       - ?s—ñ‚ð•À‚×‚é
% sclin     - ƒVƒXƒeƒ€‚Ì“ü—Í‚ðƒXƒP?[ƒŠƒ“ƒO
% sclout    - ƒVƒXƒeƒ€‚Ì?o—Í‚ðƒXƒP?[ƒŠƒ“ƒO
% sel       - ?s/—ñ‚Ü‚½‚Í?o—Í/“ü—Í‚ð‘I‘ð
% starp     - RedhefferƒXƒ^?[?Ï
% transp    - varying/system?s—ñ‚Ì“]’u
%
% ?s—ñ‚Ì?î•ñ‚Ì•\Ž¦?Aƒvƒ?ƒbƒg
%
% drawmag   - ‘Î˜bŒ^‚Ìƒ}ƒEƒX‚ðŽg‚Á‚½•`‰æ‚Æ‹ßŽ—‚Ìƒc?[ƒ‹
% minfo     - ?s—ñ‚Ì?î•ñ‚Ì?o—Í
% mprintf   - ?s—ñ‚Ì?‘Ž®•t‚«•\Ž¦
% rifd      - ŽÀ?”•”?A‹•?”•”?AŽü”g?”?AŒ¸?Š—¦‚Ì•\Ž¦
% see       - varying/system?s—ñ‚Ì•\Ž¦
% seeiv     - varying?s—ñ‚Ì“Æ—§•Ï?”‚Ì•\Ž¦
% seesys    - varying/system?s—ñ‚Ì?‘Ž®•t‚«‚Ì•\Ž¦
% vplot     - varying?s—ñ‚Ìƒvƒ?ƒbƒg
% vzoom     - ƒvƒ?ƒbƒgƒEƒBƒ“ƒhƒE‚Åƒ}ƒEƒX‚ðŽg‚Á‚ÄŽ²‚ð‘I‘ð
% wsgui     - ƒOƒ‰ƒtƒBƒJƒ‹‚Èƒ??[ƒNƒXƒy?[ƒX‘€?ìƒc?[ƒ‹
%
% ƒ‚ƒfƒŠƒ“ƒO‹@”\
%
% fitsys    - Žü”g?”‰ž“šƒf?[ƒ^‚ð“`’BŠÖ?”‚Å‹ßŽ—
% nd2sys    - SISO“`’BŠÖ?”‚ðSYSTEM?s—ñ‚É•ÏŠ·
% pck       - ?ó‘Ô‹óŠÔƒf?[ƒ^(A, B, C, D)‚©‚çsystem?s—ñ‚ð?ì?¬
% pss2sys   - [A B;C D]?s—ñ‚ðmu-tools‚Ìsystem?s—ñ‚É•ÏŠ·
% sys2pss   - SYSTEM?s—ñ‚©‚ç?ó‘Ô‹óŠÔ?s—ñ[A B; C D]‚ð’Š?o
% sysic     - SYSTEM?s—ñ‚Ì‘ŠŒÝŒ‹?‡?ì?¬ƒvƒ?ƒOƒ‰ƒ€
% unpck     - SYSTEM?s—ñ‚©‚ç?ó‘Ô‹óŠÔƒf?[ƒ^(A,B,C,D)‚ð’Š?o
% zp2sys    - “`’BŠÖ?”‚Ì‹É‚Æ—ë“_‚ðSYSTEM?s—ñ‚É•ÏŠ·
%
% System?s—ñŠÖ?”
%
% reordsys  - SYSTEM?s—ñ‚Ì?ó‘Ô‚Ì•À‚×‘Ö‚¦
% samhld    - ˜A‘±ŽžŠÔƒVƒXƒeƒ€‚ÌƒTƒ“ƒvƒ‹ƒz?[ƒ‹ƒh‹ßŽ—
% spoles    - SYSTEM?s—ñ‚Ì‹É
% statecc   - SYSTEM?s—ñ‚É?À•W•ÏŠ·‚ð“K—p
% strans    - SYSTEM?s—ñ‚Ì‘o‘ÎŠp?À•W•ÏŠ·
% sysrand   - ƒ‰ƒ“ƒ_ƒ€‚ÈSYSTEM?s—ñ‚Ì?ì?¬
% szeros    - SYSTEM?s—ñ‚Ì“`’B—ë“_
% tustin    - Prewarped Tustin•ÏŠ·‚ðŽg‚Á‚Ä˜A‘±SYSTEM?s—ñ‚ð—£ŽUSYSTEM?s—ñ
%             ‚É•ÏŠ·
%
% ƒ‚ƒfƒ‹‚Ì’áŽŸŒ³‰»
%
% hankmr    - SYSTEM?s—ñ‚Ì?Å“KHankelƒmƒ‹ƒ€‹ßŽ—
% sdecomp   - SYSTEM?s—ñ‚ð2‚Â‚ÌSYSTEM?s—ñ‚É•ª‰ð
% sfrwtbal  - SYSTEM?s—ñ‚ÌŽü”g?”?d‚Ý•t‚«•½?t‰»ŽÀŒ»
% sfrwtbld  - SYSTEM?s—ñ‚ÌˆÀ’è‚ÈŽü”g?”?d‚Ý•t‚«ŽÀŒ»
% sncfbal   - SYSTEM?s—ñ‚ÌŠù–ñ•ª‰ð‚Ì•½?t‰»ŽÀŒ»
% srelbal   - SYSTEM?s—ñ‚ÌŠm—¦“I•½?t‰»ŽÀŒ»
% sresid    - SYSTEM?s—ñ‚Ì?ó‘Ô—Ê‚ðŽæ‚è?œ‚­
% strunc    - SYSTEM?s—ñ‚Ì?ó‘Ô‚Ì?í?œ
% sysbal    - SYSTEM?s—ñ‚Ì•½?t‰»ŽÀŒ»
%
% ƒVƒXƒeƒ€‰ž“š
%
% cos_tr    - —]Œ·?M?†‚ðVARYING?s—ñ‚Æ‚µ‚Ä?¶?¬
% dtrsp     - ?üŒ`ƒVƒXƒeƒ€‚Ì—£ŽUŽžŠÔ‰ž“š
% frsp      - SYSTEM?s—ñ‚ÌŽü”g?”‰ž“š
% sin_tr    - ?³Œ·?M?†‚ðVARYING?s—ñ‚Æ‚µ‚Ä?¶?¬
% sdtrsp    - ?üŒ`ƒVƒXƒeƒ€‚ÌƒTƒ“ƒvƒ‹’lŽžŠÔ‰ž“š
% siggen    - ?M?†‚ðVARYING?s—ñ‚Æ‚µ‚Ä?¶?¬
% simgui    - ƒOƒ‰ƒtƒBƒJƒ‹‚È?üŒ`ƒVƒXƒeƒ€ƒVƒ~ƒ…ƒŒ?[ƒVƒ‡ƒ“ƒc?[ƒ‹
% step_tr   - ƒXƒeƒbƒv?M?†‚ðVARYING?s—ñ‚Æ‚µ‚Ä?¶?¬
% trsp      - ?üŒ`ƒVƒXƒeƒ€‚ÌŽžŠÔ‰ž“š
%
% H_2?AH_?‡‰ð?Í?AƒVƒ“ƒZƒVƒX
%
% dhfsyn    - —£ŽUŽžŠÔH?‡?§Œä?ÝŒv
% dhfnorm   - ˆÀ’è‚ÈSYSTEM?s—ñ‚Ì—£ŽUŽžŠÔ?‡ƒmƒ‹ƒ€‚ÌŒvŽZ
% emargin   - ƒMƒƒƒbƒvŒv—Êƒ?ƒoƒXƒgˆÀ’è?«
% gap       - 2‚Â‚ÌSYSTEM?s—ñŠÔ‚ÌƒMƒƒƒbƒvŒv—Ê‚ÌŒvŽZ
% h2norm    - ˆÀ’è‚Å?AŒµ–§‚Éƒvƒ?ƒp‚ÈSYSTEM?s—ñ‚Ì2ƒmƒ‹ƒ€‚ðŒvŽZ
% h2syn     - H_2?§Œä?ÝŒv
% hinffi    - H?‡‘S?î•ñ?§Œä‘¥
% hinfnorm  - ˆÀ’è‚Åƒvƒ?ƒp‚ÈSYSTEM?s—ñ‚ÌH?‡ƒmƒ‹ƒ€‚ðŒvŽZ
% hinfsyn   - H?‡?§Œä?ÝŒv
% hinfsyne  - H?‡?Å?¬ƒGƒ“ƒgƒ?ƒs?[?§Œä?ÝŒv
% linfnorm  - ƒvƒ?ƒp‚ÈSYSTEM?s—ñ‚ÌL?‡ƒmƒ‹ƒ€‚ðŒvŽZ
% ncfsyn    - H?‡ƒ‹?[ƒv?®Œ`?§Œä?ÝŒv
% nugap     - SYSTEM?s—ñŠÔ‚ÌnuƒMƒƒƒbƒvŒv—Ê‚ÌŒvŽZ
% pkvnorm   - VARYING?s—ñ‚Ìƒs?[ƒN(“Æ—§•Ï?”‚ÉŠÖ‚·‚é)ƒmƒ‹ƒ€
% sdhfsyn   - ƒTƒ“ƒvƒ‹’lH?‡(—U“±L_2ƒmƒ‹ƒ€)?§Œä?ÝŒv
% sdhfnorm  - ˆÀ’è‚ÈSYSTEM?s—ñ‚ÌƒTƒ“ƒvƒ‹’lH?‡ƒmƒ‹ƒ€(—U“±L_2ƒmƒ‹ƒ€)
%
% ?\‘¢‰»“ÁˆÙ’l(mu)‰ð?Í‚ÆƒVƒ“ƒZƒVƒX
%
% blknorm   - constant/varying?s—ñ‚Ìƒuƒ?ƒbƒN–ˆ‚Ìƒmƒ‹ƒ€
% cmmusyn   - Constant?s—ñ‚ÌmuƒVƒ“ƒZƒVƒX
% dkit      - Ž©“®‰»‚³‚ê‚½D-KƒCƒ^ƒŒ?[ƒVƒ‡ƒ“
% dkitgui   - ƒOƒ‰ƒtƒBƒJƒ‹‚ÈDKƒCƒ^ƒŒ?[ƒVƒ‡ƒ“ƒc?[ƒ‹
% dypert    - Žü”g?”‚Ìmuƒf?[ƒ^‚©‚ç—L—??Û“®‚ð?ì?¬
% fitmag    - ƒQƒCƒ“ƒf?[ƒ^‚ðŽÀ—L—?“`’BŠÖ?”‹ßŽ—
% fitmaglp  - ƒQƒCƒ“ƒf?[ƒ^‚ðŽÀ—L—?“`’BŠÖ?”‹ßŽ—
% genmu     - ˆê”Ê‰»mu‚Ì?ãŠE‚ÌŒvŽZ
% genphase  - ƒQƒCƒ“ƒf?[ƒ^‚Ì?Å?¬ˆÊ‘ŠŽü”g?”‰ž“š‚ð?¶?¬
% magfit    - ƒQƒCƒ“ƒf?[ƒ^‚ðŽÀ—L—?“`’BŠÖ?”‹ßŽ—
% msf       - DKƒCƒ^ƒŒ?[ƒVƒ‡ƒ“—p‚ÌDƒXƒP?[ƒ‹‹ßŽ—
% msfbatch  - msf‚Ìƒoƒbƒ`ƒo?[ƒWƒ‡ƒ“
% mu        - constant/varying?s—ñ‚Ìmu‰ð?Í
% muftbtch  - ƒoƒbƒ`Œ`Ž®‚ÌDƒXƒP?[ƒ‹‹ßŽ—ƒ‹?[ƒ`ƒ“(?«—ˆ‚ÍƒTƒ|?[ƒg‚ð?s‚í‚È‚¢
%             ‚Ì‚Å?Amsfbatch‚ðŽg‚Á‚Ä‚­‚¾‚³‚¢)
% musynfit  - ‘Î˜b“I‚ÈDƒXƒP?[ƒ‹—L—?‹ßŽ—(?«—ˆ‚ÍƒTƒ|?[ƒg‚ð?s‚í‚È‚¢‚Ì‚Å?A
%             msf‚ðŽg‚Á‚Ä‚­‚¾‚³‚¢)
% musynflp  - ‘Î˜b“I‚ÈDƒXƒP?[ƒ‹—L—?‹ßŽ—(?«—ˆ‚ÍƒTƒ|?[ƒg‚ð?s‚í‚È‚¢‚Ì‚Å?A
%             msf‚ðŽg‚Á‚Ä‚­‚¾‚³‚¢)
% muunwrap  - muŒvŽZ‚©‚çƒf?[ƒ^‚ð’Š?o
% randel    - ƒ‰ƒ“ƒ_ƒ€‚È?Û“®‚ð?¶?¬
% sisorat   - 1ŽŸ‘S’Ê‰ß“à‘}
% unwrapd   - mu‚©‚çDƒXƒP?[ƒŠƒ“ƒO?s—ñ‚ð?ì?¬
% unwrapp   - mu‚©‚çDelta?Û“®‚ð?ì?¬
% wcperf    - ?Åˆ«ƒP?[ƒX‚Ì?«”\‹È?ü‚Æ?Û“®
%
% VARYING?s—ñ‚ÌŽæ‚èˆµ‚¢
%
% getiv     - VARYING?s—ñ‚Ì“Æ—§•Ï?”‚Ì?o—Í
% indvcmp   - 2‚Â‚Ì?s—ñ‚Ì“Æ—§•Ï?”ƒf?[ƒ^‚Ì”äŠr
% massign   - ?s—ñ‚Ì—v‘f‚ÌŠ„‚è“–‚Ä
% scliv     - “Æ—§•Ï?”‚ÌƒXƒP?[ƒŠƒ“ƒO
% sortiv    - “Æ—§•Ï?”‚Ì•À‚×‘Ö‚¦
% tackon    - VARYING?s—ñ‚ÌŒ‹?‡
% var2con   - VARYING?s—ñ‚ðCONSTANT?s—ñ‚É•ÏŠ·
% varyrand  - ƒ‰ƒ“ƒ_ƒ€‚ÈVARYING?s—ñ‚ð?¶?¬
% vpck      - VARYING?s—ñ‚Ìˆ³?k
% vunpck    - VARYING?s—ñ‚Ì•ª‰ð
% xtract    - VARYING?s—ñ‚Ì•”•ª“I’Š?o
% xtracti   - VARYING?s—ñ‚Ì•”•ª“I’Š?o
%
% Varying?s—ñ‚ÉŠÖ‚·‚é•W?€MATLABƒRƒ}ƒ“ƒh
%
% vabs      - constant/varying?s—ñ‚Ì?â‘Î’l
% vceil     - constant/varying?s—ñ‚Ì—v‘f‚Ì?‡•ûŒü‚Ö‚ÌŠÛ‚ß
% vdet      - constant/varying?s—ñ‚Ì?s—ñŽ®
% vdiag     - constant/varying?s—ñ‚Ì‘ÎŠp—v‘f
% veig      - constant/varying?s—ñ‚ÌŒÅ—L’l•ª‰ð
% vexpm     - constant/varying?s—ñ‚ÌŽw?”
% vfft      - VARYING?s—ñ‚ÌFFT
% vfloor    - constant/varying?s—ñ‚Ì—v‘f‚Ì-?‡•ûŒü‚Ö‚ÌŠÛ‚ß
% vifft     - VARYING?s—ñ‚Ì‹tFFT
% vinv      - constant/varying?s—ñ‚Ì‹t?s—ñ
% vimag     - constant/varying?s—ñ‚Ì‹•?”•”
% vnorm     - varying/constant?s—ñ‚Ìƒmƒ‹ƒ€
% vpoly     - constant/varying?s—ñ‚Ì“Á?«‘½?€Ž®
% vpinv     - constant/varying?s—ñ‚Ì‹[Ž—‹t?s—ñ
% vrank     - constant/varying?s—ñ‚Ìƒ‰ƒ“ƒN
% vrcond    - constant/varying?s—ñ‚Ì?ðŒ??”
% vreal     - constant/varying?s—ñ‚ÌŽÀ?”•”
% vroots    - constant/varying?s—ñ‚Ì‘½?€Ž®‚Ì?ª
% vschur    - constant/varying?s—ñ‚ÌSchur•ª‰ð
% vspect    - VARYING?s—ñ‚É‘Î‚·‚éSignal Processing‚ÌƒXƒyƒNƒgƒ‹‰ð?Í
%             ƒRƒ}ƒ“ƒh
% vsqrtm    - constant/varying?s—ñ‚Ì•½•û?ª
% vsvd      - constant/varying?s—ñ‚Ì“ÁˆÙ’l•ª‰ð
%
% Varying?s—ñ‚ÉŠÖ‚·‚é•t‰Á“I‚È‹@”\
%
% vcjt      - constant/varying?s—ñ‚Ì‹¤–ð“]’u
% vcond     - constant/varying?s—ñ‚Ì?ðŒ??”
% vconj     - constant/varying?s—ñ‚Ì•¡‘f‹¤–ð
% vdcmate   - VARYING?s—ñ‚ÌŠÔˆø‚«
% vebe      - VARYING?s—ñ‚Ì—v‘f’PˆÊ‚Ì‰‰ŽZ
% veberec   - —v‘f’PˆÊ‚Ì‹t?”
% veval     - VARYING?s—ñ‚Ìˆê”ÊŠÖ?”‚Ì•]‰¿
% vveval    - VARYING?s—ñ‚Ìˆê”ÊŠÖ?”‚Ì•]‰¿
% mveval    - VARYING?s—ñ‚Ìˆê”ÊŠÖ?”‚Ì•]‰¿
% vfind     - “Æ—§•Ï?”‚ð‹?‚ß‚é
% vinterp   - VARYING?s—ñ‚Ì“à‘}
% vldiv     - constant/varying?s—ñ‚Ì?¶?œŽZ
% vrdiv     - constant/varying?s—ñ‚Ì‰E?œŽZ
% vrho      - constant/varying?s—ñ‚ÌƒXƒyƒNƒgƒ‹”¼Œa
% vtp       - constant/varying?s—ñ‚Ì“]’u
% vtrace    - constant/varying?s—ñ‚Ì‘ÎŠp‚Ì˜a
%
% ƒ†?[ƒeƒBƒŠƒeƒB‚Æ‚»‚Ì‘¼‚ÌŠÖ?”
%
% add_disk  - ƒiƒCƒLƒXƒgƒvƒ?ƒbƒg‚É’PˆÊ‰~‚ð’Ç‰Á
% cf2sys    - ?³‹K‰»‚³‚ê‚½Šù–ñ•ª‰ð‚©‚ç?s—ñ‚ð?ì?¬
% clyap     - ˜A‘±ŒnLyapunov•û’öŽ®
% crand     - ˆê—l•ª•z‚·‚éƒ‰ƒ“ƒ_ƒ€‚È•¡‘f?s—ñ‚ð?ì?¬
% crandn    - ?³‹K•ª•z‚·‚éƒ‰ƒ“ƒ_ƒ€‚È•¡‘f?s—ñ‚ð?ì?¬
% csord     - ?‡?˜•t‚¯‚ç‚ê‚½•¡‘fSchur?s—ñ
% mfilter   - Butterworth, Bessel, RCƒtƒBƒ‹ƒ^‚ð?ì?¬
% negangle  - ?s—ñ—v‘f‚ÌŠp“x‚ð0‚©‚ç-2 pi‚ÌŠÔ‚ÅŒvŽZ
% ric_eig   - ŒÅ—L’l•ª‰ð‚ðŽg‚Á‚Ä?ARiccati•û’öŽ®‚ð‰ð‚­
% ric_schr  - Schur•ª‰ð‚ðŽg‚Á‚Ä?ARiccati•û’öŽ®‚ð‰ð‚­
% unum      - “ü—Í‚ÌŽŸŒ³
% xnum      - ?ó‘Ô‚ÌŽŸŒ³
% ynum      - ?o—Í‚ÌŽŸŒ³
%

%   Generated from Contents.m_template revision 1.1.6.1  $Date: 2004/03/10 21:22:23 $
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc. 
