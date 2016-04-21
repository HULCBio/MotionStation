% GFLINEQ   素ガロア体上で、Ax = b の特解を求める
%
% X = GFLINEQ(A, B) は GF(2) での線形方程式 A X = B の特解を出力します。
% A, B, X の元は 0 または 1 です。方程式が解を持たない場合、X は空行列と
% なります。
%
% X = GFLINEQ(A, B, P) は GF(P) での線形方程式 A X = B の特解を出力します。
% A, B, X の元は 0 と P-1 の間の整数です。
%
% [X, VLD] = GFLINEQ(...) は解の存在を示すフラグを出力します。VLD = 1 の
% 場合は、解 X が存在し、有効であることを示します。VLD = 0 の場合は、解は
% 存在しません。
%
% 参考： GFADD, GFDIV, GFROOTS, GFRANK, GFCONV, CONV.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $   $Date: 2003/06/23 04:34:38 $   
