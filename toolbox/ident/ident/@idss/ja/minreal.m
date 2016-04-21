% IDSS/MINREAL  は、最小実現を行います。
%
% MMOD = MINREAL(MODEL) は、与えられた IDSS モデル MODEL に対して、すべ
% ての不可制御モード、または、不可観測モードを取り去った、MODEL と等価な
% モデル MMODを出力します。
%
% MSYS = MINREAL(SYS,TOL) は、状態のダイナミクスの除去にトレランス TOL 
% を設定します。デフォルト値は、TOL = SQRT(EPS) で、このトレランスを大き
% くすると、よりキャンセルの機会が大きくなります。
%  
% MINREAL は、Control System Toolbox を必要とします。



%   Copyright 1986-2001 The MathWorks, Inc.
