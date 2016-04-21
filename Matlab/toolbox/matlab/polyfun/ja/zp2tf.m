% ZP2TF   零点-極から伝達関数への変換
% 
% [NUM,DEN] = ZP2TF(Z,P,K )は、伝達関数
%
%                 NUM(s)
%         H(s) = -------- 
%                 DEN(s)
%
% を作成します。ベクトル Z は零点の位置、ベクトル P は極の位置、スカラ 
% K は利得です。ベクトル NUM と DEN は、それぞれ、s の降ベキ順に並べら
% れた分子と分母の係数が出力されます。
%
% 参考：TF2ZP.


%   J.N. Little 7-17-85
%   Revised 6-27-88
%   Copyright 1984-2003 The MathWorks, Inc.