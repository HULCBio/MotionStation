% SS2ZP   状態空間から零点-極への変換
% 
% [Z,P,K] = SS2ZP(A,B,C,D,IU) は、単入力 IU から、システム
%
%     x = Ax + Bu
%     y = Cx + Du
%
% の伝達関数
% 
%                  -1           (s-z1)(s-z2)...(s-zn)
%     H(s) = C(sI-A) B + D =  k ---------------------
%                               (s-p1)(s-p2)...(s-pn)
% 
% を計算します。ベクトル P は、伝達関数の分母の極の位置を含んでいます。
% 分子のゼロは、出力 y と同数の列数をもつ行列 Z の列に出力されます。
% 各分子の伝達関数の利得は、列ベクトル K に出力されます。
%
% 参考：ZP2SS,PZMAP,TZERO, EIG.


%   J.N. Little 7-17-85
%   Revised 3-12-87 JNL, 8-10-90 CLT, 1-18-91 ACWG, 2-22-94 AFP.
%   Copyright 1984-2003 The MathWorks, Inc.