% TZERO   LTIシステムの伝達零点
% 
% Z = TZERO(SYS) は、LTIシステム SYS の伝達零点を出力します。
%
% [Z,GAIN] = TZERO(SYS) は、システムがSISOの場合、伝達関数のゲインも
% 出力します。
% 
% Z = TZERO(A,B,C,D) は、状態空間行列に直接的に働き、状態空間システムの
% 伝達零点を出力します。   
%        .
%        x = Ax + Bu     または   x[n+1] = Ax[n] + Bu[n]
%        y = Cx + Du              y[n]  = Cx[n] + Du[n]
%
% 参考 : ZERO, PZMAP, POLE.


%   Clay M. Thompson  7-23-90, 
%       Revised: P.Gahinet 5-15-96
%   Copyright 1986-2002 The MathWorks, Inc. 
