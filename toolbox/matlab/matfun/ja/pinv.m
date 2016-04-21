% PINV   擬似逆行列
% 
% X = PINV(A) は、A*X*A = A、X*A*X = X で、A*X と X*A がエルミートであるよ
% うな A' と同じ次元の行列 X を出力します。計算は SVD(A) に基づき、許容値よ
% り小さい特異値はゼロとして取り扱われます。デフォルトの許容値は、
% MAX(SIZE(A)) * NORM(A) * EPS です。
%
% PINV(A,TOL) は、デフォルトの代わりに許容値 TOL を使います。
%
% 入力 A のサポートクラス 
%   float: double, single
%
% 参考 RANK.

%   Copyright 1984-2004 The MathWorks, Inc. 

