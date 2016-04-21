% GFDECONV   ガロア体上の多項式の除算
%
% [Q, R] = GFDECONV(B, A) は、GF(2) で B を A で除算し、商 Q と剰余 R を
% 計算します。
%
% A, B, Q, R は、昇ベキの順に並んだ多項式係数を示す、行ベクトルです。
%
% [Q, R] = GFDECONV(B, A, P) は、GF(P) で B を A で除算し、商 Q と剰余 R
% を計算します。ここで、P はスカラの素数です。
%
% [Q, R] = GFDECONV(B, A, FIELD) は、2つの GF(P^M) 多項式間で除算し、 
% 商 Q と剰余 R を計算します。ここで FIELD は GF(P^M) の全元のM-タプルを
% 含む行列です。Pは素数で、Mは正の整数です。GF(P^M) の全元のM-タプルを
% 生成するには、FIELD = GFTUPLE([-1:P^M-2]', M, P) を使ってください。
%
% このシンタックスでは、各係数は指数形式で指定されます。つまり、
% [-Inf, 0, 1, 2, ...] は GF(P^M) の体元 [0, 1, alpha, alpha^2, ...] を
% 表現します。
%
% 例題:
%     GF(5)上での除算: (1+ 3x+ 2x^3+ 4x^4)/(1+ x) = (1+ 2x+ 3x^2+ 4x^3)
%        [q, r] = gfdeconv([1 3 0 2 4], [1 1], 5)
%     q = [1 2 3 4], r = 0 を返します。
%
%     GF(2^4)上での除算:
%        field = gftuple([-1:2^4-2]', 4, 2);
%        [q, r] = gfdeconv([2 6 7 8 9 6],[1 1],field)
%     q = [1 2 3 4 5], r = -Inf を返します。
%
% GF(P) または GF(P^M) 上の要素ごとの除算については、GFDIV を参照して
% ください。
%
% 参考： GFCONV, GFADD, GFSUB, GFTUPLE.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $Date: 2003/06/23 04:34:34 $
