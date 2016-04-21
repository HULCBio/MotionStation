% IOFR 状態空間表現のインナー/アウター分解
%
% [SS_IN,SS_INP,SS_OUT] = IOFR(SS_)、または、
% [AIN,BIN,CIN,DIN,AINP,BINP,CINP,DINP,AOUT,BOUT,COUT,DOUT] = ...
% IOFR(A,B,C,D)は、m行n列伝達関数 G: SS_ = MKSYS(A,B,C,D) (m>=n)を、つぎ
% のように、インナー/アウター分解します。
% 
%                      G = |Th Thp| |M|
%                                   |0|
% ここで、
%                      [Th Thp] : 正方でインナー
%                      M        : アウター因子
%
% 結果として得られる4つ1組で表現される状態空間は、(ain,bin,...)、または、
% つぎのように出力されます。
%
%            ss_in  = mksys(ain,bin,cin,din);
%            ss_inp = mksys(ainp,binp,cinp,dinp);
%            ss_out = mksys(aout,bout,cout,dout);
%
% 標準的な状態空間表現は、"branch"により抽出することができます。



% Copyright 1988-2002 The MathWorks, Inc. 
