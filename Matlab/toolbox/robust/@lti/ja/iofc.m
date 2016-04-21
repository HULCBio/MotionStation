% IOFC 状態空間表現のインナー/アウター分解
%
% [SS_IN,SS_INP,SS_OUT] = IOFC(SS_)、または、
% [AIN,BIN,CIN,DIN,AINP,BINP,CINP,DINP,AOUT,BOUT,COUT,DOUT] = ....
% IOFC(A,B,C,D)は、m行n列の伝達関数 G: SS_ = MKSYS(A,B,C,D) (m<n)を、つ
% ぎのように、インナー/アウター分解します。
% 
%                      G = |M  0| |Th |
%                                 |Thp|
% 
% ここで、
%                     |Th |: 正方でインナー
%                     |Thp|
%
%                      M : アウター因子
%
% 結果として得られる4つ1組で表現される状態空間は、(ain,bin,...)、または、
% つぎのように出力されます。
%
%            ss_in  = mksys(ain,bin,cin,din);
%            ss_inp = mksys(ainp,binp,cinp,dinp);
%            ss_out = mksys(aout,bout,cout,dout);
%
% 標準的な状態空間表現は、"branch"により抽出することができます。



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
