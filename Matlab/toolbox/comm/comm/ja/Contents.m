% Communications Toolbox
% Version 3.0 (R14) 05-May-2004
%
% ?î•ñŒ¹
%   randerr      - ƒrƒbƒgŒë‚èƒpƒ^?[ƒ“‚Ì?ì?¬
%   randint      - ˆê—l•ª•z‚·‚é—??”?®?”‚Ì?s—ñ‚Ì?ì?¬
%   randsrc      - ‘O‚à‚Á‚Ä?İ’è‚µ‚½ƒAƒ‹ƒtƒ@ƒxƒbƒg‚ğg‚Á‚Ä?Aƒ‰ƒ“ƒ_ƒ€?s—ñ
%                  ‚Ì?ì?¬
%   wgn          - ”’?FƒKƒEƒXƒmƒCƒY‚Ì?ì?¬
%
% ?M?†‰ğ?ÍŠÖ?”
%   biterr       - ƒrƒbƒgƒGƒ‰?[?”‚ÆƒrƒbƒgƒGƒ‰?[ƒŒ?[ƒg‚ÌŒvZ
%   eyediagram   - ƒAƒCƒpƒ^?[ƒ“‚Ì?¶?¬
%   scatterplot  - ƒXƒLƒƒƒ^?[ƒvƒ?ƒbƒg‚Ì?¶?¬
%   symerr       - ƒVƒ“ƒ{ƒ‹ƒGƒ‰?[?”‚ÆƒVƒ“ƒ{ƒ‹ƒGƒ‰?[ƒŒ?[ƒg‚ÌŒvZ
%
% ?î•ñ‚Ì•„?†‰»
%   compand      - ƒÊ–@‘¥?A‚Ü‚½‚Í?AA–@‘¥ˆ³?k/?L’£‚É‚æ‚é?î•ñŒ¹•„?†‰»
%   dpcmdeco     - ?·•ªƒpƒ‹ƒX•„?†•Ï’²•û®‚ğg—p‚µ‚Ä•œ?†
%   dpcmenco     - ?·•ªƒpƒ‹ƒX•„?†•Ï’²•û®‚ğg—p‚µ‚Ä•„?†‰»
%   dpcmopt      - DPCMƒpƒ‰ƒ??[ƒ^‚ğ?Å“K‰»
%   lloyds       - LloydƒAƒ‹ƒSƒŠƒYƒ€‚ğg‚Á‚Ä—Êq‰»ƒpƒ‰ƒ??[ƒ^‚ğ?Å“K‰»
%   quantiz      - —Êq‰»ƒCƒ“ƒfƒbƒNƒX‚Æ—Êq‰»‚µ‚½?o—Í’l‚ğ?¶?¬
%
% Œë‚è?§Œä•„?†‰»
%   bchpoly      - ƒoƒCƒiƒŠBCH•„?†‚Ìƒpƒ‰ƒ??[ƒ^‚Ü‚½‚Í?¶?¬‘½?€®‚ğ?¶?¬
%   convenc      - ?ô‚İ?‚İ•„?†‰»
%   cyclgen      - ?„‰ñ•„?†‚ÌƒpƒŠƒeƒBƒ`ƒFƒbƒN?s—ñ?A?¶?¬?s—ñ‚ğ?¶?¬
%   cyclpoly     - ?„‰ñ•„?†‚Ì?¶?¬‘½?€®‚ğ?¶?¬
%   decode       - ƒuƒ?ƒbƒN•œ?†
%   encode       - ƒuƒ?ƒbƒN•„?†‰»
%   gen2par      - ?¶?¬?s—ñ‚ğƒpƒŠƒeƒBƒ`ƒFƒbƒN?s—ñ‚Ö•ÏŠ·
%   gfweight     - ?üŒ`ƒuƒ?ƒbƒN•„?†‚Ì?Å?¬‹——£‚ğŒvZ
%   hammgen      - Hamming•„?†‚Ì?¶?¬?s—ñ‚ÆƒpƒŠƒeƒBƒ`ƒFƒbƒN?s—ñ‚ğ?ì?¬
%   rsdec        - ƒŠ?[ƒhƒ\ƒ?ƒ‚ƒ“•œ?†
%   rsenc        - ƒŠ?[ƒhƒ\ƒ?ƒ‚ƒ“•„?†‰»
%   rsdecof      - ƒŠ?[ƒhƒ\ƒ?ƒ‚ƒ“•„?†‰»‚³‚ê‚½ASCIIƒtƒ@ƒCƒ‹‚ğ•œ?†
%   rsencof      - ƒŠ?[ƒhƒ\ƒ?ƒ‚ƒ“•„?†‰»‚ğg‚Á‚ÄASCIIƒtƒ@ƒCƒ‹‚ğ•„?†‰»
%   rsgenpoly    - ƒŠ?[ƒhƒ\ƒ?ƒ‚ƒ“•„?†‚Ì?¶?¬‘½?€®‚ğ?ì?¬
%   syndtable    - ƒVƒ“ƒhƒ??[ƒ€•œ?†ƒe?[ƒuƒ‹‚ğ?¶?¬
%   vitdec       - ?ô‚İ?‚İ•„?†‰»‚³‚ê‚½ƒoƒCƒiƒŠƒf?[ƒ^‚ğViterbiƒAƒ‹ƒSƒŠƒYƒ€‚ğg‚Á‚Ä•œ?†
%
% Œë‚è?§Œä•„?†‰»—p‚Ì’á?…?€ŠÖ?”
%   bchdeco      - BCH •œ?†
%   bchenco      - BCH •„?†‰»
%
% •Ï’²/•œ’²
%   ademod       - ƒAƒiƒ?ƒOƒpƒXƒoƒ“ƒh•œ’²
%   ademodce     - ƒAƒiƒ?ƒOƒx?[ƒXƒoƒ“ƒh•œ’²
%   amod         - ƒAƒiƒ?ƒOƒpƒXƒoƒ“ƒh•Ï’²
%   amodce       - ƒAƒiƒ?ƒOƒx?[ƒXƒoƒ“ƒh•Ï’²
%   apkconst     - ‰~Œ`ASK/PSK ?M?†“_”z’u?}‚Ìƒvƒ?ƒbƒg
%   ddemod       - ƒfƒBƒWƒ^ƒ‹ƒpƒXƒoƒ“ƒh•œ’²
%   ddemodce     - ƒfƒBƒWƒ^ƒ‹ƒx?[ƒXƒoƒ“ƒh•œ’²
%   demodmap     - •œ’²?M?†‚©‚çƒfƒBƒWƒ^ƒ‹ƒ?ƒbƒZ?[ƒW‚Öƒfƒ}ƒbƒsƒ“ƒO
%   dmod         - ƒfƒBƒWƒ^ƒ‹ƒpƒXƒoƒ“ƒh•Ï’²
%   dmodce       - ƒfƒBƒWƒ^ƒ‹ƒx?[ƒXƒoƒ“ƒh•Ï’²
%   modmap       - ƒfƒBƒWƒ^ƒ‹?M?†‚ğƒAƒiƒ?ƒO?M?†‚Öƒ}ƒbƒsƒ“ƒO
%   qaskdeco     - QASK?³•û?M?†“_”z’u‚©‚çƒ?ƒbƒZ?[ƒW‚ğƒfƒ}ƒbƒsƒ“ƒO
%   qaskenco     - ƒ?ƒbƒZ?[ƒW‚ğQASK?³•û?M?†“_”z’u‚Éƒ}ƒbƒsƒ“ƒO
%
% “ÁêƒtƒBƒ‹ƒ^
%   hank2sys     - ƒnƒ“ƒPƒ‹?s—ñ‚ğ?üŒ`ƒVƒXƒeƒ€‚É•ÏŠ·
%   hilbiir      - ƒqƒ‹ƒxƒ‹ƒg•ÏŠ· IIR ƒtƒBƒ‹ƒ^
%   rcosflt      - ƒRƒTƒCƒ“ƒ??[ƒ‹ƒIƒtƒtƒBƒ‹ƒ^‚ğg‚Á‚Ä?A“ü—Í?M?†‚ğƒtƒBƒ‹
%                  ƒ^ƒŠƒ“ƒO
%   rcosine      - ƒRƒTƒCƒ“ƒ??[ƒ‹ƒIƒtƒtƒBƒ‹ƒ^‚ğ?İŒv
%
% “ÁêƒtƒBƒ‹ƒ^—p‚Ì’á?…?€ŠÖ?”
%   rcosfir      - ƒRƒTƒCƒ“ƒ??[ƒ‹ƒIƒtFIR ƒtƒBƒ‹ƒ^‚ğ?İŒv
%   rcosiir      - ƒRƒTƒCƒ“ƒ??[ƒ‹ƒIƒtIIR ƒtƒBƒ‹ƒ^‚ğ?İŒv
%
% ƒ`ƒƒƒlƒ‹ŠÖ?”
%   awgn         - ”’?FƒKƒEƒXƒmƒCƒY‚ğ?M?†‚É•t‰Á 
%   
% ƒKƒ?ƒA‘Ì‚ÌŒvZ
%   gfadd        - ƒKƒ?ƒA‘Ì?ã‚Ì‘½?€®‚Ì˜a
%   gfconv       - ƒKƒ?ƒA‘Ì?ã‚Ì‘½?€®‚Ì?Ï
%   gfcosets     - ƒKƒ?ƒA‘Ì‚Ì‰~ü“™•ª?è—]—Ş‚Ì?ì?¬
%   gfdeconv     - ƒKƒ?ƒA‘Ì?ã‚Ì‘½?€®‚Ì?œZ
%   gfdiv        - ƒKƒ?ƒA‘Ì‚ÌŒ³‚Ì?œZ
%   gffilter     - ‘fƒKƒ?ƒA‘Ì?ã‚Ì‘½?€®‚ğg‚Á‚½ƒf?[ƒ^‚ÌƒtƒBƒ‹ƒ^ƒŠƒ“ƒO
%   gflineq      - ‘fƒKƒ?ƒA‘Ì?ã‚Å?üŒ`•û’ö®Ax = b‚ğ‰ğ‚­
%   gfminpol     - ƒKƒ?ƒA‘Ì‚ÌŒ³‚Ì?Å?¬‘½?€®‚ğŒŸ?o
%   gfmul        - ƒKƒ?ƒA‘Ì‚ÌŒ³‚Ì?æZ
%   gfplus       - 2‚Â‚ÌƒKƒ?ƒA‘Ì‚ÌŒ³‚ğ‰ÁZ
%   gfpretty     - ‘½?€®‚ğ?®Œ`‚µ‚Ä•\¦
%   gfprimck     - ƒKƒ?ƒA‘Ì?ã‚Ì‘½?€®‚ªŒ´n‘½?€®‚Å‚ ‚é‚©ƒ`ƒFƒbƒN
%   gfprimdf     - ƒKƒ?ƒA‘Ì‚ÌƒfƒtƒHƒ‹ƒgŒ´n‘½?€®‚ğ?¶?¬
%   gfprimfd     - ƒKƒ?ƒA‘Ì‚ÌŒ´n‘½?€®‚ğŒŸ?õ
%   gfrank       - ƒKƒ?ƒA‘Ì?ã‚Ì?s—ñ‚Ìƒ‰ƒ“ƒN‚ğŒvZ
%   gfrepcov     - GF(2)?ã‚Ì‘½?€®•\Œ»‚ğ‘¼‚Ì•\Œ»‚É•ÏŠ·
%   gfroots      - ‘fƒKƒ?ƒA‘Ì?ã‚Ì‘½?€®‚Ì?ª‚ÌŒŸ?o
%   gfsub        - ƒKƒ?ƒA‘Ì?ã‚Ì‘½?€®‚ÌŒ¸Z
%   gftrunc      - ƒKƒ?ƒA‘Ì?ã‚Ì‘½?€®•\Œ»‚ğƒRƒ“ƒpƒNƒg‚É•\Œ»
%   gftuple      - ƒKƒ?ƒA‘Ì‚ÌŒ³‚ÌƒtƒH?[ƒ}ƒbƒg‚ğŠÈ’P‰»‚Ü‚½‚Í•ÏŠ·
%
% ƒ†?[ƒeƒBƒŠƒeƒB
%   bi2de        - 2?iƒxƒNƒgƒ‹‚ğ10?i?”‚É•ÏŠ·
%   de2bi        - 10?i?”‚ğ2?i?”‚É•ÏŠ·
%   erf          - Œë?·ŠÖ?”
%   erfc         - ‘Š•âŒë?·ŠÖ?”
%   istrellis    - “ü—Í‚ª‘Ã“–‚ÈƒgƒŒƒŠƒX?\‘¢‘Ì‚©‚Ç‚¤‚©ƒ`ƒFƒbƒN
%   oct2dec      - 8?i?”‚ğ10?i?”‚É•ÏŠ·
%   poly2trellis - ?ô?‚İ•„?†‘½?€®‚ğƒgƒŒƒŠƒX•\Œ»‚É•ÏŠ·
%   vec2mat      - ƒxƒNƒgƒ‹‚ğ?s—ñ‚É•ÏŠ·
% 
% Q?l?F COMMDEMOS, SIGNAL.



% Generated from Contents.m_template revision 1.1.6.1
% Copyright 1996-2004 The MathWorks, Inc.
