% GFMUL ガロア体の元を乗算
% 
% C = GFMUL(A, B) は、GF(2) の元ごとに、A と B の乗算を行います。A と B 
% はスカラか、または同じサイズのベクトルか行列です。A と B の各要素は、
% GF(2) の元を表現します。A と B の要素は、0 または 1 です。
%
% C = GFMUL(A, B, P) は、GF(P) の元ごとに、A と B の乗算を行います。
% ここで P は素数のスカラです。A と B の各要素は、GF(P) の元を表現します。 
% A と B の各要素は、0 と P-1 の間の整数です。
%
% C = GFMUL(A, B, FIELD) は、 GF(P^M) の元ごとに、A と B の乗算を行います。
% ここで P は素数で、M は正の整数です。A と B の各要素は、指数形式で
% GF(P^M) の元を表現します。A と B の各要素は、-Inf と P^M-2 の間の整数
% です。FIELD は GF(P^M) の全元をリストする行列で、同じ原始元と関連して
% 並べられています。FIELD は FIELD = GFTUPLE([-1:P^M-2]', M, P); を使って
% 生成することができます。
%
% GF(P) または GF(P^M) の多項式の乗算については、GFCONV を使ってください。
%
% 参考:   GFDIV, GFDECONV, GFADD, GFSUB, GFTUPLE.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:40 $
