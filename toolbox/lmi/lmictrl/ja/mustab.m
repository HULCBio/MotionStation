% [margin,peakf,fs,ds,gs] = mustab(sys,delta,freqs)
%
% ノルム有界、または、セクタ有界で線形時不変な不確かさをもつシステムのロ
% バスト安定余裕MARGINを推定します。
%                   ___________
%                   |         |
%              +----|  DELTA  |<---+
%              |    |_________|    |
%              |                   |
%              |    ___________    |
%              +--->|         |----+
%                   |   SYS   |
%          u  ----->|_________|----->  y
%
%
% MARGIN >= 1ならば、相互接続はロバスト安定です。
%
% MARGINの逆数は、混合μの上界です。
%
% 入力:
%  SYS         動的システム(LTISYSを参照)。
%  DELTA       不確かさの構造(UBLOCKを参照)。
%  FREQS       オプション入力である周波数点ベクトル。
%
% 出力:
%  MARGIN      ロバスト安定余裕。
%  PEAKF       余裕がもっとも小さくなる周波数。
%  FS,DS,GS    テストされた周波数FSでのD,Gスケーリング。
%              周波数FS(i)でのスケーリングDi, Giは、つぎの式で与えられま
%              す。
% 
%                  Di = getdg(DS,i);    Gi = getdg(GS,i);
%
% 参考：      MUBND, MUPERF, GETDG, UBLOCK, UDIAG, UINFO.



% Copyright 1995-2002 The MathWorks, Inc. 
