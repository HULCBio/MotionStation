% STVAL   st-型の関数の評価
%
% Z = STVAL(ST,X) は、st-型が ST 内にある関数の X での値を出力します。
% Z は、ST にある関数が1変数でd要素のベクトル値で、また size(X) が [m,n] 
% の場合、大きさ [d*m,n] の行列です。
% ST にある関数が m>1 のm変数でd要素のベクトル値の場合、Z の大きさは以下
% になります。
%
%                       [d,n],         X の大きさが [m,n] のとき
%               [d,n1,...,nm],         d>1 で X が {X1,...,Xm} のとき
%                 [n1,...,nm],         d が 1 で X が {X1,...,Xm} のとき
%
% 参考 : FNVAL, PPUAL, RSVAL, SPVAL, PPVAL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
