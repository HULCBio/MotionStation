% SS2TF   状態空間から伝達関数への変換
% 
% [NUM,DEN] = SS2TF(A,B,C,D,iu) は、iu番目の入力からシステム
% 
%     x = Ax + Bu
%     y = Cx + Du
%
% の伝達関数
% 
%             NUM(s)          -1
%     H(s) = -------- = C(sI-A) B + D
%             DEN(s)
% 
% を計算します。ベクトル DEN には、s の降ベキ順に並べられた分母の係数が
% 含まれます。分子の係数は、出力 y と同数の行数をもつ行列 NUM に出力され
% ます。
%
% 参考：TF2SS, ZP2TF, ZP2SS.


%   J.N. Little 4-21-85
%   Revised 7-25-90 Clay M. Thompson, 10-11-90 A.Grace
%   Copyright 1984-2003 The MathWorks, Inc. 