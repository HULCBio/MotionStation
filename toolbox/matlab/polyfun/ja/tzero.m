% TZERO   LTIシステムの伝達零点
% 
% Z = TZERO(SYS) は、LTIシステム SYS の伝達零点を出力します。
% 
% システムがSISOの場合は、[Z,GAIN] = TZERO(SYS) は、伝達関数利得も出力
% します。
% 
% Z = TZERO(A,B,C,D) は、状態空間行列を直接処理し、状態空間システムの
% 伝達零点を出力します。
%             .
%             x = Ax + Bu     または   x[n+1] = Ax[n] + Bu[n]
%             y = Cx + Du              y[n]  = Cx[n] + Du[n]
%
% 参考： PZMAP, POLE, EIG.


%   Clay M. Thompson  7-23-90
%       Revised: A.Potvin 6-1-94, P.Gahinet 5-15-96
%   Copyright 1984-2004 The MathWorks, Inc. 